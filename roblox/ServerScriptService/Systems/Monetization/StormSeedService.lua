local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StormSeedPurchaseRequest = Remotes:WaitForChild("StormSeedPurchaseRequest")

local STORM_SEED_PRODUCT_ID = 1234567890
local REQUEST_COOLDOWN_SECONDS = 5
local PURCHASE_TIMEOUT_SECONDS = 300
local DEFAULT_FALLBACK_STORM = "Drizzle"

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

function StormSeedService:CleanupPlayer(userId)
    self.pendingPurchases[userId] = nil
    self.requestCooldowns[userId] = nil
end

function StormSeedService:GrantStormFromReceipt(playerId)
    local pending = self.pendingPurchases[playerId]
    if not pending then
        warn("StormSeedService: missing pending purchase, granting fallback storm")
        self.weatherManager:SetWeather(DEFAULT_FALLBACK_STORM, 120)
        return true
    end

    local age = os.clock() - pending.requestedAt
    if age > PURCHASE_TIMEOUT_SECONDS then
        warn("StormSeedService: pending purchase expired, granting fallback storm")
        self.weatherManager:SetWeather(DEFAULT_FALLBACK_STORM, 120)
        self.pendingPurchases[playerId] = nil
        return true
    end

    self.weatherManager:SetWeather(pending.stormId, 180)
    self.pendingPurchases[playerId] = nil
    return true
end

function StormSeedService:Init()
    Players.PlayerRemoving:Connect(function(player)
        self:CleanupPlayer(player.UserId)
    end)

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

        local granted = self:GrantStormFromReceipt(receiptInfo.PlayerId)
        if granted then
            return Enum.ProductPurchaseDecision.PurchaseGranted
        end

        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

return StormSeedService
