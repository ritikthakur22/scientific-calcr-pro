import os

def replace_in_file(filepath, replacements):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        print(f"Skipping binary file: {filepath}")
        return

    new_content = content
    for old_str, new_str in replacements.items():
        new_content = new_content.replace(old_str, new_str)
    
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")

replacements = {
    "CalcX Pro": "Scientific CalcR Pro",
    "calcx_pro": "scientific_calcr_pro",
    "com.crdy.calcxpro": "com.crdy.scientificcalcrpro"
}

targets = [
    ".idea/modules.xml",
    "windows/runner/Runner.rc",
    "windows/runner/main.cpp",
    "windows/CMakeLists.txt",
    "linux/runner/my_application.cc",
    "linux/CMakeLists.txt",
    "macos/Runner.xcodeproj/project.pbxproj",
    "macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme",
    "macos/Runner/Configs/AppInfo.xcconfig"
]

for target in targets:
    replace_in_file(target, replacements)

print("Done renaming remaining occurrences.")
