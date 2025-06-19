#!/usr/bin/env python3
import os
import sys
import shutil
import re
import subprocess
from datetime import datetime
from pathlib import Path

def main():
    # Configuration
    old_html_path = Path.home() / "Sentium" / "sentium-pixel" / "play"
    new_html_path = Path.cwd() / "export"
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = Path.home() / "Sentium" / f"sentium-pixel/play-backup-{timestamp}"
    
    print("Merging HTML updates while preserving custom code...")
    print(f"Old HTML path: {old_html_path}")
    print(f"New HTML path: {new_html_path}")
    
    # Check if directories exist
    if not old_html_path.exists():
        print(f"Error: Old HTML directory not found at {old_html_path}")
        sys.exit(1)
    
    if not new_html_path.exists():
        print(f"Error: New HTML export not found at {new_html_path}")
        sys.exit(1)
    
    # Create backup
    print(f"Creating backup at {backup_path}")
    shutil.copytree(old_html_path, backup_path)
    
    # Find old HTML file
    html_files = list(old_html_path.glob("*.html"))
    if not html_files:
        print("Error: No HTML file found in old directory")
        sys.exit(1)
    
    old_html_file = html_files[0]
    print(f"Found old HTML file: {old_html_file}")
    
    # Extract custom sections from old HTML
    print("Extracting custom code sections...")
    
    with open(old_html_file, 'r', encoding='utf-8') as f:
        old_content = f.read()
    
    # Extract custom sections
    custom_css = extract_section(old_content, '<!-- CUSTOM CSS START -->', '<!-- CUSTOM CSS END -->')
    custom_js = extract_section(old_content, '<!-- CUSTOM JS START -->', '<!-- CUSTOM JS END -->')
    custom_content = extract_section(old_content, '<!-- CUSTOM CONTENT START -->', '<!-- CUSTOM CONTENT END -->')
    readme_content = extract_section(old_content, '<!-- Add content below the cart here -->', '<!-- body_0 -->')
    
    # Copy new files to old location
    print("Copying new HTML/JS files...")
    
    # Copy HTML file (rename to index.html)
    new_html = new_html_path / "sentium-pico.html"
    if new_html.exists():
        shutil.copy2(new_html, old_html_path / "index.html")
    else:
        print("Error: New HTML file not found")
        sys.exit(1)
    
    # Copy JS file
    new_js = new_html_path / "sentium-pico.js"
    if new_js.exists():
        shutil.copy2(new_js, old_html_path / "sentium-pico.js")
    
    # Copy PNG file if exists
    new_png = new_html_path / "sentium-pico.p8.png"
    if new_png.exists():
        shutil.copy2(new_png, old_html_path / "sentium-pico.p8.png")
    
    # Check if we have custom sections to merge
    has_custom_content = any([custom_css, custom_js, custom_content, readme_content])
    
    if has_custom_content:
        print("Found custom sections to merge!")
        
        # Read the new HTML file
        with open(old_html_path / "index.html", 'r', encoding='utf-8') as f:
            html_content = f.read()
        
        # Merge custom sections
        html_content = merge_custom_sections(html_content, custom_css, custom_js, custom_content, readme_content)
        
        # Write back to file
        with open(old_html_path / "index.html", 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print("Custom sections merged successfully!")
        
    else:
        print("No marked custom sections found. You may need to manually merge custom code.")
        print("Please check the differences between:")
        print(f"   Backup: {backup_path}")
        print(f"   Current: {old_html_path}")
    
    print("")
    print("HTML merge completed!")
    print(f"Backup created at: {backup_path}")
    print(f"Updated files are in: {old_html_path}")
    print("")
    print("Next steps:")
    print("1. Test the updated HTML file")
    print("2. If there are issues, compare with backup to identify missing custom code")
    print("3. Add custom code markers for future updates:")
    print("   <!-- CUSTOM CSS START --> ... <!-- CUSTOM CSS END -->")
    print("   <!-- CUSTOM JS START --> ... <!-- CUSTOM JS END -->")
    print("   <!-- CUSTOM CONTENT START --> ... <!-- CUSTOM CONTENT END -->")

def extract_section(content, start_marker, end_marker):
    """Extract content between start and end markers"""
    start_idx = content.find(start_marker)
    if start_idx == -1:
        return ""
    
    end_idx = content.find(end_marker, start_idx)
    if end_idx == -1:
        return ""
    
    # Include the end marker in the extraction
    return content[start_idx:end_idx + len(end_marker)]

def merge_custom_sections(html_content, custom_css, custom_js, custom_content, readme_content):
    """Merge custom sections back into the HTML content"""
    
    # Insert custom CSS before </head>
    if custom_css:
        html_content = html_content.replace('</head>', f'{custom_css}\n</head>')
    
    # Insert custom JS before </body>
    if custom_js:
        html_content = html_content.replace('</body>', f'{custom_js}\n</body>')
    
    # Insert custom content after <body>
    if custom_content:
        html_content = re.sub(r'(<body[^>]*>)', r'\1\n' + custom_content, html_content)
    
    # Insert readme content before </body>
    if readme_content:
        html_content = html_content.replace('</body>', f'{readme_content}\n</body>')
    
    return html_content

if __name__ == "__main__":
    main()
