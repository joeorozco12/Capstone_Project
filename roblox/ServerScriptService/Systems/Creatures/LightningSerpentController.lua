local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StormEventBroadcast = Remotes:WaitForChild("StormEventBroadcast")

local LightningSerpentController = {}
LightningSerpentController.__index = LightningSerpentController

function LightningSerpentController.new(weatherManager, serpentTemplate)
    local self = setmetatable({}, LightningSerpentController)
    self.weatherManager = weatherManager
    self.serpentTemplate = serpentTemplate
    self.activeSerpent = nil
    self.cooldownUntil = 0
    return self
end

function LightningSerpentController:TrySpawn()
    if os.clock() < self.cooldownUntil then
        return
    end

    if self.weatherManager:GetCurrentWeather() ~= "WorldbreakerSupercell" then
        return
    end

    if self.activeSerpent then
        return
    end

    self.activeSerpent = self.serpentTemplate:Clone()
    self.activeSerpent.Parent = Workspace:WaitForChild("StormRuntime")
    self.activeSerpent:PivotTo(CFrame.new(0, 220, 0))

    self.cooldownUntil = os.clock() + 600
    StormEventBroadcast:FireAllClients({
        eventId = "LightningSerpentAppears",
        message = "⚡ The Lightning Serpent descends from the storm!",
    })
end

return LightningSerpentController
