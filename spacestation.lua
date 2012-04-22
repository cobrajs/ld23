module(..., package.seeall)

require 'utils'
require 'vector'
require 'orbiter'

function SpaceStation()
  self = orbiter.Orbiter()

  self.offset = -100

  self.orbitColor:set(unpack(color.grey.rgba))
  self.color:set(0,nil,0)

  self.speed = 0.1
  self.size = 5

  self:updateOrbit()

  return self
end
