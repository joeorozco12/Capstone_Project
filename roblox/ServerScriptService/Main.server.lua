local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local function ensureFolder(parent, name)
    local folder = parent:FindFirstChild(name)
    if folder then
        return folder
    end

    folder = Instance.new("Folder")
    folder.Name = name
    folder.Parent = parent
    return folder
end

local function ensureRemote(remotesFolder, name, className)
    local remote = remotesFolder:FindFirstChild(name)
    if remote and remote.ClassName == className then
        return remote
    end

    if remote then
        remote:Destroy()
    end

    remote = Instance.new(className)
    remote.Name = name
    remote.Parent = remotesFolder
    return remote
end

-- Ensure network primitives exist even in a blank place file.
local remotesFolder = ensureFolder(ReplicatedStorage, "Remotes")
ensureRemote(remotesFolder, "WeatherStateChanged", "RemoteEvent")
ensureRemote(remotesFolder, "StormEventBroadcast", "RemoteEvent")
ensureRemote(remotesFolder, "StormSeedPurchaseRequest", "RemoteEvent")
ensureRemote(remotesFolder, "CreatureEncounterEvent", "RemoteEvent")
ensureRemote(remotesFolder, "JournalSyncRequest", "RemoteFunction")

local WeatherManager = require(ServerScriptService.Systems.Weather.WeatherManager)
local StormScheduler = require(ServerScriptService.Systems.Weather.StormScheduler)
local LightningStormSystem = require(ServerScriptService.Systems.Weather.LightningStormSystem)
local WetSurfaceService = require(ServerScriptService.Systems.Weather.WetSurfaceService)
local LightningSerpentController = require(ServerScriptService.Systems.Creatures.LightningSerpentController)
local StormSeedService = require(ServerScriptService.Systems.Monetization.StormSeedService)
local WeatherPool = require(ServerScriptService.Config.WeatherPool)

local weatherManager = WeatherManager.new()
local scheduler = StormScheduler.new(weatherManager, WeatherPool)
local lightningSystem = LightningStormSystem.new(weatherManager)
local wetSurfaceService = WetSurfaceService.new(weatherManager)

local serpentTemplate = ReplicatedStorage:FindFirstChild("LightningSerpentTemplate")
local serpentController = LightningSerpentController.new(weatherManager, serpentTemplate)

local stormSeedService = StormSeedService.new(weatherManager)
stormSeedService:Init()

weatherManager:SetWeather("Drizzle", 90)

RunService.Heartbeat:Connect(function(deltaTime)
    scheduler:Step()
    lightningSystem:Update(deltaTime)
    wetSurfaceService:Apply()
    serpentController:TrySpawn()
end)
