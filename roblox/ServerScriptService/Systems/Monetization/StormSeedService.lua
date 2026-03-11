local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StormSeedPurchaseRequest = Remotes:WaitForChild("StormSeedPurchaseRequest")

local STORM_SEED_PRODUCT_ID = 1234567890
local REQUEST_COOLDOWN_SECONDS = 5

local ALLOWED_STORMS = {
    Drizzle = true,
    Thunderstorm = true,
    Monsoon = true,
    IonSurge = true,
}

local StormSeedService = {}
StormSeedService.__index = StormSeedService

function StormSeedService.new(weatherManager)
    local self = setmetatable({}, StormSeedService)
    self.weatherManager = weatherManager
    self.pendingPurchases = {}
    self.requestCooldowns = {}
    return self
end

function StormSeedService:CanRequest(player)
    local now = os.clock()
    local nextTime = self.requestCooldowns[player.UserId] or 0

    if now < nextTime then
        return false
    end

    self.requestCooldowns[player.UserId] = now + REQUEST_COOLDOWN_SECONDS
    return true
end

function StormSeedService:Init()
    StormSeedPurchaseRequest.OnServerEvent:Connect(function(player, stormId)
        if typeof(stormId) ~= "string" then
            return
        end

        if not ALLOWED_STORMS[stormId] then
            return
        end

        if not self:CanRequest(player) then
            return
        end

        self.pendingPurchases[player.UserId] = {
            stormId = stormId,
            requestedAt = os.clock(),
        }

        MarketplaceService:PromptProductPurchase(player, STORM_SEED_PRODUCT_ID)
    end)

    MarketplaceService.ProcessReceipt = function(receiptInfo)
        if receiptInfo.ProductId ~= STORM_SEED_PRODUCT_ID then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        local pending = self.pendingPurchases[receiptInfo.PlayerId]
        if not pending then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end

        self.weatherManager:SetWeather(pending.stormId, 180)
        self.pendingPurchases[receiptInfo.PlayerId] = nil

        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end

return StormSeedService
