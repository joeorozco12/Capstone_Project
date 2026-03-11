local Players = game:GetService("Players")

local LightningSerpentAI = {}
LightningSerpentAI.__index = LightningSerpentAI

function LightningSerpentAI.new(serpentModel)
    local self = setmetatable({}, LightningSerpentAI)
    self.model = serpentModel
    self.time = 0
    self.targetPlayer = nil
    return self
end

function LightningSerpentAI:PickTarget()
    local list = Players:GetPlayers()
    if #list == 0 then
        self.targetPlayer = nil
        return
    end
    self.targetPlayer = list[math.random(1, #list)]
end

function LightningSerpentAI:Update(deltaTime)
    if not self.model or not self.model.Parent then
        return
    end

    self.time += deltaTime
    if self.time % 8 < deltaTime then
        self:PickTarget()
    end

    local root = self.model.PrimaryPart
    if not root then
        return
    end

    local basePos = root.Position
    local arcOffset = Vector3.new(math.sin(self.time * 1.2) * 25, math.cos(self.time) * 8, math.cos(self.time * 0.8) * 25)

    if self.targetPlayer and self.targetPlayer.Character and self.targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = self.targetPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 35, 0)
        local desired = targetPos + arcOffset
        self.model:PivotTo(CFrame.lookAt(desired, targetPos))
    else
        self.model:PivotTo(CFrame.new(basePos + arcOffset))
    end
end

return LightningSerpentAI
