pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
-- snake
-- by peter seibel

#include snake.lua

__gfx__
dddddddd0222222000099000000a0000000000000000800000000000000000000000000002288220022222200222222002222220000880000222222000222220
dddddddd222222220009000000333000087787700022220000222200002222000022220022288222222222222222222222222222022882202222222202222222
dddddddd222222220009000000383000077877800223232002222220022222200222232022322322222222222232222222222322222222222222222202232222
dddddddd222222220888880008333300078778700222222002222220023222200222222822222222222222228822222222222288223223222222222288222222
dddddddd2222222288f8888003333800087787700222222002222220822222200222232022222222222222228822222222222288222222222232232288222222
dddddddd22222222888f888033833330077877800222222002323220023222200222222022222222223223222232222222222322222222222222222202232222
dddddddd222222228888888083333830078778700022220000222200002222000022220022222222222882222222222222222222222222220228822002222222
dddddddd022222200888880000040000000000000000000000080000000000000000000002222220022882200222222002222220022222200008800000222220
02222200000550000222222000222220022222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220022552202222222202222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22223220222222222222222202252222222252200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222288225225222222222255222222222222550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222288222222222252252255222222222222550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22223220222222222222222202252222222252200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222220222222220225522002222222222222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222200022222200005500000222220022222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
