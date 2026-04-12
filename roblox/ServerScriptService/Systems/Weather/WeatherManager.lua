local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local WeatherStateChanged = Remotes:WaitForChild("WeatherStateChanged")

local WeatherManager = {}
WeatherManager.__index = WeatherManager

function WeatherManager.new(config)
    local self = setmetatable({}, WeatherManager)
    self.config = config or {}
    self.currentWeather = "Clear"
    self.weatherStartedAt = 0
    self.weatherDuration = 0
    return self
end

function WeatherManager:SetWeather(weatherId, duration)
    assert(type(weatherId) == "string" and weatherId ~= "", "weatherId must be a non-empty string")

    local safeDuration = tonumber(duration) or 0
    if safeDuration < 0 then
        safeDuration = 0
    end

    self.currentWeather = weatherId
    self.weatherStartedAt = os.clock()
    self.weatherDuration = safeDuration

    WeatherStateChanged:FireAllClients({
        weatherId = self.currentWeather,
        startedAt = self.weatherStartedAt,
        duration = self.weatherDuration,
        serverTime = workspace:GetServerTimeNow(),
    })
end

function WeatherManager:GetCurrentWeather()
    return self.currentWeather
end

function WeatherManager:GetState()
    return {
        weatherId = self.currentWeather,
        startedAt = self.weatherStartedAt,
        duration = self.weatherDuration,
    }
end

function WeatherManager:IsWeatherExpired()
    return (os.clock() - self.weatherStartedAt) >= self.weatherDuration
end

return WeatherManager
