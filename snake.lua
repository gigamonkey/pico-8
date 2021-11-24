-- snake

-- direction (dx and dy or maybe a table of those)
-- table of segments


function _init()
  rectfill(0, 0, 128, 128, 13)
  x = 64
  y = 64
end

function _update()
  if (btn(0)) snake.direction = LEFT
  if (btn(1)) snake.direction = RIGHT
  if (btn(2)) snake.direction = UP
  if (btn(3)) snake.direction = DOWN
  x += snake.direction.dx * snake.speed
  y += snake.direction.dy * snake.speed
end

function _draw()
  spr(1, (x \ 8) * 8, (y \ 8) * 8)
end

function to_cell(i)
  return { x = i % 8, y = i \ 8 }
end

function to_index(cell)
  return cell.y * 8 + cell.x
end

SIZE = 8 -- 128px display / 16px sprites.

UP    = { dx = 0, dy = -1 }
DOWN  = { dx = 0, dy = 1 }
LEFT  = { dx = -1, dy = 0 }
RIGHT = { dx = 1, dy = 0 }

snake = {
  direction = RIGHT,
  speed = 2,
  head = 1,
  tail = 0,
  segments = { [0] = to_index({x = 8, y = 8}) }
}
