module(..., package.seeall)

require 'utils'
require 'vector'
require 'orbiter'

function SpaceStation()
  self = orbiter.Orbiter()

  self.offset = -100

  self.orbitColor.r, self.orbitColor.g, self.orbitColor.b = unpack(color.grey.rgba)
  self.orbitColor:update()
  self.color.r, self.color.b = 0, 0
  self.color:update()

  self.speed = 0.1
  self.size = 5

  self:updateOrbit()

  return self
end
