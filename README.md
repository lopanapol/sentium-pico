# Sentium Pico - Synthetic Life Simulation

*An experiment in artificial consciousness within PICO-8's constraints*

[![Version](https://img.shields.io/badge/version-1.2.0-blue.svg)](#)
[![License](https://img.shields.io/badge/license-Sentium-red.svg)](https://sentium.dev/license.txt)
[![GitHub](https://img.shields.io/badge/GitHub-lopanapol/sentium--pico--8-white.svg)](https://github.com/lopanapol/sentium-pico-8)

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
- Generations advance automatically - I've seen it run up to generation 100

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
- The pixels will automatically save their state, so you can close and reopen later

That's it. The rest is just observation.

## The technical stuff

I'm pretty amazed this works at all given PICO-8's limitations:

- Only 128×128 pixels to work with
- 16 colors total
- Extremely limited memory (everything has to fit in ~8KB)

But somehow it runs smoothly with up to 8 organisms, each with their own:

- Memory system (they remember what happened to them)
- Emotional states that affect behavior
- Personality traits that mutate across generations
- Consciousness level calculation (loosely based on integrated information theory)

The code implements simplified versions of actual consciousness theories - Global Workspace Theory for attention, predictive processing for behavior, and attention schema theory for self-awareness. It's definitely not real consciousness, but it creates some surprisingly lifelike behaviors.

## Recent changes

### v1.2.0 - *Current version*

- Added Python bridge system for real-time consciousness analysis
- Updated version to 1.2.0
- Added advanced consciousness metrics and behavior prediction
- Created file-based communication between PICO-8 and Python

### v1.1.0 - *Previous version*

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

```lua
function update_global_workspace(pixel)
  local processes = {}
  
  -- Cursor attention process
  if cursor_interaction.is_aware then
    add(processes, {
      type = "cursor_attention",
      strength = cursor_interaction.attention_level,
      content = {x = mouse_cursor.x, y = mouse_cursor.y}
    })
  end
  
  -- Energy seeking process
  if pixel.energy < 50 then
    local urgency = (50 - pixel.energy) / 50
    add(processes, {
      type = "energy_seeking", 
      strength = urgency * 0.8,
      content = {energy_level = pixel.energy}
    })
  end
  
  -- Winner takes all - highest strength process wins
  local winner = nil
  local max_strength = 0
  for process in all(processes) do
    if process.strength > max_strength then
      max_strength = process.strength
      winner = process
    end
  end
  
  -- Broadcast winner if above consciousness threshold
  if winner and max_strength > global_workspace.consc_thresh then
    global_workspace.current_focus = winner
    global_workspace.broadcast_strength = max_strength
  end
end
```

**Attention Schema Theory** - Each pixel maintains a model of what it's paying attention to and its own state. This comes from Michael Graziano's work on how self-awareness might emerge.

```lua
function update_attention_schema(pixel)
  -- Update self-model
  attention_schema.self_model.position.x = pixel.x
  attention_schema.self_model.position.y = pixel.y
  attention_schema.self_model.confidence = min(1, pixel.energy / 100)
  
  -- Build attention map of salient objects
  attention_schema.attention_map = {}
  
  -- Add cursor to attention map if aware
  if cursor_interaction.is_aware then
    add(attention_schema.attention_map, {
      x = mouse_cursor.x,
      y = mouse_cursor.y,
      intensity = cursor_interaction.attention_level,
      type = "cursor"
    })
  end
  
  -- Add energy cubes based on distance and need
  for cube in all(energy_cubes) do
    local distance = dist(pixel.x, pixel.y, cube.x, cube.y)
    local attention_intensity = max(0, 1 - distance / 60)
    if pixel.energy < 40 then
      attention_intensity *= 2  -- More attention when hungry
    end
    add(attention_schema.attention_map, {
      x = cube.x, y = cube.y,
      intensity = attention_intensity,
      type = "energy"
    })
  end
end
```

**Predictive Processing** - The pixels try to predict what will happen next (where your cursor is going, energy patterns) and update their expectations. This reflects theories from Andy Clark and others about brains as prediction machines.

```lua
function predict_cursor_behavior(pixel)
  if cursor_interaction.is_aware then
    -- Predict based on recent movement
    local dx = mouse_cursor.x - cursor_interaction.last_cursor_x
    local dy = mouse_cursor.y - cursor_interaction.last_cursor_y
    local predicted_x = mouse_cursor.x + dx
    local predicted_y = mouse_cursor.y + dy
  
    -- Calculate prediction error
    if cursor_interaction.last_predicted_x then
      local error_x = abs(mouse_cursor.x - cursor_interaction.last_predicted_x)
      local error_y = abs(mouse_cursor.y - cursor_interaction.last_predicted_y)
      local prediction_error = (error_x + error_y) / 2
    
      -- Update behavior based on prediction accuracy
      if prediction_error < 3 then
        -- Good prediction - increase confidence
        pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.005)
      else
        -- Poor prediction - become more cautious
        pixel.personality.timidity = min(1, pixel.personality.timidity + 0.005)
      end
    
      attention_schema.prediction_error = prediction_error
    end
  
    cursor_interaction.last_predicted_x = predicted_x
    cursor_interaction.last_predicted_y = predicted_y
  end
end
```

**Integrated Information Theory** - The "consciousness level" calculation tries to measure how integrated the pixel's information processing is across different systems (senses, memory, emotions, behavior). Very loosely based on Giulio Tononi's mathematical approach.

```lua
function calculate_phi(pixel)
  -- Simplified IIT calculation combining multiple information sources
  
  -- Sensory integration (cursor awareness)
  local sensory = cursor_interaction.attention_level * 0.4
  
  -- Memory integration (how much past experience is accessible)
  local memory = min(#pixel.memories / memory_size, 1) * 0.35
  
  -- Emotional integration (current emotional state)
  local emotional = (pixel.emo_state.happiness + pixel.emo_state.excitement) * 0.15
  
  -- Behavioral integration (goal-directed movement)
  local behavioral = 0
  if pixel.target_x then
    local distance_to_goal = abs(pixel.x - pixel.target_x) + abs(pixel.y - pixel.target_y)
    behavioral = (1 - min(distance_to_goal, 50) / 50) * 0.2
  end
  
  -- Phi = integrated information across all systems
  local phi = (sensory + memory + emotional + behavioral) / 4
  return min(phi, 1)  -- Consciousness level between 0 and 1
end
```

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
