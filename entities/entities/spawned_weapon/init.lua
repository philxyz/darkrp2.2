AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end
end

function ENT:UseModelForClass(class)
	self.class = class

	if class == "weapon_real_cs_glock18" then
		self:SetModel("models/weapons/w_pist_glock18.mdl")
	elseif class == "weapon_real_cs_p228" then
		self:SetModel("models/weapons/w_pist_p228.mdl")
	elseif class == "weapon_real_cs_five-seven" then
		self:SetModel("models/weapons/w_pist_fiveseven.mdl")
	elseif class == "weapon_real_cs_desert_eagle" then
		self:SetModel("models/weapons/w_pist_deagle.mdl")
	elseif class == "weapon_real_cs_ak47" then
		self:SetModel("models/weapons/w_rif_ak47.mdl")
	elseif class == "weapon_real_cs_m4a1" then
		self:SetModel("models/weapons/w_rif_m4a1.mdl")
	elseif class == "weapon_real_cs_mp5a4" then
		self:SetModel("models/weapons/w_smg_mp5.mdl")
	elseif class == "weapon_real_cs_mac10" then
		self:SetModel("models/weapons/w_smg_mac10.mdl")
	elseif class == "weapon_real_cs_g3sg1" then
		self:SetModel("models/weapons/w_snip_g3sg1.mdl")
	elseif class == "weapon_real_cs_pumpshotgun" then
		self:SetModel("models/weapons/w_shot_m3super90.mdl")
	end
end

function ENT:Use(activator, caller)
	if self.used then return end

	local weapon = ents.Create(self.class)

	if not IsValid(weapon) then return false end

	weapon:SetAngles(self:GetAngles())
	weapon:SetPos(self:GetPos())
	weapon:SetNetworkedString("Owner", "Shared")
	weapon:Spawn()
	self.used = true
	self:Remove()
end
