local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"

-- Load wave spritesheet
local spriteWave = love.graphics.newImage("assets/sprites/wavespritesheet.png")
local gridWave = Anim8.newGrid(450, 400, spriteWave:getWidth(), spriteWave:getHeight())

local Wave = Class{}
function Wave:init(x, y, animationSpeed)
    self.x = x
    self.y = y

    -- Creating a new wave animation
    self.animationSpeed = animationSpeed or 0.25
    self.animation = Anim8.newAnimation(gridWave('4-1', 1), self.animationSpeed)
    
    -- Wave properties for animation
    self.scale = 0.85
    self.originalX = x
    self.moveSpeed = 30
    self.amplitude = 5

    -- This is random so that all the waves are in different phases and it makes it more unique and less robotic
    self.time = love.math.random() * math.pi * 2
end

function Wave:update(dt)
    -- Update animation and time
    self.animation:update(dt)
    self.time = self.time + dt
    
    -- Move the wave horizontally from right to left
    self.x = self.x - (self.moveSpeed * dt)
    
    -- If wave moves off-screen, reset to original position
    if self.x < -200 then
        self.x = gameWidth + 50 
    end
    
    -- Add a subtle bobbing effect to mimic a real wave
    local bobY = math.sin(self.time * 2) * self.amplitude
    self.currentY = self.y + bobY
end

function Wave:draw()
    -- Draw the actual animation of the wave
    love.graphics.setColor(1, 1, 1)
    self.animation:draw(spriteWave, self.x, self.currentY or self.y, 0, self.scale, self.scale)
end

return Wave