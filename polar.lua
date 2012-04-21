module(..., package.seeall)

require 'utils'
require 'vector'

function math.cartesian(polar, center)
  if not center then center = {x=0, y=0} end
  local x = math.cos(math.rad(polar.ang)) * polar.dst + center.x
  local y = math.sin(math.rad(polar.ang)) * polar.dst + center.y
  return x, y
end

function math.polar(pos, center)
  if not center then center = {x=0, y=0} end
  local vect = vector.Vector:new(pos.x - center.x, pos.y - center.y)
  local dst = vect:mag()
  local ang = vect.x ~= 0 and math.deg(math.atan(math.abs(vect.y)/math.abs(vect.x))) or 90
  if vect.x > 0 then
    if vect.y < 0 then
      ang = 360 - ang 
    end
  else
    if vect.y > 0 then
      ang = 180 - ang
    else
      ang = 180 + ang
    end
  end
  return ang, dst--{dst=dst, ang=ang}
end

