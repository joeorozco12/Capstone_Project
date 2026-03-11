local StormScheduler = {}
StormScheduler.__index = StormScheduler

function StormScheduler.new(weatherManager, weatherPool)
    local self = setmetatable({}, StormScheduler)
    self.weatherManager = weatherManager
    self.weatherPool = weatherPool
    self.rng = Random.new()
    return self
end

local function weightedPick(rng, entries)
    local total = 0
    for _, item in ipairs(entries) do
        total += item.weight
    end

    local roll = rng:NextNumber(0, total)
    local cursor = 0
    for _, item in ipairs(entries) do
        cursor += item.weight
        if roll <= cursor then
            return item
        end
    end
    return entries[#entries]
end

function StormScheduler:Step()
    if not self.weatherManager:IsWeatherExpired() then
        return
    end

    local nextWeather = weightedPick(self.rng, self.weatherPool)
    self.weatherManager:SetWeather(nextWeather.id, nextWeather.duration)
end

return StormScheduler
