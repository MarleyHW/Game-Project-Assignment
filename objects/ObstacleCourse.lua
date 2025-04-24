local Class = require("libs.hump.class")
local Obstacle = require("objects.Obstacle")
local Orca = require("objects.orca")
local ObstacleCourse = Class{}

function ObstacleCourse:init()
    self.obstacles = {}
    self.spawnTimer = 0
    self.spawnInterval = 2.0 
    self.minSpawnInterval = 0.7 
    self.orcaSpawnChance = 0.2 -- chance of an orca spawning
end

function ObstacleCourse:update(dt, difficultyMultiplier)
    -- Update existing obstacles
    for i, obstacle in ipairs(self.obstacles) do
        obstacle:update(dt, difficultyMultiplier)
    end

    -- Remove inactive obstacles
    for i = #self.obstacles, 1, -1 do
        if not self.obstacles[i].active then
            table.remove(self.obstacles, i)
        end
    end

    -- Spawn new obstacles
    self.spawnTimer = self.spawnTimer + dt

    -- Change spawn based on difficulty
    local currentInterval = math.max(
        self.minSpawnInterval,
        self.spawnInterval - (difficultyMultiplier - 1) * 0.8
    )

    if self.spawnTimer >= currentInterval then
        self.spawnTimer = 0
        
        -- Determine if we should spawn an orca or regular obstacle
        local lane = math.random(1, 3)
        local newObstacle
        
        -- Orca has a chance to spawn that increases with difficulty
        local orcaRoll = math.random()
        local orcaChance = self.orcaSpawnChance * difficultyMultiplier
        
        if orcaRoll < orcaChance then
            -- Spawn an orca
            newObstacle = Orca(lane)
        else
            -- Spawn regular obstacle
            newObstacle = Obstacle(lane)
        end
        
        table.insert(self.obstacles, newObstacle)
        
        -- Sometimes spawn multiple obstacles
        if difficultyMultiplier > 1.3 and math.random() < 0.3 then
            local secondLane = math.random(1, 3)
            -- Make sure it's not in the same lane
            while secondLane == lane do
                secondLane = math.random(1, 3)
            end
            
            -- Don't spawn multiple orcas together
            table.insert(self.obstacles, Obstacle(secondLane))
        end
    end
end

function ObstacleCourse:draw()
    for _, obstacle in ipairs(self.obstacles) do
        obstacle:draw()
    end
end

function ObstacleCourse:collision(surfer)
    -- Check collision with any obstacle
    for _, obstacle in ipairs(self.obstacles) do
        if obstacle:collision(surfer) then
            return true
        end
    end
    return false
end

return ObstacleCourse