local Class = require("libs.hump.class")
local bgSky = love.graphics.newImage("assets/bg/sky.png")
local bgWaves = love.graphics.newImage("assets/bg/bgWaves.png")

local Background = Class{}
function Background:init()
    self.bgSkyPos = 0
    self.bgWavesPos = 0
    self.bgWidth = bgSky:getWidth()
    self.wavesWidth = bgWaves:getWidth()
    self.bgSpeed = 30
    
    -- Background is not properly formatted so it needs scaled
    self.scaleX = gameWidth / self.bgWidth
    self.scaleY = gameHeight / bgSky:getHeight()
    
    -- Calculate the scaled width for scrolling
    self.scaledWidth = self.bgWidth * self.scaleX
    
    -- Calculate wave position at the bottom of the screen
    self.wavesY = gameHeight - bgWaves:getHeight() + 50
end

function Background:update(dt)
    -- Making sure the sky and waves scroll and wrap properly one after each other
    self.bgSkyPos = (self.bgSkyPos + self.bgSpeed * dt) % self.scaledWidth
    self.bgWavesPos = (self.bgWavesPos + self.bgSpeed * 2 * dt) % self.wavesWidth
end

function Background:drawBackground()
    -- Draw the sky in the background
    love.graphics.draw(bgSky, -self.bgSkyPos, 0, 0, self.scaleX, self.scaleY)
    love.graphics.draw(bgSky, self.scaledWidth - self.bgSkyPos, 0, 0, self.scaleX, self.scaleY)
end

function Background:drawForeground()
    -- Draw the waves at the bottom of the screen (this is where the player will be surfing)
    love.graphics.draw(bgWaves, -self.bgWavesPos, self.wavesY)
    -- Second wave for seamless scrolling
    love.graphics.draw(bgWaves, self.wavesWidth - self.bgWavesPos, self.wavesY)
end

return Background