local Class = require "libs.hump.class"
local SkinUnlocks = Class{}

function SkinUnlocks:init()
    -- Available skins
    self.skins = {
        {
            name = "Default",
            unlocked = true,
            scoreRequirement = 0,
            preview = love.graphics.newImage("assets/sprites/surfer1.png")
        },
        {
            name = "Pro Surfer",
            unlocked = false,
            scoreRequirement = 100,
            preview = love.graphics.newImage("assets/sprites/surfer2.png")
        },
        {
            name = "Champion",
            unlocked = false,
            scoreRequirement = 500,
            preview = love.graphics.newImage("assets/sprites/surfer3.png")
        }
    }

    -- Surfer skin that is currently selected
    self.currentSkinIndex = 1
    self.newUnlock = false
end

function SkinUnlocks:checkUnlocks(score)
    -- Checking if a skin has been unlocked or not
    local hadNewUnlock = false
    for i, skin in ipairs(self.skins) do
        if not skin.unlocked and score >= skin.scoreRequirement then
            skin.unlocked = true
            hadNewUnlock = true
        end
    end

    self.newUnlock = hadNewUnlock
    return hadNewUnlock
end

function SkinUnlocks:draw()
    local screenWidth = gameWidth
    local screenHeight = gameHeight
    local gridSize = 3
    local itemWidth = 120
    local itemHeight = 150
    local spacing = 30
    local startX = (screenWidth - (itemWidth * gridSize + spacing * (gridSize - 1))) / 2
    local startY = 200

    -- Drawing all of the available surfer skins to choose from
    for i, skin in ipairs(self.skins) do
        local x = startX + (i-1) * (itemWidth + spacing)
        local y = startY

        -- Draw the selection box for displaying each skin
        if i == self.currentSkinIndex then
            love.graphics.setColor(0.3, 0.7, 1, 1)
            love.graphics.rectangle("line", x - 5, y - 5, itemWidth + 10, itemHeight + 10, 10, 10)
        end
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
        love.graphics.rectangle("fill", x, y, itemWidth, itemHeight, 5, 5)
        
        -- Draw the preview for the skin and properly center it
        if skin.unlocked then
            love.graphics.setColor(1, 1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        end
        local imgWidth = skin.preview:getWidth()
        local imgHeight = skin.preview:getHeight()
        local scaleX = (itemWidth - 20) / imgWidth
        local scaleY = (itemHeight - 60) / imgHeight
        local scale = math.min(scaleX, scaleY)
        love.graphics.draw(
            skin.preview,
            x + itemWidth/2,
            y + itemHeight/2 - 15,
            0,
            scale, scale,
            imgWidth/2, imgHeight/2
        )

        -- Displaying the name and indicating whether or not it is unlocked
        love.graphics.setFont(instructionFont)
        love.graphics.printf(skin.name, x, y + itemHeight - 40, itemWidth, "center")
        if not skin.unlocked then
            love.graphics.setColor(1, 0.5, 0.3, 1)
            love.graphics.printf("Score: " .. skin.scoreRequirement, x, y + itemHeight - 20, itemWidth, "center")
        elseif i == self.currentSkinIndex then
            love.graphics.setColor(0.3, 1, 0.3, 1)
            love.graphics.printf("Selected", x, y + itemHeight - 20, itemWidth, "center")
        end

        love.graphics.setColor(1, 1, 1, 1)
    end
end

function SkinUnlocks:handleInput(key)
    -- Allowing player to select which skin they want to select by using arrow keys
    if key == "left" and self.currentSkinIndex > 1 then
        self.currentSkinIndex = self.currentSkinIndex - 1
    elseif key == "right" and self.currentSkinIndex < #self.skins then
        self.currentSkinIndex = self.currentSkinIndex + 1
    end

    -- Only allow selection of unlocked skins
    if not self.skins[self.currentSkinIndex].unlocked then
        if key == "left" then
            -- Find the next unlocked skin to the left
            for i = self.currentSkinIndex - 1, 1, -1 do
                if self.skins[i].unlocked then
                    self.currentSkinIndex = i
                    break
                end
            end
        elseif key == "right" then
            -- Find the next unlocked skin to the right
            for i = self.currentSkinIndex + 1, #self.skins do
                if self.skins[i].unlocked then
                    self.currentSkinIndex = i
                    break
                end
            end
        end
    end
end

function SkinUnlocks:selectCurrent()
    -- Ensure the skin is unlocked
    if self.skins[self.currentSkinIndex].unlocked then
        return self.currentSkinIndex
    else
        -- Default to the first skin if the selected skin has not been unlocked yet
        return 1
    end
end

function SkinUnlocks:getCurrentSkin()
    return self.currentSkinIndex
end

function SkinUnlocks:hasNewUnlock()
    return self.newUnlock
end

return SkinUnlocks