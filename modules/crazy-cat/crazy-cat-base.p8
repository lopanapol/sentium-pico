pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- crazy-cat-base.p8

--[[
  This is the base file for the 32x32 cat game.
  Import your spritesheet into this file.
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

function _init()
  cat = create_pixel(64, 64, {
    curiosity = 0.9,
    timidity = 0.1,
    energy_cons = 0.5
  })
end

function _update()
  update_consciousness()

  if (abs(cat.x - dot.x) < cat.size and
      abs(cat.y - dot.y) < cat.size) then
    dot.x = rnd(128)
    dot.y = rnd(128)
    score += 1
    cat.emo_state.happiness = min(1, cat.emo_state.happiness + 0.5)
    cat.emo_state.excitement = min(1, cat.emo_state.excitement + 0.3)
  end
end

function _draw()
  cls()
  
  local frame = flr(time() * 4) % 2
  spr(cat_sprite_base + (frame * 16), cat.x - 16, cat.y - 16, 4, 4)

  circfill(dot.x, dot.y, dot.size, 8)
  print("score: "..score, 8, 8, 7)
end

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
    div_progress = 0,
    metab_eff = 1,
    repro_drive = 0,
    stuck_timer = 0
  }
end

function update_consciousness()
  update_movement(cat)
  update_emotions(cat)
end

function update_movement(pixel)
  local move_speed = 1.5
  pixel.target_x = dot.x
  pixel.target_y = dot.y
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
  pixel.emo_state.distress *= 0.95
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
_... (content truncated) ..._
