local Class = require("libs.hump.class")
local Timer = require("libs.hump.timer")
-- Load obstacle sprites
local obstacleSprites = {}
obstacleSprites[1] = love.graphics.newImage("assets/sprites/obstacle_seaweed.png")
obstacleSprites[2] = love.graphics.newImage("assets/sprites/obstacle_rock.png")
obstacleSprites[3] = love.graphics.newImage("assets/sprites/driftwood.png")
local Obstacle = Class{}

function Obstacle:init(lanePosition)
    -- Position, movement, and ensuring that obstacles start offscreen
    self.x = gameWidth + 50 
    self.y = 0
    self.speed = 200 

    -- Choose random obstacle type
    self.obstacleType = math.random(1, #obstacleSprites)
    self.sprite = obstacleSprites[self.obstacleType]

    -- Set dimensions
    self.width = self.sprite:getWidth() * 0.6
    self.height = self.sprite:getHeight() * 0.6
    
    -- Set vertical position based on lane
    if lanePosition == 1 then
        self.y = gameHeight/2 - 60
    elseif lanePosition == 2 then 
        self.y = gameHeight/2 - 10
    else
        self.y = gameHeight - 130
    end
    
    -- Animation properties
    self.rotation = 0
    self.bobHeight = 0
    self.bobDirection = 1
    self.bobSpeed = math.random(1, 3)
    
    --State of game
    self.active = true
    self.scored = false
end

function Obstacle:update(dt, speedMultiplier)
    -- Move obstacle
    self.x = self.x - self.speed * speedMultiplier * dt
    
    -- Animate bobbing up and down
    self.bobHeight = self.bobHeight + self.bobDirection * self.bobSpeed * dt
    if math.abs(self.bobHeight) > 5 then
        self.bobDirection = -self.bobDirection
    end
    
    -- Rotate obstacle a little
    self.rotation = self.rotation + dt * 0.1
    if self.x + self.width < 0 then
        self.active = false
    end
end

function Obstacle:draw()
    local scale = 0.1 
    local originX = self.sprite:getWidth() / 2
    local originY = self.sprite:getHeight() / 2
    love.graphics.draw(
        self.sprite, 
        self.x + originX * scale, 
        self.y + self.bobHeight + originY * scale,
        self.rotation, 
        scale, scale, 
        originX, originY
    )
    if debugFlag then
        love.graphics.rectangle("line", self.x, self.y, self.width * scale, self.height * scale)
    end
end

function Obstacle:collision(surfer)
    -- Check for collision with surfer
    if not self.active then return false end
    local scale = 0.1
    local obstacleWidth = self.width * scale
    local obstacleHeight = self.height * scale
    local colX = self.x + obstacleWidth >= surfer.x and surfer.x + surfer.width * 0.15 >= self.x
    local colY = self.y + obstacleHeight >= surfer.y and surfer.y + surfer.height * 0.15 >= self.y

    return colX and colY
end

return Obstacle