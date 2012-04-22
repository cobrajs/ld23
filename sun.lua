module(..., package.seeall)

require 'utils'
require 'vector'
require 'orbiter'

function Sun()
  self = orbiter.Orbiter()

  self.offset = 0

  self.orbitColor:set(unpack(color.grey.rgba))
  self.color:set(nil,nil,0)

  self.flare = false
  self.flareLength = 0
  self.flareFade = 0
  self.flareBullets = nil
  self.flareBulletType = 1

  self.speed = 0.3
  self.size = 40

  self:updateOrbit()

  self.doFlare = function(self, bullets)
    self.flare = true
    self.flareLength = 1
    self.flareFade = self.flareFade + 1
    self.flareBullets = bullets
  end

  self.updateCallback = function(self, dt)
    if self.flare then
      self.flareLength = self.flareLength - dt
      if self.flareLength <= 0 then
        self.flareLength = 0
        self.flare = false
        self.flareFade = self.flareFade - 1
      end
      if self.flareFade == 97 then
        for i=0,360,5 do 
          self.flareBullets:add(self.pos.x, self.pos.y, i, 2)
        end
      end
    end

    if self.flareFade % 2 == 1 then
      self.flareFade = self.flareFade + 2
    else
      self.flareFade = self.flareFade - 2
    end
    if self.flareFade < 0 then self.flareFade = 0 end
    if self.flareFade > 100 then self.flareFade = 99 end
    self.color:set(
      255 * (self.flareFade/100 * 0.8 + 0.2),
      255 * (self.flareFade/100 * 0.8 + 0.2),
      0
    )
  end

  return self
end
