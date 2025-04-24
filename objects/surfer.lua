local Class = require("libs.hump.class")
local surferSprites = {
    love.graphics.newImage("assets/sprites/surfer1.png"),
    love.graphics.newImage("assets/sprites/surfer2.png"),
    love.graphics.newImage("assets/sprites/surfer3.png")
}

local Surfer = Class{}
function Surfer:init() 
    -- Position
    self.x = gameWidth * 0.2
    self.y = gameHeight * 0.8

    -- Surfer skins
    self.currentSkin = currentSkin or 1
    self.sprite = surferSprites[self.currentSkin]
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()

    -- Dimensions
    self.sprite = surferSprites[self.currentSkin]
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
    self.scale = 0.1

    -- Animation state
    self.currentAnimation = "idle"
    self.currentFrame = 1
    self.animationTime = 0
    self.animationSpeed = 0.1

    -- Game state
    self.score = 0
    self.lives = 3
    self.invincible = false
    self.invincibleTime = 0
    self.invincibleFlash = 0

    -- Movement
    self.moveSpeed = 400
    self.moveDistance = 100
    self.targetY = self.y
    self.sprites = surferSprites
end 

function Surfer:update(dt)
    -- Moving surfer up and down
    if math.abs(self.y - self.targetY) > 2 then
        local direction = (self.targetY > self.y) and 1 or -1
        self.y = self.y + direction * self.moveSpeed * dt
    else
        self.y = self.targetY
    end
    
    -- Update invincibility after colliding with obstacle
    if self.invincible then
        self.invincibleTime = self.invincibleTime - dt
        self.invincibleFlash = self.invincibleFlash + dt
        
        if self.invincibleTime <= 0 then
            self.invincible = false
        end
    end

    -- Check if player is staying within the boundary
    if self.y < gameHeight / 2 - 80 then
        self.y = gameHeight / 2 - 80
        self.targetY =  gameHeight / 2 - 80
    elseif self.y > gameHeight - 70 then
        self.y = gameHeight - 70
        self.targetY = gameHeight - 70
    end

    -- Updating timer for scoring
    if self.scoreTimer and self.scoreTimer > 0 then
        self.scoreTimer = self.scoreTimer - dt
        if self.scoreTimer <= 0 then
            self.scoreText = nil
        end
    end
end

function Surfer:draw()
    -- Flash effect to indicate player is invincible
    if self.invincible and math.floor(self.invincibleFlash * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    -- Drawing the surfer sprite
    local drawScale = 0.20
    love.graphics.draw(self.sprite, self.x + 50, self.y, 0, drawScale, drawScale, self.width / 2, self.height / 2)
    love.graphics.setColor(1, 1, 1, 1) 

    -- Debug info
    if debugFlag then
        love.graphics.rectangle("line", self.x, self.y, self.width * drawScale, self.height * drawScale)
        love.graphics.print("Y: " .. math.floor(self.y), self.x, self.y - 20)
    end
end

function Surfer:moveUp()
    -- Move up without exceeding upper boundary
    self.targetY = math.max(5, self.y - self.moveDistance)
end

function Surfer:moveDown()
    -- Move down without exceeding lower boundary
    self.targetY = math.min(gameHeight - 5, self.y + self.moveDistance)
end

function Surfer:showScoreIndicator(text)
    -- To show a temporary score pop up 
    self.scoreText = text
    self.scoreTimer = 2 
end

function Surfer:changeSkin(skinIndex)
    -- Handling when the player selects a new skin from the skins menu
    self.currentSkin = skinIndex
    self.sprite = self.sprites[self.currentSkin]
    self.width = self.sprite:getWidth()
    self.height = self.sprite:getHeight()
end

return Surfer