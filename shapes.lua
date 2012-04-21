module(..., package.seeall)

require 'utils'
require 'vector'

function Rect(x, y, width, height)
  self = vector.Vector:new(x,y)
  self.type = 'rect'
  self.width = width
  self.height = height
  return self
end

function Circle(x, y, r)
  self = vector.Vector:new(x, y)
  self.type = 'circle'
  self.r = r
  self.width = r * 2
  self.height = r * 2
  return self
end

function Collides(a, b)
  if a.type == 'rect' and b.type == 'rect' then
    return CollidesRects(a, b)
  elseif a.type == 'rect' and b.type == 'circle' then
    return CollidesRectCircle(a, b)
  elseif a.type == 'circle' and b.type == 'rect' then
    return CollidesRectCircle(b, a)
  elseif a.type == 'circle' and b.type == 'circle' then
    return CollidesCircles(a, b)
  else error("Invalid types passed into Collides")
  end
end

function CollidesRects(a, b)
end

function CollidesRectCircle(a, b)
end

function CollidesCircles(a, b)
  return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2)) <= a.r + b.r
end

