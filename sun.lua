module(..., package.seeall)

require 'utils'
require 'vector'
require 'orbiter'

function Sun()
  self = orbiter.Orbiter()

  self.offset = 20

  self.color.g = 0
  self.color:update()

  self.flare = false
  self.flareLength = 0
  self.flareFade = 0

  self.speed = 0.3
  self.size = 40

  self:updateOrbit()

  self.doFlare = function(self)
    self.flare = true
    self.flareLength = 1
    self.flareFade = self.flareFade + 1
  end

  self.updateCallback = function(self, dt)
    if self.flare then
      self.flareLength = self.flareLength - dt
      if self.flareLength <= 0 then
        self.flareLength = 0
        self.flare = false
        self.flareFade = self.flareFade - 1
      end
    end

    if self.flareFade % 2 == 1 then
      self.flareFade = self.flareFade + 2
    else
      self.flareFade = self.flareFade - 2
    end
    if self.flareFade < 0 then self.flareFade = 0 end
    if self.flareFade > 100 then self.flareFade = 99 end
    self.color.r = 255 * (self.flareFade/100 * 0.8 + 0.2)
    self.color.g = 255 * (self.flareFade/100 * 0.8 + 0.2)
    self.color:update()
  end

  return self
end
