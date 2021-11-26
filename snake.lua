-- snake

SIZE = 16 -- 128px display / 8px sprites.

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
  head = 1,
  tail = 0,
  segments = { [0] = {x = 64, y = 64} },
  dead = false,
}

-- Grid is table keyed with x,y coordinates whose values are the
-- contents of that cell, either grass, snake, food, or superfood.
grid = {}

for x = 0, SIZE - 1 do
  for y = 0, SIZE - 1 do
    grid[(y * SIZE + x) + 1] = GRASS
  end
end

-- Basic game structure

function _init()
  cls()
  grid[to_index({x=13, y=12})] = FOOD
  grid[to_index({x=0, y=0})] = SUPER_FOOD

  for cell, value in pairs(grid) do
    local x = ((cell - 1) % SIZE) * 8;
    local y = ((cell - 1) \ SIZE) * 8;
    spr(GRASS, x, y)
    spr(value, x, y)
  end
  grid[to_index(snake.segments[0])] = SNAKE
  move(snake)
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
    spr(heads[snake.direction] + 4, hd.x, hd.y)
  else
    spr(heads[snake.direction], hd.x, hd.y)
  end
end


-- The rest of the code

function to_cell(i)
  return { x = (i - 1) % SIZE, y = (i - 1) \ SIZE }
end

function to_index(cell)
  return (cell.y * SIZE + cell.x) + 1
end

function head(snake)
  return snake.segments[(snake.head + 63) % 64]
end

function current_cell(snake)
  return { x = (snake.x \ 8) * 8, y = (snake.y \ 8) * 8 }
end

function next_cell(snake)
  return { x = snake.x + snake.dx, y = snake.y + snake.dy }
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
  return cell.x < 0 or cell.x >= 128 or cell.y < 0 or cell.y >= 128
end

function legal_turn(d, t)
  return d.dx == t.dy or d.dy == t.dx
end

function move(snake)
  snake.x += snake.direction.dx * snake.speed
  snake.y += snake.direction.dy * snake.speed

  local current = current_cell(snake)
  local head = head(snake)

  -- Entering new cell. If the new cell is off the grid our we are
  -- crashing into ourself don't actually enter it.
  if (current.x ~= head.x or current.y ~= head.y) then
    local i = to_index(current)
    if off_board(current) or grid[i] == SNAKE then
      snake.dead = true
    else
      apply_next_turn(snake)
      spr(1, head.x, head.y) -- draw body segment in old head position.
      grid[to_index(current)] = SNAKE
      snake.segments[(snake.head + 63) % 64] = current
    end
  end
end
