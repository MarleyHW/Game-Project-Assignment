local Utils = {}

function Utils.newTween(startValue, min, max, duration, updateFunc, completeFunc)
    local tween = {
        startValue = startValue,
        currentValue = startValue,
        minValue = min,
        maxValue = max,
        duration = duration,
        elapsedTime = 0,
        updateFunc = updateFunc,
        completeFunc = completeFunc,
        completed = false,

        update = function(self, dt)
            if self.completed then return end

            self.elapsedTime = self.elapsedTime + dt
            local progress = math.min(1, self.elapsedTime / self.duration)
            self.currentValue = self.startValue + (self.maxValue - self.startValue) * progress

            if self.updateFunc then
                self.updateFunc(self.currentValue)
            end
            
            if progress >= 1 and not self.completed then
                self.completed = true
                if self.completeFunc then
                    self.completeFunc()
                end
            end
        end
    }

    return tween
end

return Utils