local Class = require("libs.hump.class")
local anim8 = require("libs.anim8")
local Obstacle = require("objects.Obstacle")

local Orca = Class{__includes = Obstacle}

function Orca:init(lanePosition)
    -- Initialize the orca properties and changing the type of obstacle
    Obstacle.init(self, lanePosition)
    self.obstacleType = "orca"
    
    -- Load orca spritesheet
    self.spritesheet = love.graphics.newImage("assets/sprites/orcas.png")
    
    -- Calculate frame dimensions based on the spritesheet
    local frameWidth = math.floor(self.spritesheet:getWidth() / 8 - 10)
    local frameHeight = self.spritesheet:getHeight()
    
    -- Create animation grid
    local grid = anim8.newGrid(frameWidth, frameHeight, self.spritesheet:getWidth(), self.spritesheet:getHeight())
    self.animation = anim8.newAnimation(grid('1-8', 1), 0.1)
    
    -- Adjust size and speed for the orca
    self.width = frameWidth
    self.height = frameHeight
    self.speed = 200

    -- Scaling and the hitbox for the orca
    self.scale = 1
    self.hitboxOffsetX = frameWidth * 0.3
    self.hitboxOffsetY = frameHeight * 0.2
    self.hitboxWidth = frameWidth * 0.4
    self.hitboxHeight = frameHeight * 0.6
end

function Orca:update(dt, speedMultiplier)
    -- Update base movement and animation
    self.x = self.x - self.speed * speedMultiplier * dt
    self.animation:update(dt)
    
    -- Detecting when it goes offscreen to make it inactive
    if self.x + self.width * self.scale < 0 then
        self.active = false
    end
end

function Orca:draw()
    -- Draw the orca animation
    self.animation:draw(self.spritesheet, self.x, self.y, 0, self.scale, self.scale, 0, 0)
    
    -- Draw collision box for debugging
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
    -- Check for collision
    if not self.active then return false end
    
    -- Calculate orca's actual hitbox position
    local orcaX = self.x + self.hitboxOffsetX
    local orcaY = self.y + self.hitboxOffsetY
    local orcaWidth = self.hitboxWidth
    local orcaHeight = self.hitboxHeight
    
    -- Get surfer's hitbox dimensions
    local surferScale = 0.1
    local surferHitboxOffsetX = surfer.width * 0.3 * surferScale
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