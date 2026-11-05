import re
from typing import Optional, Dict, List

# Multilingual Vernacular Crop Dictionary (English, Kannada ಕನ್ನಡ, Hindi हिन्दी)
CROP_DICTIONARY: Dict[str, List[str]] = {
    "tomato": ["tomato", "tomatoes", "ಟೊಮ್ಯಾಟೊ", "ಟೊಮೇಟೊ", "टमाटर"],
    "onion": ["onion", "onions", "ಈರುಳ್ಳಿ", "प्याज"],
    "potato": ["potato", "potatoes", "ಆಲೂಗಡ್ಡೆ", "ಆಲೂ", "आलू"],
    "carrot": ["carrot", "carrots", "ಕ್ಯಾರೆಟ್", "गाजर"],
    "cabbage": ["cabbage", "ಕ್ಯಾಬೇಜ್", "ಕೋಸು", "पत्तागोभी", "गोभी"],
    "green capsicum": ["capsicum", "green capsicum", "ಕ್ಯಾಪ್ಸಿಕಂ", "ದೊಡ್ಡ ಮೆಣಸಿನಕಾಯಿ", "शिमला मिर्च"],
    "green chilli": ["chilli", "green chilli", "ಮೆಣಸಿನಕಾಯಿ", "हरी मिर्च"],
    "palak": ["palak", "spinach", "ಪಾಲಕ್", "पालक"],
    "coriander": ["coriander", "ಕೊತ್ತಂಬರಿ", "धनिया"],
    "ginger": ["ginger", "ಶುಂಠಿ", "अदरक"],
    "garlic": ["garlic", "ಬೆಳ್ಳುಳ್ಳಿ", "लहसुन"],
    "banana": ["banana", "ಬಾಳೆಹಣ್ಣು", "केला"],
    "papaya": ["papaya", "ಪಪ್ಪಾಯಿ", "पपीता"],
    "ragi": ["ragi", "finger millet", "ರಾಗಿ", "रागी"],
    "rice": ["rice", "paddy", "ಅಕ್ಕಿ", "ಭತ್ತ", "चावल", "धान"],
    "wheat": ["wheat", "ಗೋಧಿ", "गेहूं"],
    "apple": ["apple", "ಸೇಬು", "सेब"],
    "honey": ["honey", "ಜೇನುತುಪ್ಪ", "शहद"],
    "brinjal": ["brinjal", "eggplant", "ಬದನೆಕಾಯಿ", "बैंगन"],
    "cauliflower": ["cauliflower", "ಹೂಕೋಸು", "फूलगोभी"],
    "green peas": ["green peas", "peas", "ಬಟಾಣಿ", "मटर"]
}

def extract_crop_entity(text: str) -> Optional[str]:
    """
    Extracts standardized Crop Entity from multilingual query text
    supporting English, Kannada, and Hindi scripts.
    """
    text_lower = text.lower()
    for crop_name, variants in CROP_DICTIONARY.items():
        for v in variants:
            # Match word boundary or exact script occurrence
            if re.search(r'(?:\b|(?<=\s)|(?<=^))' + re.escape(v) + r'(?:\b|(?=\s)|(?=$))', text_lower):
                return crop_name.title()
    return None
