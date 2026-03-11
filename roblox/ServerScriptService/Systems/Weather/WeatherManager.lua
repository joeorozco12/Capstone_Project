local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local WeatherStateChanged = Remotes:WaitForChild("WeatherStateChanged")

local WeatherManager = {}
WeatherManager.__index = WeatherManager

function WeatherManager.new(config)
    local self = setmetatable({}, WeatherManager)
    self.config = config
    self.currentWeather = nil
    self.weatherStartedAt = 0
    self.weatherDuration = 0
    return self
end

function WeatherManager:SetWeather(weatherId, duration)
    self.currentWeather = weatherId
    self.weatherStartedAt = os.clock()
    self.weatherDuration = duration

    WeatherStateChanged:FireAllClients({
        weatherId = weatherId,
        startedAt = self.weatherStartedAt,
        duration = duration,
    })
end

function WeatherManager:GetCurrentWeather()
    return self.currentWeather
end

function WeatherManager:IsWeatherExpired()
    if not self.currentWeather then
        return true
    end
    return (os.clock() - self.weatherStartedAt) >= self.weatherDuration
end

return WeatherManager
