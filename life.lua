debug = false
off = 0
on = 3
density = 5
size = 2
max_d = 128 / size

speed = 0.5

current = {}

sound_on = true


function _init()
  seed_pop()
  last = time()
  drawn = false
end

function _update()
  if btnp(4) then
    sound_on = not sound_on
  end

  if btnp(5) then
    seed_pop()
  else
    local t = time()
    if (t - last) > speed then
      current = next_generation()
      last = t
      drawn = false
    end
  end
end

function _draw()
  if not drawn then

    if (sound_on) sfx(0)

    cls(off)
    for x = 0, max_d - 1 do
      for y = 0, max_d - 1 do
        if current[x*max_d + y] then
          rectfill(x * size, y * size, ((x + 1) * size) - 1, ((y + 1) * size) - 1, on)
        end
      end
    end
    drawn = true
  end
end

-- populate the field with random on cells
function seed_pop()
  for x = 0, max_d - 1 do
    for y = 0, max_d - 1 do
      if (flr(rnd(density)) == 0) then
        current[x*max_d + y] = true
      end
    end
  end
end

function next_generation()
  local nextgen = {}
  for x = 0, max_d - 1 do
    for y = 0, max_d - 1 do
      if in_next_generation(x, y) then
        nextgen[x*max_d + y] = true
      end
    end
  end
  return nextgen
end

-- value for cell at x, y in next generation
function in_next_generation(x, y)
  local n = live_neighbors(x, y)
  return n == 3 or (is_alive(x, y) and n == 2)
end

-- Is the cell at x, y currently alive?
function is_alive(x, y)
  return current[x*max_d + y] ~= nil
end

-- number of alive neighbors. doesn't count self.
function live_neighbors(x, y)
  local count = 0
  for i = -1, 1 do
    for j = -1, 1 do
      if not (i == 0 and j == 0) then
        nx = (x + i) % max_d
        ny = (y + j) % max_d
        if is_alive(nx, ny) then
          count += 1
        end
      end
    end
  end
  return count
end
