local CreatureService = {}
CreatureService.__index = CreatureService

function CreatureService.new(lightningSerpentController)
    local self = setmetatable({}, CreatureService)
    self.lightningSerpentController = lightningSerpentController
    self.activeEncounters = {}
    return self
end

function CreatureService:BeginEncounter(player, creatureId)
    local encounterId = string.format("%d_%s_%d", player.UserId, creatureId, os.time())
    self.activeEncounters[encounterId] = {
        playerUserId = player.UserId,
        creatureId = creatureId,
        startedAt = os.clock(),
        stage = "Track",
    }
    return encounterId
end

function CreatureService:AdvanceEncounter(encounterId)
    local encounter = self.activeEncounters[encounterId]
    if not encounter then
        return nil
    end

    if encounter.stage == "Track" then
        encounter.stage = "Calm"
    elseif encounter.stage == "Calm" then
        encounter.stage = "Capture"
    else
        encounter.stage = "Complete"
    end

    return encounter.stage
end

return CreatureService
