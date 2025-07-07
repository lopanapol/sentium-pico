pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- crazy-cat-conscious.p8
-- version 2.0.0

--[[
  This is the conscious version of the 32x32 cat game.
  The cat is now powered by the Sentium Pico consciousness model.
--]]

cat = {}
dot = {
  x = 32,
  y = 32,
  size = 4
}
score = 0

-- IMPORTANT: Set this to the top-left sprite number of your cat
-- For example, if your cat starts at sprite 68, set this to 68.
local cat_sprite_base = 0

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

  cat = create_pixel(64, 64, {
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
      position = {x = 64, y = 64},
      size = 16,
      confidence = 0.5
    },
    prediction_error = 0
  }
  predictive_processing = {
    learning_rate = 0.01
  }
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

  if (abs(cat.x - dot.x) < cat.size and
      abs(cat.y - dot.y) < cat.size) then
    dot.x = rnd(128)
    dot.y = rnd(128)
    score += 1
    cat.energy = min(100, cat.energy + 50)
    cat.emo_state.happiness = min(1, cat.emo_state.happiness + 0.5)
    cat.emo_state.excitement = min(1, cat.emo_state.excitement + 0.3)
    sig_event = true
    event_type = "dot_captured"
    emotion_impact = 0.4
  end
end

function _draw()
  cls()
  
  -- Draw the cat sprite
  local frame = flr(time() * 4) % 2
  spr(cat_sprite_base + (frame * 16), cat.x - 16, cat.y - 16, 4, 4)

  -- Draw the dot
  circfill(dot.x, dot.y, dot.size, 8)
  
  -- Draw UI
  print("score: "..score, 8, 8, 7)
  draw_ui()
  draw_cursor()
end

-- Sentium Pico Functions (adapted for crazy-cat)

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
    stuck_timer = 0
  }
end

function update_consciousness()
  update_movement(cat)
  update_emotions(cat)
  process_metacognition(cat)
  update_global_workspace(cat)
  update_attention_schema(cat)
  update_predictive_processing(cat)
  
  cat.consc_level = calculate_phi(cat)
  cat.energy = max(0, cat.energy - 0.05)
  form_memories(cat)
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
  
  -- Dot seeking (replaces energy seeking)
  if pixel.energy < 80 then
    local urgency = (80 - pixel.energy) / 80
    add(processes, {
      type = "dot_seeking", 
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
  
  -- Add dot to attention map
  local dist_to_dot = dist(pixel.x, pixel.y, dot.x, dot.y)
  local dot_intensity = max(0, 1 - dist_to_dot / 128)
  if pixel.energy < 80 then
    dot_intensity *= 2
  end
  add(attention_schema.attention_map, {
    x = dot.x, y = dot.y,
    intensity = dot_intensity,
    type = "dot"
  })
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
  local move_speed = 1.5
  
  -- Default behavior: wander
  if (global_workspace.current_focus == nil) then
    if rnd(1) < 0.02 then
      pixel.target_x = 20 + rnd(88)
      pixel.target_y = 20 + rnd(88)
    end
  else
    -- Conscious behavior
    local focus = global_workspace.current_focus
    if focus.type == "dot_seeking" then
      pixel.target_x = dot.x
      pixel.target_y = dot.y
      move_speed = 2.0
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
    pixel.x = max(16, min(111, pixel.x))
    pixel.y = max(16, min(111, pixel.y))
  end
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
    local dot_mem_count = 0
    for i=max(1, #pixel.memories-4), #pixel.memories do
      if pixel.memories[i].type == "dot_captured" then
        dot_mem_count += 1
      end
    end
    if dot_mem_count > 2 then
      -- Reinforce dot-seeking behavior
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

  local cursor_dist = dist(cat.x, cat.y, mouse_cursor.x, mouse_cursor.y)
  local awareness_range = cursor_interaction.influence_radius + cat.personality.curiosity * 20

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
  local phi_bar_width = min(30, flr(cat.consc_level * 30))
  rectfill(4, 120, 4 + phi_bar_width, 122, 11)
  rect(3, 119, 34, 123, 5)

  -- Energy level
  print("energy", 40, 110, 7)
  local energy_bar_width = min(30, cat.energy/100 * 30)
  rectfill(40, 120, 40 + energy_bar_width, 122, 11)
  rect(39, 119, 70, 123, 5)

  -- Dominant Emotion
  local emo_x = 80
  local emo_y = 110
  local dominant_emotion = get_dominant_emotion(cat)
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000011000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000155000000000055100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000001ddd100000005dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000001d7d50000000d7d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000001d7ddddddddd77d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000dd000001d777777777777d100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d77d00001d777777777777d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d77d00001d770777777717d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d7d0000dddd70777777717ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d75000001d771777077707d010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d751001dddd77777777777ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d751000010d77777777777d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000d7751111105dd7777777ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000d71ddddddd5ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000d777777777755555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001d777777777777d777d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001577777777777ded77d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000577777777777ded77d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001577777777d777d777d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015d7777777d777777d500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000157ddddddd7d0007d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000015710750007d0007d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000770770007700077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
