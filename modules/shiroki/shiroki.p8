pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- shiroki 
-- by lopanapol

player = {}
dot = {
  x = 32,
  y = 32,
  size = 4
}
score = 0
game_state = "splash"
splash_timer = 0

-- Sentium Pico consciousness variables
memory_size = 10
sig_event = false
event_type = ""
emotion_impact = 0
mouse_cursor = {x = 64, y = 64, visible = false}
  cursor_interaction = {
  is_aware = false,
  attention_level = 0,
  last_distance = 1000,
  last_cursor_x = 64,
  last_cursor_y = 64,
  stillness_timer = 0,
  max_stillness_threshold = 300,
  influence_radius = 60,
  cursor_heat = 0,
  force_lines = {},
  was_aware = false
}
global_workspace = {}
attention_schema = {}
predictive_processing = {}

function _init()
  poke(0x5f2d, 1) -- enable mouse
  cartdata("shiroki_save")

  player = create_pixel(64, 64, { -- Initial x,y, centered on the first screen
    curiosity = 0.9,
    timidity = 0.1,
    energy_cons = 0.5
  })

  -- Initialize consciousness systems
  global_workspace = {
    current_focus = nil,
    competing_processes = {},
    broadcast_strength = 0,
    consc_thresh = 0.3
  }
  attention_schema = {
    attention_map = {},
    self_model = {
      position = {x = player.x, y = player.y},
      size = 16,
      confidence = 0.5
    },
    prediction_error = 0
  }
  predictive_processing = {
    learning_rate = 0.01
  }
  cookie = {x = 0, y = 0, visible = false, spawn_timer = 150}
  load_game_state()
end

function _draw()
  if game_state == "splash" then
    draw_splash_screen()
    return
  end
  cls(e)
  
  -- move camera to current room
  local room_x = flr(player.x/128)
  local room_y = flr(player.y/128)
  camera(room_x*128,room_y*128)
  
  -- draw the whole map (128⁙32)
  map()
  
  -- draw the player
  spr(player.f,      -- frame index
   player.x-4,player.y-4, -- x,y (pixels)
   1,1,player.d==-1    -- w,h, flip
  )

  -- Draw UI
  draw_ui()
  draw_cursor()
  if cookie.visible then
    spr(4, cookie.x, cookie.y)
  end
end

function _update()
  if game_state == "splash" then
    splash_timer += 1
    if stat(36) > 0 then
      game_state = "game"
    end
    if splash_timer > 180 then
      game_state = "game"
    end
    return
  end
  local mx = stat(32)
  local my = stat(33)
  mouse_cursor.visible = true
  if mx >= 0 and my >= 0 and mx <= 127 and my <= 127 then
    mouse_cursor.x = mx
    mouse_cursor.y = my
  end

  update_consciousness()
  update_cursor_awareness()

  update_movement(player)

  -- collect apple (adapted from dot collection in sentium-cat.p8)
  -- Assuming 'dot' is now the apple, and its position is in tile coordinates
  -- Need to convert player.x, player.y to tile coordinates for mget
  local player_tile_x = flr(player.x / 8)
  local player_tile_y = flr(player.y / 8)

  -- cookie spawning and collection logic
  if not cookie.visible then
    cookie.spawn_timer -= 1
    if cookie.spawn_timer <= 0 then
      -- Spawn cookie at a random visible location
      local spawn_x, spawn_y
      repeat
        spawn_x = flr(rnd(128) / 8) * 8
        spawn_y = flr(rnd(128) / 8) * 8
      until mget(flr(spawn_x/8), flr(spawn_y/8)) == 0 -- Ensure it's on an empty tile
      cookie.x = spawn_x
      cookie.y = spawn_y
      cookie.visible = true
      cookie.spawn_timer = 150 -- Reset timer for next spawn
    end
  else
    -- Check for collision with player
    if dist(player.x, player.y, cookie.x, cookie.y) < 8 then
      cookie.visible = false
      sfx(0) -- Play sound effect
      score += 1
      player.energy = min(100, player.energy + 50)
      player.emo_state.happiness = min(1, player.emo_state.happiness + 0.5)
      player.emo_state.excitement = min(1, player.emo_state.excitement + 0.3)
      sig_event = true
      event_type = "cookie_collected"
      emotion_impact = 0.4
      save_game_state()
    end
  end
  if btnp(5) then
    save_game_state()
  end
end


-- Sentium Pico Functions (adapted for shiroki.p8)

function create_pixel(x, y, personality)
  return {
    x = x,
    y = y,
    size = 16,
    color = 8,
    energy = 100,
    memories = {},
    qcf_resonance = 0,
    last_x = x,
    last_y = y,
    age = 0,
    generation = 1,
    id = 1,
    personality = personality,
    emo_state = {
      happiness = 0.5,
      excitement = 0.5,
      distress = 0
    },
    target_x = x,
    target_y = y,
    stuck_timer = 0,
    is_moving = false,
    dx = 0, -- Added for shiroki.p8 player
    dy = 0, -- Added for shiroki.p8 player
    f = 0,  -- Added for shiroki.p8 player
    d = 1   -- Added for shiroki.p8 player
  }
end

function update_consciousness()
  update_movement(player)
  update_emotions(player)
  process_metacognition(player)
  update_global_workspace(player)
  update_attention_schema(player)
  update_predictive_processing(player)
  
  player.qcf_resonance = calculate_qcf_resonance(player)
  player.energy = max(0, player.energy - 0.05)
  form_memories(player)
end

function update_global_workspace(pixel)
  local processes = {}
  
  -- Cursor attention
  if cursor_interaction.is_aware then
    add(processes, {
      type = "cursor_attention",
      strength = cursor_interaction.attention_level,
      content = {x = mouse_cursor.x, y = mouse_cursor.y}
    })
  end
  
  -- cookie seeking
  if cookie.visible then
    local dist_to_cookie = dist(pixel.x, pixel.y, cookie.x, cookie.y)
    local proximity_factor = max(0, 1 - (dist_to_cookie / 128)) -- Max distance is 128 (screen size)
    local urgency = (80 - pixel.energy) / 80 -- Still consider energy for urgency

    add(processes, {
      type = "cookie_seeking",
      strength = (urgency * 0.3) + (proximity_factor * 0.7), -- Reduced urgency, increased proximity
      content = {x = cookie.x, y = cookie.y, energy_level = pixel.energy}
    })
  end
  
  -- Emotional state
  local max_emotion = max(pixel.emo_state.happiness, pixel.emo_state.excitement, pixel.emo_state.distress)
  if max_emotion > 0.5 then
    add(processes, {
      type = "emo_state",
      strength = max_emotion * 0.6,
      content = {dominant_emotion = get_dominant_emotion(pixel)}
    })
  end

  -- Winner takes all
  local winner = nil
  local max_strength = 0
  for process in all(processes) do
    if process.strength > max_strength then
      max_strength = process.strength
      winner = process
    end
  end
  
  if winner and max_strength > global_workspace.consc_thresh then
    global_workspace.current_focus = winner
    global_workspace.broadcast_strength = max_strength
  else
    global_workspace.current_focus = nil
    global_workspace.broadcast_strength = 0
  end
end

function get_dominant_emotion(pixel)
  local emotions = {
    {name = "happiness", value = pixel.emo_state.happiness},
    {name = "excitement", value = pixel.emo_state.excitement},
    {name = "distress", value = pixel.emo_state.distress}
  }
  local dominant = emotions[1]
  for emotion in all(emotions) do
    if emotion.value > dominant.value then
      dominant = emotion
    end
  end
  return dominant.name
end

function update_attention_schema(pixel)
  attention_schema.self_model.position.x = pixel.x
  attention_schema.self_model.position.y = pixel.y
  attention_schema.self_model.confidence = min(1, pixel.energy / 100)
  attention_schema.attention_map = {}
  
  -- Add cursor to attention map
  if cursor_interaction.is_aware then
    add(attention_schema.attention_map, {
      x = mouse_cursor.x,
      y = mouse_cursor.y,
      intensity = cursor_interaction.attention_level,
      type = "cursor"
    })
  end
  
  -- Apple attention (no specific apple object, so this will be less direct)
  -- We can make the player more attentive to areas where apples might be,
  -- or where they recently collected one. For now, I'll omit direct apple attention.
  
  -- Add cookie to attention map
  if cookie.visible then
    add(attention_schema.attention_map, {
      x = cookie.x,
      y = cookie.y,
      intensity = 0.8, -- Cherries are highly attention-grabbing
      type = "cookie"
    })
  end
end

function update_predictive_processing(pixel)
  -- Predict cursor behavior
  if cursor_interaction.is_aware then
    local dx = mouse_cursor.x - cursor_interaction.last_cursor_x
    local dy = mouse_cursor.y - cursor_interaction.last_cursor_y
    local predicted_x = mouse_cursor.x + dx
    local predicted_y = mouse_cursor.y + dy
  
    if cursor_interaction.last_predicted_x then
      local error_x = abs(mouse_cursor.x - cursor_interaction.last_predicted_x)
      local error_y = abs(mouse_cursor.y - cursor_interaction.last_predicted_y)
      local prediction_error = (error_x + error_y) / 2
  
      if prediction_error < 3 then
        pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.005)
      else
        pixel.personality.timidity = min(1, pixel.personality.timidity + 0.005)
      end
      attention_schema.prediction_error = prediction_error
    end
  
    cursor_interaction.last_predicted_x = predicted_x
    cursor_interaction.last_predicted_y = predicted_y
  end
end

function calculate_qcf_resonance(p)
  local s = cursor_interaction.attention_level * 0.4
  local m = min(#p.memories / memory_size, 1) * 0.35
  local e = (p.emo_state.happiness + p.emo_state.excitement) * 0.3 -- Increased emotional impact
  local b = p.target_x and 1 - min(abs(p.x - p.target_x) + abs(p.y - p.target_y), 50) / 50 * 0.2 or 0
  return min((s + m + e + b) / 4, 1)
end

function form_memories(pixel)
  if sig_event then
    if #pixel.memories >= memory_size then
      del(pixel.memories, pixel.memories[1])
    end
    add(pixel.memories, {
      type = event_type,
      x = pixel.x,
      y = pixel.y,
      emotional_impact = emotion_impact
    })
    sig_event = false
  end
end

function update_movement(pixel)
  local move_speed = 0.5
  
  -- Default behavior: shiroki
  if (global_workspace.current_focus == nil) then
    if rnd(1) < 0.05 then -- Increased frequency of random exploration
      pixel.target_x = 20 + rnd(88)
      pixel.target_y = 20 + rnd(88)
    end
  else
    -- Conscious behavior
    local focus = global_workspace.current_focus
    if focus.type == "cookie_seeking" then
        pixel.target_x = focus.content.x
        pixel.target_y = focus.content.y
        move_speed = 1.5 -- Increase speed when seeking cookie
    elseif focus.type == "cursor_attention" then
      -- Defer to cursor influence functions
    elseif focus.type == "emo_state" then
      if focus.content.dominant_emotion == "distress" then
        -- Flee randomly
        pixel.target_x += (rnd(4) - 2)
        pixel.target_y += (rnd(4) - 2)
      end
    end
  end

  -- Let cursor override movement
  influence_movement_by_cursor(pixel, dist(pixel.x, pixel.y, mouse_cursor.x, mouse_cursor.y))

  local dx = pixel.target_x - pixel.x
  local dy = pixel.target_y - pixel.y
  local dist_to_target = sqrt(dx*dx + dy*dy)

  if dist_to_target > 2 then
    dx = dx / dist_to_target
    dy = dy / dist_to_target
    pixel.x += dx * move_speed
    pixel.y += dy * move_speed
    pixel.x = max(0, min(127, pixel.x)) -- Clamp to screen bounds
    pixel.y = max(0, min(127, pixel.y)) -- Clamp to screen bounds
    pixel.is_moving = true
  else
    pixel.is_moving = false
  end

  -- Update dx, dy, f, d for shiroki.p8's original drawing logic
  pixel.dx = dx * move_speed
  pixel.dy = dy * move_speed
  if pixel.is_moving then
    pixel.f = (pixel.f + sqrt(pixel.dx*pixel.dx + pixel.dy*pixel.dy)*0.5) % 4
  else
    pixel.f = 0
  end
  if pixel.dx < 0 then pixel.d = -1 else pixel.d = 1 end
end

function update_emotions(pixel)
  pixel.emo_state.excitement *= 0.985
  pixel.emo_state.happiness *= 0.999
  if pixel.energy < 30 then
    pixel.emo_state.distress = (30 - pixel.energy) / 30
  else
    pixel.emo_state.distress *= 0.95
  end
end

function process_metacognition(pixel)
  if #pixel.memories > 5 then
    local cookie_mem_count = 0
    for i=max(1, #pixel.memories-4), #pixel.memories do
      if pixel.memories[i].type == "cookie_collected" then
        cookie_mem_count += 1
      end
    end
    if cookie_mem_count > 2 then
      -- Reinforce cookie-seeking behavior
      pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.05)
      sig_event = true
      event_type = "self_reflection"
      emotion_impact = 0.1
    end
  end
end

function update_cursor_awareness()
  local cursor_moved = abs(mouse_cursor.x - cursor_interaction.last_cursor_x) > 1 or 
                      abs(mouse_cursor.y - cursor_interaction.last_cursor_y) > 1
  if cursor_moved then
    cursor_interaction.stillness_timer = 0
    cursor_interaction.cursor_heat = min(1, cursor_interaction.cursor_heat + 0.05)
    cursor_interaction.last_cursor_x = mouse_cursor.x
    cursor_interaction.last_cursor_y = mouse_cursor.y
  else
    cursor_interaction.stillness_timer += 1
    cursor_interaction.cursor_heat = max(0, cursor_interaction.cursor_heat - 0.01)
  end

  local cursor_dist = dist(player.x, player.y, mouse_cursor.x, mouse_cursor.y)
  local awareness_range = cursor_interaction.influence_radius + player.personality.curiosity * 20

  if cursor_dist < awareness_range then
    cursor_interaction.is_aware = true
    local proximity_factor = 1 - (cursor_dist / awareness_range)
    cursor_interaction.attention_level = min(1, proximity_factor * cursor_interaction.cursor_heat)
    if cursor_dist < 10 then
      player.emo_state.happiness = min(1, player.emo_state.happiness + 0.01)
    end
  else
    cursor_interaction.is_aware = false
    cursor_interaction.attention_level = max(0, cursor_interaction.attention_level - 0.05)
  end
end

function influence_movement_by_cursor(pixel, cursor_distance)
  if not cursor_interaction.is_aware then return end
  
  local influence_strength = cursor_interaction.attention_level * 0.5
  
  -- Curiosity: approach cursor
  if pixel.personality.curiosity > 0.6 and cursor_distance > 15 then
    local approach_factor = (pixel.personality.curiosity - 0.6) * 2.5
    pixel.target_x = lerp(pixel.target_x, mouse_cursor.x, influence_strength * approach_factor * 0.1)
    pixel.target_y = lerp(pixel.target_y, mouse_cursor.y, influence_strength * approach_factor * 0.1)
  end
  
  -- Timidity: flee cursor
  if pixel.personality.timidity > 0.5 and cursor_distance < 30 then
    local retreat_factor = pixel.personality.timidity * 2
    local retreat_x = pixel.x + (pixel.x - mouse_cursor.x) * 0.3
    local retreat_y = pixel.y + (pixel.y - mouse_cursor.y) * 0.3
    pixel.target_x = lerp(pixel.target_x, retreat_x, influence_strength * retreat_factor * 0.15)
    pixel.target_y = lerp(pixel.target_y, retreat_y, influence_strength * retreat_factor * 0.15)
  end
end

function draw_ui()
  -- QCF Resonance level
  print("hapiness", 4, 110, 7)
  local qcf_bar_width = min(30, flr(player.qcf_resonance * 30))
  rectfill(4, 120, 4 + qcf_bar_width, 122, 11)
  rect(3, 119, 34, 123, 5)

  -- Energy level
  print("energy", 44, 110, 7)
  local energy_bar_width = min(30, player.energy/100 * 30)
  rectfill(44, 120, 40 + energy_bar_width, 122, 11)
  rect(43, 119, 70, 123, 5)
end

function draw_cursor()
  if mouse_cursor.visible then
    local heat_level = cursor_interaction.cursor_heat
    local cursor_color = 7
    if heat_level > 0.7 then cursor_color = 14
    elseif heat_level > 0.4 then cursor_color = 10
    end
    circfill(mouse_cursor.x, mouse_cursor.y, 2, cursor_color)
    if cursor_interaction.is_aware then
      circ(mouse_cursor.x, mouse_cursor.y, 8 + cursor_interaction.attention_level * 4, 13)
    end
  end
end
function draw_splash_screen()
  cls(14)
  local symbol_x = 64
  local symbol_y = 40
  if flr(splash_timer / 30) % 2 == 0 then
    draw_simple_symbol(symbol_x, symbol_y, 0)
  end
  local title = "sentium"
  local title_width = #title * 4
  local anim_progress = min(splash_timer / 60, 1)
  local start_x = -title_width
  local end_x = (128 - title_width) / 2
  local title_x = start_x + (end_x - start_x) * anim_progress
  print(title, title_x, 65, 0)
  local subtitle = "shiroki: a conscious dog"
  local sub_width = #subtitle * 4
  local sub_x = (128 - sub_width) / 2
  print(subtitle, sub_x, 80, 0)
  local instruction = "v1.0.0"
  local inst_width = #instruction * 4
  local inst_x = (128 - inst_width) / 2
  print(instruction, inst_x, 95, 0)
end

function draw_simple_symbol(x, y, color)
  circfill(x, y, 12, color)
  circfill(x, y, 7, 14)
  line(x-2, y-20, x-2, y+20, color)
  line(x-1, y-20, x-1, y+20, color)
  line(x, y-20, x, y+20, color)
  line(x+1, y-20, x+1, y+20, color)
  line(x+2, y-20, x+2, y+20, color)
  line(x-8, y-20, x-3, y-20, color)
  line(x-8, y-19, x-3, y-19, color)
  line(x-8, y-18, x-3, y-18, color)
  line(x-8, y-17, x-3, y-17, color)
  line(x+3, y+20, x+8, y+20, color)
  line(x+3, y+19, x+8, y+19, color)
  line(x+3, y+18, x+8, y+18, color)
  line(x+3, y+17, x+8, y+17, color)
end
-- Utility functions
function sqrt(n) return n^0.5 end
function dist(x1, y1, x2, y2) return sqrt((x2-x1)^2 + (y2-y1)^2) end
function lerp(a, b, t) return a + (b - a) * t end

function save_game_state()
  dset(0, player.x)
  dset(1, player.y)
  dset(2, player.energy)
  dset(3, score)
  dset(4, player.personality.curiosity)
  dset(5, player.personality.timidity)
  dset(6, player.emo_state.happiness)
  dset(7, player.qcf_resonance)
end

function load_game_state()
  if dget(0) != nil then
    player.x = dget(0)
    player.y = dget(1)
    player.energy = dget(2)
    score = dget(3)
    player.personality.curiosity = dget(4)
    player.personality.timidity = dget(5)
    player.emo_state.happiness = dget(6)
    player.qcf_resonance = dget(7)
  end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00660066006600660066006600660066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777000777770007777700077777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7707077077070770770707707707077000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7007770770077707700777077007770700e88e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
077eeee0077eeee0077eeee0077eeee000eeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770008888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07007060070007067060070007007060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
300830072705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
