AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/paper01.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
	local ply = self:GetNWEntity("owning_ent")
end

function ENT:OnRemove()
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxletters", ply:GetNWInt("maxletters") - 1)
end
