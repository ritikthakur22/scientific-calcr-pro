import os
import shutil

root_dir = "/home/crdy/testing/scientific_calcr_pro"

replacements = [
    ("scientific_calcr_pro", "scientific_calcr_pro"),
    ("Scientific CalcR Pro", "Scientific CalcR Pro"),
    ("scientificcalcrpro", "scientificcalcrpro"),
    ("ScientificCalcrPro", "ScientificCalcrPro"),
    ("scientific_calcr", "scientific_calcr"),
    ("Scientific CalcR", "Scientific CalcR"),
]

exclude_dirs = {".dart_tool", "build", ".idea", ".gradle", "Pods", "linux", "macos", "windows", ".git"}

def safe_replace(content):
    for old, new in replacements:
        content = content.replace(old, new)
    return content

for dirpath, dirnames, filenames in os.walk(root_dir):
    dirnames[:] = [d for d in dirnames if d not in exclude_dirs]
    for filename in filenames:
        filepath = os.path.join(dirpath, filename)
        if filename.endswith((".png", ".jpg", ".jpeg", ".ttf", ".so", ".dill", ".icns", ".ico", ".svg")):
            continue
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
        except UnicodeDecodeError:
            continue
            
        new_content = safe_replace(content)
            
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)

old_pkg_dir = os.path.join(root_dir, "android/app/src/main/kotlin/com/crdy/scientificcalcrpro")
new_pkg_dir = os.path.join(root_dir, "android/app/src/main/kotlin/com/crdy/scientificcalcrpro")

if os.path.exists(old_pkg_dir):
    shutil.move(old_pkg_dir, new_pkg_dir)
