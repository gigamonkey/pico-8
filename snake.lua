-- snake

-- direction (dx and dy or maybe a table of those)
-- table of segments


function _init()
  rectfill(0, 0, 128, 128, 13)
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
  move(snake)
end

function _draw()
  local h = heads[snake.direction]
  local hd = head(snake)
  --print("X: " .. hd.x * 8 .. "; Y: " .. hd.y * 8 .. "; h: " .. h)

  spr(h, hd.x, hd.y)
end

function to_cell(i)
  return { x = i % 8, y = i \ 8 }
end

function to_index(cell)
  return cell.y * 8 + cell.x
end


function head(snake)
  return snake.segments[(snake.head + 63) % 64]
end

function current_cell(snake)
  return { x = (snake.x \ 8) * 8, y = (snake.y \ 8) * 8 }
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

function legal_turn(d, t)
  return d.dx == t.dy or d.dy == t.dx
end

function move(snake)
  snake.x += snake.direction.dx * snake.speed
  snake.y += snake.direction.dy * snake.speed
  -- draw head with correct sprite
  local current = current_cell(snake)
  local head = head(snake)
  --print("C X: " .. current.x .. " Y: " .. current.y .. ". H X: " .. head.x .. "; Y: " .. head.y)

  if (current.x ~= head.x or current.y ~= head.y) then
    -- Entering new cell.

    -- print("Setting head")
    -- print("C X: " .. current.x .. " Y: " .. current.y .. ". H X: " .. head.x .. "; Y: " .. head.y)
    --print("new cell")

    apply_next_turn(snake)

    spr(1, head.x, head.y)
    snake.segments[(snake.head + 63) % 64] = current
  else
    --print("same cell")
  end
end



SIZE = 8 -- 128px display / 16px sprites.

UP    = { dx = 0, dy = -1 }
DOWN  = { dx = 0, dy = 1 }
LEFT  = { dx = -1, dy = 0 }
RIGHT = { dx = 1, dy = 0 }

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
  segments = { [0] = {x = 64, y = 64} }
}
