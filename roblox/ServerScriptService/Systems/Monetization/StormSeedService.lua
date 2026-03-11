local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StormSeedPurchaseRequest = Remotes:WaitForChild("StormSeedPurchaseRequest")

local STORM_SEED_PRODUCT_ID = 1234567890

local StormSeedService = {}
StormSeedService.__index = StormSeedService

function StormSeedService.new(weatherManager)
    local self = setmetatable({}, StormSeedService)
    self.weatherManager = weatherManager
    self.pendingPurchases = {}
    return self
end

function StormSeedService:Init()
    StormSeedPurchaseRequest.OnServerEvent:Connect(function(player, stormId)
        self.pendingPurchases[player.UserId] = stormId
        MarketplaceService:PromptProductPurchase(player, STORM_SEED_PRODUCT_ID)
    end)

    MarketplaceService.ProcessReceipt = function(receiptInfo)
        local stormId = self.pendingPurchases[receiptInfo.PlayerId]
        if stormId then
            self.weatherManager:SetWeather(stormId, 180)
            self.pendingPurchases[receiptInfo.PlayerId] = nil
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end

return StormSeedService
