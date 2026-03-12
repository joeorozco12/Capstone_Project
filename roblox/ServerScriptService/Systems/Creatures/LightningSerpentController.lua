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
    self.nextTemplateRetryAt = 0
    self.missingTemplateWarned = false
    self.runtimeFolder = Workspace:FindFirstChild("StormRuntime") or Instance.new("Folder")
    self.runtimeFolder.Name = "StormRuntime"
    self.runtimeFolder.Parent = Workspace
    return self
end

function LightningSerpentController:ResolveTemplate()
    if self.serpentTemplate and self.serpentTemplate.Parent then
        return self.serpentTemplate
    end

    local now = os.clock()
    if now < self.nextTemplateRetryAt then
        return nil
    end

    self.nextTemplateRetryAt = now + 10
    self.serpentTemplate = ReplicatedStorage:FindFirstChild("LightningSerpentTemplate")

    if not self.serpentTemplate and not self.missingTemplateWarned then
        warn("LightningSerpentController: LightningSerpentTemplate not found in ReplicatedStorage")
        self.missingTemplateWarned = true
    elseif self.serpentTemplate then
        self.missingTemplateWarned = false
    end

    return self.serpentTemplate
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

    local template = self:ResolveTemplate()
    if not template then
        return nil
    end

    self.activeSerpent = template:Clone()
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
