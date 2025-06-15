#!/usr/bin/env fish

# Script to copy exported files from PICO-8 carts folder to /export in this repository

set REPO_DIR (dirname (status --current-filename))
set EXPORT_DIR "$REPO_DIR/export"
set PICO_CARTS_DIR "$HOME/Library/Application Support/pico-8/carts"

echo "Copying exported files from PICO-8 carts folder to repository..."
echo "Source: $PICO_CARTS_DIR"
echo "Destination: $EXPORT_DIR"
echo

# Create export directory if it doesn't exist
if not test -d "$EXPORT_DIR"
    echo "Creating export directory..."
    mkdir -p "$EXPORT_DIR"
end

# Check if PICO-8 carts directory exists
if not test -d "$PICO_CARTS_DIR"
    echo "Error: PICO-8 carts directory not found at $PICO_CARTS_DIR"
    exit 1
end

# Define export file patterns to look for
set export_patterns "*.html" "*.js" "*.bin" "*.zip" "*.p8.png"

echo "Looking for exported files with patterns: $export_patterns"
echo

set total_copied 0

for pattern in $export_patterns
    set files (find "$PICO_CARTS_DIR" -name "$pattern" -type f)
    
    for file in $files
        set filename (basename "$file")
        
        # Skip if it's just a regular cart PNG (not an export)
        if string match -q "*.p8.png" "$filename"
            # Check if this is actually an exported cart (has accompanying files)
            set base_name (string replace ".p8.png" "" "$filename")
            if not test -f "$PICO_CARTS_DIR/$base_name.html" -o -f "$PICO_CARTS_DIR/$base_name.js"
                continue
            end
        end
        
        echo "Copying $filename..."
        cp "$file" "$EXPORT_DIR/"
        
        if test $status -eq 0
            echo "Successfully copied $filename"
            set total_copied (math $total_copied + 1)
        else
            echo "Failed to copy $filename"
        end
    end
end

# Also look for any directories that might be export folders
set export_dirs (find "$PICO_CARTS_DIR" -name "*_html" -type d -o -name "*.bin" -type d)
for dir in $export_dirs
    set dirname (basename "$dir")
    echo "Copying directory $dirname..."
    cp -r "$dir" "$EXPORT_DIR/"
    
    if test $status -eq 0
        echo "Successfully copied directory $dirname"
        set total_copied (math $total_copied + 1)
    else
        echo "Failed to copy directory $dirname"
    end
end

# Also copy standalone PNG files that are cart labels
set png_files (find "$PICO_CARTS_DIR" -maxdepth 1 -name "*.png" -type f)
for file in $png_files
    set filename (basename "$file")
    echo "Copying PNG $filename..."
    cp "$file" "$EXPORT_DIR/"
    
    if test $status -eq 0
        echo "Successfully copied $filename"
        set total_copied (math $total_copied + 1)
    else
        echo "Failed to copy $filename"
    end
end

echo
if test $total_copied -gt 0
    echo "Copy operation completed! Copied $total_copied items to $EXPORT_DIR"
else
    echo "No export files found to copy"
    echo "Make sure you have exported your cartridge using commands like:"
    echo "  > EXPORT SENTIRIA_PICO.HTML"
    echo "  > EXPORT SENTIRIA_PICO.BIN"
end
