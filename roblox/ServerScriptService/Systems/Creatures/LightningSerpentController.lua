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
    self.runtimeFolder = Workspace:FindFirstChild("StormRuntime") or Instance.new("Folder")
    self.runtimeFolder.Name = "StormRuntime"
    self.runtimeFolder.Parent = Workspace
    return self
end

function LightningSerpentController:TrySpawn()
    if os.clock() < self.cooldownUntil then
        return nil
    end

    if self.weatherManager:GetCurrentWeather() ~= "WorldbreakerSupercell" then
        return nil
    end

    if self.activeSerpent and self.activeSerpent.Parent then
        return self.activeSerpent
    end

    if not self.serpentTemplate then
        warn("LightningSerpentController: serpentTemplate is missing")
        return nil
    end

    self.activeSerpent = self.serpentTemplate:Clone()
    self.activeSerpent.Parent = self.runtimeFolder
    self.activeSerpent:PivotTo(CFrame.new(0, 220, 0))

    self.cooldownUntil = os.clock() + 600
    StormEventBroadcast:FireAllClients({
        eventId = "LightningSerpentAppears",
        message = "⚡ The Lightning Serpent descends from the storm!",
    })

    return self.activeSerpent
end

function LightningSerpentController:DespawnActiveSerpent()
    if self.activeSerpent and self.activeSerpent.Parent then
        self.activeSerpent:Destroy()
    end
    self.activeSerpent = nil
end

return LightningSerpentController
