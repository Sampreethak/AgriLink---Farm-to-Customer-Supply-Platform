"""
AgriLink Multilingual Translation Service
=========================================
Supports per-persona preferred language communication across:
English (en), Kannada (kn), Hindi (hi), Telugu (te), Tamil (ta), Malayalam (ml).

Engine priority:
1. Google Gemini Flash-Lite / Flash fallback chain (already live & free on EC2)
2. Hugging Face Router / Inference API (supports facebook/nllb-200-distilled-600M or Qwen/Llama)
3. Built-in offline agricultural phrasebook fallback
"""

import os
import json
from typing import Optional, Dict, Any

SUPPORTED_LANGUAGES = {
    "en": "English",
    "kn": "Kannada",
    "hi": "Hindi",
    "te": "Telugu",
    "ta": "Tamil",
    "ml": "Malayalam",
}

NLLB_LANG_CODES = {
    "en": "eng_Latn",
    "kn": "kan_Knda",
    "hi": "hin_Deva",
    "te": "tel_Telu",
    "ta": "tam_Taml",
    "ml": "mal_Mlym",
}

# Offline fallback dictionary for key agricultural/order terms
OFFLINE_PHRASEBOOK = {
    "kn": {
        "in stock": "ಲಭ್ಯವಿದೆ",
        "out of stock": "ಸ್ಟಾಕ್ ಇಲ್ಲ",
        "fresh": "ತಾಜಾ",
        "organic": "ಸಾವಯವ",
        "tomato": "ಟೊಮ್ಯಾಟೊ",
        "onion": "ಈರುಳ್ಳಿ",
        "potato": "ಆಲೂಗಡ್ಡೆ",
    },
    "hi": {
        "in stock": "उपलब्ध है",
        "out of stock": "स्टॉक समाप्त",
        "fresh": "ताज़ा",
        "organic": "जैविक",
        "tomato": "टमाटर",
        "onion": "प्याज",
        "potato": "आलू",
    },
}


class MultilingualTranslationService:
    def __init__(self):
        self.gemini_api_key = os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY") or self._load_env_key("GEMINI_API_KEY")
        self.hf_api_key = os.getenv("HUGGINGFACE_API_KEY") or os.getenv("HF_TOKEN") or self._load_env_key("HUGGINGFACE_API_KEY")
        self.hf_translate_model = os.getenv("HF_TRANSLATE_MODEL", "Qwen/Qwen3.8-Flash-Next")
        self._cache: Dict[str, str] = {}

    def _load_env_key(self, key_name: str) -> str:
        try:
            env_path = os.path.join(os.path.dirname(os.path.dirname(__file__)), "backend_fastapi", ".env")
            if os.path.exists(env_path):
                with open(env_path, "r", encoding="utf-8") as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith(f"{key_name}="):
                            return line.split("=", 1)[1].strip().strip('"').strip("'")
        except Exception:
            pass
        return ""

    def translate(
        self,
        text: str,
        target_language: str = "en",
        source_language: str = "auto",
    ) -> Dict[str, Any]:
        clean_text = (text or "").strip()
        target_code = (target_language or "en").strip().lower()
        target_name = SUPPORTED_LANGUAGES.get(target_code, "English")

        if not clean_text:
            return {
                "status": "success",
                "original_text": clean_text,
                "translated_text": clean_text,
                "target_language": target_code,
                "target_language_name": target_name,
                "provider": "passthrough",
            }

        cache_key = f"{target_code}:{clean_text}"
        if cache_key in self._cache:
            return {
                "status": "success",
                "original_text": clean_text,
                "translated_text": self._cache[cache_key],
                "target_language": target_code,
                "target_language_name": target_name,
                "provider": "cache",
            }

        # 1. Try Google Gemini (live & free)
        translated, provider = self._translate_via_gemini(clean_text, target_name, source_language)

        # 2. Fallback to Hugging Face Router if Gemini unavailable
        if not translated:
            translated, provider = self._translate_via_hf(clean_text, target_name, target_code)

        # 3. Deterministic offline fallback
        if not translated:
            translated = self._offline_fallback(clean_text, target_code)
            provider = "offline_glossary_fallback"

        self._cache[cache_key] = translated
        return {
            "status": "success",
            "original_text": clean_text,
            "translated_text": translated,
            "target_language": target_code,
            "target_language_name": target_name,
            "provider": provider,
        }

    def transliterate(self, text: str, target_language: str = "kn") -> Dict[str, Any]:
        """Converts phonetic Romanized typing (e.g. 'namaskara') into native script (e.g. 'ನಮಸ್ಕಾರ')."""
        clean_text = (text or "").strip()
        target_code = (target_language or "en").strip().lower()
        target_name = SUPPORTED_LANGUAGES.get(target_code, "English")
        if not clean_text or target_code == "en":
            return {
                "status": "success",
                "original_text": clean_text,
                "transliterated_text": clean_text,
                "target_language": target_code,
            }

        if self.gemini_api_key:
            import requests
            prompt = (
                f"Transliterate (convert phonetic Roman/English letters into {target_name} script, "
                f"preserving the spoken words rather than translating meaning if already in {target_name}, "
                f"or translating smoothly if typed in English). "
                f"Return ONLY the {target_name} script text with no quotes or notes.\n\nText: {clean_text}"
            )
            payload = {
                "contents": [{"parts": [{"text": prompt}]}],
                "generationConfig": {"maxOutputTokens": 256, "temperature": 0.1},
            }
            for model_name in [os.getenv("GEMINI_AGRI_MODEL", "gemini-3.5-flash-lite"), "gemini-3.1-flash-lite", "gemini-2.5-flash-lite"]:
                url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={self.gemini_api_key}"
                try:
                    res = requests.post(url, json=payload, timeout=10)
                    if res.status_code == 200:
                        candidates = res.json().get("candidates", [])
                        if candidates:
                            parts = candidates[0].get("content", {}).get("parts", [])
                            out = "\n".join(
                                p.get("text", "").strip()
                                for p in parts
                                if not p.get("thought", False) and p.get("text", "").strip()
                            ).strip()
                            if out:
                                return {
                                    "status": "success",
                                    "original_text": clean_text,
                                    "transliterated_text": out,
                                    "target_language": target_code,
                                }
                except Exception:
                    continue

        return {
            "status": "success",
            "original_text": clean_text,
            "transliterated_text": clean_text,
            "target_language": target_code,
        }

    def synthesize_tts_audio(self, text: str, lang_code: str = "en") -> bytes:
        """Synthesizes native MP3 speech audio for en, kn, hi, te, ta, ml via Google TTS."""
        import re
        import urllib.request
        import urllib.parse

        clean = re.sub(r"[*_#`•🌾🧪🌿⚠️⏱️🛡️]", " ", text or "")
        clean = re.sub(r"\s+", " ", clean).strip()
        if not clean:
            return b""

        tl = (lang_code or "en").strip().lower()
        if tl not in SUPPORTED_LANGUAGES:
            tl = "en"

        # Split into <=180 char chunks so Google TTS handles long prescriptions cleanly
        chunks = []
        words = clean.split(" ")
        current = ""
        for w in words:
            if len(current) + len(w) + 1 <= 180:
                current = f"{current} {w}".strip()
            else:
                if current:
                    chunks.append(current)
                current = w[:180]
        if current:
            chunks.append(current)

        audio_parts = []
        for chunk in chunks[:10]:
            q = urllib.parse.quote(chunk)
            url = f"https://translate.google.com/translate_tts?ie=UTF-8&tl={tl}&client=tw-ob&q={q}"
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=10) as res:
                audio_parts.append(res.read())
        return b"".join(audio_parts)

    def _translate_via_gemini(self, text: str, target_name: str, source_language: str) -> tuple[Optional[str], str]:
        if not self.gemini_api_key:
            return None, ""
        import requests

        prompt = (
            f"Translate the following agricultural marketplace message into natural, clear {target_name}. "
            f"Keep numbers, prices (₹), units (kg, L), and crop names accurate. "
            f"Return ONLY the translated text with no explanation or quotes.\n\n"
            f"Text: {text}"
        )
        payload = {
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"maxOutputTokens": 512, "temperature": 0.1},
        }
        models = [
            os.getenv("GEMINI_AGRI_MODEL", "gemini-3.5-flash-lite"),
            "gemini-3.1-flash-lite",
            "gemini-2.5-flash-lite",
            "gemma-4-26b-a4b-it",
        ]
        for model_name in models:
            url = f"https://generativelanguage.googleapis.com/v1beta/models/{model_name}:generateContent?key={self.gemini_api_key}"
            try:
                res = requests.post(url, json=payload, timeout=12)
                if res.status_code == 200:
                    data = res.json()
                    candidates = data.get("candidates", [])
                    if candidates:
                        parts = candidates[0].get("content", {}).get("parts", [])
                        out = "\n".join(
                            p.get("text", "").strip()
                            for p in parts
                            if not p.get("thought", False) and p.get("text", "").strip()
                        ).strip()
                        if out:
                            return out, f"Google Gemini ({model_name})"
            except Exception:
                continue
        return None, ""

    def _translate_via_hf(self, text: str, target_name: str, target_code: str) -> tuple[Optional[str], str]:
        if not self.hf_api_key:
            return None, ""
        import requests

        url = "https://router.huggingface.co/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {self.hf_api_key}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": self.hf_translate_model,
            "messages": [
                {
                    "role": "user",
                    "content": f"Translate this agricultural text to {target_name}. Return ONLY the translation:\n{text}",
                }
            ],
            "max_tokens": 300,
            "temperature": 0.1,
        }
        try:
            res = requests.post(url, headers=headers, json=payload, timeout=10)
            if res.status_code == 200:
                choices = res.json().get("choices", [])
                if choices:
                    out = choices[0].get("message", {}).get("content", "").strip()
                    if out:
                        return out, f"Hugging Face ({self.hf_translate_model})"
        except Exception:
            pass
        return None, ""

    def _offline_fallback(self, text: str, target_code: str) -> str:
        glossary = OFFLINE_PHRASEBOOK.get(target_code, {})
        result = text
        for eng, local in glossary.items():
            if eng in result.lower():
                result = result.replace(eng, local).replace(eng.title(), local)
        return result
