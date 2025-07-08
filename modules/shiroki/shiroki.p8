pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- shiroki demo
-- by zep

player = {}
dot = {
  x = 32,
  y = 32,
  size = 4
}
score = 0

-- IMPORTANT: Set this to the top-left sprite number of your cat
-- For example, if your cat starts at sprite 68, set this to 68.
local cat_sprite_idle = 0
local cat_sprite_walk1 = 0 -- First frame of walking animation (32x32 sprite)
local cat_sprite_walk2 = 4 -- Second frame of walking animation (32x32 sprite)

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
  force_lines = {}
}
global_workspace = {}
attention_schema = {}
predictive_processing = {}

function _init()
  poke(0x5f2d, 1) -- enable mouse

  player = create_pixel(24*8-4, 24*8-4, { -- Initial x,y from shiroki.p8, converted to pixels
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
end

function _draw()
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
  print("score: "..score, 8, 8, 7)
  draw_ui()
  draw_cursor()
end

function _update()
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

  if (mget(player_tile_x, player_tile_y) == 10) then
    mset(player_tile_x, player_tile_y, 14)
    sfx(0)
    score += 1
    player.energy = min(100, player.energy + 50)
    player.emo_state.happiness = min(1, player.emo_state.happiness + 0.5)
    player.emo_state.excitement = min(1, player.emo_state.excitement + 0.3)
    sig_event = true
    event_type = "apple_collected"
    emotion_impact = 0.4
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
    consc_level = 0,
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
  
  player.consc_level = calculate_phi(player)
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
  
  -- Apple seeking (replaces dot seeking)
  -- For shiroki.p8, we don't have a specific "apple" object with x,y.
  -- The player collects apples by moving over tiles.
  -- So, this part needs to be adapted or removed.
  -- For now, I'll keep it but it won't directly influence movement towards a specific apple.
  if pixel.energy < 80 then
    local urgency = (80 - pixel.energy) / 80
    add(processes, {
      type = "apple_seeking", 
      strength = urgency * 0.9,
      content = {energy_level = pixel.energy}
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

function calculate_phi(p)
  local s = cursor_interaction.attention_level * 0.4
  local m = min(#p.memories / memory_size, 1) * 0.35
  local e = (p.emo_state.happiness + p.emo_state.excitement) * 0.15
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
    if rnd(1) < 0.01 then
      pixel.target_x = 20 + rnd(88)
      pixel.target_y = 20 + rnd(88)
    end
  else
    -- Conscious behavior
    local focus = global_workspace.current_focus
    if focus.type == "apple_seeking" then
      -- Since there's no specific apple object, this will make the player
      -- shiroki more purposefully, perhaps towards areas where apples are common.
      -- For now, it will just increase movement speed.
      move_speed = 1
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
  pixel.f = (pixel.f + sqrt(pixel.dx*pixel.dx + pixel.dy*pixel.dy)*0.5) % 4
  if (sqrt(pixel.dx*pixel.dx + pixel.dy*pixel.dy) < 0.3) pixel.f=0
  if pixel.dx < 0 then pixel.d = -1 else pixel.d = 1 end
end

function update_emotions(pixel)
  pixel.emo_state.excitement *= 0.985
  pixel.emo_state.happiness *= 0.99
  if pixel.energy < 30 then
    pixel.emo_state.distress = (30 - pixel.energy) / 30
  else
    pixel.emo_state.distress *= 0.95
  end
end

function process_metacognition(pixel)
  if #pixel.memories > 5 then
    local apple_mem_count = 0
    for i=max(1, #pixel.memories-4), #pixel.memories do
      if pixel.memories[i].type == "apple_collected" then
        apple_mem_count += 1
      end
    end
    if apple_mem_count > 2 then
      -- Reinforce apple-seeking behavior
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
  -- Consciousness level
  print("conscious", 4, 110, 7)
  local phi_bar_width = min(30, flr(player.consc_level * 30))
  rectfill(4, 120, 4 + phi_bar_width, 122, 11)
  rect(3, 119, 34, 123, 5)

  -- Energy level
  print("energy", 40, 110, 7)
  local energy_bar_width = min(30, player.energy/100 * 30)
  rectfill(40, 120, 40 + energy_bar_width, 122, 11)
  rect(39, 119, 70, 123, 5)

  -- Dominant Emotion
  local emo_x = 80
  local emo_y = 110
  local dominant_emotion = get_dominant_emotion(player)
  local emo_color = 7
  if dominant_emotion == "excitement" then emo_color = 14
  elseif dominant_emotion == "happiness" then emo_color = 11
  elseif dominant_emotion == "distress" then emo_color = 8
  end
  print(dominant_emotion, emo_x, emo_y, emo_color)

  -- Current Focus
  if global_workspace.current_focus then
    local focus_text = global_workspace.current_focus.type
    print("focus: "..focus_text, 4, 100, 12)
  else
    print("focus: diffuse", 4, 100, 6)
  end
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

-- Utility functions
function sqrt(n) return n^0.5 end
function dist(x1, y1, x2, y2) return sqrt((x2-x1)^2 + (y2-y1)^2) end
function lerp(a, b, t) return a + (b - a) * t end

__gfx__
0000000000000000000000000000000000000b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000700070007000700070007000700070000b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000777777007777700077777770777770088b8800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77071770700707707007077070071770088888780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70077707700777077007770770077707088888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07766e6007766e6007766e6007766e6008e888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777007777770008e88800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07007060070607067060070670607060000888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
