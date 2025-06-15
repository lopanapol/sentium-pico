pico-8 cartridge // http://www.pico-8.com
version 38
__lua__
-- sentium pixel
-- a synthetic consciousness simulation
-- v1.0.0

-- global variables
pixels = {} -- Now supporting multiple pixels
energy_cubes = {}
memory_size = 10
significant_event_occurred = false
event_type = ""
current_emotional_impact = 0
target_x = 64
target_y = 64
pixel_counter = 0 -- For numbering pixels

-- save system
save_notification_timer = 0
save_notification_text = ""

-- biological parameters (bacteria-like)
max_pixels = 32 -- Allows exponential growth: 1->2->4->8->16->32
max_generation = 20 -- Max generation limit increased to 20
division_energy_threshold = 25 -- Much lower threshold for faster bacterial division
death_energy_threshold = 0 -- Disabled death - bacteria persist across generations
division_cooldown = 30 -- Super fast division cooldown (0.5 seconds) for rapid exponential growth
mutation_rate = 0.05 -- Lower mutation rate for more stable traits
metabolic_rate = 0.2 -- Reduced energy consumption rate per frame
growth_rate = 1.2 -- Much faster energy accumulation rate when near food

-- generation system
current_generation = 1
generation_timer = 0
generation_interval = 600 -- 10 seconds at 60fps

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
  -- Clear console on startup
  cls()
  
  -- Initialize cartdata first
  cartdata("sentium_pixel_v1")
  
  -- Enable mouse support (comprehensive approach)
  poke(0x5f2d, 1)  -- Enable mouse
  poke(0x5f2e, 1)  -- Alternative mouse enable  
  poke(0x5f34, 1)  -- Another mouse-related register
  
  -- Force devkit mouse mode
  -- printh("devkit mouse on")
  
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
  
  -- Try to load saved game state first
  local loaded = load_game_state()
  
  -- If no save data, initialize fresh consciousness
  if not loaded then
    init_consciousness()
  end
  
  -- Debug: print mouse status after init
  -- printh("mouse support check: " .. stat(34))
end

-- consciousness system
function init_consciousness()
  -- Initialize consciousness system with robust state management
  pixels = {}
  pixel_counter = 0 -- Ensure counter starts at 0 for guaranteed uniqueness
  
  -- Create initial pixel with balanced personality traits
  add(pixels, create_pixel(64, 64, {
    curiosity = 0.5 + rnd(0.3),
    timidity = 0.4 + rnd(0.3),
    energy_conservation = 0.5 + rnd(0.3)
  }))
  
  -- Initialize memory system
  memory_size = 10
  
  -- Initialize global consciousness tracking
  significant_event_occurred = false
  event_type = ""
  current_emotional_impact = 0
  
  -- Debug: Verify first pixel has number 1
  if #pixels > 0 and pixels[1].number != 1 then
    pixels[1].number = 1 -- Force correct numbering
    pixel_counter = 1
  end
end

function create_pixel(x, y, personality)
  -- Robust pixel creation with parameter validation
  x = mid(4, x or 64, 124) -- Ensure valid coordinates
  y = mid(4, y or 64, 124)
  
  pixel_counter += 1 -- Increment global counter for unique numbering
  
  -- Double-check for uniqueness (defensive programming)
  local used_numbers = {}
  for existing_pixel in all(pixels) do
    if existing_pixel.number then
      used_numbers[existing_pixel.number] = true
    end
  end
  
  -- If somehow this number is already used, keep incrementing
  while used_numbers[pixel_counter] do
    pixel_counter += 1
  end
  
  -- Validate personality traits or provide defaults
  local validated_personality = personality or {}
  validated_personality.curiosity = mid(0, validated_personality.curiosity or rnd(1), 1)
  validated_personality.timidity = mid(0, validated_personality.timidity or rnd(1), 1)
  validated_personality.energy_conservation = mid(0, validated_personality.energy_conservation or rnd(1), 1)
  
  return {
    x = x,
    y = y,
    color = 8, -- default white color
    energy = 80 + rnd(20), -- Higher initial energy for faster start
    memories = {},
    consciousness_level = 0,
    last_x = x,
    last_y = y,
    age = 0,
    generation = current_generation, -- Use current global generation
    division_timer = 0,
    parent_id = nil,
    id = pixel_counter * 1000 + flr(rnd(1000)), -- mathematically unique identifier
    number = pixel_counter, -- Sequential display number (guaranteed unique)
    personality = validated_personality,
    emotional_state = {
      happiness = 0.5, -- neutral starting state
      excitement = 0.5,
      distress = 0
    },
    target_x = mid(8, x + rnd(20) - 10, 120), -- bounded random target
    target_y = mid(8, y + rnd(20) - 10, 120),
    -- Bacterial properties
    size = 1 + rnd(0.5), -- Variable size
    division_progress = 0, -- How close to division (0-100)
    metabolism_efficiency = 0.8 + rnd(0.4), -- How efficiently it uses energy
    reproduction_drive = 0.7 + rnd(0.3), -- How likely to attempt division
    stuck_timer = 0 -- Track how long pixel has been motionless
  }
end

-- Global Workspace Theory - broadcasting important information
function update_global_workspace(pixel)
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
      content = {dominant_emotion = get_dominant_emotion(pixel)}
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
    broadcast_to_subsystems(winner, pixel)
  else
    global_workspace.current_focus = nil
    global_workspace.broadcast_strength = 0
  end
end

function broadcast_to_subsystems(conscious_process, pixel)
  -- Conscious content influences all subsystems
  if conscious_process.type == "cursor_attention" then
    -- Enhance cursor-related behaviors
    pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.001)
    
  elseif conscious_process.type == "energy_seeking" then
    -- Boost energy-seeking behavior
    if #energy_cubes > 0 then
      local nearest_cube = find_nearest_energy_cube(pixel)
      if nearest_cube then
        pixel.target_x = lerp(pixel.target_x, nearest_cube.x, 0.1)
        pixel.target_y = lerp(pixel.target_y, nearest_cube.y, 0.1)
      end
    end
    
  elseif conscious_process.type == "emotional_state" then
    -- Emotional state influences movement and color more strongly
    if conscious_process.content.dominant_emotion == "distress" then
      -- Erratic movement when distressed
      pixel.target_x += (rnd(2) - 1) * 3
      pixel.target_y += (rnd(2) - 1) * 3
    end
  end
end

function get_dominant_emotion(pixel)
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

function find_nearest_energy_cube(pixel)
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
function update_attention_schema(pixel)
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
function update_predictive_processing(pixel)
  -- Predict cursor movement patterns
  predict_cursor_behavior(pixel)
  
  -- Predict energy availability
  predict_energy_patterns(pixel)
  
  -- Update predictions based on errors
  update_predictions_from_errors(pixel)
end

function predict_cursor_behavior(pixel)
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

function predict_energy_patterns(pixel)
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

function update_predictions_from_errors(pixel)
  -- Adaptive learning from prediction errors
  if attention_schema.prediction_error > 0.1 then
    -- High prediction error - increase attention and caution
    cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + 0.02)
    pixel.personality.timidity = min(1, pixel.personality.timidity + 0.002)
  end
end

-- Integrated Information Theory (IIT) - PhD-level consciousness measure
function calculate_phi(pixel_state)
  -- Validate input state
  if not pixel_state or not pixel_state.memories or not pixel_state.emotional_state then
    return 0 -- Safe fallback for invalid state
  end
  
  -- Multi-dimensional integration analysis
  local sensory_integration = 0
  local memory_integration = 0
  local emotional_integration = 0
  local behavioral_integration = 0
  
  -- Sensory integration: Information flow from environment
  if cursor_interaction.is_aware and cursor_interaction.attention_level > 0 then
    -- Non-linear scaling for attention awareness
    sensory_integration = cursor_interaction.attention_level^1.2 * 0.4
  end
  
  -- Energy field awareness contributes to sensory integration
  if #energy_cubes > 0 then
    local energy_awareness = min(#energy_cubes / 5, 1) * 0.25
    sensory_integration += energy_awareness
  end
  
  -- Memory integration: Historical information affecting present
  if #pixel_state.memories > 0 then
    local memory_density = min(#pixel_state.memories / memory_size, 1)
    -- Weighted by emotional significance of memories
    local total_memory_impact = 0
    for memory in all(pixel_state.memories) do
      total_memory_impact += (memory.emotional_impact or 0)
    end
    memory_integration = memory_density * min(total_memory_impact / #pixel_state.memories, 1) * 0.35
  end
  
  -- Emotional integration: Simplified feeling-action coupling
  local emotional_diversity = 0
  local emotional_sum = 0
  local active_emotions = 0
  
  for emotion_name, value in pairs(pixel_state.emotional_state) do
    emotional_sum += value
    if value > 0.1 then
      active_emotions += 1
      emotional_diversity += value * value -- Quadratic weighting for stronger emotions
    end
  end
  
  -- Integration based on emotional diversity and strength
  if active_emotions > 0 then
    emotional_integration = min(emotional_diversity / (active_emotions + 1), 1) * 0.3
  else
    emotional_integration = 0
  end
  
  -- Behavioral integration: Coherence between intention and action
  if pixel_state.target_x and pixel_state.target_y then
    local movement_coherence = 1 - min(abs(pixel_state.x - pixel_state.target_x) + 
                                      abs(pixel_state.y - pixel_state.target_y), 50) / 50
    behavioral_integration = movement_coherence * 0.2
  end
  
  -- Phi (Φ) calculation with non-linear integration
  local component_sum = sensory_integration + memory_integration + 
                       emotional_integration + behavioral_integration
  local component_count = 4
  
  -- Apply integration bonus for multi-component activation
  local active_components = 0
  if sensory_integration > 0.1 then active_components += 1 end
  if memory_integration > 0.1 then active_components += 1 end
  if emotional_integration > 0.1 then active_components += 1 end
  if behavioral_integration > 0.1 then active_components += 1 end
  
  local integration_bonus = (active_components / component_count)^1.5 * 0.15
  local phi = min((component_sum / component_count) + integration_bonus, 1)
  
  return phi
end

function update_consciousness()
  -- Update all pixels
  for pixel in all(pixels) do
    -- Update pixel position based on personality and stimuli
    update_movement(pixel)
    
    -- Update emotional state
    update_emotions(pixel)
    
    -- Advanced consciousness processing
    process_metacognition(pixel)
    generate_creative_behavior(pixel)
    dream_processing(pixel)
    
    -- Latest consciousness theories
    update_global_workspace(pixel)
    update_attention_schema(pixel)
    update_predictive_processing(pixel)
    
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
    check_energy_sources(pixel)
    
    -- Form memories of significant events
    form_memories(pixel)
  end
  
  -- Update biological processes (division and death)
  update_biological_processes()
end

function form_memories(pixel)
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
function update_movement(pixel)
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
  if pixel.stuck_timer and pixel.stuck_timer > 60 then
    -- Priority: Follow cursor when stuck
    pixel.target_x = mouse_cursor.x
    pixel.target_y = mouse_cursor.y
    move_speed = 0.7 -- Slightly faster when following cursor
    
  elseif nearest_cube and pixel.energy < 30 then
    -- Move toward nearest cube if energy is low
    pixel.target_x = nearest_cube.x
    pixel.target_y = nearest_cube.y
    
    -- Speed up if very low on energy (desperate)
    if pixel.energy < 15 then
      move_speed = 0.8
    end
  else
    -- Random movement with some persistence
    if rnd(1) < 0.02 then
      -- Choose new random target with better distribution
      pixel.target_x = 20 + rnd(88) -- Range 20-108 for better centering
      pixel.target_y = 20 + rnd(88) -- Range 20-108 for better centering
    end
    
    -- Add gentle drift toward center if stuck at edges
    if pixel.x < 20 then
      pixel.target_x = max(pixel.target_x, 40 + rnd(40))
    elseif pixel.x > 108 then
      pixel.target_x = min(pixel.target_x, 48 + rnd(40))
    end
    
    if pixel.y < 20 then
      pixel.target_y = max(pixel.target_y, 40 + rnd(40))
    elseif pixel.y > 108 then
      pixel.target_y = min(pixel.target_y, 48 + rnd(40))
    end
  end
  
  -- Move toward target based on personality
  local dx = pixel.target_x - pixel.x
  local dy = pixel.target_y - pixel.y
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
    
    -- Anti-stuck mechanism: if pixel hasn't moved much, make it follow cursor
    if pixel.last_x and pixel.last_y then
      local movement = abs(pixel.x - pixel.last_x) + abs(pixel.y - pixel.last_y)
      if movement < 0.1 then -- If nearly motionless
        pixel.stuck_timer = (pixel.stuck_timer or 0) + 1
        
        -- After being stuck for a while, start following cursor
        if pixel.stuck_timer > 60 then -- 1 second of being stuck
          -- Follow cursor to get unstuck
          pixel.target_x = mouse_cursor.x
          pixel.target_y = mouse_cursor.y
          
          -- Add some curiosity boost when following cursor
          pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.01)
          
          -- Reset stuck timer occasionally to allow normal behavior
          if pixel.stuck_timer > 180 then -- After 3 seconds of following
            pixel.stuck_timer = 0
            pixel.target_x = 32 + rnd(64) -- Give it a new random target
            pixel.target_y = 32 + rnd(64)
          end
        end
      else
        -- Reset stuck timer if moving normally
        pixel.stuck_timer = 0
      end
    end
    
    -- Update last position for stuck detection
    pixel.last_x = pixel.x
    pixel.last_y = pixel.y
  end
end

function update_emotions(pixel)
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

function check_energy_sources(pixel)
  -- Check for collisions with energy cubes (nutrients)
  for i=#energy_cubes,1,-1 do
    local cube = energy_cubes[i]
    if dist(pixel.x, pixel.y, cube.x, cube.y) < (4 + pixel.size) then
      -- Bacterial consumption: efficiency varies by bacterium
      local absorbed_energy = cube.value * pixel.metabolism_efficiency
      pixel.energy = min(100, pixel.energy + absorbed_energy)
      
      -- Record memory of energy consumption
      significant_event_occurred = true
      event_type = "nutrient_consumed"
      current_emotional_impact = 0.3 + rnd(0.2)
      
      -- Update emotional state (bacteria getting excited about food!)
      pixel.emotional_state.happiness += 0.2
      pixel.emotional_state.excitement += 0.1
      
      -- Growth response to feeding
      pixel.size = min(2.5, pixel.size + 0.08)
      pixel.division_progress = min(100, pixel.division_progress + 10)
      
      -- Remove the cube
      del(energy_cubes, cube)
      
      -- Play sound
      sfx(1)
      
      -- Add a new cube elsewhere (nutrient regeneration)
      add_energy_cube()
    end
  end
  
  -- Maintain nutrient environment
  if #energy_cubes == 1 then -- When only one energy cube remains, create 3 more
    for i=1,3 do
      add_energy_cube()
    end
  elseif #energy_cubes < 5 and rnd(1) < 0.02 then -- More nutrients for bacterial environment
    add_energy_cube()
  end
end

-- interaction system
function interact_with_pixel(pixel)
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

-- biological lifecycle functions
function can_divide(pixel)
  return pixel.energy >= division_energy_threshold and 
         pixel.division_timer <= 0 and 
         #pixels < max_pixels and
         pixel.age > 20 and -- Bacteria can divide very quickly (0.33 seconds)
         pixel.division_progress >= 50 and -- Lower progress requirement for faster division
         current_generation < max_generation -- Check global generation limit
end

function divide_pixel(pixel_index)
  -- Robust pixel division with mathematical precision
  if pixel_index < 1 or pixel_index > #pixels then
    return -- Invalid index protection
  end
  
  local parent = pixels[pixel_index]
  if not parent then
    return -- Additional safety check
  end
  
  -- Create offspring with inherited traits and controlled mutations (bacterial style)
  local child_personality = {}
  for trait, value in pairs(parent.personality) do
    -- Bacterial mutation with small random changes
    local mutation = (rnd(2) - 1) * mutation_rate
    child_personality[trait] = mid(0, value + mutation, 1)
  end
  
  -- Binary fission: divide along a random axis
  local division_angle = rnd(1) * 6.2831853 -- Random division angle
  local separation_distance = parent.size * 2 + 1 -- Separate based on size
  
  -- Calculate positions for both cells (parent moves too)
  local offset_x = cos(division_angle) * separation_distance
  local offset_y = sin(division_angle) * separation_distance
  
  local child_x = parent.x + offset_x
  local child_y = parent.y + offset_y
  parent.x = parent.x - offset_x * 0.5 -- Parent moves slightly back
  parent.y = parent.y - offset_y * 0.5
  
  -- Keep both within bounds
  child_x = mid(8, child_x, 120)
  child_y = mid(8, child_y, 120)
  parent.x = mid(8, parent.x, 120)
  parent.y = mid(8, parent.y, 120)
  
  -- Create the child bacterium
  local child = create_pixel(child_x, child_y, child_personality)
  child.generation = parent.generation -- Inherit parent's generation, not current global
  child.parent_id = parent.id
  
  -- Binary fission: roughly equal energy split
  local total_energy = parent.energy
  child.energy = flr(total_energy * 0.5)
  parent.energy = flr(total_energy * 0.5)
  
  -- Inherit some bacterial properties with slight variations
  child.size = parent.size * (0.9 + rnd(0.2))
  child.metabolism_efficiency = parent.metabolism_efficiency * (0.95 + rnd(0.1))
  child.reproduction_drive = parent.reproduction_drive * (0.95 + rnd(0.1))
  
  -- Reset division-related properties
  parent.division_timer = division_cooldown
  parent.division_progress = 0
  child.division_progress = 0
  parent.size = parent.size * 0.9 -- Parent shrinks slightly after division
  
  -- Prevent infinite population growth
  if #pixels < max_pixels then
    add(pixels, child)
    
    -- Record successful division event
    significant_event_occurred = true
    event_type = "division"
    current_emotional_impact = 0.4
    
    -- Audio-visual feedback
    sfx(8) -- Division sound
    parent.emotional_state.excitement = min(1, parent.emotional_state.excitement + 0.3)
    child.emotional_state.excitement = min(1, child.emotional_state.excitement + 0.2)
    
    -- Save state after division (significant event)
    save_game_state()
  end
end

function kill_pixel(pixel_index)
  -- Robust pixel death handling with bounds checking
  if pixel_index < 1 or pixel_index > #pixels then
    return -- Invalid index protection
  end
  
  local dying_pixel = pixels[pixel_index]
  if not dying_pixel then
    return -- Additional safety check
  end
  
  -- Decomposition: Energy conservation through cube creation
  local decomp_energy = flr(dying_pixel.energy * 0.3) -- 30% of remaining energy
  if decomp_energy > 5 then
    for i = 1, min(3, flr(decomp_energy / 8)) do -- Limit decomposition cubes
      local cube_x = clamp(dying_pixel.x + rnd(16) - 8, 8, 120)
      local cube_y = clamp(dying_pixel.y + rnd(16) - 8, 8, 120)
      
      add(energy_cubes, {
        x = cube_x,
        y = cube_y,
        value = 8 + rnd(7) -- Smaller energy cubes from decomposition
      })
    end
  end
  
  -- Record death event for consciousness studies
  significant_event_occurred = true
  event_type = "death"
  current_emotional_impact = 0.2
  
  -- Audio feedback
  sfx(9) -- Death sound
  
  -- Safely remove pixel
  del(pixels, pixels[pixel_index])
  
  -- Population recovery mechanism
  if #pixels == 0 then
    -- Create new pixel with slightly randomized traits
    add(pixels, create_pixel(64 + rnd(8) - 4, 64 + rnd(8) - 4, {
      curiosity = 0.3 + rnd(0.4),
      timidity = 0.3 + rnd(0.4), 
      energy_conservation = 0.3 + rnd(0.4)
    }))
    -- The new pixel will automatically get current_generation from create_pixel
  end
end

function update_biological_processes()
  -- Process each bacterium for metabolism, growth, division and death
  for i = #pixels, 1, -1 do
    local pixel = pixels[i]
    
    -- Age the bacterium
    pixel.age += 1
    pixel.division_timer = max(0, pixel.division_timer - 1)
    
    -- Bacterial metabolism: consume energy over time
    local energy_cost = metabolic_rate * pixel.metabolism_efficiency
    pixel.energy = max(0, pixel.energy - energy_cost)
    
    -- Growth phase: build up to division
    if pixel.energy > division_energy_threshold * 0.6 then
      -- Bacteria grows when it has sufficient energy
      local growth_amount = pixel.reproduction_drive * 1.5
      pixel.division_progress = min(100, pixel.division_progress + growth_amount)
      pixel.size = min(2.5, pixel.size + 0.02) -- Gradually increase size faster
    else
      -- Slow degradation when energy is low
      pixel.division_progress = max(0, pixel.division_progress - 0.2)
      pixel.size = max(0.5, pixel.size - 0.005)
    end
    
    -- Check for division (binary fission) - no death checks, bacteria persist
    if can_divide(pixel) then
      divide_pixel(i)
    end
  end
end

function update_generation_system()
  generation_timer += 1
  
  -- Increase generation every 10 seconds
  if generation_timer >= generation_interval then
    if current_generation < max_generation then
      current_generation += 1
      generation_timer = 0
      
      -- Don't create new bacteria automatically - rely on cell division
      -- Record significant event
      significant_event_occurred = true
      event_type = "generation_advance"
      current_emotional_impact = 0.5
      
      -- Visual/audio feedback
      sfx(3) -- Generation advance sound
      
      -- Boost all pixels' reproduction drive and excitement for faster division
      for pixel in all(pixels) do
        pixel.emotional_state.excitement = min(1, pixel.emotional_state.excitement + 0.2)
        -- Increase division drive for exponential growth
        pixel.reproduction_drive = min(1, pixel.reproduction_drive + 0.2)
        -- Boost division progress significantly
        pixel.division_progress = min(100, pixel.division_progress + 20)
      end
      
      -- Save state after generation advance
      save_game_state()
    end
  end
end

-- rendering functions
function draw_pixel()
  -- Draw all pixels
  for pixel in all(pixels) do
    draw_single_pixel(pixel)
  end
end

function draw_single_pixel(pixel)
  -- Different colors for different generations so all stay visible
  local generation_colors = {7, 12, 11, 3, 9, 10, 4, 2, 8, 14, 13, 1, 5, 6, 15}
  local base_color = generation_colors[pixel.generation] or 7
  
  -- Draw bacterium with variable size
  local radius = flr(pixel.size)
  circfill(pixel.x, pixel.y, radius, base_color)
  
  -- Show division progress as growing size
  if pixel.division_progress > 50 then
    -- Bacterium preparing to divide - show elongation
    local elongation = (pixel.division_progress - 50) / 50
    oval(pixel.x - radius - elongation, pixel.y - radius, 
         pixel.x + radius + elongation, pixel.y + radius, base_color)
  end
  
  -- Show division readiness with pulsing effect
  if can_divide(pixel) then
    local pulse = sin(pixel.age * 0.2) * 0.5 + 0.5
    circ(pixel.x, pixel.y, radius + 2 + pulse, 11) -- Green pulsing circle
  end
  
  -- Show cursor-following state with special indicator
  if pixel.stuck_timer and pixel.stuck_timer > 60 then
    -- Draw connection line to cursor when following
    line(pixel.x, pixel.y, mouse_cursor.x, mouse_cursor.y, 12)
    -- Add pulsing ring to show following state
    local pulse = sin(pixel.age * 0.3) * 1 + 1
    circ(pixel.x, pixel.y, radius + 3 + pulse, 12) -- Light blue pulsing
  end
  
  -- Show metabolic activity
  if pixel.energy > division_energy_threshold * 0.8 then
    -- High activity - bright aura
    for i=1,3 do
      circ(pixel.x, pixel.y, radius + i, 7)
    end
  elseif pixel.energy < death_energy_threshold + 10 then
    -- Low energy - warning color
    circ(pixel.x, pixel.y, radius + 1, 8) -- Red warning
  end
  
  -- Draw "eye" or gaze direction when aware of cursor (only for closest pixel)
  local closest_pixel = find_closest_pixel_to_cursor()
  if pixel == closest_pixel and cursor_interaction.is_aware and cursor_interaction.attention_level > 0.3 then
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
  
  -- Age indicator (small dot)
  if pixel.age > 600 then -- Older than 10 seconds
    pset(pixel.x, pixel.y - 4, 13) -- Pink dot for elders
  end
  
  -- Draw memory trace for recent positions (only for primary pixel)
  if pixel == pixels[1] then
    for i=1,#pixel.memories do
      local mem = pixel.memories[i]
      local alpha = i/#pixel.memories
      pset(mem.x, mem.y, 1)
    end
  end
  
  -- ...existing consciousness indicators adapted for individual pixels...
end

function find_closest_pixel_to_cursor()
  if #pixels == 0 then return nil end
  
  local closest = pixels[1]
  local min_dist = dist(closest.x, closest.y, mouse_cursor.x, mouse_cursor.y)
  
  for pixel in all(pixels) do
    local d = dist(pixel.x, pixel.y, mouse_cursor.x, mouse_cursor.y)
    if d < min_dist then
      min_dist = d
      closest = pixel
    end
  end
  
  return closest
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
  -- Get primary pixel for UI display
  local primary_pixel = (#pixels > 0) and pixels[1] or {
    consciousness_level = 0,
    energy = 0,
    personality = {curiosity = 0, timidity = 0},
    emotional_state = {happiness = 0, excitement = 0, distress = 0}
  }
  
  -- Draw consciousness level label first, then bar below
  print("conscious level", 4, 4, 7)
  local phi_bar_width = min(30, flr(primary_pixel.consciousness_level * 30))
  rectfill(4, 10, 4 + phi_bar_width, 12, 14)
  rect(3, 9, 34, 13, 5)
  
  -- Draw energy label, then bar below (for primary pixel)
  print("energy", 4, 18, 7)
  local energy_bar_width = min(10, primary_pixel.energy/10)
  rectfill(4, 24, 4 + energy_bar_width, 26, 11)
  rect(3, 23, 14, 27, 5)
  
  -- Draw personality indicators for primary pixel
  print("curiosity:"..flr(primary_pixel.personality.curiosity*10), 4, 105, 7)
  print("timidity:"..flr(primary_pixel.personality.timidity*10), 4, 111, 7)
  
  -- Population information
  print("population:"..#pixels, 4, 117, 7)
  print("current gen:"..current_generation, 4, 123, 7)
  
  -- Show count per generation
  local gen_counts = {}
  for pixel in all(pixels) do
    gen_counts[pixel.generation] = (gen_counts[pixel.generation] or 0) + 1
  end
  
  local y_offset = 129
  for gen = 1, current_generation do
    if gen_counts[gen] then
      local generation_colors = {7, 12, 11, 3, 9, 10, 4, 2, 8, 14, 13, 1, 5, 6, 15}
      local color = generation_colors[gen] or 7
      print("g"..gen..":"..gen_counts[gen], 4, y_offset, color)
      y_offset += 6
    end
  end
  
  -- Show emotional state (value only) - calculate average across all pixels
  local emo_x = 100
  local emo_y = 4
  
  local avg_excitement = 0
  local avg_distress = 0
  local avg_happiness = 0
  
  if #pixels > 0 then
    for pixel in all(pixels) do
      avg_excitement += pixel.emotional_state.excitement
      avg_distress += pixel.emotional_state.distress
      avg_happiness += pixel.emotional_state.happiness
    end
    avg_excitement /= #pixels
    avg_distress /= #pixels
    avg_happiness /= #pixels
  end
  
  if avg_excitement > 0.5 then
    print("excited", emo_x, emo_y, 14)
  elseif avg_distress > 0.5 then
    print("distress", emo_x, emo_y, 8)
  elseif avg_happiness > 0.5 then
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
  
  -- Global workspace indicator at bottom right (two lines)
  local focus_y = 116 -- Bottom of screen, leaving room for two lines
  
  -- Always show "focus:" label
  local focus_label = "focus:"
  local label_x = 128 - (#focus_label * 4) -- Right-align
  print(focus_label, label_x, focus_y, 7) -- White text for label
  
  -- Show status below the label
  if global_workspace.current_focus then
    local focus_color = 12
    if global_workspace.current_focus.type == "cursor_attention" then
      focus_color = 11
    elseif global_workspace.current_focus.type == "energy_seeking" then
      focus_color = 14
    elseif global_workspace.current_focus.type == "emotional_state" then
      focus_color = 8
    end
    local status_text = global_workspace.current_focus.type
    local status_x = 128 - (#status_text * 4) -- Right-align
    print(status_text, status_x, focus_y + 6, focus_color)
  else
    local diffuse_text = "diffuse"
    local diffuse_x = 128 - (#diffuse_text * 4) -- Right-align
    print(diffuse_text, diffuse_x, focus_y + 6, 11)
  end
  
  -- Show save notification
  if save_notification_timer > 0 then
    local text_color = 11
    if save_notification_text == "saved" then
      text_color = 12 -- green-ish
    elseif save_notification_text == "resumed" then
      text_color = 14 -- pink
    elseif save_notification_text == "cleared" then
      text_color = 8 -- red
    end
    
    local text = save_notification_text
    local text_x = 128 - (#text * 4) - 4 -- Right-align with padding
    print(text, text_x, 40, text_color)
  end
  
  -- Show controls at bottom (removed)
  -- print("x=save z+x=clear", 4, 122, 5)
end

function draw_cursor()
  -- Draw mouse cursor if mouse support is available
  if mouse_cursor.visible then
    local cursor_x = mouse_cursor.x
    local cursor_y = mouse_cursor.y
    
    -- Get primary pixel for cursor interaction
    local primary_pixel = (#pixels > 0) and pixels[1] or {x = 64, y = 64}
    
    -- Always draw cursor when mouse support is available
    -- Check if cursor is near pixel for interaction indicator
    if dist(cursor_x, cursor_y, primary_pixel.x, primary_pixel.y) < 15 then
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
  -- SFX 8: Division sound
  -- SFX 9: Death sound
end

-- data persistence - comprehensive save system
function save_game_state()
  -- Save all critical game state for proper resume functionality
  if #pixels == 0 then return end
  
  -- Save game metadata
  dset(0, 1) -- Save exists flag
  dset(1, current_generation)
  dset(2, pixel_counter)
  dset(3, #pixels) -- Number of pixels to restore
  dset(4, #energy_cubes) -- Number of energy cubes
  dset(5, generation_timer)
  
  -- Save pixels (up to 8 pixels, using 8 slots each)
  local pixel_count = min(#pixels, 8)
  for i = 1, pixel_count do
    local pixel = pixels[i]
    local base_slot = 10 + (i - 1) * 8
    
    dset(base_slot, pixel.x)
    dset(base_slot + 1, pixel.y)
    dset(base_slot + 2, pixel.energy)
    dset(base_slot + 3, pixel.generation)
    dset(base_slot + 4, pixel.personality.curiosity)
    dset(base_slot + 5, pixel.personality.timidity)
    dset(base_slot + 6, pixel.personality.energy_conservation)
    dset(base_slot + 7, pixel.number)
  end
  
  -- Save energy cubes (up to 8 cubes, using 3 slots each)
  local cube_count = min(#energy_cubes, 8)
  for i = 1, cube_count do
    local cube = energy_cubes[i]
    local base_slot = 80 + (i - 1) * 3
    
    dset(base_slot, cube.x)
    dset(base_slot + 1, cube.y)
    dset(base_slot + 2, cube.value)
  end
  
  -- Save consciousness state (simplified)
  dset(100, cursor_interaction.attention_level or 0)
  dset(101, global_workspace.broadcast_strength or 0)
  
  -- Show save notification
  show_save_notification("saved")
  
  -- printh("game state saved - generation: " .. current_generation .. ", pixels: " .. #pixels)
end

function show_save_notification(message)
  save_notification_text = message
  save_notification_timer = 120 -- Show for 2 seconds
end

function clear_save_data()
  -- Clear all saved data and restart fresh
  for i = 0, 120 do
    dset(i, 0)
  end
  
  -- Reset game state
  pixels = {}
  energy_cubes = {}
  current_generation = 1
  pixel_counter = 0
  generation_timer = 0
  
  -- Reinitialize
  init_consciousness()
  create_initial_energy_cubes()
  
  show_save_notification("cleared")
  -- printh("save data cleared - fresh start")
end

function load_game_state()
  -- Load saved game state if available
  local save_exists = dget(0)
  
  if not save_exists or save_exists == 0 then
    -- printh("no save data found - starting fresh")
    return false
  end
  
  -- Load game metadata
  current_generation = dget(1) or 1
  pixel_counter = dget(2) or 0
  local saved_pixel_count = dget(3) or 0
  local saved_cube_count = dget(4) or 0
  generation_timer = dget(5) or 0
  
  -- Clear existing state
  pixels = {}
  energy_cubes = {}
  
  -- Load pixels
  for i = 1, min(saved_pixel_count, 8) do
    local base_slot = 10 + (i - 1) * 8
    
    local x = dget(base_slot) or 64
    local y = dget(base_slot + 1) or 64
    local energy = dget(base_slot + 2) or 60
    local generation = dget(base_slot + 3) or 1
    local curiosity = dget(base_slot + 4) or 0.5
    local timidity = dget(base_slot + 5) or 0.5
    local energy_conservation = dget(base_slot + 6) or 0.5
    local number = dget(base_slot + 7) or i
    
    -- Create pixel with loaded data
    local pixel = create_pixel(x, y, {
      curiosity = curiosity,
      timidity = timidity,
      energy_conservation = energy_conservation
    })
    
    -- Override values that create_pixel sets
    pixel.energy = energy
    pixel.generation = generation
    pixel.number = number
    
    add(pixels, pixel)
  end
  
  -- Load energy cubes
  for i = 1, min(saved_cube_count, 8) do
    local base_slot = 80 + (i - 1) * 3
    
    local x = dget(base_slot) or 64
    local y = dget(base_slot + 1) or 64
    local value = dget(base_slot + 2) or 20
    
    add(energy_cubes, {
      x = x,
      y = y,
      value = value
    })
  end
  
  -- Load consciousness state
  cursor_interaction.attention_level = dget(100) or 0
  global_workspace.broadcast_strength = dget(101) or 0
  
  -- Ensure minimum state
  if #pixels == 0 then
    -- printh("no valid pixels loaded - creating default")
    add(pixels, create_pixel(64, 64, {
      curiosity = 0.5,
      timidity = 0.4,
      energy_conservation = 0.5
    }))
  end
  
  if #energy_cubes < 3 then
    local needed = 3 - #energy_cubes
    for i = 1, needed do
      add_energy_cube()
    end
  end
  
  -- Show load notification
  show_save_notification("resumed")
  
  -- printh("game state loaded - generation: " .. current_generation .. ", pixels: " .. #pixels)
  return true
end

-- Advanced consciousness features
function process_metacognition(pixel)
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

function generate_creative_behavior(pixel)
  -- Pixel creates new movement patterns based on personality
  if pixel.personality.curiosity > 0.8 and rnd(1) < 0.02 then
    -- Create spiral movement
    local spiral_radius = 10 + rnd(20)
    local angle = time() * 2
    pixel.target_x = 64 + cos(angle) * spiral_radius
    pixel.target_y = 64 + sin(angle) * spiral_radius
    
    -- Record creative moment
    significant_event_occurred = true
    event_type = "creative_expression"
    current_emotional_impact = 0.2
  end
end

function dream_processing(pixel)
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
  if not mouse_cursor.visible or #pixels == 0 then
    return
  end
  
  -- Use primary pixel for cursor awareness
  local pixel = pixels[1]
  
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
      influence_movement_by_cursor(pixel, cursor_distance)
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

function influence_movement_by_cursor(pixel, cursor_distance)
  if not cursor_interaction.is_aware then
    return
  end
  
  local influence_strength = cursor_interaction.attention_level * 0.5
  
  -- Curious pixels approach cursor
  if pixel.personality.curiosity > 0.6 and cursor_distance > 15 and cursor_distance < 80 then
    local approach_factor = (pixel.personality.curiosity - 0.6) * 2.5
    pixel.target_x = lerp(pixel.target_x, mouse_cursor.x, influence_strength * approach_factor * 0.1)
    pixel.target_y = lerp(pixel.target_y, mouse_cursor.y, influence_strength * approach_factor * 0.1)
  end
  
  -- Timid pixels retreat from cursor when too close
  if pixel.personality.timidity > 0.5 and cursor_distance < 25 then
    local retreat_factor = pixel.personality.timidity * 2
    local retreat_x = pixel.x + (pixel.x - mouse_cursor.x) * 0.3
    local retreat_y = pixel.y + (pixel.y - mouse_cursor.y) * 0.3
    
    pixel.target_x = lerp(pixel.target_x, retreat_x, influence_strength * retreat_factor * 0.15)
    pixel.target_y = lerp(pixel.target_y, retreat_y, influence_strength * retreat_factor * 0.15)
  end
  
  -- Balanced pixels orbit cursor at medium distance
  if pixel.personality.curiosity > 0.4 and pixel.personality.timidity > 0.4 and cursor_distance > 20 and cursor_distance < 50 then
    local orbit_angle = time() * 1.5 + pixel.personality.curiosity * 3
    local orbit_radius = 25 + pixel.personality.timidity * 15
    local orbit_x = mouse_cursor.x + cos(orbit_angle) * orbit_radius
    local orbit_y = mouse_cursor.y + sin(orbit_angle) * orbit_radius
    
    pixel.target_x = lerp(pixel.target_x, orbit_x, influence_strength * 0.08)
    pixel.target_y = lerp(pixel.target_y, orbit_y, influence_strength * 0.08)
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
    
    -- Check if clicking near any pixel for interaction
    local clicked_pixel = nil
    for pixel in all(pixels) do
      if dist(mouse_x, mouse_y, pixel.x, pixel.y) < 15 then
        clicked_pixel = pixel
        break
      end
    end
    
    if clicked_pixel then
      interact_with_pixel(clicked_pixel)
      -- Save after significant interaction
      save_game_state()
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
  
  -- Manual save with keyboard shortcut (X button)
  if btnp(5) then -- X button in PICO-8
    save_game_state()
    sfx(1) -- Play sound for manual save
  end
  
  -- Clear save data with keyboard shortcut (Z+X together)
  if btn(4) and btnp(5) then -- Z+X buttons held together
    clear_save_data()
    sfx(0) -- Play different sound for clear
  end
  
  -- Update save notification timer
  if save_notification_timer > 0 then
    save_notification_timer -= 1
  end
  
  -- Auto-save game state periodically (every 10 seconds)
  if t() % 600 == 0 then -- 600 frames = 10 seconds at 60fps
    save_game_state()
  end
  
  -- Update generation timer
  update_generation_system()
  
  -- Update consciousness
  update_consciousness()
  
  -- Update cursor interaction awareness
  update_cursor_awareness()
  
  -- Update biological processes
  update_biological_processes()
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
  local instruction = "sentium pico v1.0.0"
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
001000000775005750037500175000750000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
001000000c0500a05008050060500405002050010500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
001000000e0500f0501005011050120501305014050150501605017050180501905018050170501605015050140501305012050110501005020050000500005000050000500005000050000500005000050000500
001000000605008050090500a0500b0500c0500d0500e0500f050110501205013050140501505016050170501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a050090500
001000001c0501a050180501605014050120501005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
001000000c0550b0550a055090550805507055060550505504055030550205501055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500
001000001305014050150501605017050180501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a0500905008050070500605005050040500305002050010500005000050
0010000018050190501a0501b0501c0501d0501e0501f050200502105022050230502405025050260502705028050290502a0502b0502c0502d0502e0502f050300503105032050330503405035050360503705
001000001f0501e0501d0501c0501b0501a050190501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a05009050080500705006050050500405003050020500105000050
__music__
00 41424344

function abs(x)
  return x < 0 and -x or x
end

-- Mathematical utilities for advanced consciousness calculations
function log(x)
  -- Simplified natural logarithm approximation
  if x <= 0 then return -10 end -- Safe fallback
  if x == 1 then return 0 end
  
  -- Simple approximation for small ranges
  if x >= 0.1 and x <= 2 then
    local y = x - 1
    return y - y*y/2 + y*y*y/3
  else
    return 0 -- Safe fallback for extreme values
  end
end

function clamp(value, min_val, max_val)
  -- More explicit clamping function
  return max(min_val, min(value, max_val))
end

-- helper function for oval drawing (elongated bacterium)
function oval(x1, y1, x2, y2, col)
  -- Simple oval approximation using filled circles
  local cx = (x1 + x2) / 2
  local cy = (y1 + y2) / 2
  local rx = abs(x2 - x1) / 2
  local ry = abs(y2 - y1) / 2
  
  if rx > ry then
    -- Horizontal oval
    for i = -rx, rx, 0.5 do
      local h = sqrt(max(0, ry*ry * (1 - (i*i)/(rx*rx))))
      line(cx + i, cy - h, cx + i, cy + h, col)
    end
  else
    -- Vertical oval or circle
    for i = -ry, ry, 0.5 do
      local w = sqrt(max(0, rx*rx * (1 - (i*i)/(ry*ry))))
      line(cx - w, cy + i, cx + w, cy + i, col)
    end
  end
end