local Class = require "libs.hump.class"
local Anim8 = require "libs.anim8"

-- Load wave spritesheet
local spriteWave = love.graphics.newImage("assets/sprites/wavespritesheet.png")
local gridWave = Anim8.newGrid(450, 400, spriteWave:getWidth(), spriteWave:getHeight())

local Wave = Class{}

function Wave:init(x, y, animationSpeed)
    self.x = x
    self.y = y
    -- Default animation speed if not provided
    self.animationSpeed = animationSpeed or 0.25
    
    -- Create animation from the 4 frames in the spritesheet
    self.animation = Anim8.newAnimation(gridWave('4-1', 1), self.animationSpeed)
    
    -- Wave properties
    self.scale = 0.85 -- Scale of the wave
    
    -- Wave movement properties
    self.originalX = x -- Store original X to reset position
    self.moveSpeed = 30 -- Speed of horizontal movement
    self.amplitude = 5 -- For a subtle vertical bobbing effect
    self.time = love.math.random() * math.pi * 2 -- Random starting phase
end

function Wave:update(dt)
    -- Update animation frames
    self.animation:update(dt)
    
    -- Update time for wave bobbing effect
    self.time = self.time + dt
    
    -- Move the wave horizontally from right to left
    self.x = self.x - (self.moveSpeed * dt)
    
    -- If wave moves off-screen, reset to original position
    if self.x < -200 then -- Assuming 200 is the width of a wave frame
        self.x = gameWidth + 50 -- Reset to right side of screen
    end
    
    -- Add a subtle vertical bobbing effect
    local bobY = math.sin(self.time * 2) * self.amplitude
    self.currentY = self.y + bobY
end

function Wave:draw()
    -- Draw the wave with proper color and alpha
    love.graphics.setColor(1, 1, 1)
    
    -- Draw the animation at the current position with bobbing effect
    self.animation:draw(spriteWave, self.x, self.currentY or self.y, 0, self.scale, self.scale)
    
    -- Reset color to default
    love.graphics.setColor(1, 1, 1, 1)
end

return Wave