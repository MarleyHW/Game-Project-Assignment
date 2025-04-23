local Class = require "libs.hump.class"
-- Collectible item class
local Collectible = Class{}

function Collectible:init(type, lanePosition)
    -- seashell or lifejacket
    self.type = type 
    -- Load sprite based on type
    if self.type == "seashell" then
        self.sprite = love.graphics.newImage("assets/sprites/seashell.png")
    else
        self.sprite = love.graphics.newImage("assets/sprites/lifejacket.png")
    end
    -- Position and dimensions
    self.x = gameWidth + 50 
    local baseScale = 0.3
    self.width = self.sprite:getWidth() * baseScale
    self.height = self.sprite:getHeight() * baseScale
    -- Set vertical position based on lane
    if lanePosition == 1 then 
        self.y = gameHeight/2 - 80
    elseif lanePosition == 2 then 
        self.y = gameHeight/2 - 40
    else 
        self.y = gameHeight/2 + 80
    end
    -- Animation properties
    self.rotation = 0
    self.scale = 1
    self.alpha = 1
    self.pulseDirection = 1
    -- Game state
    self.active = true
    self.collected = false
    -- Base speed
    self.speed = 180 
end

function Collectible:update(dt, speedMultiplier)
    -- Move collectible
    self.x = self.x - self.speed * speedMultiplier * dt
    -- Animate collectible
    self.rotation = self.rotation + dt * 2
    -- Pulse animation
    self.scale = self.scale + self.pulseDirection * dt * 0.5
    if self.scale > 1.1 then
        self.scale = 1.1
        self.pulseDirection = -1
    elseif self.scale < 0.9 then
        self.scale = 0.9
        self.pulseDirection = 1
    end
    -- Deactivate if off screen
    if self.x + self.width < 0 then
        self.active = false
    end
end

function Collectible:draw()
    -- Draw with animation
    love.graphics.setColor(1, 1, 1, self.alpha)
    local baseScale = 0.1 
    love.graphics.draw(
        self.sprite, 
        self.x + (self.width * baseScale) / 2, 
        self.y + (self.height * baseScale) / 2,
        self.rotation,
        baseScale * self.scale, baseScale * self.scale,
        self.width / 2, self.height / 2
    )

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1) 
    -- Draw debug info
    if debugFlag then
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    end
end

function Collectible:collision(surfer)
    -- Check for collision with surfer
    if not self.active or self.collected then return false end
    
    local baseScale = 0.1
    local collectibleWidth = self.width * baseScale
    local collectibleHeight = self.height * baseScale
    
    local colX = self.x + collectibleWidth >= surfer.x and surfer.x + surfer.width * 0.15 >= self.x
    local colY = self.y + collectibleHeight >= surfer.y and surfer.y + surfer.height * 0.15 >= self.y
    
    return colX and colY
end

-- CollectibleSystem class to manage all collectibles
local CollectibleSystem = Class{}

function CollectibleSystem:init()
    self.collectibles = {}
    self.spawnTimer = 0
    -- Time between collectible spawns (10 seconds)
    self.spawnInterval = 10.0
    -- Probability of spawning a lifejacket vs seashell (20% chance)
    self.lifejacketProbability = 0.2
end

function CollectibleSystem:update(dt, difficultyMultiplier)
    -- Update existing collectibles
    for i, collectible in ipairs(self.collectibles) do
        collectible:update(dt, difficultyMultiplier)
    end
    
    -- Remove inactive collectibles
    for i = #self.collectibles, 1, -1 do
        if not self.collectibles[i].active then
            table.remove(self.collectibles, i)
        end
    end
    
    -- Spawn new collectibles every 10 seconds
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
        self.spawnTimer = 0
        
        -- Determine collectible type (seashell or lifejacket)
        local collectibleType = "seashell"
        if math.random() < self.lifejacketProbability then
            collectibleType = "lifejacket"
        end
        
        -- Create new collectible in random lane
        local randomLane = math.random(1, 3)
        local newCollectible = Collectible(collectibleType, randomLane)
        table.insert(self.collectibles, newCollectible)
    end
end

function CollectibleSystem:draw()
    for _, collectible in ipairs(self.collectibles) do
        collectible:draw()
    end
end

function CollectibleSystem:checkCollisions(surfer)
    -- Check collision with any collectible
    for i, collectible in ipairs(self.collectibles) do
        if collectible:collision(surfer) then
            collectible.collected = true
            collectible.active = false
            return collectible.type
        end
    end
    return nil
end

return CollectibleSystem