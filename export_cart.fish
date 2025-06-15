#!/usr/bin/env fish

# Script to help export Sentium Pixel PICO-8 cart for itch.io

set CART_NAME "sentium_pixel"
set VERSION (cat VERSION 2>/dev/null || echo "1.0.0")
set SCRIPT_DIR (dirname (status -f))

# Set pico8 directory based on OS
if test (uname) = "Darwin" # macOS
    set PICO8_DIR ~/Library/Application\ Support/pico-8/carts/
else if test (uname) = "Linux"
    set PICO8_DIR ~/.lexaloffle/pico-8/carts/
else # Windows
    echo "Windows is not directly supported by this script."
    echo "Please manually copy your cart to your PICO-8 carts folder."
    exit 1
end

# Create exports directory if it doesn't exist
mkdir -p $SCRIPT_DIR/export

echo "====================================="
echo "Sentium Pixel PICO-8 Export Utility"
echo "====================================="
echo "Version: $VERSION"
echo ""

# Check if PICO8 directory exists
if not test -d $PICO8_DIR
    echo "Error: PICO-8 directory not found at $PICO8_DIR"
    echo "Please install PICO-8 or update this script with your PICO-8 location."
    exit 1
end

# Copy cart to PICO-8 directory
echo "Copying cart to PICO-8 directory..."
cp $SCRIPT_DIR/$CART_NAME.p8 $PICO8_DIR
echo "Cart copied to $PICO8_DIR$CART_NAME.p8"
echo ""

# Provide export instructions
echo "Export Instructions:"
echo "1. Open PICO-8"
echo "2. Type: load $CART_NAME"
echo "3. Run the cart with: run"
echo "4. Test your cart thoroughly"
echo "5. Export with these commands:"
echo "   - export $CART_NAME.html"
echo "   - export $CART_NAME.png"
echo "   - export $CART_NAME.bin"
echo ""
echo "6. Take screenshots with F6 while playing"
echo ""

# Check for existing exports
echo "Checking for existing exports..."
set EXPORTS_FOUND 0

if test -f $PICO8_DIR/exports/$CART_NAME.html
    echo "- HTML export found"
    set EXPORTS_FOUND 1
end

if test -f $PICO8_DIR/exports/$CART_NAME.png
    echo "- PNG export found"
    set EXPORTS_FOUND 1
end

if test -f $PICO8_DIR/exports/$CART_NAME.bin
    echo "- BIN export found"
    set EXPORTS_FOUND 1
end

if test $EXPORTS_FOUND -eq 0
    echo "No exports found yet. Please follow the export instructions above."
else
    echo ""
    echo "Would you like to copy these exports to your local export directory? (y/n)"
    read copy_response
    
    if test "$copy_response" = "y"
        echo "Copying exports to $SCRIPT_DIR/export/..."
        
        if test -f $PICO8_DIR/exports/$CART_NAME.html
            cp $PICO8_DIR/exports/$CART_NAME.html $SCRIPT_DIR/export/
            echo "- Copied HTML export"
        end
        
        if test -f $PICO8_DIR/exports/$CART_NAME.png
            cp $PICO8_DIR/exports/$CART_NAME.png $SCRIPT_DIR/export/
            echo "- Copied PNG export"
        end
        
        if test -f $PICO8_DIR/exports/$CART_NAME.bin
            cp $PICO8_DIR/exports/$CART_NAME.bin $SCRIPT_DIR/export/
            echo "- Copied BIN export"
        end
        
        echo "Exports copied successfully!"
    end
end

echo ""
echo "Next steps:"
echo "1. Upload your exports to itch.io"
echo "2. Configure your itch.io page as described in PUBLISHING_GUIDE.md"
echo ""
echo "Done!"
