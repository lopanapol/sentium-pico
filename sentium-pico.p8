pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
pixels = {}
energy_cubes = {}
memory_size = 10
sig_event = false
event_type = ""
emotion_impact = 0
target_x = 64
target_y = 64
pixel_counter = 0
save_timer = 0
save_text = ""
max_pixels = 32
max_gen = 20
div_energy = 25
death_energy = 0
div_cooldown = 30
mutation_rate = 0.05
metabolic_rate = 0.2
growth_rate = 1.2
cur_gen = 1
gen_timer = 0
gen_interval = 600
game_state = "splash"
splash_timer = 0
mouse_cursor = {
  x = 64,
  y = 64,
  visible = false
}
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
  max_stillness_threshold = 300,
  last_predicted_x = nil,
  last_predicted_y = nil
}
function _init()
  cls()
  cartdata("sentium_pixel_v1")
  poke(0x5f2d, 1)
  poke(0x5f2e, 1)
  poke(0x5f34, 1)
  mouse_cursor.visible = true
  mouse_cursor.x = 64
  mouse_cursor.y = 64
  init_consciousness()
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
      size = 3,
      confidence = 0.5
    },
    world_model = {},
    prediction_error = 0
  }
  predictive_processing = {
    predictions = {},
    prediction_errors = {},
    learning_rate = 0.01,
    confidence_levels = {}
  }
  init_energy_system()
  create_initial_energy_cubes()
  load_sounds()
  local loaded = load_game_state()
  if not loaded then
    init_consciousness()
  end
end
function init_consciousness()
  pixels = {}
  pixel_counter = 0
  add(pixels, create_pixel(64, 64, {
    curiosity = 0.5 + rnd(0.3),
    timidity = 0.4 + rnd(0.3),
    energy_cons = 0.5 + rnd(0.3)
  }))
  memory_size = 10
  sig_event = false
  event_type = ""
  emotion_impact = 0
  if #pixels > 0 and pixels[1].number != 1 then
    pixels[1].number = 1
    pixel_counter = 1
  end
end
function create_pixel(x, y, personality)
  x = mid(4, x or 64, 124)
  y = mid(4, y or 64, 124)
  pixel_counter += 1
  local used_numbers = {}
  for existing_pixel in all(pixels) do
    if existing_pixel.number then
      used_numbers[existing_pixel.number] = true
    end
  end
  while used_numbers[pixel_counter] do
    pixel_counter += 1
  end
  local validated_personality = personality or {}
  validated_personality.curiosity = mid(0, validated_personality.curiosity or rnd(1), 1)
  validated_personality.timidity = mid(0, validated_personality.timidity or rnd(1), 1)
  validated_personality.energy_cons = mid(0, validated_personality.energy_cons or rnd(1), 1)
  return {
    x = x,
    y = y,
    color = 8,
    energy = 80 + rnd(20),
    memories = {},
    consc_level = 0,
    last_x = x,
    last_y = y,
    age = 0,
    generation = cur_gen,
    division_timer = 0,
    parent_id = nil,
    id = pixel_counter * 1000 + flr(rnd(1000)),
    number = pixel_counter,
    personality = validated_personality,
    emo_state = {
      happiness = 0.5,
      excitement = 0.5,
      distress = 0
    },
    target_x = mid(8, x + rnd(20) - 10, 120),
    target_y = mid(8, y + rnd(20) - 10, 120),
    size = 1 + rnd(0.5),
    div_progress = 0,
    metab_eff = 0.8 + rnd(0.4),
    repro_drive = 0.7 + rnd(0.3),
    stuck_timer = 0
  }
end
function update_global_workspace(pixel)
  local processes = {}
  if cursor_interaction.is_aware then
    add(processes, {
      type = "cursor_attention",
      strength = cursor_interaction.attention_level,
      content = {x = mouse_cursor.x, y = mouse_cursor.y, distance = cursor_interaction.last_distance}
    })
  end
  if pixel.energy < 50 then
    local urgency = (50 - pixel.energy) / 50
    add(processes, {
      type = "energy_seeking",
      strength = urgency * 0.8,
      content = {energy_level = pixel.energy, urgency = urgency}
    })
  end
  if #pixel.memories > 5 then
    add(processes, {
      type = "memory_recall",
      strength = 0.4,
      content = {memory_count = #pixel.memories}
    })
  end
  local max_emotion = max(pixel.emo_state.happiness, 
                         pixel.emo_state.excitement, 
                         pixel.emo_state.distress)
  if max_emotion > 0.5 then
    add(processes, {
      type = "emo_state",
      strength = max_emotion * 0.6,
      content = {dominant_emotion = get_dominant_emotion(pixel)}
    })
  end
  global_workspace.competing_processes = processes
  local winner = nil
  local max_strength = 0
  for process in all(processes) do
    if process.strength > max_strength then
      max_strength = process.strength
      winner = process
    end
  end
  if winner and max_strength > global_workspace.consc_thresh then
    if global_workspace.current_focus == nil or 
       global_workspace.current_focus.type != winner.type then
      sfx(6)
    end
    global_workspace.current_focus = winner
    global_workspace.broadcast_strength = max_strength
    broadcast_to_subsystems(winner, pixel)
  else
    global_workspace.current_focus = nil
    global_workspace.broadcast_strength = 0
  end
end
function broadcast_to_subsystems(conscious_process, pixel)
  if conscious_process.type == "cursor_attention" then
    pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.001)
  elseif conscious_process.type == "energy_seeking" then
    if #energy_cubes > 0 then
      local nearest_cube = find_nearest_energy_cube(pixel)
      if nearest_cube then
        pixel.target_x = lerp(pixel.target_x, nearest_cube.x, 0.1)
        pixel.target_y = lerp(pixel.target_y, nearest_cube.y, 0.1)
      end
    end
  elseif conscious_process.type == "emo_state" then
    if conscious_process.content.dominant_emotion == "distress" then
      pixel.target_x += (rnd(2) - 1) * 3
      pixel.target_y += (rnd(2) - 1) * 3
    end
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
function update_attention_schema(pixel)
  attention_schema.self_model.position.x = pixel.x
  attention_schema.self_model.position.y = pixel.y
  attention_schema.self_model.confidence = min(1, pixel.energy / 100)
  attention_schema.attention_map = {}
  if cursor_interaction.is_aware then
    add(attention_schema.attention_map, {
      x = mouse_cursor.x,
      y = mouse_cursor.y,
      intensity = cursor_interaction.attention_level,
      type = "cursor"
    })
  end
  for cube in all(energy_cubes) do
    local distance = dist(pixel.x, pixel.y, cube.x, cube.y)
    local attention_intensity = max(0, 1 - distance / 60)
    if pixel.energy < 40 then
      attention_intensity *= 2
    end
    add(attention_schema.attention_map, {
      x = cube.x,
      y = cube.y,
      intensity = attention_intensity,
      type = "energy"
    })
  end
  make_predictions()
end
function make_predictions()
  if cursor_interaction.last_cursor_x and cursor_interaction.last_cursor_y then
    local dx = mouse_cursor.x - cursor_interaction.last_cursor_x
    local dy = mouse_cursor.y - cursor_interaction.last_cursor_y
    local predicted_x = mouse_cursor.x + dx
    local predicted_y = mouse_cursor.y + dy
    if cursor_interaction.last_predicted_x then
      local error_x = abs(mouse_cursor.x - cursor_interaction.last_predicted_x)
      local error_y = abs(mouse_cursor.y - cursor_interaction.last_predicted_y)
      local new_error = (error_x + error_y) / 2
      if new_error < 3 and attention_schema.prediction_error > 5 then
        sfx(5)
      end
      attention_schema.prediction_error = new_error
    end
    cursor_interaction.last_predicted_x = predicted_x
    cursor_interaction.last_predicted_y = predicted_y
  end
end
function update_predictive_processing(pixel)
  predict_cursor_behavior(pixel)
  predict_energy_patterns(pixel)
  update_predictions_from_errors(pixel)
end
function predict_cursor_behavior(pixel)
  if cursor_interaction.is_aware then
    local movement_speed = dist(mouse_cursor.x, cursor_interaction.last_cursor_x,
                               mouse_cursor.y, cursor_interaction.last_cursor_y)
    local predicted_stillness = movement_speed < 1
    local actual_stillness = cursor_interaction.stillness_timer > 30
    if predicted_stillness != actual_stillness then
      if actual_stillness and not predicted_stillness then
        pixel.personality.timidity = min(1, pixel.personality.timidity + 0.005)
      elseif not actual_stillness and predicted_stillness then
        pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.005)
      end
    end
  end
end
function predict_energy_patterns(pixel)
  local predicted_energy = pixel.energy - 0.02
  local activity_level = abs(pixel.x - (pixel.last_x or pixel.x)) + 
                        abs(pixel.y - (pixel.last_y or pixel.y))
  predicted_energy -= activity_level * 0.01
  pixel.last_x = pixel.x
  pixel.last_y = pixel.y
end
function update_predictions_from_errors(pixel)
  if attention_schema.prediction_error > 0.1 then
    cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + 0.02)
    pixel.personality.timidity = min(1, pixel.personality.timidity + 0.002)
  end
end
function calculate_phi(pixel_state)
  if not pixel_state or not pixel_state.memories or not pixel_state.emo_state then
    return 0
  end
  local sensory_integration = 0
  local memory_integration = 0
  local emotional_integration = 0
  local behavioral_integration = 0
  if cursor_interaction.is_aware and cursor_interaction.attention_level > 0 then
    sensory_integration = cursor_interaction.attention_level^1.2 * 0.4
  end
  if #energy_cubes > 0 then
    local energy_awareness = min(#energy_cubes / 5, 1) * 0.25
    sensory_integration += energy_awareness
  end
  if #pixel_state.memories > 0 then
    local memory_density = min(#pixel_state.memories / memory_size, 1)
    local total_memory_impact = 0
    for memory in all(pixel_state.memories) do
      total_memory_impact += (memory.emotional_impact or 0)
    end
    memory_integration = memory_density * min(total_memory_impact / #pixel_state.memories, 1) * 0.35
  end
  local emotional_diversity = 0
  local emotional_sum = 0
  local active_emotions = 0
  for emotion_name, value in pairs(pixel_state.emo_state) do
    emotional_sum += value
    if value > 0.1 then
      active_emotions += 1
      emotional_diversity += value * value
    end
  end
  if active_emotions > 0 then
    emotional_integration = min(emotional_diversity / (active_emotions + 1), 1) * 0.3
  else
    emotional_integration = 0
  end
  if pixel_state.target_x and pixel_state.target_y then
    local movement_coherence = 1 - min(abs(pixel_state.x - pixel_state.target_x) + 
                                      abs(pixel_state.y - pixel_state.target_y), 50) / 50
    behavioral_integration = movement_coherence * 0.2
  end
  local component_sum = sensory_integration + memory_integration + 
                       emotional_integration + behavioral_integration
  local component_count = 4
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
  for pixel in all(pixels) do
    update_movement(pixel)
    update_emotions(pixel)
    process_metacognition(pixel)
    generate_creative_behavior(pixel)
    dream_processing(pixel)
    update_global_workspace(pixel)
    update_attention_schema(pixel)
    update_predictive_processing(pixel)
    local old_consciousness = pixel.consc_level or 0
    pixel.consc_level = calculate_phi(pixel)
    if pixel.consc_level > old_consciousness + 0.1 then
      sfx(3)
    end
    pixel.energy = max(0, pixel.energy - 0.02)
    check_energy_sources(pixel)
    form_memories(pixel)
  end
  update_biological_processes()
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
  if pixel.stuck_timer and pixel.stuck_timer > 60 then
    pixel.target_x = mouse_cursor.x
    pixel.target_y = mouse_cursor.y
    move_speed = 0.7
  elseif nearest_cube and pixel.energy < 30 then
    pixel.target_x = nearest_cube.x
    pixel.target_y = nearest_cube.y
    if pixel.energy < 15 then
      move_speed = 0.8
    end
  else
    if rnd(1) < 0.02 then
      pixel.target_x = 20 + rnd(88)
      pixel.target_y = 20 + rnd(88)
    end
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
  local dx = pixel.target_x - pixel.x
  local dy = pixel.target_y - pixel.y
  local dist_to_target = sqrt(dx*dx + dy*dy)
  if dist_to_target > 2 then
    dx = dx / dist_to_target
    dy = dy / dist_to_target
    local timidity_factor = 1 - pixel.personality.timidity * 0.5
    local energy_cons = pixel.personality.energy_cons
    local final_speed = move_speed * timidity_factor
    if pixel.energy > 70 and energy_cons > 0.7 then
      final_speed *= 0.7
    end
    pixel.x += dx * final_speed
    pixel.y += dy * final_speed
    pixel.x = mid(4, pixel.x, 124)
    pixel.y = mid(4, pixel.y, 124)
    if pixel.last_x and pixel.last_y then
      local movement = abs(pixel.x - pixel.last_x) + abs(pixel.y - pixel.last_y)
      if movement < 0.1 then
        pixel.stuck_timer = (pixel.stuck_timer or 0) + 1
        if pixel.stuck_timer > 60 then
          pixel.target_x = mouse_cursor.x
          pixel.target_y = mouse_cursor.y
          pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.01)
          if pixel.stuck_timer > 180 then
            pixel.stuck_timer = 0
            pixel.target_x = 32 + rnd(64)
            pixel.target_y = 32 + rnd(64)
          end
        end
      else
        pixel.stuck_timer = 0
      end
    end
    pixel.last_x = pixel.x
    pixel.last_y = pixel.y
  end
end
function update_emotions(pixel)
  pixel.emo_state.excitement *= 0.985
  pixel.emo_state.happiness *= 0.99
  if cursor_interaction.stillness_timer > 120 then
    pixel.emo_state.excitement *= 0.97
  end
  if pixel.energy < 30 then
    pixel.emo_state.distress = (30 - pixel.energy) / 30
  else
    pixel.emo_state.distress *= 0.95
  end
  if pixel.emo_state.distress > 0.7 then
    pixel.color = 8
  elseif pixel.emo_state.excitement > 0.7 then
    pixel.color = 14
  elseif pixel.emo_state.happiness > 0.7 then
    pixel.color = 11
  else
    pixel.color = 7
  end
end
function init_energy_system()
  energy_cubes = {}
end
function create_initial_energy_cubes()
  for i=1,3 do
    add_energy_cube()
  end
end

function create_center_energy_cubes()
  -- Create 3 energy cubes positioned around the center of the screen
  local center_x = 64
  local center_y = 64
  local positions = {
    {x = center_x - 15, y = center_y - 10},
    {x = center_x + 15, y = center_y - 10},
    {x = center_x, y = center_y + 15}
  }
  
  for i = 1, 3 do
    add(energy_cubes, {
      x = positions[i].x,
      y = positions[i].y,
      value = 20 + flr(rnd(15))
    })
  end
end

function add_energy_cube()
  local x = 10 + rnd(108)
  local y = 10 + rnd(108)
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
  for i=#energy_cubes,1,-1 do
    local cube = energy_cubes[i]
    if dist(pixel.x, pixel.y, cube.x, cube.y) < (4 + pixel.size) then
      local absorbed_energy = cube.value * pixel.metab_eff
      pixel.energy = min(100, pixel.energy + absorbed_energy)
      sig_event = true
      event_type = "nutrient_consumed"
      emotion_impact = 0.3 + rnd(0.2)
      pixel.emo_state.happiness += 0.2
      pixel.emo_state.excitement += 0.1
      pixel.size = min(2.5, pixel.size + 0.08)
      pixel.div_progress = min(100, pixel.div_progress + 10)
      del(energy_cubes, cube)
      sfx(1)
      add_energy_cube()
    end
  end
  if #energy_cubes == 1 then
    for i=1,3 do
      add_energy_cube()
    end
  elseif #energy_cubes < 5 and rnd(1) < 0.02 then
    add_energy_cube()
  end
end
function interact_with_pixel(pixel)
  local base_impact = 0.2 + rnd(0.3)
  local awareness_multiplier = 1 + cursor_interaction.attention_level * 0.5
  local emotional_impact = base_impact * awareness_multiplier
  if cursor_interaction.is_aware then
    emotional_impact *= 1.3
    sig_event = true
    event_type = "anticipated_interaction"
    emotion_impact = emotional_impact
  else
    emotional_impact *= 1.5
    pixel.emo_state.excitement += 0.2
    event_type = "surprise_interaction"
  end
  pixel.emo_state.excitement += emotional_impact
  pixel.emo_state.excitement = min(pixel.emo_state.excitement, 1)
  if cursor_interaction.attention_level > 0.5 then
    pixel.personality.timidity = max(0, pixel.personality.timidity - 0.02)
    pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.01)
  else
    pixel.personality.timidity = min(1, pixel.personality.timidity + 0.005)
  end
  cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + 0.3)
  cursor_interaction.approach_timer = 0
  cursor_interaction.retreat_timer = 0
  sig_event = true
  emotion_impact = emotional_impact
  sfx(0)
end
function record_interaction(type)
  sig_event = true
  event_type = type
  emotion_impact = 0.1 + rnd(0.2)
end
function can_divide(pixel)
  return pixel.energy >= div_energy and 
         pixel.division_timer <= 0 and 
         #pixels < max_pixels and
         pixel.age > 20 and
         pixel.div_progress >= 50 and
         cur_gen < max_gen
end
function divide_pixel(pixel_index)
  if pixel_index < 1 or pixel_index > #pixels then
    return
  end
  local parent = pixels[pixel_index]
  if not parent then
    return
  end
  local child_personality = {}
  for trait, value in pairs(parent.personality) do
    local mutation = (rnd(2) - 1) * mutation_rate
    child_personality[trait] = mid(0, value + mutation, 1)
  end
  local division_angle = rnd(1) * 6.2831853
  local separation_distance = parent.size * 2 + 1
  local offset_x = cos(division_angle) * separation_distance
  local offset_y = sin(division_angle) * separation_distance
  local child_x = parent.x + offset_x
  local child_y = parent.y + offset_y
  parent.x = parent.x - offset_x * 0.5
  parent.y = parent.y - offset_y * 0.5
  child_x = mid(8, child_x, 120)
  child_y = mid(8, child_y, 120)
  parent.x = mid(8, parent.x, 120)
  parent.y = mid(8, parent.y, 120)
  local child = create_pixel(child_x, child_y, child_personality)
  child.generation = parent.generation
  child.parent_id = parent.id
  local total_energy = parent.energy
  child.energy = flr(total_energy * 0.5)
  parent.energy = flr(total_energy * 0.5)
  child.size = parent.size * (0.9 + rnd(0.2))
  child.metab_eff = parent.metab_eff * (0.95 + rnd(0.1))
  child.repro_drive = parent.repro_drive * (0.95 + rnd(0.1))
  parent.division_timer = div_cooldown
  parent.div_progress = 0
  child.div_progress = 0
  parent.size = parent.size * 0.9
  if #pixels < max_pixels then
    add(pixels, child)
    sig_event = true
    event_type = "division"
    emotion_impact = 0.4
    sfx(8)
    parent.emo_state.excitement = min(1, parent.emo_state.excitement + 0.3)
    child.emo_state.excitement = min(1, child.emo_state.excitement + 0.2)
    save_game_state()
  end
end
function kill_pixel(pixel_index)
  if pixel_index < 1 or pixel_index > #pixels then
    return
  end
  local dying_pixel = pixels[pixel_index]
  if not dying_pixel then
    return
  end
  local decomp_energy = flr(dying_pixel.energy * 0.3)
  if decomp_energy > 5 then
    for i = 1, min(3, flr(decomp_energy / 8)) do
      local cube_x = clamp(dying_pixel.x + rnd(16) - 8, 8, 120)
      local cube_y = clamp(dying_pixel.y + rnd(16) - 8, 8, 120)
      add(energy_cubes, {
        x = cube_x,
        y = cube_y,
        value = 8 + rnd(7)
      })
    end
  end
  sig_event = true
  event_type = "death"
  emotion_impact = 0.2
  sfx(9)
  del(pixels, pixels[pixel_index])
  if #pixels == 0 then
    add(pixels, create_pixel(64 + rnd(8) - 4, 64 + rnd(8) - 4, {
      curiosity = 0.3 + rnd(0.4),
      timidity = 0.3 + rnd(0.4), 
      energy_cons = 0.3 + rnd(0.4)
    }))
  end
end
function update_biological_processes()
  for i = #pixels, 1, -1 do
    local pixel = pixels[i]
    pixel.age += 1
    pixel.division_timer = max(0, pixel.division_timer - 1)
    local energy_cost = metabolic_rate * pixel.metab_eff
    pixel.energy = max(0, pixel.energy - energy_cost)
    if pixel.energy > div_energy * 0.6 then
      local growth_amount = pixel.repro_drive * 1.5
      pixel.div_progress = min(100, pixel.div_progress + growth_amount)
      pixel.size = min(2.5, pixel.size + 0.02)
    else
      pixel.div_progress = max(0, pixel.div_progress - 0.2)
      pixel.size = max(0.5, pixel.size - 0.005)
    end
    if can_divide(pixel) then
      divide_pixel(i)
    end
  end
end
function update_generation_system()
  gen_timer += 1
  if gen_timer >= gen_interval then
    if cur_gen < max_gen then
      cur_gen += 1
      gen_timer = 0
      sig_event = true
      event_type = "generation_advance"
      emotion_impact = 0.5
      sfx(3)
      for pixel in all(pixels) do
        pixel.emo_state.excitement = min(1, pixel.emo_state.excitement + 0.2)
        pixel.repro_drive = min(1, pixel.repro_drive + 0.2)
        pixel.div_progress = min(100, pixel.div_progress + 20)
      end
      save_game_state()
    end
  end
end
function draw_pixel()
  for pixel in all(pixels) do
    draw_single_pixel(pixel)
  end
end
function draw_single_pixel(pixel)
  local generation_colors = {7, 12, 11, 3, 9, 10, 4, 2, 8, 14, 13, 1, 5, 6, 15}
  local base_color = generation_colors[pixel.generation] or 7
  local radius = flr(pixel.size)
  circfill(pixel.x, pixel.y, radius, base_color)
  if pixel.div_progress > 50 then
    local elongation = (pixel.div_progress - 50) / 50
    oval(pixel.x - radius - elongation, pixel.y - radius, 
         pixel.x + radius + elongation, pixel.y + radius, base_color)
  end
  if can_divide(pixel) then
    local pulse = sin(pixel.age * 0.2) * 0.5 + 0.5
    circ(pixel.x, pixel.y, radius + 2 + pulse, 11)
  end
  if pixel.stuck_timer and pixel.stuck_timer > 60 then
    line(pixel.x, pixel.y, mouse_cursor.x, mouse_cursor.y, 12)
    local pulse = sin(pixel.age * 0.3) * 1 + 1
    circ(pixel.x, pixel.y, radius + 3 + pulse, 12)
  end
  if pixel.energy > div_energy * 0.8 then
    for i=1,3 do
      circ(pixel.x, pixel.y, radius + i, 7)
    end
  elseif pixel.energy < death_energy + 10 then
    circ(pixel.x, pixel.y, radius + 1, 8)
  end
  local closest_pixel = find_closest_pixel_to_cursor()
  if pixel == closest_pixel and cursor_interaction.is_aware and cursor_interaction.attention_level > 0.3 then
    local eye_x = pixel.x + cursor_interaction.gaze_offset_x
    local eye_y = pixel.y + cursor_interaction.gaze_offset_y
    pset(eye_x, eye_y, 0)
    local iris_color = 5
    if pixel.emo_state.excitement > 0.6 then
      iris_color = 12
    elseif pixel.emo_state.distress > 0.6 then
      iris_color = 8
    elseif pixel.emo_state.happiness > 0.6 then
      iris_color = 11
    end
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
  if pixel.age > 600 then
    pset(pixel.x, pixel.y - 4, 13)
  end
  if pixel == pixels[1] then
    for i=1,#pixel.memories do
      local mem = pixel.memories[i]
      local alpha = i/#pixel.memories
      pset(mem.x, mem.y, 1)
    end
  end
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
    rectfill(cube.x-2, cube.y-2, cube.x+2, cube.y+2, 14)
  end)
end
function draw_background()
  for x=0,127,8 do
    for y=0,127,8 do
      pset(x, y, 1)
    end
  end
end
function draw_ui()
  local primary_pixel = (#pixels > 0) and pixels[1] or {
    consc_level = 0,
    energy = 0,
    personality = {curiosity = 0, timidity = 0},
    emo_state = {happiness = 0, excitement = 0, distress = 0}
  }
  print("conscious", 4, 4, 7)
  local phi_bar_width = min(30, flr(primary_pixel.consc_level * 30))
  rectfill(4, 13, 4 + phi_bar_width, 15, 14)
  rect(3, 12, 34, 16, 5)
  print("energy", 4, 21, 7)
  local energy_bar_width = min(10, primary_pixel.energy/10)
  rectfill(4, 27, 4 + energy_bar_width, 29, 11)
  rect(3, 26, 14, 30, 5)
  print("curiosity:"..flr(primary_pixel.personality.curiosity*10), 4, 105, 7)
  print("timidity:"..flr(primary_pixel.personality.timidity*10), 4, 111, 7)
  print("population:"..#pixels, 4, 117, 7)
  print("current gen:"..cur_gen, 4, 123, 7)
  local gen_counts = {}
  for pixel in all(pixels) do
    gen_counts[pixel.generation] = (gen_counts[pixel.generation] or 0) + 1
  end
  local y_offset = 129
  for gen = 1, cur_gen do
    if gen_counts[gen] then
      local generation_colors = {7, 12, 11, 3, 9, 10, 4, 2, 8, 14, 13, 1, 5, 6, 15}
      local color = generation_colors[gen] or 7
      print("g"..gen..":"..gen_counts[gen], 4, y_offset, color)
      y_offset += 6
    end
  end
  local emo_x = 100
  local emo_y = 4
  local avg_excitement = 0
  local avg_distress = 0
  local avg_happiness = 0
  if #pixels > 0 then
    for pixel in all(pixels) do
      avg_excitement += pixel.emo_state.excitement
      avg_distress += pixel.emo_state.distress
      avg_happiness += pixel.emo_state.happiness
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
  if cursor_interaction.is_aware then
    local awareness_text = "aware"
    local awareness_color = 11
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      awareness_text = "bored"
      awareness_color = 6
    elseif cursor_interaction.attention_level > 0.8 then
      awareness_text = "focused"
      awareness_color = 14
    elseif cursor_interaction.attention_level > 0.5 then
      awareness_text = "watching"
      awareness_color = 12
    end
    print(awareness_text, emo_x, emo_y + 8, awareness_color)
    local bar_width = flr(cursor_interaction.attention_level * 20)
    local bar_color = awareness_color
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      bar_color = 5
    end
    rectfill(emo_x, emo_y + 16, emo_x + bar_width, emo_y + 17, bar_color)
    rect(emo_x - 1, emo_y + 15, emo_x + 21, emo_y + 18, 5)
  end
  if attention_schema.prediction_error > 0.05 then
    print("prediction error", emo_x, emo_y + 24, 8)
  end
  local focus_y = 116
  local focus_label = "focus:"
  local label_x = 128 - (#focus_label * 4)
  print(focus_label, label_x, focus_y, 7)
  if global_workspace.current_focus then
    local focus_color = 12
    if global_workspace.current_focus.type == "cursor_attention" then
      focus_color = 11
    elseif global_workspace.current_focus.type == "energy_seeking" then
      focus_color = 14
    elseif global_workspace.current_focus.type == "emo_state" then
      focus_color = 8
    end
    local status_text = global_workspace.current_focus.type
    local status_x = 128 - (#status_text * 4)
    print(status_text, status_x, focus_y + 6, focus_color)
  else
    local diffuse_text = "diffuse"
    local diffuse_x = 128 - (#diffuse_text * 4)
    print(diffuse_text, diffuse_x, focus_y + 6, 11)
  end
  if save_timer > 0 then
    local text_color = 11
    if save_text == "saved" then
      text_color = 12
    elseif save_text == "resumed" then
      text_color = 14
    elseif save_text == "cleared" then
      text_color = 8
    end
    local text = save_text
    local text_x = 128 - (#text * 4) - 4
    print(text, text_x, 40, text_color)
  end
end
function draw_cursor()
  if mouse_cursor.visible then
    local cursor_x = mouse_cursor.x
    local cursor_y = mouse_cursor.y
    local primary_pixel = (#pixels > 0) and pixels[1] or {x = 64, y = 64}
    if dist(cursor_x, cursor_y, primary_pixel.x, primary_pixel.y) < 15 then
      line(cursor_x-4, cursor_y, cursor_x+4, cursor_y, 11)
      line(cursor_x, cursor_y-4, cursor_x, cursor_y+4, 11)
      circfill(cursor_x, cursor_y, 2, 11)
      circ(cursor_x, cursor_y, 6, 11)
    else
      line(cursor_x-3, cursor_y, cursor_x+3, cursor_y, 7)
      line(cursor_x, cursor_y-3, cursor_x, cursor_y+3, 7)
      circfill(cursor_x, cursor_y, 1, 7)
    end
    if cursor_interaction.is_aware then
      local awareness_color = 13
      local awareness_radius = 8 + cursor_interaction.attention_level * 4
      circ(cursor_x, cursor_y, awareness_radius, awareness_color)
      if cursor_interaction.attention_level > 0.6 then
        local sparkle_count = flr(cursor_interaction.attention_level * 4)
        for i = 1, sparkle_count do
          local angle = (time() + i) * 2
          local sparkle_radius = 10 + i * 2
          local sparkle_x = cursor_x + cos(angle) * sparkle_radius
          local sparkle_y = cursor_y + sin(angle) * sparkle_radius
          pset(sparkle_x, sparkle_y, 14)
        end
      end
    end
  end
end
function dist(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return sqrt(dx*dx + dy*dy)
end
function load_sounds()
end
function save_game_state()
  if #pixels == 0 then return end
  dset(0, 1)
  dset(1, cur_gen)
  dset(2, pixel_counter)
  dset(3, #pixels)
  dset(4, #energy_cubes)
  dset(5, gen_timer)
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
    dset(base_slot + 6, pixel.personality.energy_cons)
    dset(base_slot + 7, pixel.number)
  end
  local cube_count = min(#energy_cubes, 8)
  for i = 1, cube_count do
    local cube = energy_cubes[i]
    local base_slot = 80 + (i - 1) * 3
    dset(base_slot, cube.x)
    dset(base_slot + 1, cube.y)
    dset(base_slot + 2, cube.value)
  end
  dset(100, cursor_interaction.attention_level or 0)
  dset(101, global_workspace.broadcast_strength or 0)
  show_save_notification("saved")
end
function show_save_notification(message)
  save_text = message
  save_timer = 120
end
function clear_save_data()
  for i = 0, 120 do
    dset(i, 0)
  end
  pixels = {}
  energy_cubes = {}
  cur_gen = 1
  pixel_counter = 0
  gen_timer = 0
  init_consciousness()
  create_initial_energy_cubes()
  show_save_notification("cleared")
end
function load_game_state()
  local save_exists = dget(0)
  if not save_exists or save_exists == 0 then
    return false
  end
  cur_gen = dget(1) or 1
  pixel_counter = dget(2) or 0
  local saved_pixel_count = dget(3) or 0
  local saved_cube_count = dget(4) or 0
  gen_timer = dget(5) or 0
  pixels = {}
  energy_cubes = {}
  for i = 1, min(saved_pixel_count, 8) do
    local base_slot = 10 + (i - 1) * 8
    local x = dget(base_slot) or 64
    local y = dget(base_slot + 1) or 64
    local energy = dget(base_slot + 2) or 60
    local generation = dget(base_slot + 3) or 1
    local curiosity = dget(base_slot + 4) or 0.5
    local timidity = dget(base_slot + 5) or 0.5
    local energy_cons = dget(base_slot + 6) or 0.5
    local number = dget(base_slot + 7) or i
    local pixel = create_pixel(x, y, {
      curiosity = curiosity,
      timidity = timidity,
      energy_cons = energy_cons
    })
    pixel.energy = energy
    pixel.generation = generation
    pixel.number = number
    add(pixels, pixel)
  end
  -- Clear all energy cubes and create 3 new ones in the center
  energy_cubes = {}
  create_center_energy_cubes()
  cursor_interaction.attention_level = dget(100) or 0
  global_workspace.broadcast_strength = dget(101) or 0
  if #pixels == 0 then
    add(pixels, create_pixel(64, 64, {
      curiosity = 0.5,
      timidity = 0.4,
      energy_cons = 0.5
    }))
  end
  show_save_notification("resumed")
  return true
end
function process_metacognition(pixel)
  if #pixel.memories > 5 then
    local pattern_recognition = 0
    for i=max(1, #pixel.memories-4), #pixel.memories do
      local mem = pixel.memories[i]
      if mem.type == "energy_consumed" then
        pattern_recognition += 1
      end
    end
    if pattern_recognition > 3 then
      pixel.personality.curiosity = min(1, pixel.personality.curiosity + 0.05)
      sig_event = true
      event_type = "self_reflection"
      emotion_impact = 0.1
    end
  end
end
function generate_creative_behavior(pixel)
  if pixel.personality.curiosity > 0.8 and rnd(1) < 0.02 then
    local spiral_radius = 10 + rnd(20)
    local angle = time() * 2
    pixel.target_x = 64 + cos(angle) * spiral_radius
    pixel.target_y = 64 + sin(angle) * spiral_radius
    sig_event = true
    event_type = "creative_expression"
    emotion_impact = 0.2
  end
end
function dream_processing(pixel)
  if pixel.energy < 20 and rnd(1) < 0.1 then
    for i=1,#pixel.memories do
      local mem = pixel.memories[i]
      if mem.emotional_impact > 0.2 then
        pset(mem.x + rnd(6)-3, mem.y + rnd(6)-3, 13)
      end
    end
    if rnd(1) < 0.01 then
      pixel.personality.timidity = max(0, pixel.personality.timidity - 0.005)
    end
  end
end
function update_cursor_awareness()
  if not mouse_cursor.visible or #pixels == 0 then
    return
  end
  local pixel = pixels[1]
  local cursor_distance = dist(pixel.x, pixel.y, mouse_cursor.x, mouse_cursor.y)
  local awareness_range = 50 + pixel.personality.curiosity * 30
  local cursor_moved = abs(mouse_cursor.x - cursor_interaction.last_cursor_x) > 2 or 
                      abs(mouse_cursor.y - cursor_interaction.last_cursor_y) > 2
  if cursor_moved then
    cursor_interaction.stillness_timer = 0
    cursor_interaction.last_cursor_x = mouse_cursor.x
    cursor_interaction.last_cursor_y = mouse_cursor.y
  else
    cursor_interaction.stillness_timer += 1
  end
  if cursor_distance < awareness_range then
    cursor_interaction.is_aware = true
    local old_attention = cursor_interaction.attention_level
    local attention_gain = 0.05
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      attention_gain = -0.03
      cursor_interaction.attention_level = max(0, cursor_interaction.attention_level + attention_gain)
      if old_attention > 0.5 and cursor_interaction.attention_level < 0.5 then
        sfx(7)
      end
    else
      cursor_interaction.attention_level = min(1, cursor_interaction.attention_level + attention_gain)
      if old_attention < 0.8 and cursor_interaction.attention_level >= 0.8 then
        sfx(4)
      end
    end
    local dx = mouse_cursor.x - pixel.x
    local dy = mouse_cursor.y - pixel.y
    local gaze_strength = 0.3 + pixel.personality.curiosity * 0.4
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      gaze_strength *= 0.3
    end
    cursor_interaction.gaze_offset_x = dx * gaze_strength / cursor_distance
    cursor_interaction.gaze_offset_y = dy * gaze_strength / cursor_distance
    local boredom_factor = 1.0
    if cursor_interaction.stillness_timer > cursor_interaction.max_stillness_threshold then
      boredom_factor = 0.1
    end
    if cursor_distance < 20 then
      pixel.emo_state.excitement += 0.02 * boredom_factor
      if pixel.personality.timidity > 0.5 then
        pixel.emo_state.distress += 0.01 * boredom_factor
        cursor_interaction.retreat_timer += 1
      else
        pixel.emo_state.happiness += 0.01 * boredom_factor
        cursor_interaction.approach_timer += 1
      end
    elseif cursor_distance < 35 then
      pixel.emo_state.excitement += 0.01 * boredom_factor
      cursor_interaction.curiosity_triggered = true
    end
    if cursor_interaction.stillness_timer <= cursor_interaction.max_stillness_threshold then
      influence_movement_by_cursor(pixel, cursor_distance)
    end
  else
    cursor_interaction.is_aware = false
    cursor_interaction.attention_level = max(0, cursor_interaction.attention_level - 0.02)
    cursor_interaction.curiosity_triggered = false
    cursor_interaction.approach_timer = max(0, cursor_interaction.approach_timer - 1)
    cursor_interaction.retreat_timer = max(0, cursor_interaction.retreat_timer - 1)
    cursor_interaction.stillness_timer = 0
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
  if pixel.personality.curiosity > 0.6 and cursor_distance > 15 and cursor_distance < 80 then
    local approach_factor = (pixel.personality.curiosity - 0.6) * 2.5
    pixel.target_x = lerp(pixel.target_x, mouse_cursor.x, influence_strength * approach_factor * 0.1)
    pixel.target_y = lerp(pixel.target_y, mouse_cursor.y, influence_strength * approach_factor * 0.1)
  end
  if pixel.personality.timidity > 0.5 and cursor_distance < 25 then
    local retreat_factor = pixel.personality.timidity * 2
    local retreat_x = pixel.x + (pixel.x - mouse_cursor.x) * 0.3
    local retreat_y = pixel.y + (pixel.y - mouse_cursor.y) * 0.3
    pixel.target_x = lerp(pixel.target_x, retreat_x, influence_strength * retreat_factor * 0.15)
    pixel.target_y = lerp(pixel.target_y, retreat_y, influence_strength * retreat_factor * 0.15)
  end
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
  if stat(36) > 0 then
    local mouse_x = mouse_cursor.x
    local mouse_y = mouse_cursor.y
    local clicked_pixel = nil
    for pixel in all(pixels) do
      if dist(mouse_x, mouse_y, pixel.x, pixel.y) < 15 then
        clicked_pixel = pixel
        break
      end
    end
    if clicked_pixel then
      interact_with_pixel(clicked_pixel)
      save_game_state()
    else
      add(energy_cubes, {
        x = mouse_x,
        y = mouse_y,
        value = 25
      })
      record_interaction("energy_placed")
      sfx(2)
    end
  end
  if btnp(5) then
    save_game_state()
    sfx(1)
  end
  if btn(4) and btnp(5) then
    clear_save_data()
    sfx(0)
  end
  if save_timer > 0 then
    save_timer -= 1
  end
  if t() % 600 == 0 then
    save_game_state()
  end
  update_generation_system()
  update_consciousness()
  update_cursor_awareness()
  update_biological_processes()
end
function _draw()
  if game_state == "splash" then
    draw_splash_screen()
    return
  end
  cls(0)
  draw_background()
  draw_energy_cubes()
  draw_pixel()
  draw_ui()
  draw_cursor()
end
function draw_splash_screen()
  cls(9)
  local symbol_x = 64
  local symbol_y = 40
  draw_simple_symbol(symbol_x, symbol_y, 0)
  local title = "sentium"
  local title_width = #title * 4
  local title_x = (128 - title_width) / 2
  print(title, title_x, 65, 0)
  local subtitle = "consciousness simulation"
  local sub_width = #subtitle * 4
  local sub_x = (128 - sub_width) / 2
  print(subtitle, sub_x, 80, 0)
  local instruction = "sentium pico v1.0.0"
  local inst_width = #instruction * 4
  local inst_x = (128 - inst_width) / 2
  print(instruction, inst_x, 95, 0)
end
function draw_simple_symbol(x, y, color)
  circfill(x, y, 12, color)
  circfill(x, y, 7, 9)
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
function draw_large_text(text, x, y, color)
  local char_width = 12
  local char_height = 15
  for i = 1, #text do
    local char = sub(text, i, i)
    local char_x = x + (i - 1) * char_width
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
001000000c0500a050080500605004050020500105000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
001000000e0500f050100501105012050130501405015050160501705018050190501805017050160501505014050130501205011050100502005000050000500005000050000500005000050000500005000050
001000000605008050090500a0500b0500c0500d0500e0500f050110501205013050140501505016050170501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a05009050
001000001c0501a050180501605014050120501005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050
001000000c0550b0550a0550905508055070550605505055040550305502055010550005500055000550005500055000550005500055000550005500055000550005500055000550005500055000550005500055
001000001305014050150501605017050180501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a0500905008050070500605005050040500305002050010500005000050
0010000018050190501a0501b0501c0501d0501e0501f050200502105022050230502405025050260502705028050290502a0502b0502c0502d0502e0502f0503005031050320503305034050350503605037050
001000001f0501e0501d0501c0501b0501a050190501805017050160501505014050130501205011050100500f0500e0500d0500c0500b0500a05009050080500705006050050500405003050020500105000050
__music__
00 41424344
0f 0c424344
00 0e424344
0e 41424344
0f 0c424344
00 0f424344
00 0f424344
00 0f424344
00 41424344
00 41424344
0e 41424344
00 41424344
0e 41424344
0e 41424344
0f 0c424344
00 0e424344
0e 41424344
0f 0c424344
00 41424344
00 41424344
00 41424344
00 41424344
00 0f424344
0f 0f424344
00 41424344
00 41424344
0e 0e424344
0e 41424344
0f 0f424344
00 41424344
00 41424344
0e 0e424344
0e 41424344
0e 41424344

