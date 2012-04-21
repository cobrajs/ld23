module(..., package.seeall)

-- --
-- String Addons
-- --

--
-- Split a string based on splitchar
--
function string.split(word, splitchar)
  local ret = {}
  word = word..splitchar
  word:gsub('([^'..splitchar..']*)'..splitchar, function(x) table.insert(ret, x) end)
  return ret
end


-- --
-- Math Addons
-- --

--
--
--
function math.sign(number)
  return number > 0 and 1 or number < 0 and -1 or 0
end

--
-- Convert an RRGGBB format to a table of colors {r=0,g=0,b=0}
--
function RGBToTable(colors)
  assert(#colors == 6, "Invalid color for conversion (RRGGBB)")
  local a = {r=1,g=3,b=5}
  for v,i in pairs(a) do
    a[v] = tonumber('0x'..colors:sub(i,i+1))
  end
  return a
end

--
-- Check to see if the string is a number
--
function isNum(s) return type(s) == 'string' and s:find('^%d+$') end

--
-- Check to see if the string has numbers in it
--
function hasNum(s) return type(s) == 'string' and s:find('%d') end

--
-- Copy elements from the xargs table to tbl
--
function CopyXargs(tbl, xargs)
  for i, arg in pairs(xargs) do
    tbl[i] = isNum(arg) and tonumber(arg) or arg
  end
end


--
-- Load an image and add a transparency key to it (255,0,255)
--
function loadImage(filename, transkey)
  if not love.filesystem.exists(filename) then filename = 'gfx/'..filename end
  local imageData = love.image.newImageData(filename)
  transkey = transkey or {255,0,255}
  imageData:mapPixel( function(x, y, r, g, b, a) 
    if r == transkey[1] and g == transkey[2] and b == transkey[3] then
      return 0, 0, 0, 0
    else
      return r, g, b, a
    end
  end )
  return love.graphics.newImage(imageData)
end

--
-- Wrap a number from 0 to max
--
function wrap(number, max) 
  return number > max and number - max or number < 0 and number + max or number
end

--
-- Restrict a number between a min and max
--
function clamp(min, number, max)
  return math.max(math.min(max, number), min)
end

--
-- Wrap a vector to the screen
--
function wrapScreen(vector)
  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()
  vector.x = vector.x < 0 and vector.x + width or vector.x > width and vector.x - width or vector.x
  vector.y = vector.y < 0 and vector.y + height or vector.y > height and vector.y - height or vector.y
end

--
-- Check if something is in a table
--
function isIn(table, elem)
  for _,v in ipairs(table) do 
    if v == elem then
      return true
    end
  end
  return false
end

