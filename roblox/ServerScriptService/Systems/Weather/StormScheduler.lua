local StormScheduler = {}
StormScheduler.__index = StormScheduler

function StormScheduler.new(weatherManager, weatherPool, seed)
    local self = setmetatable({}, StormScheduler)
    self.weatherManager = weatherManager
    self.weatherPool = weatherPool or {}
    self.rng = seed and Random.new(seed) or Random.new()
    return self
end

local function weightedPick(rng, entries)
    local total = 0

    for _, item in ipairs(entries) do
        if type(item.weight) == "number" and item.weight > 0 then
            total += item.weight
        end
    end

    if total <= 0 then
        return nil
    end

    local roll = rng:NextNumber(0, total)
    local cursor = 0

    for _, item in ipairs(entries) do
        if type(item.weight) == "number" and item.weight > 0 then
            cursor += item.weight
            if roll <= cursor then
                return item
            end
        end
    end

    return entries[#entries]
end

function StormScheduler:Step()
    if not self.weatherManager:IsWeatherExpired() then
        return
    end

    local nextWeather = weightedPick(self.rng, self.weatherPool)
    if not nextWeather or type(nextWeather.id) ~= "string" then
        return
    end

    local duration = tonumber(nextWeather.duration) or 60
    if duration <= 0 then
        duration = 60
    end

    self.weatherManager:SetWeather(nextWeather.id, duration)
end

return StormScheduler
