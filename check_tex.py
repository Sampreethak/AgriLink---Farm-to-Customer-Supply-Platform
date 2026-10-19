import os

tex_files = []
for root, dirs, files in os.walk('latex_report_template'):
    if 'Old' in root:
        continue
    for f in files:
        if f.endswith(('.tex', '.bib', '.cls')):
            tex_files.append(os.path.join(root, f))

for path in sorted(tex_files):
    with open(path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()
    bad_lines = []
    for idx, line in enumerate(lines):
        non_ascii = [f'U+{ord(c):04X}' for c in line if ord(c) > 127]
        if non_ascii:
            bad_lines.append((idx + 1, non_ascii, line.strip()))
    if bad_lines:
        print(f"File: {path}")
        for lineno, chars, lstr in bad_lines:
            safe_str = lstr[:70].encode('ascii', 'replace').decode('ascii')
            print(f"  Line {lineno}: {', '.join(chars)} | {safe_str}")
