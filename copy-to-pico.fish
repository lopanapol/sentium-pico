#!/usr/bin/env fish

# Script to copy .p8 files from this repository to PICO-8 carts folder

set REPO_DIR (dirname (status --current-filename))
set PICO_CARTS_DIR "$HOME/Library/Application Support/pico-8/carts"

echo "Copying .p8 files from repository to PICO-8 carts folder..."
echo "Source: $REPO_DIR"
echo "Destination: $PICO_CARTS_DIR"
echo

# Check if PICO-8 carts directory exists
if not test -d "$PICO_CARTS_DIR"
    echo "Error: PICO-8 carts directory not found at $PICO_CARTS_DIR"
    exit 1
end

# Clear all export files from PICO-8 carts folder first
echo "Cleaning export files from PICO-8 carts folder..."

# Use find to remove files without wildcard warnings
find "$PICO_CARTS_DIR" -maxdepth 1 -name "*.html" -type f -delete 2>/dev/null
find "$PICO_CARTS_DIR" -maxdepth 1 -name "*.js" -type f -delete 2>/dev/null
find "$PICO_CARTS_DIR" -maxdepth 1 -name "*.zip" -type f -delete 2>/dev/null
find "$PICO_CARTS_DIR" -maxdepth 1 -name "*.bin" -type d -exec rm -rf {} + 2>/dev/null
# Remove PNG files but keep .p8.png files (cart format)
find "$PICO_CARTS_DIR" -maxdepth 1 -name "*.png" -not -name "*.p8.png" -type f -delete 2>/dev/null

echo "Export files cleared."
echo

# Find and copy all .p8 files
set p8_files (find "$REPO_DIR" -name "*.p8" -type f)

if test (count $p8_files) -eq 0
    echo "No .p8 files found in repository"
    exit 0
end

for file in $p8_files
    set filename (basename "$file")
    echo "Copying $filename..."
    cp "$file" "$PICO_CARTS_DIR/"
    
    if test $status -eq 0
        echo "Successfully copied $filename"
    else
        echo "Failed to copy $filename"
    end
end

echo
echo "Copy operation completed!"
echo "You can now access these files in PICO-8 using LOAD command"
