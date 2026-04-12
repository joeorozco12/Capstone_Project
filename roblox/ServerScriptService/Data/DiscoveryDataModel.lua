local DiscoveryDataModel = {}

function DiscoveryDataModel.NewProfile()
    return {
        version = 1,
        currencies = {
            credits = 0,
            researchData = 0,
            stormShards = 0,
            prestigeSigils = 0,
        },
        discoveries = {
            biomesVisited = {},
            weatherSeen = {},
            creaturesLogged = {},
            legendaryEventsCompleted = {},
        },
        progression = {
            forecastTier = 1,
            engineeringTier = 1,
            journalRank = 1,
        },
        cosmetics = {
            ownedWeatherSkins = {},
            ownedEmotes = {},
            uiThemes = {},
        },
        base = {
            blueprintSlots = 2,
            savedBlueprints = {},
        }
    }
end

return DiscoveryDataModel
