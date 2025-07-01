pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
-- crazy-cat.p8

--[[
  a simple game about a cat
  that goes crazy for red dots
--]]

cat = {
  x = 64,
  y = 64,
  size = 8,
  speed = 2
}

dot = {
  x = 32,
  y = 32,
  size = 4
}

score = 0

function _init()
  -- nothing to do here for now
end

function _update()
  -- move cat
  if (btn(0)) then cat.x -= cat.speed end
  if (btn(1)) then cat.x += cat.speed end
  if (btn(2)) then cat.y -= cat.speed end
  if (btn(3)) then cat.y += cat.speed end

  -- check for collision
  if (abs(cat.x - dot.x) < cat.size and
      abs(cat.y - dot.y) < cat.size) then
    -- move dot to random position
    dot.x = rnd(128)
    dot.y = rnd(128)
    score += 1
  end
end

function _draw()
  cls()
  
  -- draw cat
  spr(0, cat.x, cat.y)

  -- draw dot
  circfill(dot.x, dot.y, dot.size, 8)

  -- draw score
  print("score: "..score, 8, 8, 7)
end

__gfx__
0000000000000000
0011110000000000
0117171000000000
0177771000000000
0111111000000000
0111111000000000
0010010000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000
0000000000000000

__sfx__
-- sound effects can be edited here
-- using the pico-8 sfx editor

__music__
-- music can be edited here
-- using the pico-8 music editor
