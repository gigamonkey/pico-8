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
  x = 64,
  y = 64,
  turns = {},
  head = 0,
  tail = 0,
  segments = {},
  dead = false,
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

  grid[to_index({x=13, y=12})] = FOOD
  grid[to_index({x=0, y=0})] = SUPER_FOOD

  set_head(snake, {x=8, y=8})
  set_head(snake, {x=9, y=8})
  snake.x = 72
  snake.y = 64

  for cell, value in pairs(grid) do
    local x = ((cell - 1) % SIZE) * 8;
    local y = ((cell - 1) \ SIZE) * 8;

    spr(GRASS, x, y)
    if value ~= GRASS then
      --print("not grass at " .. ((cell - 1) % SIZE) .. "," .. ((cell - 1) \ SIZE))
    end
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
  -- TODO: draw the head more smoothly, moving into the cell in
  -- increments.
  local hd = head(snake)
  if snake.dead then
    spr(heads[snake.direction] + 4, hd.x * 8, hd.y * 8)
  else
    spr(heads[snake.direction], hd.x * 8, hd.y * 8)
  end
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

function clear_tail(snake, tail)
  grid[to_index(tail)] = GRASS
  snake.tail = (snake.tail + 1) % SIZE2D
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

function move(snake)

  snake.x += snake.direction.dx * snake.speed
  snake.y += snake.direction.dy * snake.speed

  local current = current_cell(snake)
  local head = head(snake)
  local tail = tail(snake)

  -- Entering new cell. If the new cell is off the grid our we are
  -- crashing into ourself don't actually enter it. If it doesn't
  -- contain food then we remove our tail.
  if (current.x ~= head.x or current.y ~= head.y) then
    local i = to_index(current)
    if off_board(current) or grid[i] == SNAKE then
      snake.dead = true
    else
      local is_grass = grid[i] == GRASS
      --print("grid[" .. i .. "] " .. tostring(grid[i]) .. " is_grass: " .. tostring(is_grass))
      apply_next_turn(snake)
      spr(1, head.x * 8, head.y * 8) -- draw body segment in old head position.
      set_head(snake, current)
      if is_grass then
        clear_tail(snake, tail)
        spr(0, tail.x * 8, tail.y * 8) -- clear tail
      end
    end
  end
end
