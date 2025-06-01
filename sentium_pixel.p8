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

-- initialization
function _init()
  init_consciousness()
  init_energy_system()
  create_initial_energy_cubes()
  load_sounds()
  load_consciousness()
end

-- consciousness system
function init_consciousness()
  pixel = {
    x = 64,
    y = 64,
    color = 8, -- default color
    energy = 100,
    memories = {},
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

function update_consciousness()
  -- Update pixel position based on personality and stimuli
  update_movement()
  
  -- Update emotional state
  update_emotions()
  
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
  -- Gradually return to baseline
  pixel.emotional_state.excitement *= 0.99
  pixel.emotional_state.happiness *= 0.99
  
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
  -- Calculate emotional impact based on pixel's current state
  local emotional_impact = 0.2 + rnd(0.3)
  
  -- Update emotional state
  pixel.emotional_state.excitement += emotional_impact
  pixel.emotional_state.excitement = min(pixel.emotional_state.excitement, 1)
  
  -- Record interaction in memory
  significant_event_occurred = true
  event_type = "direct_interaction"
  current_emotional_impact = emotional_impact
  
  -- Adjust personality slightly based on interaction
  pixel.personality.timidity = max(0, pixel.personality.timidity - 0.01)
  
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
  
  -- Emotional indicators
  if pixel.emotional_state.excitement > 0.7 then
    -- Add pulsing effect for excitement
    circfill(pixel.x, pixel.y, 2 + sin(time()*2), 14)
  end
  
  if pixel.emotional_state.distress > 0.7 then
    -- Add distress indicator
    circfill(pixel.x, pixel.y, 1, 8)
  end
  
  -- Draw memory trace for recent positions
  for i=1,#pixel.memories do
    local mem = pixel.memories[i]
    local alpha = i/#pixel.memories
    pset(mem.x, mem.y, 1)
  end
end

function draw_energy_cubes()
  foreach(energy_cubes, function(cube)
    rectfill(cube.x-2, cube.y-2, cube.x+2, cube.y+2, 11)
    -- Add glow effect
    if sin(time()*4) > 0 then
      rect(cube.x-3, cube.y-3, cube.x+3, cube.y+3, 10)
    end
  end)
end

function draw_background()
  -- Draw a simple grid background
  for x=0,127,8 do
    for y=0,127,8 do
      pset(x, y, 1)
    end
  end
end

function draw_ui()
  -- Draw energy level indicator
  rectfill(4, 4, 4 + pixel.energy/10, 6, 11)
  rect(3, 3, 14, 7, 5)
  
  -- Draw personality indicators
  print("c:"..flr(pixel.personality.curiosity*10), 4, 115, 7)
  print("t:"..flr(pixel.personality.timidity*10), 4, 121, 7)
  
  -- Show emotional state
  local emo_x = 90
  print("state:", emo_x, 4, 7)
  
  if pixel.emotional_state.excitement > 0.5 then
    print("excited", emo_x+20, 4, 14)
  elseif pixel.emotional_state.distress > 0.5 then
    print("distress", emo_x+20, 4, 8)
  elseif pixel.emotional_state.happiness > 0.5 then
    print("happy", emo_x+20, 4, 11)
  else
    print("neutral", emo_x+20, 4, 6)
  end
  
  -- Controls help
  print("❎:cube 🅾️:interact", 24, 121, 5)
end

-- utility functions
function dist(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return sqrt(dx*dx + dy*dy)
end

function load_sounds()
  -- No implementation needed for prototype
  -- In a full implementation you would
  -- define and load sound effects here
end

-- data persistence
function save_consciousness()
  -- Save core personality and memories to cart data
  local data_string = ""
  
  -- Add personality traits
  data_string = data_string..pixel.personality.curiosity..","
  data_string = data_string..pixel.personality.timidity..","
  data_string = data_string..pixel.personality.energy_conservation
  
  -- Save to cartdata
  cartdata("sentium_pixel_v1")
  dset(0, data_string)
end

function load_consciousness()
  -- Load saved consciousness if available
  cartdata("sentium_pixel_v1")
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

-- split function for parsing data
function split(str, sep)
  local t = {}
  local i = 1
  
  for s in str:gmatch("([^"..sep.."]+)") do
    t[i] = s
    i = i + 1
  end
  
  return t
end

-- main pico-8 functions
function _update()
  -- Process player input
  if btnp(❎) then -- X button
    -- Create energy cube at cursor position or near player
    if stat(34) == 1 then -- mouse available
      add(energy_cubes, {
        x = stat(32), -- mouse x
        y = stat(33), -- mouse y
        value = 25
      })
    else
      -- Add near pixel if no mouse
      local angle = rnd(1)
      local dist = 20 + rnd(20)
      add(energy_cubes, {
        x = pixel.x + cos(angle) * dist,
        y = pixel.y + sin(angle) * dist,
        value = 25
      })
    end
    -- Record interaction
    record_interaction("energy_placed")
    sfx(2)
  end
  
  if btnp(🅾️) then -- O button
    -- Direct interaction with pixel
    if stat(34) == 1 then -- mouse available
      if dist(stat(32), stat(33), pixel.x, pixel.y) < 10 then
        interact_with_pixel()
      end
    else
      -- Direct interaction if button pressed near pixel
      interact_with_pixel()
    end
  end
  
  -- Auto-save consciousness occasionally
  if rnd(1) < 0.001 then
    save_consciousness()
  end
  
  -- Update consciousness
  update_consciousness()
end

function _draw()
  cls(1) -- Clear screen to dark blue
  draw_background()
  draw_energy_cubes()
  draw_pixel()
  draw_ui()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
