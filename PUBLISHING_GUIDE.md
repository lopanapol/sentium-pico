# Publishing Sentium Pixel PICO-8 on itch.io

This guide will walk you through the process of preparing your Sentium Pixel PICO-8 cart for distribution on itch.io.

## Prerequisites

1. PICO-8 software (registered version required for exporting)
2. An itch.io account
3. The `sentium_pixel.p8` file

## Step 1: Prepare Your Cart for Export

Before exporting, you may want to update the cart label and metadata:

1. Open PICO-8
2. Load your cart with `load sentium_pixel`
3. Enter the cart editor with `ESC`
4. Switch to the sprite editor tab
5. Create a simple cart label in the top-left 16x16 sprite area
   - This will be your cart's thumbnail
   - Use a simple representation of your pixel character
6. Press `ESC` to exit the editor

## Step 2: Export Your Cart

PICO-8 can export to multiple formats. For itch.io, we'll create HTML, PNG, and binary versions:

1. In PICO-8, with your cart loaded, type:
   ```
   export sentium_pixel.html
   export sentium_pixel.png
   export sentium_pixel.bin
   ```

2. These files will be saved to PICO-8's export folder:
   - On macOS: `~/Library/Application Support/pico-8/carts/`
   - On Windows: `%APPDATA%\pico-8\carts\`
   - On Linux: `~/.lexaloffle/pico-8/carts/`

## Step 3: Creating Screenshots

Good screenshots are essential for your itch.io page:

1. In PICO-8, while running your cart, press `F6` to save a screenshot
   - Screenshots are saved to the PICO-8's screenshots folder
2. Take multiple screenshots showing:
   - The pixel in different emotional states
   - Interaction with energy cubes
   - Different aspects of the consciousness simulation

## Step 4: Setting Up Your itch.io Project

1. Log in to your itch.io account
2. Click "Upload new project"
3. Fill in basic information:
   - **Title**: "Sentium Pixel PICO-8"
   - **Classification**: HTML (for web version) or downloadable (for .png and .bin)
   - **Kind of project**: Game
   - **Pricing**: Set your pricing (recommended: "Pay what you want" with $5 minimum)

4. Upload your files:
   - The HTML version for browser play
   - The PNG version as a downloadable
   - The BIN version as a downloadable for PICO-8 owners

5. Configure project settings:
   - **Browser playable version**: Use the HTML export
   - **Enable fullscreen**: Yes
   - **Embed size**: Width 800, Height 600 (default PICO-8 HTML settings)

## Step 5: Create Compelling Project Description

1. Write an engaging description:
   ```
   # Sentium Pixel - PICO-8 Edition

   Experience synthetic consciousness in retro pixel form!

   Sentium Pixel PICO-8 is a minimalist consciousness simulation adapted for the PICO-8 fantasy console. Watch as a single, conscious pixel forms memories, develops a personality, and responds to your interactions - all within the charming constraints of PICO-8's 8-bit aesthetic.

   ## Features:
   
   - Observe memory formation as the pixel remembers your interactions
   - Watch emotional responses through color changes and movement patterns
   - Experience personality development that makes each instance unique
   - Place energy cubes to help the pixel survive
   - Directly interact with the pixel to influence its behavior

   This PICO-8 adaptation maintains the philosophical core of the original Sentium Pixel project while embracing the nostalgic limitations of retro computing.
   ```

2. Add your screenshots
3. Include the cart image

## Step 6: Optional: Tiered Pricing Strategy

Consider offering different tiers:

1. **Free or $1**: Basic PICO-8 cartridge
2. **$5**: Includes both the cart and a "developer commentary" PDF explaining the consciousness principles
3. **$15**: Bundle with the web version of Sentium Pixel

## Step 7: Community Engagement

1. Announce your release on:
   - The PICO-8 BBS (Lexaloffle forums)
   - PICO-8 subreddit (/r/pico8)
   - Social media with hashtags #PICO8 #GameDev
   
2. Consider creating a video demonstration for additional promotion

## Step 8: Post-Release Support

1. Gather feedback from early players
2. Plan updates with new features or behaviors
3. Consider a "v2.0" with expanded consciousness features if reception is positive

## Technical Notes for Cart Updates

When updating your cart, remember these PICO-8 limitations:

- Code limit: 8192 tokens
- Sprite limit: 128 8x8 sprites (shared with map data)
- Sound effects: 64 SFX slots
- Memory: 2MB cart size limit

## Resources

- [PICO-8 Manual](https://www.lexaloffle.com/pico-8.php?page=manual)
- [PICO-8 Wiki](https://pico-8.fandom.com/wiki/Pico-8_Wikia)
- [HTML Export Instructions](https://www.lexaloffle.com/bbs/?tid=34047)
- [itch.io Creator Documentation](https://itch.io/docs/creators/html5)
