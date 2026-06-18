import os
import re

root_dir = "/home/crdy/testing/Scientific_CalcR_Pro"
inventory_md = "/home/crdy/.gemini/antigravity-cli/brain/94589e38-772b-4c75-8a6c-811476741f75/repository_inventory.md"

def format_size(size):
    for unit in ['B', 'KB', 'MB', 'GB']:
        if size < 1024.0:
            return f"{size:3.1f} {unit}"
        size /= 1024.0

with open(inventory_md, "w") as f:
    f.write("# Repository Inventory\n\n")
    f.write("| File Path | Size | Type | Suspicious |\n")
    f.write("|---|---|---|---|\n")

    for root, dirs, files in os.walk(root_dir):
        # Exclude common large/build dirs to avoid flooding
        dirs[:] = [d for d in dirs if d not in ['.git', 'build', '.dart_tool', '.gradle']]
        for file in files:
            path = os.path.join(root, file)
            rel_path = os.path.relpath(path, root_dir)
            size = os.path.getsize(path)
            ext = os.path.splitext(file)[1] or "None"
            
            # Suspicious check
            suspicious = "Yes" if ext in ['.jks', '.keystore', '.pem'] else "No"
            f.write(f"| {rel_path} | {format_size(size)} | {ext} | {suspicious} |\n")

print("Inventory generated.")
