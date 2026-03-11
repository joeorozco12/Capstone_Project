local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local WeatherStateChanged = Remotes:WaitForChild("WeatherStateChanged")
local StormEventBroadcast = Remotes:WaitForChild("StormEventBroadcast")

WeatherStateChanged.OnClientEvent:Connect(function(payload)
    print("Weather changed:", payload.weatherId, "duration:", payload.duration)
end)

StormEventBroadcast.OnClientEvent:Connect(function(payload)
    print("Server Event:", payload.message)
end)
