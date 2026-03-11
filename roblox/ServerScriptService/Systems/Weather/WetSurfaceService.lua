local CollectionService = game:GetService("CollectionService")

local WetSurfaceService = {}
WetSurfaceService.__index = WetSurfaceService

function WetSurfaceService.new(weatherManager)
    local self = setmetatable({}, WetSurfaceService)
    self.weatherManager = weatherManager
    return self
end

function WetSurfaceService:Apply()
    local weather = self.weatherManager:GetCurrentWeather()
    local isWet = weather == "Drizzle" or weather == "Thunderstorm" or weather == "Monsoon"

    for _, part in ipairs(CollectionService:GetTagged("WeatherReactive")) do
        if part:IsA("BasePart") then
            part.Material = isWet and Enum.Material.SmoothPlastic or Enum.Material.Grass
            part.Reflectance = isWet and 0.12 or 0
        end
    end
end

return WetSurfaceService
