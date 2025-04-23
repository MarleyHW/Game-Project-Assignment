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
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    -- Set vertical position based on lane
    if lanePosition == 1 then 
        self.y = gameHeight/2 - 80
    elseif lanePosition == 2 then 
        self.y = gameHeight/2
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
    love.graphics.draw(
        self.sprite, 
        self.x + self.width / 2, 
        self.y + self.height / 2,
        self.rotation,
        self.scale, self.scale,
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
    -- Simple AABB collision
    local colX = self.x + self.width >= surfer.x and surfer.x + surfer.width >= self.x
    local colY = self.y + self.height >= surfer.y and surfer.y + surfer.height >= self.y
    return colX and colY
end
-- CollectibleSystem class to manage all collectibles
local CollectibleSystem = Class{}

function CollectibleSystem:init()
    self.collectibles = {}
    self.spawnTimer = 0
    -- Time between seashell spawns
    self.seashellInterval = 3.0 
    -- Time between lifejacket spawns
    self.lifejacketInterval = 15.0 
    self.seashellTimer = 0
    self.lifejacketTimer = 0
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
    -- Spawn new seashells
    self.seashellTimer = self.seashellTimer + dt
    if self.seashellTimer >= self.seashellInterval then
        self.seashellTimer = 0
        -- Adjust spawn rate based on difficulty
        self.seashellInterval = math.max(1.5, 3.0 - difficultyMultiplier * 0.5)
        -- Create new seashell in random lane
        local newSeashell = Collectible("seashell", math.random(1, 3))
        table.insert(self.collectibles, newSeashell)
    end
    -- Spawn new lifejackets less frequently
    self.lifejacketTimer = self.lifejacketTimer + dt
    if self.lifejacketTimer >= self.lifejacketInterval then
        self.lifejacketTimer = 0
        -- Create new lifejacket in random lane
        local newLifejacket = Collectible("lifejacket", math.random(1, 3))
        table.insert(self.collectibles, newLifejacket)
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