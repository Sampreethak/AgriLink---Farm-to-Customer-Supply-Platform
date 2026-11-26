"""
Zero-dependency pure-Python PDF 1.4 generator for AgriLink Tri-Service Reports.
Produces valid, multi-page PDF binaries without requiring reportlab or fpdf.
"""

from typing import List, Tuple


def _escape_pdf_text(text: str) -> str:
    """Escape characters that have special meaning in PDF literal strings."""
    cleaned = (
        str(text)
        .replace("₹", "INR ")
        .replace("—", "-")
        .replace("–", "-")
        .replace("•", "*")
    )
    # Keep printable ASCII to guarantee clean Helvetica rendering
    cleaned = "".join(ch if 32 <= ord(ch) <= 126 else "?" for ch in cleaned)
    return cleaned.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")


def _wrap_line(text: str, max_chars: int = 88) -> List[str]:
    words = str(text).split()
    if not words:
        return [""]
    lines: List[str] = []
    current = words[0]
    for w in words[1:]:
        if len(current) + 1 + len(w) <= max_chars:
            current += " " + w
        else:
            lines.append(current)
            current = w
    lines.append(current)
    return lines


def build_pdf_bytes(title: str, sections: List[Tuple[str, List[str]]]) -> bytes:
    """
    Build a multi-page PDF 1.4 document from a title and list of (heading, lines) sections.
    """
    # Collect styled lines: (font_key, font_size, text)
    styled_lines: List[Tuple[str, int, str]] = []
    for t_line in _wrap_line(title, 65):
        styled_lines.append(("F2", 15, t_line))
    styled_lines.append(("F1", 9, ""))

    for heading, body_lines in sections:
        styled_lines.append(("F1", 6, ""))
        for h_line in _wrap_line(heading, 75):
            styled_lines.append(("F2", 12, h_line))
        for raw in body_lines:
            for w_line in _wrap_line(raw, 90):
                styled_lines.append(("F1", 10, w_line))

    # Paginate (~48 lines per US Letter / A4 page)
    pages_lines: List[List[Tuple[str, int, str]]] = []
    current_page: List[Tuple[str, int, str]] = []
    y_cursor = 790
    for item in styled_lines:
        step = item[1] + 5
        if y_cursor - step < 50:
            pages_lines.append(current_page)
            current_page = []
            y_cursor = 790
        current_page.append(item)
        y_cursor -= step
    if current_page or not pages_lines:
        pages_lines.append(current_page)

    # Build PDF objects
    # Obj 1: Catalog
    # Obj 2: Pages
    # Obj 3: Font F1 (Helvetica)
    # Obj 4: Font F2 (Helvetica-Bold)
    # Obj 5+: Page & Content stream pairs
    objects: List[bytes] = []
    page_obj_ids: List[int] = []

    num_pages = len(pages_lines)
    for idx in range(num_pages):
        page_id = 5 + idx * 2
        page_obj_ids.append(page_id)

    kids_str = " ".join(f"{pid} 0 R" for pid in page_obj_ids)
    objects.append(b"1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n")
    objects.append(f"2 0 obj\n<< /Type /Pages /Kids [{kids_str}] /Count {num_pages} >>\nendobj\n".encode("latin-1"))
    objects.append(b"3 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n")
    objects.append(b"4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n")

    for idx, p_lines in enumerate(pages_lines):
        page_id = 5 + idx * 2
        content_id = page_id + 1

        stream_cmds = ["BT"]
        y = 790
        for font_key, font_size, text in p_lines:
            if text:
                escaped = _escape_pdf_text(text)
                stream_cmds.append(f"/{font_key} {font_size} Tf")
                stream_cmds.append(f"1 0 0 1 48 {y} Tm")
                stream_cmds.append(f"({escaped}) Tj")
            y -= font_size + 5
        # Footer page number
        stream_cmds.append("/F1 8 Tf")
        stream_cmds.append("1 0 0 1 48 28 Tm")
        stream_cmds.append(f"(AgriLink Tri-Service Ecosystem Report - Page {idx + 1} of {num_pages}) Tj")
        stream_cmds.append("ET")

        stream_bytes = "\n".join(stream_cmds).encode("latin-1")
        page_obj = (
            f"{page_id} 0 obj\n"
            f"<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] "
            f"/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> "
            f"/Contents {content_id} 0 R >>\nendobj\n"
        ).encode("latin-1")
        content_obj = (
            f"{content_id} 0 obj\n<< /Length {len(stream_bytes)} >>\nstream\n".encode("latin-1")
            + stream_bytes
            + b"\nendstream\nendobj\n"
        )
        objects.append(page_obj)
        objects.append(content_obj)

    # Assemble PDF with xref
    out = bytearray(b"%PDF-1.4\n%\xe2\xe3\xcf\xd3\n")
    offsets: List[int] = [0]
    for obj in objects:
        offsets.append(len(out))
        out.extend(obj)

    xref_pos = len(out)
    out.extend(f"xref\n0 {len(offsets)}\n".encode("latin-1"))
    out.extend(b"0000000000 65535 f \n")
    for off in offsets[1:]:
        out.extend(f"{off:010d} 00000 n \n".encode("latin-1"))

    out.extend(
        (
            f"trailer\n<< /Size {len(offsets)} /Root 1 0 R >>\n"
            f"startxref\n{xref_pos}\n%%EOF\n"
        ).encode("latin-1")
    )
    return bytes(out)
