local Class = require("libs.hump.class")
local anim8 = require("libs.anim8")
local Obstacle = require("objects.Obstacle")

local Orca = Class{__includes = Obstacle}

function Orca:init(lanePosition)
    -- Initialize the base obstacle properties
    Obstacle.init(self, lanePosition)
    
    -- Override obstacle type
    self.obstacleType = "orca"
    
    -- Load orca spritesheet
    self.spritesheet = love.graphics.newImage("assets/sprites/orcas.png")
    
    -- Calculate frame dimensions based on the spritesheet
    local frameWidth = math.floor(self.spritesheet:getWidth() / 8 - 10)  -- 8 frames in the spritesheet
    local frameHeight = self.spritesheet:getHeight()
    
    -- Create animation grid
    local grid = anim8.newGrid(frameWidth, frameHeight, self.spritesheet:getWidth(), self.spritesheet:getHeight())
    
    -- Create animation with all 8 frames, playing at 10 frames per second
    self.animation = anim8.newAnimation(grid('1-8', 1), 0.1)
    
    -- Adjust size and speed for orca
    self.width = frameWidth
    self.height = frameHeight
    self.speed = 200

    -- Scale for drawing
    self.scale = 1
    
    -- Add a custom hitbox that's smaller than the full orca
    self.hitboxOffsetX = frameWidth * 0.3
    self.hitboxOffsetY = frameHeight * 0.2
    self.hitboxWidth = frameWidth * 0.4
    self.hitboxHeight = frameHeight * 0.6
end

function Orca:update(dt, speedMultiplier)
    -- Update base movement
    self.x = self.x - self.speed * speedMultiplier * dt
    
    -- Update animation
    self.animation:update(dt)
    
    -- Mark as inactive when off screen
    if self.x + self.width * self.scale < 0 then
        self.active = false
    end
end

function Orca:draw()
    -- Draw the orca animation
    self.animation:draw(self.spritesheet, self.x, self.y, 0, self.scale, self.scale, 0, 0)
    
    -- Draw collision box in debug mode
    if debugFlag then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle(
            "line", 
            self.x + self.hitboxOffsetX, 
            self.y + self.hitboxOffsetY, 
            self.hitboxWidth, 
            self.hitboxHeight
        )
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Orca:collision(surfer)
    -- Check for collision with tighter hitbox
    if not self.active then return false end
    
    -- Calculate orca's actual hitbox position
    local orcaX = self.x + self.hitboxOffsetX
    local orcaY = self.y + self.hitboxOffsetY
    local orcaWidth = self.hitboxWidth
    local orcaHeight = self.hitboxHeight
    
    -- Get surfer's hitbox dimensions
    local surferScale = 0.1  -- Based on your code
    local surferHitboxOffsetX = surfer.width * 0.3 * surferScale  -- Adjust based on surfer sprite
    local surferHitboxOffsetY = surfer.height * 0.2 * surferScale
    local surferHitboxWidth = surfer.width * 0.4 * surferScale
    local surferHitboxHeight = surfer.height * 0.6 * surferScale
    
    -- Check for overlap between hitboxes
    local colX = orcaX + orcaWidth >= surfer.x + surferHitboxOffsetX and 
                surfer.x + surferHitboxOffsetX + surferHitboxWidth >= orcaX
    local colY = orcaY + orcaHeight >= surfer.y + surferHitboxOffsetY and 
                surfer.y + surferHitboxOffsetY + surferHitboxHeight >= orcaY
    
    return colX and colY
end

return Orca