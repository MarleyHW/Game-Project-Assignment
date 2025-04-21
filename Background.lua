local Class = require "hump.class"
local bgSky = love.graphics.newImage("bg/sky.png")
local bgClouds = love.graphics.newImage("bg/clouds.png")
local bgBeach = love.graphics.newImage("bg/beach.png")
local bgWave = love.graphics.newImage("bg/wave.png")
local bgFoam = love.graphics.newImage("bg/foam.png")
local Background = Class{}
function Background:init()
    self.skyPos = 0
    self.cloudPos = 0
    self.beachPos = 0
    self.wavePos = 0
    self.foamPos = 0
    self.skySpeed = 5
    self.cloudSpeed = 15
    self.beachSpeed = 30
    self.waveSpeed = 60
    self.foamSpeed = 90
    self.bgWidth = bgBeach:getWidth()
    self.waveAnimTime = 0
    self.waveHeight = 0
    self.waveDirection = 1
end