--[[
    ChaosRBX
    HawDevelopment
    11/28/2021
--]]

local River = require(game.ReplicatedStorage.River)

local Component = River.Component
local Type = River.Type
local Tag = River.Tag
local Entity = River.Entity
local System = River.System
local Query = River.Query
local World = River.World

local Point = Component({
    Position = Type("Vector3"),
    Instance = Type("Instance"),
    Color = Type("number")
})
local PointTag = Tag("Point")

local PointInstance
do
    local part = Instance.new("Part")
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false
    part.CastShadow = false
    part.Size = Vector3.new(0.5, 0.5, 0.5)
    part.Parent = game.Workspace
    PointInstance = part
    
    local attachment1 = Instance.new("Attachment", part)
    local attachment2 = Instance.new("Attachment", part)
    attachment1.Position = Vector3.new(0, 0, 0.25)
    
    local trail = Instance.new("Trail")
    trail.Attachment0 = attachment1
    trail.Attachment1 = attachment2
    trail.FaceCamera = true
    trail.Lifetime = 1
    trail.MaxLength = 1
    trail.WidthScale = NumberSequence.new(1, 0)
    trail.Parent = part
end

for _ = 1, 2000 do
    local Position = Vector3.new(math.random(-400, 400) / 100, math.random(-400, 400) / 100, math.random(-400, 400) / 100) 
    local Inst = PointInstance:Clone()
    Inst.Position = Position
    Inst.Parent = game.Workspace
    Entity({
        Point = Point({
            Position = Position,
            Color = Position.Magnitude,
            Instance = Inst,
        }),
        PointTag
    })
end

local SIGMA = 10
local BETA = 8 / 3
local RHO = 28
local COLOR = 10

local function Equation(origin, dt)
    local dx = SIGMA * (origin.Y - origin.X)
    local dy = origin.X * (RHO - origin.Z) - origin.Y
    local dz = origin.X * origin.Y - BETA * origin.Z
    return Vector3.new(dx * dt, dy * dt, dz * dt)
end

local UpdatePositon = System(function(entities, dt)
    for _, value in pairs(entities) do
        local point = value.Point
        point.Instance.Position += Equation(point.Instance.Position, 0.2 * dt :: number)
        point.Instance.Trail.Color = ColorSequence.new(Color3.fromHSV((tick() + point.Color) % COLOR / COLOR, 0.5, 1))
    end
end)
UpdatePositon:add(Query(PointTag))

local world = World()

world:add(UpdatePositon, "update")

world:start()