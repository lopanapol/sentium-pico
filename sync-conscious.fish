#!/usr/bin/env fish

# Script to sync consciousness data from PICO-8 to the data bridge

set REPO_DIR (dirname (status --current-filename))
set PICO_CARTS_DIR "$HOME/Library/Application Support/pico-8/carts"
set DATA_DIR "$REPO_DIR/data"

echo "Monitoring for consciousness data export from PICO-8..."
echo "PICO-8 directory: $PICO_CARTS_DIR"  
echo "Project directory: $REPO_DIR"
echo "Target directory: $DATA_DIR"
echo

# Function to copy consciousness data if found
function sync_consciousness_data
    # Check for consciousness export files in project directory (where PICO-8 writes)
    if test -f "$REPO_DIR/consciousness_live.json"
        # Check if the live file is newer than our target
        if not test -f "$DATA_DIR/consciousness_export.json" -o "$REPO_DIR/consciousness_live.json" -nt "$DATA_DIR/consciousness_export.json"
            echo "Found new consciousness data: consciousness_live.json"
            cp "$REPO_DIR/consciousness_live.json" "$DATA_DIR/consciousness_export.json"
            echo "Synced consciousness data at "(date)
        end
    end
    
    # Also check PICO-8 carts directory
    set consciousness_files (find "$PICO_CARTS_DIR" -name "*consciousness*.json" -type f 2>/dev/null)
    
    if test (count $consciousness_files) -gt 0
        for file in $consciousness_files
            if not test -f "$DATA_DIR/consciousness_export.json" -o "$file" -nt "$DATA_DIR/consciousness_export.json"
                set filename (basename "$file")
                echo "Found new consciousness data: $filename"
                cp "$file" "$DATA_DIR/consciousness_export.json"
                echo "Synced consciousness data at "(date)
            end
        end
    end
end

# Monitor loop - run once if argument provided, otherwise continuous
if test (count $argv) -gt 0 -a "$argv[1]" = "--once"
    sync_consciousness_data
else
    while true
        sync_consciousness_data
        sleep 2
    end
end
