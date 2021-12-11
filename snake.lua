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
  speed = 1,
  turns = {},
  head = 0,
  tail = 0,
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

  random_food()

  for cell, value in pairs(grid) do
    local x = ((cell - 1) % SIZE) * 8;
    local y = ((cell - 1) \ SIZE) * 8;
    spr(GRASS, x, y)
    spr(value, x, y)
  end
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
  local proportion = snake.frames_into_head / 30
  local offset = snake.speed * (1 - proportion)

  local hd = head(snake)
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
  snake.segments[snake.head] = head
  snake.head = (snake.head + 1) % SIZE2D
  grid[to_index(head)] = SNAKE
end

function clear_tail(snake, cell)
  grid[to_index(cell)] = GRASS
  spr(0, cell.x * 8, cell.y * 8)
  --local d = tail_direction(snake)
  snake.tail = (snake.tail + 1) % SIZE2D
  --local new_tail = tail(snake)
  --spr(0, new_tail.x * 8, new_tail.y * 8)
  --spr(21 + d, new_tail.x * 8, new_tail.y * 8)
end

function tail_direction(snake)
  local t = tail(snake)
  local n = snake.segments[(snake.tail + 1) % SIZE2D]
  local dx = n.x - t.x
  local dy = n.y - t.y
  if dx == 0 then
    return (dy == -1 and 0) or 1
  else
    return (dx == -1 and 2) or 3
  end
end

function head(snake)
  local is_nil = snake.segments[snake.head - 1] == nil
  local i = (snake.head + (SIZE2D - 1)) % SIZE2D
  --print(snake.head .. "; i: " .. i .. "; head is nil: " .. tostring(is_nil))
  return snake.segments[(snake.head + (SIZE2D - 1)) % SIZE2D]
end

function tail(snake)
  return snake.segments[snake.tail]
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
      print("Turned " .. snake.direction.dx .. "," .. snake.direction.dy)
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

  if snake.frames_into_head == 30 then
    -- all the way into the current head.
    apply_next_turn(snake)
    old_head = head(snake)
    new_head = next_cell(old_head, snake.direction)
    snake.frames_into_head = 0

    local i = to_index(new_head)
    if off_board(new_head) or grid[i] == SNAKE then
      snake.dead = true
    else
      local is_grass = grid[i] == GRASS
      print("head: " .. xy(old_head) .. "; new: " .. xy(new_head))
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
