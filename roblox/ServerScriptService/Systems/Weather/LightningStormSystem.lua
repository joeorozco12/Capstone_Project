local Players = game:GetService("Players")

local LightningStormSystem = {}
LightningStormSystem.__index = LightningStormSystem

function LightningStormSystem.new(weatherManager)
    local self = setmetatable({}, LightningStormSystem)
    self.weatherManager = weatherManager
    self.tickAccumulator = 0
    return self
end

function LightningStormSystem:Update(deltaTime)
    self.tickAccumulator += deltaTime
    if self.tickAccumulator < 1 then
        return
    end
    self.tickAccumulator = 0

    if self.weatherManager:GetCurrentWeather() ~= "Thunderstorm" then
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid and math.random() < 0.05 then
            humanoid:TakeDamage(8)
        end
    end
end

return LightningStormSystem
