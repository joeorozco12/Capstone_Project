local Players = game:GetService("Players")

local LightningStormSystem = {}
LightningStormSystem.__index = LightningStormSystem

function LightningStormSystem.new(weatherManager, seed)
    local self = setmetatable({}, LightningStormSystem)
    self.weatherManager = weatherManager
    self.tickAccumulator = 0
    self.rng = seed and Random.new(seed) or Random.new()
    self.damagePerStrike = 8
    self.strikeChancePerTick = 0.05
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
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid and root and humanoid.Health > 0 then
            if self.rng:NextNumber() <= self.strikeChancePerTick then
                humanoid:TakeDamage(self.damagePerStrike)
            end
        end
    end
end

return LightningStormSystem
