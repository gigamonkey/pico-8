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

-- sprites for the head.
heads = { [UP] = 13, [DOWN] = 14, [LEFT] = 15, [RIGHT] = 16 }

-- speeds: 2 really easy. 5 normal. 10 hard. 15 super hard.

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

state = 'splash'

-- Basic game structure

function _init()
  set_head(snake, {x=8, y=8})
  set_head(snake, {x=9, y=8})
  splash_screen()
end

function _update()
  if state == 'splash' then
    if btnp(2) then
      start_game()
    end
  else
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
end

function _draw()

  local x = 0
  local y = 0

  if state == 'playing' then
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


      local tx = old_tail.x + (td.dx * proportion)
      local ty = old_tail.y + (td.dy * proportion)

      spr(0, old_tail.x * 8, old_tail.y * 8)
      spr(1, tx * 8, ty * 8)
    end

    -- Draw head offset back from where it would be if we were all the
    -- way into the current head cell in proportion to how much we've
    -- moved.
    local hd = head(snake)
    local sprite = heads[snake.direction] + ((snake.dead and 4) or 0)
    x = 8 * (hd.x - (snake.direction.dx * offset))
    y = 8 * (hd.y - (snake.direction.dy * offset))

    if snake.frames_into_head == 0 then
      -- When we're just entering the new head the offset will put is
      -- back in the previous cell so we clear it out so we when we
      -- redraw the head we get the segments visible.
      spr(0, x, y)
    end

    spr(sprite, x, y)
  end
end


function splash_screen()
  cls()
  rectfill(0, 0, 127, 127, 1)
  rect(0, 0, 127, 127, 13)

  local i = 0

  i = row({1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1}, i, 3)
  i = row({1,1,1,0,1,0,0,0,1,0,1,0,1,0,1,0,1,0,1}, i, 3)
  i = row({1,0,1,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,1}, i, 3)
  i = row({1,0,1,0,1,0,0,0,1,0,1,0,1,0,1,0,0,0,1}, i, 3)
  i = row({1,0,1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1}, i, 3)
  i += 1
  i = row({1,0,1,0,0,0,0,0,1,1,1,0,1,1,1,0,1,1,1}, i, 3)
  i = row({0,1,0,0,0,0,0,0,1,1,1,0,1,0,1,0,1,0,0}, i, 3)
  i = row({1,0,1,0,1,1,1,0,1,0,1,0,1,1,1,0,1,1,1}, i, 3)
  i = row({1,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,0,0,1}, i, 3)
  i = row({1,0,1,0,0,0,0,0,1,0,1,0,1,0,1,0,1,1,1}, i, 3)
  i += 1
  i = row({1,1,1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,0,1}, i, 3)
  i = row({0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1}, i, 3)
  i = row({0,1,0,0,1,1,1,0,1,1,0,0,1,1,0,0,1,1,1}, i, 3)
  i = row({0,1,0,0,1,0,1,0,1,0,1,0,1,0,1,0,0,0,1}, i, 3)
  i = row({0,1,0,0,1,0,1,0,1,1,1,0,1,1,1,0,1,1,1}, i, 3)
  i += 1
  i = row({0,0,0,0,0,1,0,0,0,1,0,0,0,1}, i, 3)
  i = row({0,0,0,0,0,1,0,0,0,1,0,0,0,1}, i, 3)
  i = row({0,0,0,0,0,1,0,0,0,1,0,0,0,1}, i, 3)
  i = row({0,0,0,0,0,0,0,0,0,0,0,0,0,0}, i, 3)
  i = row({0,0,0,0,0,1,0,0,0,1,0,0,0,1}, i, 3)

  print("press up to start", 31, 118, 6)
end


-- The rest of the code

function start_game()
  state = 'playing'
  cls()
  for x = 0, SIZE - 1 do
    for y = 0, SIZE - 1 do
      grid[to_index({x=x, y=y})] = GRASS
    end
  end

  random_food()

  for cell, value in pairs(grid) do
    local x = ((cell - 1) % SIZE) * 8;
    local y = ((cell - 1) \ SIZE) * 8;
    spr(GRASS, x, y)
    spr(value, x, y)
  end
  music(0)
end

function block(x, y, color)
  local x_offset = 26
  local y_offset = 18
  local size = 4
  rectfill(x_offset + (x * size), y_offset + y * size, x_offset + (x + 1) * size, y_offset + (y + 1) * size, color)
end

function row(r, y, color)
  for i, v in pairs(r) do
    if v == 1 then
      block(i - 1, y, color)
    end
  end
  return y + 1
end

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
      music(-1)
      sfx(6)
    else
      local is_grass = grid[i] == GRASS
      set_head(snake, new_head)
      if is_grass then
        clear_tail(snake, tail(snake))
      else
        sfx(5)
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
  local food = FOOD + flr(rnd(6))
  grid[pos] = food
  spr(food, x, y)
end
