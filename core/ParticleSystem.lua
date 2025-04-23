-- Based on Explosion.lua from Jewels code 
local Class = require "libs.hump.class"
local imgSplash = love.graphics.newImage("assets/graphics/splash.png")
local imgSparkle = love.graphics.newImage("assets/graphics/sparkle.png")
local imgWake = love.graphics.newImage("assets/graphics/wake.png")
local imgHeart = love.graphics.newImage("assets/graphics/heart.png")
local ParticleSystem = Class{}

function ParticleSystem:init()
    -- Initialize all particle systems
    self:initSplashSystem()
    self:initCollectSystem()
    self:initWakeSystem()
    self:initLifeJacketSystem()
    -- Track active effects
    self.activeEffects = {}
    self.wakeActive = true
end

function ParticleSystem:initSplashSystem()
    self.splashSystem = love.graphics.newParticleSystem(imgSplash, 100)
    self.splashSystem:setSizes(0.03, 0.06, 0.02)
    self.splashSystem:setEmissionRate(0) 
    self.splashSystem:setSizes(0.1, 0.2, 0.05) 
    self.splashSystem:setSpeed(50, 150)
    self.splashSystem:setLinearAcceleration(-20, -100, 20, -50)
    self.splashSystem:setEmissionArea("uniform", 20, 10, 0, true)
    self.splashSystem:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    self.splashSystem:setSpread(math.pi * 0.5)
end

function ParticleSystem:initCollectSystem()
    self.collectSystem = love.graphics.newParticleSystem(imgSparkle, 50)
    self.collectSystem:setParticleLifetime(0.3, 0.7)
    self.collectSystem:setEmissionRate(0) 
    self.collectSystem:setSizes(0.1, 0.2, 0.05) 
    self.collectSystem:setSpeed(30, 80)
    self.collectSystem:setLinearAcceleration(-20, -20, 20, 20)
    self.collectSystem:setEmissionArea("uniform", 15, 15, 0, true)
    self.collectSystem:setColors(1, 1, 0.4, 1, 1, 0.4, 0.4, 0)
    self.collectSystem:setSpread(math.pi * 2)
end

function ParticleSystem:initWakeSystem()
    self.wakeSystem = love.graphics.newParticleSystem(imgWake, 200)
    self.wakeSystem:setParticleLifetime(0.5, 1.0)
    self.wakeSystem:setEmissionRate(15) 
    self.wakeSystem:setSizes(0.05, 0.15, 0.02)
    self.wakeSystem:setSpeed(10, 30)
    self.wakeSystem:setLinearAcceleration(-50, 0, -100, 0)
    self.wakeSystem:setEmissionArea("uniform", 5, 20, 0, true)
    self.wakeSystem:setColors(1, 1, 1, 0.7, 1, 1, 1, 0)
    self.wakeSystem:setPosition(gameWidth/3 - 30, gameHeight/2 + 40)
end

function ParticleSystem:initLifeJacketSystem()
    self.lifeJacketSystem = love.graphics.newParticleSystem(imgHeart, 30)
    self.lifeJacketSystem:setParticleLifetime(0.5, 1.2)
    self.lifeJacketSystem:setEmissionRate(0) 
    self.lifeJacketSystem:setSizes(0.1, 0.2, 0.05)
    self.lifeJacketSystem:setSpeed(20, 60)
    self.lifeJacketSystem:setLinearAcceleration(-10, -50, 10, -30)
    self.lifeJacketSystem:setEmissionArea("uniform", 10, 10, 0, true)
    self.lifeJacketSystem:setColors(1, 0.4, 0.4, 1, 1, 0.4, 0.4, 0) 
    self.lifeJacketSystem:setSpread(math.pi)
end

function ParticleSystem:update(dt)
    if self.wakeActive then
        self.wakeSystem:update(dt)
    end
    self.splashSystem:update(dt)
    self.collectSystem:update(dt)
    self.lifeJacketSystem:update(dt)
end

function ParticleSystem:draw()
    if self.wakeActive then
        love.graphics.draw(self.wakeSystem)
    end
    love.graphics.draw(self.splashSystem)
    love.graphics.draw(self.collectSystem)
    love.graphics.draw(self.lifeJacketSystem)
end

function ParticleSystem:createSplashEffect(x, y)
    self.splashSystem:setPosition(x, y)
    self.splashSystem:emit(50)
end

function ParticleSystem:createCollectEffect(x, y)
    self.collectSystem:setPosition(x, y)
    self.collectSystem:emit(30)
end

function ParticleSystem:createLifeJacketEffect(x, y)
    self.lifeJacketSystem:setPosition(x, y)
    self.lifeJacketSystem:emit(20)
end


function ParticleSystem:createTrickEffect(x, y)
    self.splashSystem:setPosition(x, y)
    self.splashSystem:emit(25)
end

function ParticleSystem:setWakePosition(x, y)
    self.wakeSystem:setPosition(x, y)
end

function ParticleSystem:isActive()
    return self.splashSystem:getCount() > 0 or 
           self.collectSystem:getCount() > 0 or
           self.lifeJacketSystem:getCount() > 0
end

function ParticleSystem:createCollisionEffect(x, y)
    self.splashSystem:setPosition(x, y)
    self.splashSystem:emit(40)
end


return ParticleSystem
