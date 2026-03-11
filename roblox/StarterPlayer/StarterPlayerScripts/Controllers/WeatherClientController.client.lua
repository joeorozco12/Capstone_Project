local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local WeatherStateChanged = Remotes:WaitForChild("WeatherStateChanged")
local StormEventBroadcast = Remotes:WaitForChild("StormEventBroadcast")

WeatherStateChanged.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then
        return
    end

    local weatherId = payload.weatherId or "Unknown"
    local duration = tonumber(payload.duration) or 0

    print("Weather changed:", weatherId, "duration:", duration)
    -- Hook point: update HUD + post-process effects.
end)

StormEventBroadcast.OnClientEvent:Connect(function(payload)
    if type(payload) ~= "table" then
        return
    end

    print("Server Event:", payload.message or "Event triggered")
    -- Hook point: event banners, SFX stingers, camera treatment.
end)
