pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- crazy-cat.p8

--[[
  a simple game about a cat
  that goes crazy for red dots
--]]

cat = {}

dot = {
  x = 32,
  y = 32,
  size = 4
}

score = 0

function _init()
  cat = create_pixel(64, 64, {
    curiosity = 0.9,
    timidity = 0.1,
    energy_cons = 0.5
  })
end

function _update()
  update_consciousness()

  -- check for collision
  if (abs(cat.x - dot.x) < cat.size and
      abs(cat.y - dot.y) < cat.size) then
    -- move dot to random position
    dot.x = rnd(128)
    dot.y = rnd(128)
    score += 1
    cat.emo_state.happiness = min(1, cat.emo_state.happiness + 0.5)
    cat.emo_state.excitement = min(1, cat.emo_state.excitement + 0.3)
  end
end

function _draw()
  cls()
  
  -- draw cat (32x32 version)
  local frame = flr(time() * 4) % 2
  spr(frame * 16, cat.x, cat.y, 4, 4)

  -- draw dot
  circfill(dot.x, dot.y, dot.size, 8)

  -- draw score
  print("score: "..score, 8, 8, 7)
end

function create_pixel(x, y, personality)
  return {
    x = x,
    y = y,
    color = 8,
    energy = 100,
    memories = {},
    consc_level = 0,
    last_x = x,
    last_y = y,
    age = 0,
    generation = 1,
    division_timer = 0,
    parent_id = nil,
    id = 1,
    number = 1,
    personality = personality,
    emo_state = {
      happiness = 0.5,
      excitement = 0.5,
      distress = 0
    },
    target_x = x,
    target_y = y,
    size = 16,
    div_progress = 0,
    metab_eff = 1,
    repro_drive = 0,
    stuck_timer = 0
  }
end

function update_consciousness()
  update_movement(cat)
  update_emotions(cat)
  cat.consc_level = calculate_phi(cat)
end

function update_movement(pixel)
  local move_speed = 1.5

  -- always target the dot
  pixel.target_x = dot.x
  pixel.target_y = dot.y

  local dx = pixel.target_x - pixel.x
  local dy = pixel.target_y - pixel.y
  local dist_to_target = sqrt(dx*dx + dy*dy)

  if dist_to_target > 2 then
    dx = dx / dist_to_target
    dy = dy / dist_to_target
    
    local final_speed = move_speed
    pixel.x += dx * final_speed
    pixel.y += dy * final_speed

    -- constrain to screen
    pixel.x = max(16, min(112, pixel.x))
    pixel.y = max(16, min(112, pixel.y))
  end
end

function update_emotions(pixel)
  pixel.emo_state.excitement *= 0.985
  pixel.emo_state.happiness *= 0.99
  pixel.emo_state.distress *= 0.95

  if pixel.emo_state.excitement > 0.7 then
    pixel.color = 14
  elseif pixel.emo_state.happiness > 0.7 then
    pixel.color = 11
  else
    pixel.color = 7
  end
end

function calculate_phi(p)
  local e = (p.emo_state.happiness + p.emo_state.excitement) * 0.5
  local b = p.target_x and 1 - min(abs(p.x - p.target_x) + abs(p.y - p.target_y), 50) / 50 * 0.5 or 0
  return min((e + b) / 2, 1)
end

function sqrt(n)
  return n^0.5
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000111000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000100000000000ddd100000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000066610000000006ddd100000000000000000000000000000000000000000000000000000000000000000000
00000006dd00000000000ddd0000000000000000006edd1111111166eed1000000000000000000000000000000000000000000000000dd000000000ddd000000
00000006ddd000000000ddd70000000000000000006eed4ffffff446eed100000000000000000000dd0000000dd00000000000000000ddd0000000dddd000000
00000006e66444444444d6e70000000000000000006eefffffffffffee61000000000fff000000006ed000000d600000000000000000d5dd00000ddded000000
00000006e45eeeee4eee45e70000000000000000006efffffffffffff661000000000ddf000000006eedfffdf4600000000000000000de4e4eeee444ed000000
0000000665eeeeeeeeeeed660000000000000000016ffffffffffffff441000000000d0f000000006efffffffe600000000000000000d4eeeeeeeee44d000000
000000064eeeeeeeeeeeee440000000000000111114fffffffffffffff41000000000f0f0000000defffffffff4d0000000000000000deeeeeeeeeee45000000
000000044ee00eeeee00eee40000000000001ff4414ffffffffffffff441000000000f0d0000000dffffffffffff00000000000ddd0deeeeeeeeeeeeee000000
000000044ee004ee4e00ee44000000000001ff44414fff14ffffff1ff4441000000000f00000000dff0ffffff0ff0000000000f445054eeeeeeeeeeee4500000
_... (content truncated) ..._
