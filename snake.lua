-- snake

SIZE = 16 -- 128px display / 8px sprites.
SIZE2D = SIZE * SIZE

UP    = { dx = 0, dy = -1 }
DOWN  = { dx = 0, dy = 1 }
LEFT  = { dx = -1, dy = 0 }
RIGHT = { dx = 1, dy = 0 }

GRASS = 0
SNAKE = 1
FOOD = 2
SUPER_FOOD = 3

-- sprites for the head.
heads = { [UP] = 13, [DOWN] = 14, [LEFT] = 15, [RIGHT] = 16 }

snake = {
  direction = RIGHT,
  speed = 5,
  turns = {},
  head = 0,
  tail = 0,
  vacated = nil,
  segments = {},
  dead = false,
  frames_into_head = 0
}

-- Grid is table keyed with x,y coordinates whose values are the
-- contents of that cell, either grass, snake, food, or superfood.
grid = {}

-- Basic game structure

function _init()
  cls()
  for x = 0, SIZE - 1 do
    for y = 0, SIZE - 1 do
      grid[to_index({x=x, y=y})] = GRASS
    end
  end

  set_head(snake, {x=8, y=8})
  set_head(snake, {x=9, y=8})
  snake.frames_into_head = 29

  random_food()

  for cell, value in pairs(grid) do
    local x = ((cell - 1) % SIZE) * 8;
    local y = ((cell - 1) \ SIZE) * 8;
    spr(GRASS, x, y)
    spr(value, x, y)
  end

  music(0)
end

function _update()
  if (btnp(0)) then
    add(snake.turns, LEFT)
  end
  if (btnp(1)) then
    add(snake.turns, RIGHT)
  end
  if (btnp(2)) then
    add(snake.turns, UP)
  end
  if (btnp(3)) then
    add(snake.turns, DOWN)
  end
  if not snake.dead then
    move(snake)
  end
end

function _draw()
  -- speed is in squares/second
  local proportion = snake.frames_into_head * snake.speed / 30
  local offset = (1 - proportion)

  -- Erase tail in proportion to how much we've moved. Actually done
  -- by clearing the cell and then redrawing the tail slightly offset.
  --rectfill(0, 0, 128, 24, 2)

  if snake.vacated ~= nil then
    spr(0, snake.vacated.x * 8, snake.vacated.y * 8)
    snake.vacated = nil
  end

  local old_tail = previous_tail(snake)
  if old_tail ~= nil then
    local new_tail = tail(snake)
    local td = { dx = new_tail.x - old_tail.x, dy = new_tail.y - old_tail.y }

    spr(0, old_tail.x * 8, old_tail.y * 8)
    --print("Clear  x: " .. old_tail.x * 8 .. "; y: " .. old_tail.y * 8, 0, 0, 1)

    local tx = old_tail.x + (td.dx * proportion)
    local ty = old_tail.y + (td.dy * proportion)

    --print("Draw x: " .. (tx * 8) .. "; y: " .. (ty * 8), 0, 8, 1)
    spr(1, tx * 8, ty * 8)
  end

  -- Draw head offset back from where it would be if we were all the
  -- way into the current head cell in proportion to how much we've
  -- moved.
  local hd = head(snake)
  --print("Head  x: " .. hd.x * 8 .. "; y: " .. hd.y * 8, 0, 16, 1)
  local sprite = heads[snake.direction] + ((snake.dead and 4) or 0)
  local x = 8 * (hd.x - (snake.direction.dx * offset))
  local y = 8 * (hd.y - (snake.direction.dy * offset))
  spr(sprite, x, y)

end

-- The rest of the code

function to_index(cell)
  return (cell.y * SIZE + cell.x) + 1
end

function set_head(snake, head)
  --print("setting head: " .. xy(head))
  snake.segments[snake.head] = head
  snake.head = (snake.head + 1) % SIZE2D
  grid[to_index(head)] = SNAKE
end

function clear_tail(snake, cell)
  grid[to_index(cell)] = GRASS
  snake.vacated = previous_tail(snake)
  snake.tail = (snake.tail + 1) % SIZE2D
end

function tail_direction(snake)
  local old = previous_tail(snake)
  local new = tail(snake)
  return { dx = new.x - old.x, dy = new.y - old.y }
end

function head(snake)
  return snake.segments[(snake.head + (SIZE2D - 1)) % SIZE2D]
end

function tail(snake)
  return snake.segments[snake.tail]
end

function previous_tail(snake)
  return snake.segments[(snake.tail + (SIZE2D - 1)) % SIZE2D]
end

function current_cell(snake)
  return { x = snake.x \ 8, y = snake.y \ 8 }
end

function next_cell(head, direction)
  return { x = head.x + direction.dx, y = head.y + direction.dy }
end

function apply_next_turn(snake)
  while #snake.turns > 0 do
    t = snake.turns[1]
    deli(snake.turns, 1)
    if legal_turn(snake.direction, t) then
      snake.direction = t
      break
    end
  end
end

function off_board(cell)
  return cell.x < 0 or cell.x >= SIZE or cell.y < 0 or cell.y >= SIZE
end

function legal_turn(d, t)
  return d.dx == t.dy or d.dy == t.dx
end

function xy(cell)
  return cell.x .. "," .. cell.y
end

function move(snake)

  snake.frames_into_head += 1

  local proportion = snake.frames_into_head * snake.speed / 30

  if proportion >= 1 then
    apply_next_turn(snake)
    old_head = head(snake)
    new_head = next_cell(old_head, snake.direction)
    snake.frames_into_head = 0

    local i = to_index(new_head)
    if off_board(new_head) or grid[i] == SNAKE then
      set_head(snake, new_head)
      snake.dead = true
    else
      local is_grass = grid[i] == GRASS
      --print("head: " .. xy(old_head) .. "; new: " .. xy(new_head))
      spr(1, old_head.x * 8, old_head.y * 8) -- draw body segment in old head position.
      set_head(snake, new_head)
      if is_grass then
        clear_tail(snake, tail(snake))
      else
        random_food()
      end
    end
  end
end

function random_food()
  local n = 1
  local pos = nil
  for cell, value in pairs(grid) do
    if value == GRASS then
      if rnd(1) < 1/n then
        pos = cell
      end
      n += 1
    end
  end
  local x = ((pos - 1) % SIZE) * 8;
  local y = ((pos - 1) \ SIZE) * 8;
  local kind = FOOD + flr(rnd(3))
  grid[pos] = kind
  spr(kind, x, y)
end
