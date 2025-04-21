local Class = require "hump.class"
local Timer = require "hump.timer"
-- Load obstacle sprites
local obstacleSprites = {}
obstacleSprites[1] = love.graphics.newImage("sprites/obstacle_seaweed.png")
obstacleSprites[2] = love.graphics.newImage("sprites/obstacle_rock.png")
obstacleSprites[3] = love.graphics.newImage("sprites/obstacle_driftwood.png")
local Obstacle = Class{}

function Obstacle:init(lanePosition)
    -- Position and movement
    -- Start offscreen
    self.x = gameWidth + 50 
    self.y = 0
    self.speed = 200 
    -- Choose random obstacle type
    self.obstacleType = math.random(1, #obstacleSprites)
    self.sprite = obstacleSprites[self.obstacleType]
    -- Set dimensions
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    
    -- Set vertical position based on lane
    if lanePosition == 1 then
        self.y = gameHeight/2 - 80
    elseif lanePosition == 2 then 
        self.y = gameHeight/2
    else -- Bottom lane
        self.y = gameHeight/2 + 80
    end
    
    -- Animation properties
    self.rotation = 0
    self.bobHeight = 0
    self.bobDirection = 1
    self.bobSpeed = math.random(1, 3)
    
    -- Game state
    self.active = true
    self.scored = false
end