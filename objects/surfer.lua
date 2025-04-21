local Class = require("libs.hump.class")
local surferSprites = {}
surferSprites["idle"] = {}
surferSprites["idle"][1] = love.graphics.newImage("assets/sprites/surfer_idle1.png")
surferSprites["idle"][2] = love.graphics.newImage("assets/sprites/surfer_idle2.png")
surferSprites["idle"][3] = love.graphics.newImage("assets/sprites/surfer_idle3.png")
surferSprites["trick1"] = {}
surferSprites["trick1"][1] = love.graphics.newImage("assets/sprites/surfer_trick1_1.png")
surferSprites["trick1"][2] = love.graphics.newImage("assets/sprites/surfer_trick1_2.png")
surferSprites["trick1"][3] = love.graphics.newImage("assets/sprites/surfer_trick1_3.png")
surferSprites["trick2"] = {}
surferSprites["trick2"][1] = love.graphics.newImage("assets/sprites/surfer_trick2_1.png")
surferSprites["trick2"][2] = love.graphics.newImage("assets/sprites/surfer_trick2_2.png")
surferSprites["trick2"][3] = love.graphics.newImage("assets/sprites/surfer_trick2_3.png")
surferSprites["trick3"] = {}
surferSprites["trick3"][1] = love.graphics.newImage("assets/sprites/surfer_trick3_1.png")
surferSprites["trick3"][2] = love.graphics.newImage("assets/sprites/surfer_trick3_2.png")
surferSprites["trick3"][3] = love.graphics.newImage("assets/sprites/surfer_trick3_3.png")

-- Define the Surfer class
local Surfer = Class{}
function Surfer:init() 
    -- Position
    self.x = gameWidth/3 
    self.y = gameHeight/2 
    -- Dimensions
    self.width = surferSprites["idle"][1]:getWidth()
    self.height = surferSprites["idle"][1]:getHeight()
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
    self.moveSpeed = 200
    self.verticalPosition = 2 
    self.targetY = self.y
    -- Tricks
    self.performingTrick = false
    self.currentTrick = nil
    self.trickTimer = 0
    self.trickDuration = 0
end 
function Surfer:update(dt)
    -- Update animation
    self.animationTime = self.animationTime + dt
    if self.animationTime >= self.animationSpeed then
        self.currentFrame = (self.currentFrame % #surferSprites[self.currentAnimation]) + 1
        self.animationTime = 0
    end
    
    -- Smooth vertical movement
    if math.abs(self.y - self.targetY) > 2 then
        local direction = (self.targetY > self.y) and 1 or -1
        self.y = self.y + direction * self.moveSpeed * dt
    else
        self.y = self.targetY
    end
    -- Update trick state
    if self.performingTrick then
        self.trickTimer = self.trickTimer + dt
        if self.trickTimer >= self.trickDuration then
            self.performingTrick = false
            self.currentAnimation = "idle"
        end
    end
    -- Update invincibility
    if self.invincible then
        self.invincibleTime = self.invincibleTime - dt
        self.invincibleFlash = self.invincibleFlash + dt
        
        if self.invincibleTime <= 0 then
            self.invincible = false
        end
    end
    -- Boundary check
    if self.y < 100 then
        self.y = 100
    elseif self.y > gameHeight - 150 then
        self.y = gameHeight - 150
    end
    if self.scoreTimer and self.scoreTimer > 0 then
        self.scoreTimer = self.scoreTimer - dt
        if self.scoreTimer <= 0 then
            self.scoreText = nil
        end
    end
    
end
function Surfer:draw()
    -- Draw with flashing effect when invincible
    if self.invincible and math.floor(self.invincibleFlash * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    if self.scoreText then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf(self.scoreText, 0, self.y - 40, gameWidth, "center")
    end
    
    love.graphics.draw(surferSprites[self.currentAnimation][self.currentFrame], self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1) 
    if debugFlag then
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
        love.graphics.print("Pos: " .. self.verticalPosition, self.x, self.y - 20)
    end
end
function Surfer:move(direction)
    if direction == "up" and self.verticalPosition > 1 then
        self.verticalPosition = self.verticalPosition - 1
        self.targetY = gameHeight/2 - 80 + (self.verticalPosition - 2) * 80
    elseif direction == "down" and self.verticalPosition < 3 then
        self.verticalPosition = self.verticalPosition + 1
        self.targetY = gameHeight/2 - 80 + (self.verticalPosition - 2) * 80
    end
end
function Surfer:showScoreIndicator(text)
    -- To show a temporary score pop up 
    self.scoreText = text
    self.scoreTimer = 2 
end

function Surfer:startTrick(trickType)
    if not self.performingTrick then
        self.performingTrick = true
        self.currentTrick = trickType
        -- Set animation based on trick difficulty
        if trickType == "easy" then
            self.currentAnimation = "trick1"
            self.trickDuration = 1.0
        elseif trickType == "medium" then
            self.currentAnimation = "trick2"
            self.trickDuration = 2.0
        elseif trickType == "hard" then
            self.currentAnimation = "trick3"
            self.trickDuration = 3.0
        end
        
        self.trickTimer = 0
        self.currentFrame = 1
        self.animationTime = 0
        
        return true
    end
    
    return false
end
function Surfer:endTrick()
    self.performingTrick = false
    self.currentAnimation = "idle"
    self.currentFrame = 1
    self.animationTime = 0
end

function Surfer:moveUp()
    self:move("up")
end

function Surfer:moveDown()
    self:move("down")
end

return Surfer