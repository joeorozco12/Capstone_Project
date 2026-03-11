local CollectionService = game:GetService("CollectionService")

local WetSurfaceService = {}
WetSurfaceService.__index = WetSurfaceService

function WetSurfaceService.new(weatherManager)
    local self = setmetatable({}, WetSurfaceService)
    self.weatherManager = weatherManager
    self.originalSurfaceState = {}
    return self
end

local function cacheOriginalState(cache, part)
    if cache[part] then
        return
    end

    cache[part] = {
        material = part.Material,
        reflectance = part.Reflectance,
    }

    part.Destroying:Connect(function()
        cache[part] = nil
    end)
end

function WetSurfaceService:Apply()
    local weather = self.weatherManager:GetCurrentWeather()
    local isWet = weather == "Drizzle" or weather == "Thunderstorm" or weather == "Monsoon"

    for _, part in ipairs(CollectionService:GetTagged("WeatherReactive")) do
        if part:IsA("BasePart") then
            cacheOriginalState(self.originalSurfaceState, part)

            if isWet then
                part.Reflectance = math.max(part.Reflectance, 0.12)
            else
                local original = self.originalSurfaceState[part]
                if original then
                    part.Material = original.material
                    part.Reflectance = original.reflectance
                end
            end
        end
    end
end

return WetSurfaceService
