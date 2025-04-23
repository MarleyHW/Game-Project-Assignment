-- Libraries
local Class = require("libs.hump.class")
local Timer = require("libs.hump.timer")

-- Engine
local Push = require("engine.push")

-- Core
local Background = require("core.Background")
local Utils = require("core.Utils")
local UI = require("core.UI")
local ParticleSystem = require("core.ParticleSystem")

-- Objects
local Surfer = require("objects.Surfer")
local Obstacle = require("objects.Obstacle")
local ObstacleCourse = require("objects.ObstacleCourse")
local CollectibleSystem = require("objects.CollectibleSystem")

-- Systems
local SkinUnlocks = require("systems.SkinsUnlock")

-- TitleScreen
local beachTitleBG = love.graphics.newImage("assets/bg/beach.png")

-- Global variables
gameWidth = 1024
gameHeight = 768
gameState = "start" 
debugFlag = false
highScore = 0
currentScore = 0
lastScore = 0
maxLives = 3
difficultyMultiplier = 1
timePlayed = 0
currentSkin = 1
scoreTween = nil
speedTween = nil
function love.load()
    love.window.setTitle("Tide Rider")
    windowWidth, windowHeight = love.graphics.getDimensions()
    math.randomseed(os.time())
    titleFont = love.graphics.newFont("fonts/HanaleiFill-Regular.ttf",90)
    scoreFont = love.graphics.newFont(34)
    instructionFont = love.graphics.newFont(26)
    Push:setupScreen(gameWidth, gameHeight, windowWidth, windowHeight, {
        fullscreen = false,
        resizable = true,
        canvas = true
    })    
    -- Initialize game objects
    bg = Background()
    surfer = Surfer()
    obsCourse = ObstacleCourse()
    particles = ParticleSystem()
    skins = SkinUnlocks()
    collectibles = CollectibleSystem()


    -- Debug initial positions
    print(string.format("Surfer initial position: x=%.2f, y=%.2f, w=%.2f, h=%.2f", surfer.x, surfer.y, surfer.width, surfer.height))
    for i, obstacle in ipairs(obsCourse.obstacles) do
        print(string.format("Obstacle %d initial position: x=%.2f, y=%.2f, w=%.2f, h=%.2f, lane=%d", 
            i, obstacle.x, obstacle.y, obstacle.width, obstacle.height, obstacle.lanePosition))
    end
    sounds = {}

    sounds = {} 
    sounds['music'] = love.audio.newSource("assets/sounds/west-coast-surf-instrumental-208062.mp3", "static")
    sounds['collect'] = love.audio.newSource("assets/sounds/collect-5930.mp3", "static")
    sounds['life'] = love.audio.newSource("assets/sounds/heavenly-choir-of-angels-322708.mp3", "static")
    sounds['splash'] = love.audio.newSource("assets/sounds/water-splash-199583.mp3", "static")
    sounds['collision'] = love.audio.newSource("assets/sounds/negative_beeps-6008.mp3", "static")
    sounds['gameover'] = love.audio.newSource("assets/sounds/falled-sound-effect-278635.mp3", "static")
    -- Start background music
    sounds['music']:setLooping(true)
    sounds['music']:play()
    -- Initialize tweens
    speedTween = Utils.newTween(difficultyMultiplier, 1, 3, 60)
end
function love.resize(w, h)
    Push:resize(w, h)
end

function love.update(dt)
    -- Update tweens
    if speedTween then
        speedTween:update(dt)
    end
    if scoreTween then
        scoreTween:update(dt)
    end
    if gameState == "play" then
        -- Update timers
        timePlayed = timePlayed + dt
        -- Increase difficulty over time
        difficultyMultiplier = math.min(3, 1 + (timePlayed / 60))
        -- Update game objects
        bg:update(dt)
        local drawScale = 0.15
        particles:setWakePosition(surfer.x - (surfer.width * drawScale) / 2, surfer.y + (surfer.height * drawScale) / 3)
        surfer:update(dt)
        obsCourse:update(dt, difficultyMultiplier)
        particles:update(dt)
        collectibles:update(dt, difficultyMultiplier)
        -- Check for collectibles
        local collectedType = collectibles:checkCollisions(surfer)
        if collectedType == "seashell" then
            particles:createCollectEffect(surfer.x, surfer.y)
            sounds["collect"]:play()
            currentScore = currentScore + 10
            surfer:showScoreIndicator("+10")
        elseif collectedType == "lifejacket" then
            particles:createLifeJacketEffect(surfer.x, surfer.y)
            sounds["life"]:play()
            lives = math.min(maxLives, lives + 1)
            surfer:showScoreIndicator("+1")
        end
        -- Handle obstacle collision with invincibility
        if obsCourse:collision(surfer) and not surfer.invincible then
            particles:createCollisionEffect(surfer.x, surfer.y)
            sounds["collision"]:play()
            lives = lives - 1

            -- Enable temporary invincibility
            surfer.invincible = true
            surfer.invincibleTime = 2
            surfer.invincibleFlash = 0

            if lives <= 0 then
                sounds["gameover"]:play()
                gameState = "over"
                highScore = math.max(highScore, currentScore)
                lastScore = currentScore
                skins:checkUnlocks(currentScore)
            end
        end

        -- Update score based on time and tricks
        handleScoring(dt)
    end
end

function handleScoring(dt)
    currentScore = currentScore + dt
end

function love.draw()
    Push:start()
    if gameState == "play" then
        drawPlayState()
    elseif gameState == "start" then
        drawStartState()
    elseif gameState == "over" then
        drawGameOverState()
    elseif gameState == "pause" then
        drawPauseState()
    elseif gameState == "skins" then
        drawSkinsMenu()
    end
    Push:finish()
end

function drawStartState()
    local bgScaleX = gameWidth / beachTitleBG:getWidth()
    local bgScaleY = gameHeight / beachTitleBG:getHeight()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(beachTitleBG, 0, 0, 0, bgScaleX, bgScaleY)

    -- Arcade Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0, 0.5, 1)
    love.graphics.printf("TIDE RIDER", 0, 60, gameWidth, "center")

    -- Flashing Start Game Text
    local alpha = 0.5 + 0.5 * math.sin(love.timer.getTime() * 4)
    love.graphics.setColor(0, 0.8, 1, alpha)
    love.graphics.setFont(scoreFont)
    love.graphics.printf("Press Enter to Ride", 0, 180, gameWidth, "center")

    -- Controls
    love.graphics.setColor(0, 0.8, 1, 1)
    love.graphics.setFont(instructionFont)
    love.graphics.printf("Up or Down Arrows to Surf", 0, 260, gameWidth, "center")
    love.graphics.printf("Hold W A S D for Tricks", 0, 290, gameWidth, "center")
end

function drawPlayState()
    bg:drawBackground()
    bg:drawForeground()
    obsCourse:draw()
    collectibles:draw()
    particles:draw()
    surfer:draw()
    drawPlayUI()
    if debugFlag then
        love.graphics.print("FPS: "..love.timer.getFPS(), 10, gameHeight-20)
        love.graphics.print("Difficulty: "..string.format("%.2f", difficultyMultiplier), 10, gameHeight-40)
        love.graphics.print("Time: "..string.format("%.1f", timePlayed), 10, gameHeight-60)
    end
end

function drawPlayUI()
    -- Show score
    love.graphics.print("Score: "..math.floor(currentScore), scoreFont, 10, 10)
    -- Show lives
    love.graphics.print("Lives: "..lives, scoreFont, 10, 40)
end

function drawGameOverState()
    -- Background
    local bgScaleX = gameWidth / beachTitleBG:getWidth()
    local bgScaleY = gameHeight / beachTitleBG:getHeight()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(beachTitleBG, 0, 0, 0, bgScaleX, bgScaleY)

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Wipeout!", 0, 60, gameWidth, "center")

    -- Score Info
    love.graphics.setFont(scoreFont)
    love.graphics.setColor(0, 0.8, 1, 1)
    love.graphics.printf("Score: " .. math.floor(lastScore), 0, 180, gameWidth, "center")
    love.graphics.printf("High Score: " .. math.floor(highScore), 0, 210, gameWidth, "center")

    -- Skin Unlock (if applicable)
    if skins:hasNewUnlock() then
        love.graphics.printf("New Skin Unlocked!", 0, 400, gameWidth, "center")
    end

    -- Flashing Play Again Prompt
    local alpha = 0.5 + 0.5 * math.sin(love.timer.getTime() * 4)
    love.graphics.setColor(0, 0.8, 1, alpha)
    love.graphics.setFont(scoreFont)
    love.graphics.printf("Press Enter to Play Again", 0, 250, gameWidth, "center")

    -- Instructions
    love.graphics.setColor(0, 0.8, 1, 1)
    love.graphics.setFont(instructionFont)
    love.graphics.printf("Press S to view skins", 0, 340, gameWidth, "center")
    love.graphics.printf("Press Esc to exit", 0, 370, gameWidth, "center")
end


function drawPauseState()
    love.graphics.printf("Paused", titleFont, 0, 100, gameWidth, "center")
    love.graphics.printf("Press P to resume", instructionFont, 0, 180, gameWidth, "center")
    love.graphics.printf("Press Esc to quit", instructionFont, 0, 210, gameWidth, "center")
end

function drawSkinsMenu()
    bg:drawBackground()
    
    love.graphics.printf("Surfer Skins", titleFont, 0, 60, gameWidth, "center")
    
    skins:draw()
    
    love.graphics.printf("Press Enter to select", instructionFont, 0, 380, gameWidth, "center")
    love.graphics.printf("Press B to go back", instructionFont, 0, 410, gameWidth, "center")

    love.graphics.setFont(scoreFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("High Score: " .. math.floor(highScore), 0, 100, gameWidth, "center")

end

function resetGame()
    surfer = Surfer()
    obsCourse = ObstacleCourse()
    particles = ParticleSystem()
    
    lives = 3
    currentScore = 0
    difficultyMultiplier = 1
    timePlayed = 0
    collectibles = CollectibleSystem()
    gameState = "play"
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif gameState == "play" then
        handlePlayKeypresses(key)
    elseif key == "return" and gameState ~= "play" then
        if gameState == "skins" then
            skins:selectCurrent()
            currentSkin = skins:getCurrentSkin()
            surfer:changeSkin(currentSkin)
            gameState = "start"
        else
            resetGame()
        end
    elseif key == "F2" or key == "tab" then
        debugFlag = not debugFlag
    elseif key == "p" and gameState == "pause" then
        gameState = "play"
        sounds['music']:play()
    elseif key == "p" and (gameState == "play" or gameState == "start") then
        gameState = "pause"
        sounds['music']:pause()
    elseif key == "s" and (gameState == "start" or gameState == "over") then
        gameState = "skins"
    elseif key == "b" and gameState == "skins" then
        gameState = "start"
    elseif gameState == "skins" then
        skins:handleInput(key)
    end
end

function handlePlayKeypresses(key)
    -- Movement controls
    if key == "up" then
        surfer:moveUp()
    elseif key == "down" then
        surfer:moveDown()
    end
end