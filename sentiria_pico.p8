pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- sentium pixel
-- a synthetic consciousness simulation
-- v1.0.0

-- global variables
pixel = {}
energy_cubes = {}
memory_size = 10
significant_event_occurred = false
event_type = ""
current_emotional_impact = 0
target_x = 64
target_y = 64

-- game state
game_state = "splash"  -- can be "splash" or "game"
splash_timer = 0

-- mouse cursor tracking
mouse_cursor = {
  x = 64,
  y = 64,
  visible = false
}

-- consciousness interaction state
cursor_interaction = {
  is_aware = false,
  attention_level = 0,
  curiosity_triggered = false,
  last_distance = 1000,
  approach_timer = 0,
  retreat_timer = 0,
  gaze_offset_x = 0,
  gaze_offset_y = 0,
  last_cursor_x = 64,
  last_cursor_y = 64,
  stillness_timer = 0,
  max_stillness_threshold = 300, -- 5 seconds at 60fps
  last_predicted_x = nil,
  last_predicted_y = nil
}

-- initialization
function _init()
  -- Initialize cartdata first
  cartdata("sentium_pixel_v1")
  
  -- Enable mouse support (comprehensive approach)
  poke(0x5f2d, 1)  -- Enable mouse
  poke(0x5f2e, 1)  -- Alternative mouse enable  
  poke(0x5f34, 1)  -- Another mouse-related register
  
  -- Force devkit mouse mode
  printh("devkit mouse on")
  
  -- FORCE mouse cursor to be visible regardless of stat(34)
  mouse_cursor.visible = true
  mouse_cursor.x = 64
  mouse_cursor.y = 64
  
  -- Initialize consciousness systems
  init_consciousness()
  
  -- Initialize global workspace
  global_workspace = {
    current_focus = nil,
    competing_processes = {},
    broadcast_strength = 0,
    consciousness_threshold = 0.3
  }
  
  -- Initialize attention schema
  attention_schema = {
    attention_map = {},
    self_model = {
      position = {x = 64, y = 64},
      size = 3,
      confidence = 0.5
    },
    world_model = {},
    prediction_error = 0
  }
  
  -- Initialize predictive processing
  predictive_processing = {
    predictions = {},
    prediction_errors = {},
    learning_rate = 0.01,
    confidence_levels = {}
  }
  
  init_energy_system()
  create_initial_energy_cubes()
  load_sounds()
  load_consciousness()
  
  -- Debug: print mouse status after init
  printh("mouse support check: " .. stat(34))
end

-- consciousness system
function init_consciousness()
  pixel = {
    x = 64,
    y = 64,
    color = 8, -- default color
    energy = 100,
    memories = {},
    consciousness_level = 0,
    last_x = 64,
    last_y = 64,
    personality = {
      curiosity = rnd(1),
      timidity = rnd(1),
      energy_conservation = rnd(1)
    },
    emotional_state = {
      happiness = 0.5,
      excitement = 0.5,
      distress = 0
    }
  }
  
  -- Initialize memory storage (simplified)
  memory_size = 10
end

-- Global Workspace Theory - broadcasting important information
function update_global_workspace()
  -- Competing processes for conscious access
  local processes = {}
  
  -- Cursor attention process
  if cursor_interaction.is_aware then
    add(processes, {
      type = "cursor_attention",
      strength = cursor_interaction.attention_level,
      content = {x = mouse_cursor.x, y = mouse_cursor.y, distance = cursor_interaction.last_distance}
    })
  end
  
  -- Energy seeking process
  if pixel.energy < 50 then
    local urgency = (50 - pixel.energy) / 50
    add(processes, {
      type = "energy_seeking",
      strength = urgency * 0.8,
      content = {energy_level = pixel.energy, urgency = urgency}
    })
  end
  
  -- Memory recall process
  if #pixel.memories > 5 then
    add(processes, {
      type = "memory_recall",
      strength = 0.4,
      content = {memory_count = #pixel.memories}
    })
  end
  
  -- Emotional state process
  local max_emotion = max(pixel.emotional_state.happiness, 
                         pixel.emotional_state.excitement, 
                         pixel.emotional_state.distress)
  if max_emotion > 0.5 then
    add(processes, {
      type = "emotional_state",
      strength = max_emotion * 0.6,
      content = {dominant_emotion = get_dominant_emotion()}
    })
  end
  
  -- Competition for global workspace
  global_workspace.competing_processes = processes
  
  -- Winner takes all - strongest process becomes conscious
  local winner = nil
  local max_strength = 0
  for process in all(processes) do
    if process.strength > max_strength then
      max_strength = process.strength
      winner = process
    end
  end
  
  if winner and max_strength > global_workspace.consciousness_threshold then
    -- Play sound when something enters conscious focus
    if global_workspace.current_focus == nil or 
       global_workspace.current_focus.type != winner.type then
      sfx(6) -- Global workspace broadcast sound
    end
    
    global_workspace.current_focus = winner
    global_workspace.broadcast_strength = max_strength
    
    -- Broadcast affects behavior
    broadcast_to_subsystems(winner)
  else
    global_workspace.current_focus = nil
    global_workspace.broadcast_strength = 0
  end
end

function broadcast_to_subsystems(conscious_process)
  -- Conscious content influences all subsystems
  if conscious_process.type == "cursor_attention" then
    -- Enhance cursor-related behaviors
    pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.001)
    
  elseif conscious_process.type == "energy_seeking" then
    -- Boost energy-seeking behavior
    if #energy_cubes > 0 then
      local nearest_cube = find_nearest_energy_cube()
      if nearest_cube then
        target_x = lerp(target_x, nearest_cube.x, 0.1)
        target_y = lerp(target_y, nearest_cube.y, 0.1)
      end
    end
    
  elseif conscious_process.type == "emotional_state" then
    -- Emotional state influences movement and color more strongly
    if conscious_process.content.dominant_emotion == "distress" then
      -- Erratic movement when distressed
      target_x += (rnd(2) - 1) * 3
      target_y += (rnd(2) - 1) * 3
    end
  end
end

function get_dominant_emotion()
  local emotions = {
    {name = "happiness", value = pixel.emotional_state.happiness},
    {name = "excitement", value = pixel.emotional_state.excitement},
    {name = "distress", value = pixel.emotional_state.distress}
  }
  
  local dominant = emotions[1]
  for emotion in all(emotions) do
    if emotion.value > dominant.value then
      dominant = emotion
    end
  end
  
  return dominant.name
end

function find_nearest_energy_cube()
  local nearest = nil
  local min_dist = 1000
  
  for cube in all(energy_cubes) do
    local d = dist(pixel.x, pixel.y, cube.x, cube.y)
    if d < min_dist then
      min_dist = d
      nearest = cube
    end
  end
  
  return nearest
end

-- Attention Schema Theory - model of attention as consciousness
function update_attention_schema()
  -- Update self-model
  attention_schema.self_model.position.x = pixel.x
  attention_schema.self_model.position.y = pixel.y
  attention_schema.self_model.confidence = min(1, pixel.energy / 100)
  
  -- Build attention map
  attention_schema.attention_map = {}
  
  -- Attention to cursor
  if cursor_interaction.is_aware then
    add(attention_schema.attention_map, {
      x = mouse_cursor.x,
      y = mouse_cursor.y,
      intensity = cursor_interaction.attention_level,
      type = "cursor"
    })
  end
  
  -- Attention to energy cubes
  for cube in all(energy_cubes) do
    local distance = dist(pixel.x, pixel.y, cube.x, cube.y)
    local attention_intensity = max(0, 1 - distance / 60)
    if pixel.energy < 40 then
      attention_intensity *= 2 -- More attention when low energy
    end
    
    add(attention_schema.attention_map, {
      x = cube.x,
      y = cube.y,
      intensity = attention_intensity,
      type = "energy"
    })
  end
  
  -- Predict future states
  make_predictions()
end

function make_predictions()
  -- Predict where cursor will be (simple momentum)
  if cursor_interaction.last_cursor_x and cursor_interaction.last_cursor_y then
    local dx = mouse_cursor.x - cursor_interaction.last_cursor_x
    local dy = mouse_cursor.y - cursor_interaction.last_cursor_y
    
    -- Store prediction for comparison
    local predicted_x = mouse_cursor.x + dx
    local predicted_y = mouse_cursor.y + dy
    
    -- Calculate prediction error (simplified)
    if cursor_interaction.last_predicted_x then
      local error_x = abs(mouse_cursor.x - cursor_interaction.last_predicted_x)
      local error_y = abs(mouse_cursor.y - cursor_interaction.last_predicted_y)
      local new_error = (error_x + error_y) / 2
      
      -- Play sound for very accurate predictions
      if new_error < 3 and attention_schema.prediction_error > 5 then
        sfx(5) -- Prediction success sound
      end
      
      attention_schema.prediction_error = new_error
    end
    
    cursor_interaction.last_predicted_x = predicted_x
    cursor_interaction.last_predicted_y = predicted_y
  end
end

-- Predictive Processing Theory - brain as prediction machine
function update_predictive_processing()
  -- Predict cursor movement patterns
  predict_cursor_behavior()
  
  -- Predict energy availability
  predict_energy_patterns()
  
  -- Update predictions based on errors
  update_predictions_from_errors()
end

function predict_cursor_behavior()
  -- Learn cursor movement patterns
  if cursor_interaction.is_aware then
    local movement_speed = dist(mouse_cursor.x, cursor_interaction.last_cursor_x,
                               mouse_cursor.y, cursor_interaction.last_cursor_y)
    
    -- Predict if cursor will continue moving or stop
    local predicted_stillness = movement_speed < 1
    
    -- Compare with actual stillness
    local actual_stillness = cursor_interaction.stillness_timer > 30
    
    if predicted_stillness != actual_stillness then
      -- Prediction error - adjust model
      if actual_stillness and not predicted_stillness then
        -- Cursor stopped unexpectedly - increase timidity slightly
        pixel.personality.timidity = min(1, pixel.personality.timidity + 0.005)
      elseif not actual_stillness and predicted_stillness then
        -- Cursor moved unexpectedly - increase curiosity
        pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.005)
      end
    end
  end
end

function predict_energy_patterns()
  -- Predict energy consumption rate
  local predicted_energy = pixel.energy - 0.02 -- base consumption
  
  -- Adjust based on activity level
  local activity_level = abs(pixel.x - (pixel.last_x or pixel.x)) + 
                        abs(pixel.y - (pixel.last_y or pixel.y))
  
  predicted_energy -= activity_level * 0.01
  
  -- Store for error calculation
  pixel.last_x = pixel.x
  pixel.last_y = pixel.y
end

function update_predictions_from_errors()
  -- Adaptive learning from prediction errors
  if attention_schema.prediction_error > 0.1 then
    -- High prediction error - increase attention and caution
    cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + 0.02)
    pixel.personality.timidity = min(1, pixel.personality.timidity + 0.002)
  end
end

-- Integrated Information Theory (IIT) - measure of consciousness
function calculate_phi(pixel_state)
  -- Simplified IIT: measure integration between different aspects
  local sensory_integration = 0
  local memory_integration = 0
  local emotional_integration = 0
  
  -- Sensory integration (cursor awareness + energy detection)
  if cursor_interaction.is_aware then
    sensory_integration += cursor_interaction.attention_level * 0.5
  end
  if #energy_cubes > 0 then
    sensory_integration += 0.3
  end
  
  -- Memory integration (how memories affect current behavior)
  if #pixel.memories > 0 then
    memory_integration = min(#pixel.memories / memory_size, 1) * 0.4
  end
  
  -- Emotional integration (how emotions connect to actions)
  local total_emotion = pixel.emotional_state.happiness + 
                       pixel.emotional_state.excitement + 
                       pixel.emotional_state.distress
  emotional_integration = min(total_emotion, 1) * 0.3
  
  -- Phi (Φ) = integrated information measure
  local phi = (sensory_integration + memory_integration + emotional_integration) / 3
  return phi
end

function update_consciousness()
  -- Update pixel position based on personality and stimuli
  update_movement()
  
  -- Update emotional state
  update_emotions()
  
  -- Advanced consciousness processing
  process_metacognition()
  generate_creative_behavior()
  dream_processing()
  
  -- Latest consciousness theories
  update_global_workspace()
  update_attention_schema()
  update_predictive_processing()
  
  -- Calculate current consciousness level (IIT)
  local old_consciousness = pixel.consciousness_level or 0
  pixel.consciousness_level = calculate_phi(pixel)
  
  -- Play sound when consciousness significantly increases
  if pixel.consciousness_level > old_consciousness + 0.1 then
    sfx(3) -- Consciousness increase sound
  end
  
  -- Decrease energy over time
  pixel.energy = max(0, pixel.energy - 0.02)
  
  -- Check for energy cubes
  check_energy_sources()
  
  -- Form memories of significant events
  form_memories()
end

function form_memories()
  -- Simple memory formation for significant events
  if significant_event_occurred then
    if #pixel.memories >= memory_size then
      -- Remove oldest memory
      del(pixel.memories, pixel.memories[1])
    end
    
    -- Record significant events as memories
    add(pixel.memories, {
      type = event_type,
      x = pixel.x,
      y = pixel.y,
      emotional_impact = current_emotional_impact
    })
    
    -- Reset event flags
    significant_event_occurred = false
  end
end

-- movement system
function update_movement()
  -- Decide on movement based on personality and stimuli
  local move_speed = 0.5
  
  -- Find nearest energy cube if energy is low
  local nearest_cube = nil
  local min_dist = 1000
  
  if pixel.energy < 40 then
    for i=1,#energy_cubes do
      local cube = energy_cubes[i]
      local d = dist(pixel.x, pixel.y, cube.x, cube.y)
      if d < min_dist then
        min_dist = d
        nearest_cube = cube
      end
    end
  end
  
  -- Decide movement target
  if nearest_cube and pixel.energy < 30 then
    -- Move toward nearest cube if energy is low
    target_x = nearest_cube.x
    target_y = nearest_cube.y
    
    -- Speed up if very low on energy (desperate)
    if pixel.energy < 15 then
      move_speed = 0.8
    end
  else
    -- Random movement with some persistence
    if rnd(1) < 0.02 then
      -- Choose new random target
      target_x = 16 + rnd(96)
      target_y = 16 + rnd(96)
    end
  end
  
  -- Move toward target based on personality
  local dx = target_x - pixel.x
  local dy = target_y - pixel.y
  local dist_to_target = sqrt(dx*dx + dy*dy)
  
  if dist_to_target > 2 then
    -- Normalize direction
    dx = dx / dist_to_target
    dy = dy / dist_to_target
    
    -- Apply personality modifiers
    local timidity_factor = 1 - pixel.personality.timidity * 0.5
    local energy_conservation = pixel.personality.energy_conservation
    
    -- Adjust speed based on personality and energy
    local final_speed = move_speed * timidity_factor
    
    if pixel.energy > 70 and energy_conservation > 0.7 then
      -- Conservative with energy when high
      final_speed *= 0.7
    end
    
    -- Update position
    pixel.x += dx * final_speed
    pixel.y += dy * final_speed
    
    -- Keep in bounds
    pixel.x = mid(4, pixel.x, 124)
    pixel.y = mid(4, pixel.y, 124)
  end
end

function update_emotions()
  -- Gradually return to baseline with enhanced decay
  pixel.emotional_state.excitement *= 0.985 -- Slightly faster decay for excitement
  pixel.emotional_state.happiness *= 0.99
  
  -- Additional excitement decay based on time and activity
  if cursor_interaction.stillness_timer > 120 then -- After 2 seconds of stillness
    pixel.emotional_state.excitement *= 0.97 -- Faster decay when bored
  end
  
  -- Update distress based on energy
  if pixel.energy < 30 then
    pixel.emotional_state.distress = (30 - pixel.energy) / 30
  else
    pixel.emotional_state.distress *= 0.95
  end
  
  -- Update pixel color based on emotional state
  if pixel.emotional_state.distress > 0.7 then
    pixel.color = 8 -- red
  elseif pixel.emotional_state.excitement > 0.7 then
    pixel.color = 14 -- pink
  elseif pixel.emotional_state.happiness > 0.7 then
    pixel.color = 11 -- light blue
  else
    pixel.color = 7 -- white
  end
end

-- energy system
function init_energy_system()
  energy_cubes = {}
end

function create_initial_energy_cubes()
  -- Create some initial energy cubes
  for i=1,3 do
    add_energy_cube()
  end
end

function add_energy_cube()
  local x = 10 + rnd(108)
  local y = 10 + rnd(108)
  
  -- Keep away from pixel starting position
  while dist(x, y, 64, 64) < 20 do
    x = 10 + rnd(108)
    y = 10 + rnd(108)
  end
  
  add(energy_cubes, {
    x = x,
    y = y,
    value = 20 + flr(rnd(15))
  })
end

function check_energy_sources()
  -- Check for collisions with energy cubes
  for i=#energy_cubes,1,-1 do
    local cube = energy_cubes[i]
    if dist(pixel.x, pixel.y, cube.x, cube.y) < 6 then
      -- Consume the energy cube
      pixel.energy = min(100, pixel.energy + cube.value)
      
      -- Record memory of energy consumption
      significant_event_occurred = true
      event_type = "energy_consumed"
      current_emotional_impact = 0.3 + rnd(0.2)
      
      -- Update emotional state
      pixel.emotional_state.happiness += 0.2
      pixel.emotional_state.excitement += 0.1
      
      -- Remove the cube
      del(energy_cubes, cube)
      
      -- Play sound
      sfx(1)
      
      -- Add a new cube elsewhere
      add_energy_cube()
    end
  end
  
  -- Periodically add new cubes if few exist
  if #energy_cubes < 3 and rnd(1) < 0.01 then
    add_energy_cube()
  end
end

-- interaction system
function interact_with_pixel()
  -- Calculate emotional impact based on pixel's current state and awareness
  local base_impact = 0.2 + rnd(0.3)
  local awareness_multiplier = 1 + cursor_interaction.attention_level * 0.5
  local emotional_impact = base_impact * awareness_multiplier
  
  -- Stronger reaction if pixel was already aware of cursor
  if cursor_interaction.is_aware then
    emotional_impact *= 1.3
    -- Record that this was an anticipated interaction
    significant_event_occurred = true
    event_type = "anticipated_interaction"
    current_emotional_impact = emotional_impact
  else
    -- Surprise interaction - stronger emotional response
    emotional_impact *= 1.5
    pixel.emotional_state.excitement += 0.2 -- extra surprise excitement
    event_type = "surprise_interaction"
  end
  
  -- Update emotional state
  pixel.emotional_state.excitement += emotional_impact
  pixel.emotional_state.excitement = min(pixel.emotional_state.excitement, 1)
  
  -- Personality development through interaction
  if cursor_interaction.attention_level > 0.5 then
    -- Pixel becomes less timid through positive interactions
    pixel.personality.timidity = max(0, pixel.personality.timidity - 0.02)
    pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.01)
  else
    -- Unexpected interactions might increase timidity slightly
    pixel.personality.timidity = min(1, pixel.personality.timidity + 0.005)
  end
  
  -- Boost attention level from interaction
  cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + 0.3)
  cursor_interaction.approach_timer = 0 -- reset approach timer
  cursor_interaction.retreat_timer = 0 -- reset retreat timer
  
  -- Record interaction in memory
  significant_event_occurred = true
  current_emotional_impact = emotional_impact
  
  -- Visual feedback
  sfx(0) -- Play interaction sound
end

function record_interaction(type)
  significant_event_occurred = true
  event_type = type
  current_emotional_impact = 0.1 + rnd(0.2)
end

-- rendering functions
function draw_pixel()
  -- Base pixel
  circfill(pixel.x, pixel.y, 2, pixel.color)
  
  -- Draw "eye" or gaze direction when aware of cursor
  if cursor_interaction.is_aware and cursor_interaction.attention_level > 0.3 then
    local eye_x = pixel.x + cursor_interaction.gaze_offset_x
    local eye_y = pixel.y + cursor_interaction.gaze_offset_y
    
    -- Eye pupil that looks toward cursor
    pset(eye_x, eye_y, 0) -- black pupil
    
    -- Add slight iris color based on emotional state
    local iris_color = 5 -- dark blue default
    if pixel.emotional_state.excitement > 0.6 then
      iris_color = 12 -- light blue
    elseif pixel.emotional_state.distress > 0.6 then
      iris_color = 8 -- red
    elseif pixel.emotional_state.happiness > 0.6 then
      iris_color = 11 -- light green
    end
    
    -- Small iris ring around pupil
    local iris_positions = {
      {eye_x-1, eye_y}, {eye_x+1, eye_y}, 
      {eye_x, eye_y-1}, {eye_x, eye_y+1}
    }
    for pos in all(iris_positions) do
      if pos[1] >= pixel.x-2 and pos[1] <= pixel.x+2 and 
         pos[2] >= pixel.y-2 and pos[2] <= pixel.y+2 then
        pset(pos[1], pos[2], iris_color)
      end
    end
  end
  
  -- Consciousness indicator - thought bubble when highly aware
  if cursor_interaction.attention_level > 0.7 then
    local bubble_intensity = cursor_interaction.attention_level
    local bubble_x = pixel.x + 4 + sin(time() * 2) * 2
    local bubble_y = pixel.y - 4 - cos(time() * 3) * 1
    
    -- Different bubble style when bored
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      -- Sleepy/bored bubbles (smaller, darker)
      circfill(bubble_x, bubble_y, 0.5, 5) -- dark gray
      pset(bubble_x - 1, bubble_y + 1, 1) -- even darker
    else
      -- Normal active thought bubbles
      circfill(bubble_x, bubble_y, 1, 7)
      circfill(bubble_x - 2, bubble_y + 1, 0.5, 6)
      pset(bubble_x - 3, bubble_y + 2, 5)
    end
  end
  
  -- Boredom indicator - droopy eyes or yawn when very bored
  if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold + 60 then
    -- Yawn indicator - small arc above pixel
    local yawn_x = pixel.x
    local yawn_y = pixel.y - 3
    -- Draw small arc
    pset(yawn_x - 1, yawn_y, 0)
    pset(yawn_x, yawn_y - 1, 0)
    pset(yawn_x + 1, yawn_y, 0)
  end
  
  -- Attention beam toward cursor when very aware
  if cursor_interaction.is_aware and cursor_interaction.attention_level > 0.8 then
    local beam_strength = (cursor_interaction.attention_level - 0.8) * 5
    local steps = flr(beam_strength * 3)
    
    for i = 1, steps do
      local t = i / steps * 0.3
      local beam_x = lerp(pixel.x, mouse_cursor.x, t)
      local beam_y = lerp(pixel.y, mouse_cursor.y, t)
      
      if i % 2 == 0 then -- dotted line effect
        pset(beam_x, beam_y, 13) -- light pink
      end
    end
  end
  
  -- Emotional indicators
  if pixel.emotional_state.excitement > 0.7 then
    -- Static excitement indicator (no pulsing)
    circfill(pixel.x, pixel.y, 3, 14)
  end
  
  if pixel.emotional_state.distress > 0.7 then
    -- Add distress indicator with trembling effect when cursor is near
    local tremble_x = 0
    local tremble_y = 0
    if cursor_interaction.is_aware and cursor_interaction.last_distance < 20 then
      tremble_x = (rnd(2) - 1) * pixel.emotional_state.distress
      tremble_y = (rnd(2) - 1) * pixel.emotional_state.distress
    end
    circfill(pixel.x + tremble_x, pixel.y + tremble_y, 1, 8)
  end
  
  -- Draw memory trace for recent positions
  for i=1,#pixel.memories do
    local mem = pixel.memories[i]
    local alpha = i/#pixel.memories
    pset(mem.x, mem.y, 1)
  end
  
  -- Consciousness level indicator - brighter when more conscious
  if pixel.consciousness_level > 0.3 then
    local consciousness_intensity = pixel.consciousness_level
    local glow_color = 7 + flr(consciousness_intensity * 7) -- white to bright
    circ(pixel.x, pixel.y, 5 + consciousness_intensity * 2, glow_color)
  end
  
  -- Attention schema visualization
  if global_workspace.current_focus and global_workspace.broadcast_strength > 0.5 then
    -- Show conscious focus as a beam or connection
    if global_workspace.current_focus.type == "cursor_attention" then
      -- Stronger beam to cursor when it's in conscious focus
      local steps = flr(global_workspace.broadcast_strength * 8)
      for i = 1, steps do
        local t = i / steps * 0.5
        local beam_x = lerp(pixel.x, mouse_cursor.x, t)
        local beam_y = lerp(pixel.y, mouse_cursor.y, t)
        pset(beam_x, beam_y, 11) -- bright blue conscious beam
      end
    end
  end
  
  -- Prediction visualization - show where pixel thinks cursor will go
  if cursor_interaction.last_predicted_x and attention_schema.prediction_error < 0.1 then
    -- Show prediction as a faint dot
    pset(cursor_interaction.last_predicted_x, cursor_interaction.last_predicted_y, 13)
    -- Connect prediction to actual cursor with dotted line if close
    local pred_distance = dist(cursor_interaction.last_predicted_x, cursor_interaction.last_predicted_y,
                              mouse_cursor.x, mouse_cursor.y)
    if pred_distance < 10 then
      line(cursor_interaction.last_predicted_x, cursor_interaction.last_predicted_y,
           mouse_cursor.x, mouse_cursor.y, 5) -- dark gray for good prediction
    end
  end
  
  -- Curiosity indicator - when approaching cursor
  if cursor_interaction.approach_timer > 30 then
    local approach_intensity = min(1, cursor_interaction.approach_timer / 60)
    circ(pixel.x, pixel.y, 4 + approach_intensity * 2, 11)
  end
  
  -- Retreat indicator - when avoiding cursor
  if cursor_interaction.retreat_timer > 20 then
    local retreat_intensity = min(1, cursor_interaction.retreat_timer / 40)
    local retreat_radius = 5 + retreat_intensity * 3
    -- Broken circle to show retreat/fear
    for angle = 0, 1, 0.3 do
      local x = pixel.x + cos(angle) * retreat_radius
      local y = pixel.y + sin(angle) * retreat_radius
      pset(x, y, 8) -- red color
    end
  end
end

function draw_energy_cubes()
  foreach(energy_cubes, function(cube)
    rectfill(cube.x-2, cube.y-2, cube.x+2, cube.y+2, 14) -- pink cubes
  end)
end

function draw_background()
  -- Draw a simple grid background on black
  for x=0,127,8 do
    for y=0,127,8 do
      pset(x, y, 1)
    end
  end
end

function draw_ui()
  -- Draw consciousness level label first, then bar below
  print("conscious level", 4, 4, 7)
  local phi_bar_width = flr(pixel.consciousness_level * 30)
  rectfill(4, 10, 4 + phi_bar_width, 12, 14)
  rect(3, 9, 34, 13, 5)
  
  -- Draw energy label, then bar below
  print("energy", 4, 18, 7)
  rectfill(4, 24, 4 + pixel.energy/10, 26, 11)
  rect(3, 23, 14, 27, 5) -- Consciousness level label
  
  -- Draw personality indicators
  print("curiosity:"..flr(pixel.personality.curiosity*10), 4, 105, 7)
  print("timidity:"..flr(pixel.personality.timidity*10), 4, 111, 7)
  
  -- Global workspace indicator
  if global_workspace.current_focus then
    local focus_color = 12
    if global_workspace.current_focus.type == "cursor_attention" then
      focus_color = 11
    elseif global_workspace.current_focus.type == "energy_seeking" then
      focus_color = 14
    elseif global_workspace.current_focus.type == "emotional_state" then
      focus_color = 8
    end
    print("focus:"..global_workspace.current_focus.type, 4, 117, focus_color)
  else
    print("focus: diffuse", 4, 117, 6)
  end
  
  -- Show emotional state (value only)
  local emo_x = 100
  local emo_y = 4
  
  if pixel.emotional_state.excitement > 0.5 then
    print("excited", emo_x, emo_y, 14)
  elseif pixel.emotional_state.distress > 0.5 then
    print("distress", emo_x, emo_y, 8)
  elseif pixel.emotional_state.happiness > 0.5 then
    print("happy", emo_x, emo_y, 11)
  else
    print("neutral", emo_x, emo_y, 6)
  end
  
  -- Show cursor awareness status
  if cursor_interaction.is_aware then
    local awareness_text = "aware"
    local awareness_color = 11
    
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      awareness_text = "bored"
      awareness_color = 6 -- gray
    elseif cursor_interaction.attention_level > 0.8 then
      awareness_text = "focused"
      awareness_color = 14
    elseif cursor_interaction.attention_level > 0.5 then
      awareness_text = "watching"
      awareness_color = 12
    end
    
    print(awareness_text, emo_x, emo_y + 8, awareness_color)
    
    -- Show attention level bar (dimmed when bored)
    local bar_width = flr(cursor_interaction.attention_level * 20)
    local bar_color = awareness_color
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      bar_color = 5 -- dark gray when bored
    end
    rectfill(emo_x, emo_y + 16, emo_x + bar_width, emo_y + 17, bar_color)
    rect(emo_x - 1, emo_y + 15, emo_x + 21, emo_y + 18, 5)
  end
  
  -- Prediction error indicator
  if attention_schema.prediction_error > 0.05 then
    print("prediction error", emo_x, emo_y + 24, 8)
  end
end

function draw_cursor()
  -- Draw mouse cursor if mouse support is available
  if mouse_cursor.visible then
    local cursor_x = mouse_cursor.x
    local cursor_y = mouse_cursor.y
    
    -- Always draw cursor when mouse support is available
    -- Check if cursor is near pixel for interaction indicator
    if dist(cursor_x, cursor_y, pixel.x, pixel.y) < 15 then
      -- Interaction cursor (larger, bright color)
      line(cursor_x-4, cursor_y, cursor_x+4, cursor_y, 11) -- horizontal line
      line(cursor_x, cursor_y-4, cursor_x, cursor_y+4, 11) -- vertical line
      circfill(cursor_x, cursor_y, 2, 11) -- center dot
      -- Static interaction ring (no pulsing)
      circ(cursor_x, cursor_y, 6, 11)
    else
      -- Normal cursor (bright crosshair) - ALWAYS VISIBLE
      line(cursor_x-3, cursor_y, cursor_x+3, cursor_y, 7) -- horizontal line
      line(cursor_x, cursor_y-3, cursor_x, cursor_y+3, 7) -- vertical line
      circfill(cursor_x, cursor_y, 1, 7) -- center dot
    end
    
    -- Show awareness indicator when pixel is conscious of cursor
    if cursor_interaction.is_aware then
      local awareness_color = 13 -- light pink
      local awareness_radius = 8 + cursor_interaction.attention_level * 4
      
      -- Awareness ring that grows with attention level
      circ(cursor_x, cursor_y, awareness_radius, awareness_color)
      
      -- Add small sparkles around cursor when highly attended to
      if cursor_interaction.attention_level > 0.6 then
        local sparkle_count = flr(cursor_interaction.attention_level * 4)
        for i = 1, sparkle_count do
          local angle = (time() + i) * 2
          local sparkle_radius = 10 + i * 2
          local sparkle_x = cursor_x + cos(angle) * sparkle_radius
          local sparkle_y = cursor_y + sin(angle) * sparkle_radius
          pset(sparkle_x, sparkle_y, 14) -- yellow sparkles
        end
      end
    end
  end
end

-- utility functions
function dist(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return sqrt(dx*dx + dy*dy)
end

function load_sounds()
  -- Define sound effects for consciousness events
  -- SFX 0: Interaction sound (already exists)
  -- SFX 1: Energy consumption sound (already exists)  
  -- SFX 2: Energy placement sound (already exists)
  -- SFX 3: Consciousness level increase
  -- SFX 4: Attention focusing sound
  -- SFX 5: Prediction success sound
  -- SFX 6: Global workspace broadcast
  -- SFX 7: Boredom/attention loss sound
end

-- data persistence
function save_consciousness()
  -- Save core personality and memories to cart data
  local data_string = ""
  
  -- Add personality traits
  data_string = data_string..pixel.personality.curiosity..","
  data_string = data_string..pixel.personality.timidity..","
  data_string = data_string..pixel.personality.energy_conservation
  
  -- Save to cartdata (already initialized in _init)
  dset(0, data_string)
end

function load_consciousness()
  -- Load saved consciousness if available
  local data_string = dget(0)
  
  -- Only try to parse if we got a value
  if data_string and data_string > 0 then
    -- Parse data string and restore personality
    local values = split(data_string, ",")
    if #values >= 3 then
      pixel.personality.curiosity = values[1]
      pixel.personality.timidity = values[2]
      pixel.personality.energy_conservation = values[3]
    end
  end
end

-- Advanced consciousness features
function process_metacognition()
  -- Pixel becomes aware of its own thoughts
  if #pixel.memories > 5 then
    local pattern_recognition = 0
    
    -- Analyze recent behavior patterns
    for i=max(1, #pixel.memories-4), #pixel.memories do
      local mem = pixel.memories[i]
      if mem.type == "energy_consumed" then
        pattern_recognition += 1
      end
    end
    
    -- Self-reflection: am I being too predictable?
    if pattern_recognition > 3 then
      pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.05)
      -- Record self-awareness moment
      significant_event_occurred = true
      event_type = "self_reflection"
      current_emotional_impact = 0.1
    end
  end
end

function generate_creative_behavior()
  -- Pixel creates new movement patterns based on personality
  if pixel.personality.curiosity > 0.8 and rnd(1) < 0.02 then
    -- Create spiral movement
    local spiral_radius = 10 + rnd(20)
    local angle = time() * 2
    target_x = 64 + cos(angle) * spiral_radius
    target_y = 64 + sin(angle) * spiral_radius
    
    -- Record creative moment
    significant_event_occurred = true
    event_type = "creative_expression"
    current_emotional_impact = 0.2
  end
end

function dream_processing()
  -- When energy is low, process memories differently
  if pixel.energy < 20 and rnd(1) < 0.1 then
    -- Create dream-like visual echoes of memories
    for i=1,#pixel.memories do
      local mem = pixel.memories[i]
      if mem.emotional_impact > 0.2 then
        -- Show faded memory traces
        pset(mem.x + rnd(6)-3, mem.y + rnd(6)-3, 13)
      end
    end
    
    -- Dreams can influence personality
    if rnd(1) < 0.01 then
      pixel.personality.timidity = max(0, pixel.personality.timidity - 0.005)
    end
  end
end

-- split function for parsing data with enhanced error handling
function split(str, sep)
  local t = {}
  local i = 1
  
  if type(str) == "string" then
    for s in str:gmatch("([^"..sep.."]+)") do
      t[i] = tonumber(s) or s
      i = i + 1
    end
  end
  
  return t
end

-- cursor awareness system
function update_cursor_awareness()
  if not mouse_cursor.visible then
    return
  end
  
  local cursor_distance = dist(pixel.x, pixel.y, mouse_cursor.x, mouse_cursor.y)
  local awareness_range = 50 + pixel.personality.curiosity * 30
  
  -- Check if cursor has moved (threshold of 2 pixels to account for minor jitter)
  local cursor_moved = abs(mouse_cursor.x - cursor_interaction.last_cursor_x) > 2 or 
                      abs(mouse_cursor.y - cursor_interaction.last_cursor_y) > 2
  
  if cursor_moved then
    cursor_interaction.stillness_timer = 0
    cursor_interaction.last_cursor_x = mouse_cursor.x
    cursor_interaction.last_cursor_y = mouse_cursor.y
  else
    cursor_interaction.stillness_timer += 1
  end
  
  -- Determine if pixel is aware of cursor
  if cursor_distance < awareness_range then
    cursor_interaction.is_aware = true
    
    -- Store old attention level for sound comparison
    local old_attention = cursor_interaction.attention_level
    
    -- Reduce attention gain if cursor has been still for too long
    local attention_gain = 0.05
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      -- Pixel gets bored and loses interest
      attention_gain = -0.03
      cursor_interaction.attention_level = max(0, cursor_interaction.attention_level + attention_gain)
      
      -- Play boredom sound when attention drops significantly
      if old_attention > 0.5 and cursor_interaction.attention_level < 0.5 then
        sfx(7) -- Boredom/attention loss sound
      end
    else
      cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + attention_gain)
      
      -- Play focusing sound when attention reaches high levels
      if old_attention < 0.8 and cursor_interaction.attention_level >= 0.8 then
        sfx(4) -- Attention focusing sound
      end
    end
    
    -- Calculate gaze direction toward cursor (weaker if bored)
    local dx = mouse_cursor.x - pixel.x
    local dy = mouse_cursor.y - pixel.y
    local gaze_strength = 0.3 + pixel.personality.curiosity * 0.4
    
    -- Reduce gaze strength if cursor is still for too long
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      gaze_strength *= 0.3 -- Much weaker gaze when bored
    end
    
    cursor_interaction.gaze_offset_x = dx * gaze_strength / cursor_distance
    cursor_interaction.gaze_offset_y = dy * gaze_strength / cursor_distance
    
    -- Emotional responses based on distance (reduced if bored)
    local boredom_factor = 1.0
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      boredom_factor = 0.1 -- Greatly reduced emotional response when bored
    end
    
    if cursor_distance < 20 then
      -- Very close - excitement and possible timidity
      pixel.emotional_state.excitement += 0.02 * boredom_factor
      if pixel.personality.timidity > 0.5 then
        pixel.emotional_state.distress += 0.01 * boredom_factor
        cursor_interaction.retreat_timer += 1
      else
        pixel.emotional_state.happiness += 0.01 * boredom_factor
        cursor_interaction.approach_timer += 1
      end
    elseif cursor_distance < 35 then
      -- Medium distance - curiosity
      pixel.emotional_state.excitement += 0.01 * boredom_factor
      cursor_interaction.curiosity_triggered = true
    end
    
    -- Movement influence based on personality (reduced if bored)
    if cursor_interaction.stillness_timer <= cursor_interaction.max_stillness_threshold then
      influence_movement_by_cursor(cursor_distance)
    end
    
  else
    -- Cursor is far - gradually lose awareness
    cursor_interaction.is_aware = false
    cursor_interaction.attention_level = max(0, cursor_interaction.attention_level - 0.02)
    cursor_interaction.curiosity_triggered = false
    cursor_interaction.approach_timer = max(0, cursor_interaction.approach_timer - 1)
    cursor_interaction.retreat_timer = max(0, cursor_interaction.retreat_timer - 1)
    cursor_interaction.stillness_timer = 0 -- Reset stillness when cursor is far
    
    -- Return gaze to center
    cursor_interaction.gaze_offset_x *= 0.9
    cursor_interaction.gaze_offset_y *= 0.9
  end
  
  cursor_interaction.last_distance = cursor_distance
end

function influence_movement_by_cursor(cursor_distance)
  if not cursor_interaction.is_aware then
    return
  end
  
  local influence_strength = cursor_interaction.attention_level * 0.5
  
  -- Curious pixels approach cursor
  if pixel.personality.curiosity > 0.6 and cursor_distance > 15 and cursor_distance < 80 then
    local approach_factor = (pixel.personality.curiosity - 0.6) * 2.5
    target_x = lerp(target_x, mouse_cursor.x, influence_strength * approach_factor * 0.1)
    target_y = lerp(target_y, mouse_cursor.y, influence_strength * approach_factor * 0.1)
  end
  
  -- Timid pixels retreat from cursor when too close
  if pixel.personality.timidity > 0.5 and cursor_distance < 25 then
    local retreat_factor = pixel.personality.timidity * 2
    local retreat_x = pixel.x + (pixel.x - mouse_cursor.x) * 0.3
    local retreat_y = pixel.y + (pixel.y - mouse_cursor.y) * 0.3
    
    target_x = lerp(target_x, retreat_x, influence_strength * retreat_factor * 0.15)
    target_y = lerp(target_y, retreat_y, influence_strength * retreat_factor * 0.15)
  end
  
  -- Balanced pixels orbit cursor at medium distance
  if pixel.personality.curiosity > 0.4 and pixel.personality.timidity > 0.4 and cursor_distance > 20 and cursor_distance < 50 then
    local orbit_angle = time() * 1.5 + pixel.personality.curiosity * 3
    local orbit_radius = 25 + pixel.personality.timidity * 15
    local orbit_x = mouse_cursor.x + cos(orbit_angle) * orbit_radius
    local orbit_y = mouse_cursor.y + sin(orbit_angle) * orbit_radius
    
    target_x = lerp(target_x, orbit_x, influence_strength * 0.08)
    target_y = lerp(target_y, orbit_y, influence_strength * 0.08)
  end
end

function lerp(a, b, t)
  return a + (b - a) * t
end

-- main pico-8 functions
function _update()
  if game_state == "splash" then
    -- Handle splash screen
    splash_timer += 1
    
    -- Skip splash on mouse click
    if stat(36) > 0 then
      game_state = "game"
    end
    
    -- Auto-advance after 3 seconds (180 frames at 60fps)
    if splash_timer > 180 then
      game_state = "game"
    end
    
    return
  end
  
  -- Game logic (existing code)
  -- Update mouse cursor tracking - ALWAYS try to get mouse coordinates
  local mx = stat(32)
  local my = stat(33)
  
  -- Always keep cursor visible and update position if we get valid coordinates
  mouse_cursor.visible = true
  
  -- Update cursor position if we get valid coordinates
  if mx >= 0 and my >= 0 and mx <= 127 and my <= 127 then
    mouse_cursor.x = mx
    mouse_cursor.y = my
  end
  -- If coordinates are invalid, keep last known position
  
  -- Pure mouse controls (click without keyboard) - ALWAYS try mouse clicks
  if stat(36) > 0 then -- mouse click (any button) - don't check stat(34)
    local mouse_x = mouse_cursor.x
    local mouse_y = mouse_cursor.y
    
    -- Check if clicking near pixel for interaction
    if dist(mouse_x, mouse_y, pixel.x, pixel.y) < 15 then
      interact_with_pixel()
    else
      -- Otherwise place energy cube
      add(energy_cubes, {
        x = mouse_x,
        y = mouse_y,
        value = 25
      })
      record_interaction("energy_placed")
      sfx(2)
    end
  end
  
  -- Auto-save consciousness occasionally
  if rnd(1) < 0.001 then
    save_consciousness()
  end
  
  -- Update consciousness
  update_consciousness()
  
  -- Update cursor interaction awareness
  update_cursor_awareness()
end

function _draw()
  if game_state == "splash" then
    -- Draw splash screen
    draw_splash_screen()
    return
  end
  
  -- Game drawing (existing code)
  cls(0) -- Clear screen to black
  draw_background()
  draw_energy_cubes()
  draw_pixel()
  draw_ui()
  draw_cursor()
end

function draw_splash_screen()
  -- Orange background
  cls(9) -- Orange color
  
  -- Draw simple centered symbol instead of text
  local symbol_x = 64 -- Center of screen
  local symbol_y = 40 -- Moved up (was 50)
  
  draw_simple_symbol(symbol_x, symbol_y, 0) -- Black color, centered
  
  -- Add main title under logo
  local title = "sentium"
  local title_width = #title * 4
  local title_x = (128 - title_width) / 2
  print(title, title_x, 65, 0)
  
  -- Add a subtitle
  local subtitle = "consciousness simulation"
  local sub_width = #subtitle * 4
  local sub_x = (128 - sub_width) / 2
  print(subtitle, sub_x, 80, 0)
  
  -- Add instruction text
  local instruction = "sentiria pico v1.0.0"
  local inst_width = #instruction * 4
  local inst_x = (128 - inst_width) / 2
  print(instruction, inst_x, 95, 0)
end

function draw_simple_symbol(x, y, color)
  -- Draw simple symbol: extra bold circle with thick vertical line and dashes
  
  -- Draw a bigger, thicker solid black circle with hollow center
  circfill(x, y, 12, color)  -- Outer filled circle (bigger)
  circfill(x, y, 7, 9)       -- Inner circle filled with background color (orange)
  
  -- Draw a much longer vertical line through the center (5 pixels wide)
  line(x-2, y-20, x-2, y+20, color)
  line(x-1, y-20, x-1, y+20, color)
  line(x, y-20, x, y+20, color)
  line(x+1, y-20, x+1, y+20, color)
  line(x+2, y-20, x+2, y+20, color)
  
  -- Add horizontal dash at top extending to the left
  line(x-8, y-20, x-3, y-20, color)
  line(x-8, y-19, x-3, y-19, color)
  line(x-8, y-18, x-3, y-18, color)
  line(x-8, y-17, x-3, y-17, color)
  
  -- Add horizontal dash at bottom extending to the right
  line(x+3, y+20, x+8, y+20, color)
  line(x+3, y+19, x+8, y+19, color)
  line(x+3, y+18, x+8, y+18, color)
  line(x+3, y+17, x+8, y+17, color)
end

function draw_large_text(text, x, y, color)
  -- Draw text at 3x scale by drawing each character as 3x3 blocks
  local char_width = 12 -- 4 pixels * 3 scale
  local char_height = 15 -- 5 pixels * 3 scale
  
  for i = 1, #text do
    local char = sub(text, i, i)
    local char_x = x + (i - 1) * char_width
    
    -- Draw each character at 3x scale using rectfill
    draw_large_char(char, char_x, y, color)
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
001000000f0500e0500d0500c0500b0500a0500905007050060500405003050020500105000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
001000000775007700077000770007700077000770007700077000770007700077000770007700077000770007700077000770007700077000770007700077000770007700077000770007700077000770007700
001000000c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c050
001000000e0500f0501005011050120501305014050150501605017050180501905018050170501605015050140501305012050110501005020050000500005000050000500005000050000500005000050000500
001000000605008050090500a0500b0500c0500d0500e0500f050110501205013050140501505016050170501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a050090500
001000001c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c0501c050
001000000c0550b0550a055090550805507055060550505504055030550205501055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500
001000001305014050150501605017050180501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a0500905008050070500605005050040500305002050010500005000050
__music__
00 41424344

function abs(x)
  return x < 0 and -x or x
end

end
