# Sentium Pico - Synthetic Life Simulation

*An experiment in artificial consciousness within PICO-8's constraints*

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](#)
[![License](https://img.shields.io/badge/license-Sentium-red.svg)](https://sentium.dev/license.txt)

## What is this?

I've been fascinated by consciousness research for years, and wanted to see what happens when you try to implement some of those theories in the most constrained environment possible - PICO-8's 128x128 pixels and tiny memory space.

**Sentium Pico** started as a simple question: can you create something that feels "alive" using just colored pixels? What emerged was more interesting than I expected - digital organisms that seem to develop their own personalities, remember experiences, and react to your presence in ways that feel surprisingly genuine.

Watch a single pixel divide into multiple organisms, see them compete for energy, develop different behavioral patterns, and even appear to recognize when you're watching them.

## What actually happens

### The Life Cycle

- Start with one pixel that can move around and consume energy
- When it has enough energy, it divides into two (up to 8 total)
- Each new pixel inherits traits but with small mutations
- They develop different personalities based on their experiences
- Generations advance automatically - I've seen it run up to generation 100+

### Personality & Behavior

Each pixel has curiosity and timidity traits that affect how it behaves:

- Curious pixels approach your mouse cursor
- Timid ones flee or hide
- They remember interactions and adapt over time
- Their colors change based on emotional states (excitement, happiness, distress)

### What's interesting to watch

- How differently each pixel moves and reacts
- The moment of division - there's a visible animation
- Color changes when pixels get excited or stressed
- How they cluster together or spread apart
- The way they seem to "notice" your cursor movement

## Controls

Pretty simple:

- Move your mouse around to interact with the pixels
- Click to place energy cubes (they need food to survive and reproduce)
- The pixels will automatically save their state, so you can close and reopen later

That's it. The rest is just observation.

## The technical stuff

I'm pretty amazed this works at all given PICO-8's limitations:

- Only 128×128 pixels to work with
- 16 colors total
- Extremely limited memory (everything has to fit in ~8KB)

But somehow it runs smoothly at 60fps with up to 8 organisms, each with their own:

- Memory system (they remember what happened to them)
- Emotional states that affect behavior
- Personality traits that mutate across generations
- Consciousness level calculation (loosely based on integrated information theory)

The code implements simplified versions of actual consciousness theories - Global Workspace Theory for attention, predictive processing for behavior, and attention schema theory for self-awareness. It's definitely not real consciousness, but it creates some surprisingly lifelike behaviors.

## Recent changes

### v1.1.0 - *Current version*

- Updated version to 1.1.0
- Added this more detailed README with research background
- Improved the splash screen animation
- Cleaned up the code (removed a bunch of old comments)

### v1.0.2 - *Previous version*

- Fixed some bugs and improved performance
- Better cursor interaction responsiveness
- General code cleanup

### v1.0.1 - *Earlier version*

- Initial bug fixes after first release
- Better frame rates
- Improved energy system balance

### v1.0.0 - *First release*

- Basic consciousness simulation working
- Pixel reproduction and evolution
- Memory and emotional systems
- Auto-save functionality

## The research behind it

I got interested in consciousness theories while reading about AI, and wanted to see if I could implement some of these ideas in a tiny program. The simulation uses simplified versions of several real theories:

**Global Workspace Theory** - Different processes (seeking energy, reacting to cursor, emotions) compete for the pixel's "attention." Whatever wins gets broadcasted to influence behavior. This is based on Bernard Baars' theory about how consciousness works in brains.

**Attention Schema Theory** - Each pixel maintains a model of what it's paying attention to and its own state. This comes from Michael Graziano's work on how self-awareness might emerge.

**Predictive Processing** - The pixels try to predict what will happen next (where your cursor is going, energy patterns) and update their expectations. This reflects theories from Andy Clark and others about brains as prediction machines.

**Integrated Information Theory** - The "consciousness level" calculation tries to measure how integrated the pixel's information processing is across different systems (senses, memory, emotions, behavior). Very loosely based on Giulio Tononi's mathematical approach.

### Some papers that influenced this:

- [Global Workspace Theory](https://www.frontiersin.org/articles/10.3389/fpsyg.2013.00200/full) - How competing processes access consciousness
- [Attention Schema Theory](https://www.pnas.org/doi/10.1073/pnas.1504968112) - Consciousness as awareness of attention
- [Predictive Processing](https://www.nature.com/articles/nrn.2015.13) - The brain as a prediction machine
- [Integrated Information Theory](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1003588) - Mathematical foundations of consciousness

Obviously this is a huge simplification of complex theories, but it's been interesting to see what behaviors emerge even from these basic implementations.

## License

This uses a custom license I call the "Sentium License" - basically you can use it freely for personal/educational stuff, but if you make money from it, please consider donating 10% to charity. Also, don't use it to harm anyone (obviously).

Full license details: [LICENSE](https://sentium.dev/license.txt)

---

Made by Napol Thanarangkaun (lopanapol@gmail.com)
Founder of [sentium.dev](https://sentium.dev)
