local Class = require "libs.hump.class"
local TrickSystem = Class{}

function TrickSystem:init(surfer)
    self.surfer = surfer
    -- Trick definitions
    self.tricks = {
        -- Easy tricks are 1 second and 5 points
        easy = {
            w = "Nose Pick",
            a = "Hand Drag",
            s = "Tail Slide",
            d = "Snap Turn"
        },
        
        -- Medium tricks are 2 seconds and 10 points
        medium = {
            ["wa"] = "360 Spin",
            ["sd"] = "Floater",
            ["as"] = "Cutback",
            ["dw"] = "Air Drop"
        },
        
        -- Hard tricks are 3 seconds and 20 points
        hard = {
            ["wsd"] = "Barrel Roll",
            ["dsa"] = "Aerial Reverse",
            ["was"] = "Tube Ride",
            ["awd"] = "Rodeo Flip"
        }
    }
    
    -- Current trick state
    self.currentTrick = nil
    self.trickDifficulty = nil
    self.trickTimer = 0
    self.trickDuration = 0
    self.trickInput = ""
    self.inputActive = false
    self.inputBuffer = ""
    self.inputBufferTime = 0
    self.maxBufferTime = 0.5 
    -- Trick success indicator
    self.showSuccessIndicator = false
    self.successIndicatorTime = 0
    self.successPoints = 0
    -- Animation properties for trick indicator
    self.indicatorScale = 1
    self.indicatorAlpha = 1
end

function TrickSystem:update(dt)
    -- Update input buffer timing
    if self.inputActive then
        self.inputBufferTime = self.inputBufferTime + dt
        if self.inputBufferTime > self.maxBufferTime then
            self.inputActive = false
            self.inputBuffer = ""
        end
    end
    -- Update current trick timer
    if self.currentTrick then
        self.trickTimer = self.trickTimer + dt
        -- Check if trick completed
        if self.trickTimer >= self.trickDuration then
            self:completeTrick(true)
        end
    end
    -- Update success indicator
    if self.showSuccessIndicator then
        self.successIndicatorTime = self.successIndicatorTime + dt
        -- Animate indicator
        self.indicatorScale = 1 + math.sin(self.successIndicatorTime * 10) * 0.2
        self.indicatorAlpha = 1 - (self.successIndicatorTime / 2)
        -- Remove indicator after 2 seconds
        if self.successIndicatorTime >= 2 then
            self.showSuccessIndicator = false
        end
    end
end

function TrickSystem:performTrick(key)
    if self.currentTrick then
        return false
    end
    if not self.inputActive then
        self.inputActive = true
        self.inputBuffer = key
        self.inputBufferTime = 0
    else
        self.inputBuffer = self.inputBuffer .. key
        self.inputBufferTime = 0
    end
    -- Check for trick matches
    local trickFound = false
    -- Hard tricks are 3 key combos
    for combo, trickName in pairs(self.tricks.hard) do
        if self.inputBuffer == combo then
            self:startTrick(trickName, "hard", 3.0, 20)
            trickFound = true
            break
        end
    end
    
    -- Medium tricks are 2 key combos
    if not trickFound and #self.inputBuffer >= 2 then
        local lastTwoKeys = string.sub(self.inputBuffer, -2)
        for combo, trickName in pairs(self.tricks.medium) do
            if lastTwoKeys == combo then
                self:startTrick(trickName, "medium", 2.0, 10)
                trickFound = true
                break
            end
        end
    end
    -- Easy tricks are single keys
    if not trickFound then
        local lastKey = string.sub(self.inputBuffer, -1)
        for combo, trickName in pairs(self.tricks.easy) do
            if lastKey == combo then
                self:startTrick(trickName, "easy", 1.0, 5)
                trickFound = true
                break
            end
        end
    end
    
    return trickFound
end

function TrickSystem:startTrick(trickName, difficulty, duration, points)
    self.currentTrick = trickName
    self.trickDifficulty = difficulty
    self.trickDuration = duration
    self.trickPoints = points
    self.trickTimer = 0
    
    -- Tell surfer to animate trick
    self.surfer:startTrick(difficulty)
    
    -- Reset input state
    self.inputActive = false
    self.inputBuffer = ""
    
    return true
end

function TrickSystem:completeTrick(success)
    if success then
        -- Award points
        self.surfer.score = self.surfer.score + self.trickPoints
        
        -- Show success indicator
        self.showSuccessIndicator = true
        self.successIndicatorTime = 0
        self.successPoints = self.trickPoints
    end
    
    -- Reset trick state
    self.currentTrick = nil
    self.trickDifficulty = nil
    self.surfer:endTrick()
    
    return success
end

function TrickSystem:isTrickActive()
    return self.currentTrick ~= nil
end

function TrickSystem:drawTrickIndicator()
    if self.currentTrick then
        -- Draw trick name and progress
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.printf("TRICK: " .. self.currentTrick, 0, 50, gameWidth, "center")
        -- Progress bar
        local progressWidth = 200
        local progress = self.trickTimer / self.trickDuration
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        love.graphics.rectangle("fill", (gameWidth - progressWidth) / 2, 80, progressWidth, 10)
        -- Determine color based on difficulty
        if self.trickDifficulty == "easy" then
            love.graphics.setColor(0, 1, 0, 0.8) 
        elseif self.trickDifficulty == "medium" then
            love.graphics.setColor(1, 1, 0, 0.8)
        else
            love.graphics.setColor(1, 0.5, 0, 0.8) 
        end
        love.graphics.rectangle("fill", (gameWidth - progressWidth) / 2, 80, progressWidth * progress, 10)
        love.graphics.setColor(1, 1, 1, 1) 
    end
    -- Success indicator
    if self.showSuccessIndicator then
        love.graphics.setColor(1, 1, 0, self.indicatorAlpha)
        love.graphics.printf("+" .. self.successPoints .. " POINTS!", 0, 110, gameWidth, "center")
        love.graphics.setColor(1, 1, 1, 1) -- Reset color
    end
end

return TrickSystem