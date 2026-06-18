import os

search_dir = '.'
pairs = [
    ('com.scientific_calcr.pro.scientific_calcr_pro', 'com.scientific_calcr.pro'),
    ('com.scientific_calcr.pro.scientific_calcrPro', 'com.scientific_calcr.pro')
]

exclude_dirs = {'.git', 'build', '.dart_tool', '.idea'}

for root, dirs, files in os.walk(search_dir):
    dirs[:] = [d for d in dirs if d not in exclude_dirs]
    for file in files:
        if file == 'replace_pkg.py' or file == 'rename_pkg2.py':
            continue
        filepath = os.path.join(root, file)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            changed = False
            for old, new in pairs:
                if old in content:
                    content = content.replace(old, new)
                    changed = True
            if changed:
                print(f"Replacing in {filepath}")
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
        except Exception as e:
            pass
