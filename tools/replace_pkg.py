import os

search_dir = '.'
search_str = 'com.scientific_calcr.pro'
replace_str = 'com.scientific_calcr.pro'

exclude_dirs = {'.git', 'build', '.dart_tool', '.idea'}

for root, dirs, files in os.walk(search_dir):
    dirs[:] = [d for d in dirs if d not in exclude_dirs]
    for file in files:
        filepath = os.path.join(root, file)
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            if search_str in content:
                print(f"Replacing in {filepath}")
                content = content.replace(search_str, replace_str)
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
        except Exception as e:
            pass
