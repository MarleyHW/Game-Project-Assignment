local Class = require("libs.hump.class")
local bgSky = love.graphics.newImage("assets/bg/sky.png")
local bgClouds = love.graphics.newImage("assets/bg/clouds.png")
local bgBeach = love.graphics.newImage("assets/bg/beach.png")
local bgWave = love.graphics.newImage("assets/bg/wave.png")
local bgFoam = love.graphics.newImage("assets/bg/foam.png")
local Background = Class{}
function Background:init()
    self.skyPos = 0
    self.cloudPos = 0
    self.beachPos = 0
    self.wavePos = 0
    self.foamPos = 0
    self.skySpeed = 5
    self.cloudSpeed = 15
    self.beachSpeed = 30
    self.waveSpeed = 60
    self.foamSpeed = 90
    self.bgWidth = bgBeach:getWidth()
    self.waveAnimTime = 0
    self.waveHeight = 0
    self.waveDirection = 1
end

function Background:update(dt)
    self.skyPos = (self.skyPos + self.skySpeed * dt) % self.bgWidth
    self.cloudPos = (self.cloudPos + self.cloudSpeed * dt) % self.bgWidth
    self.beachPos = (self.beachPos + self.beachSpeed * dt) % self.bgWidth
    self.wavePos = (self.wavePos + self.waveSpeed * dt) % self.bgWidth
    self.foamPos = (self.foamPos + self.foamSpeed * dt) % self.bgWidth
    self.waveAnimTime = self.waveAnimTime + dt
    if self.waveAnimTime > 0.05 then
        self.waveHeight = self.waveHeight + self.waveDirection
        if self.waveHeight >= 5 or self.waveHeight <= -5 then
            self.waveDirection = -self.waveDirection
        end
        self.waveAnimTime = 0
    end
end

function Background:drawBackground()
    love.graphics.draw(bgSky, -self.skyPos, 0)
    love.graphics.draw(bgSky, self.bgWidth - self.skyPos, 0)
    love.graphics.draw(bgClouds, -self.cloudPos, 50)
    love.graphics.draw(bgClouds, self.bgWidth - self.cloudPos, 50)
    love.graphics.draw(bgBeach, -self.beachPos, 150)
    love.graphics.draw(bgBeach, self.bgWidth - self.beachPos, 150)
end

function Background:drawWave()
    love.graphics.draw(bgWave, -self.wavePos, 250 + self.waveHeight)
    love.graphics.draw(bgWave, self.bgWidth - self.wavePos, 250 + self.waveHeight)
    love.graphics.draw(bgFoam, -self.foamPos, 240 + self.waveHeight)
    love.graphics.draw(bgFoam, self.bgWidth - self.foamPos, 240 + self.waveHeight)
end

function Background:drawForeground()
    -- Empty now but would need to be chnaged by me or Ryland
end

return Background