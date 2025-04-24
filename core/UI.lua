local Class = require "libs.hump.class"
local lifeIcon = love.graphics.newImage("assets/bg/life.png")
local UI = Class{}

function UI:init()
    -- Animation properties for UI elements
    self.scoreScale = 1
    self.scorePulse = false
    self.scorePulseTime = 0

    -- Previous score for animation
    self.prevScore = 0

    -- Tween for score display
    self.displayScore = 0
    self.targetScore = 0

    -- Score and lives position
    self.scoreX = 10
    self.scoreY = 10
    self.livesX = gameWidth - 120
    self.livesY = 10
end

function UI:update(dt, score)
    -- Update score display tween
    if self.targetScore ~= score then
        self.targetScore = score
        self.scorePulse = true
        self.scorePulseTime = 0
    end

    if self.displayScore < self.targetScore then
        self.displayScore = math.min(self.targetScore, self.displayScore + dt * 50)
    end

    -- Update score pulse animation
    if self.scorePulse then
        self.scorePulseTime = self.scorePulseTime + dt
        self.scoreScale = 1 + math.sin(self.scorePulseTime * 10) * 0.2
        
        if self.scorePulseTime >= 0.5 then
            self.scorePulse = false
            self.scoreScale = 1
        end
    end
end

function UI:drawScore(score)
    -- Update the target score
    self.targetScore = score

    -- Calculate tween if needed
    if math.abs(self.displayScore - self.targetScore) > 0.1 then
        self.displayScore = self.displayScore + (self.targetScore - self.displayScore) * 0.1
    else
        self.displayScore = self.targetScore
    end

    -- Draw score with scaling effect
    love.graphics.setFont(scoreFont)

    -- Draw background glow for readability
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.printf("SCORE: " .. math.floor(self.displayScore), self.scoreX + 2, self.scoreY + 2, 200, "left")
        
    -- Draw score with scaling effect if pulsing
    if self.scorePulse then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.push()
        love.graphics.scale(self.scoreScale, self.scoreScale)
        love.graphics.printf("SCORE: " .. math.floor(self.displayScore), self.scoreX / self.scoreScale, self.scoreY / self.scoreScale, 200 / self.scoreScale, "left")
        love.graphics.pop()
    else
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf("SCORE: " .. math.floor(self.displayScore), 
            self.scoreX, self.scoreY, 200, "left")
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- Drawing the amount of lives the player has
function UI:drawLives(lives)
    love.graphics.setFont(regularFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("LIVES:", self.livesX, self.livesY)
    for i = 1, lives do
        love.graphics.draw(lifeIcon, self.livesX + 60 + (i-1) * 30, self.livesY)
    end
end

-- Drawing the highest score achieved
function UI:drawHighScore(highScore)
    love.graphics.setFont(regularFont)
    love.graphics.printf("HIGH SCORE: " .. highScore, 0, gameHeight - 40, gameWidth, "center")
end

return UI