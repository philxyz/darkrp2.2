AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/Rock001a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:Ignite(20, 0)
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then
		phys:Wake()
	end

	self:GetPhysicsObject():EnableMotion(true)
	self:GetPhysicsObject():SetMass(1000)
	self:GetPhysicsObject():EnableGravity(false)
end

function ENT:findSky(ply)
	local foundSky = util.IsInWorld(ply:GetPos())
	local zPos = ply:GetPos().z

	while fountSky == true do
		zPos = zPos + 100
		foundSky = util.IsInWorld(Vector(ply:GetPos().x, ply:GetPos().y, zPos))
		Msg("My Z: " .. ply.GeyPos().z .. " -- zPos: " .. zPos .. " -- Is in world: " .. foundSky .. "\n")
	end

	return zPos - 20
end


function ENT:SetTarget(ent)
	local foundSky = util.IsInWorld(ent:GetPos())
	local zPos = ent:GetPos().z

	for a = 1, 30, 1 do
		zPos = zPos + 100
		foundSky = util.IsInWorld(Vector(ent:GetPos().x, ent:GetPos().y, zPos))
		if not foundSky then
			zPos = zPos - 120
			break
		end
	end

	self:SetPos(Vector(ent:GetPos().x + math.random(-4000, 4000), ent:GetPos().y + math.random(-4000, 4000), zPos))
	local speed = 100000000
	local VNormal = (Vector(ent:GetPos().x + math.random(-500, 500), ent:GetPos().y + math.random(-500, 500), ent:GetPos().z) - self:GetPos()):GetNormal()
	meteor:GetPhysicsObject():ApplyForceCenter(VNormal * speed)
end

function ENT:Destruct()
	util.BlastDamage(self, self, self:GetPos(), 200, 60)

	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:Destruct2()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(10)
	util.Effect("Explosion", effectdata)
end

function ENT:OnTakeDamage(dmg)
	if dmg:GetDamage() > 5 then
		self:Destruct2()
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, physobj)
	self:Destruct()
	self:Remove()
end
