-- ========================
-- =          Crate SENT by Mahalis
-- ========================

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local weaponClasses = {}
weaponClasses["ak47"] = "weapon_real_cs_ak47"
weaponClasses["mp5"] = "weapon_real_cs_mp5a4"
weaponClasses["m4"] = "weapon_real_cs_m4a1"
weaponClasses["mac10"] = "weapon_real_cs_mac10"
weaponClasses["shotgun"] = "weapon_real_cs_pumpshotgun"
weaponClasses["sniper"] = "weapon_real_cs_g3sg1"

function ENT:Initialize()
	self:SetModel("models/Items/item_item_crate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetNWBool("shipment", true)
	self.locked = false
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self:SetNWInt("damage", 100)
	self:SetNWString("Owner", "Shared")
end

function ENT:OnTakeDamage(dmg)
	self:SetNWInt("damage", self:GetNWInt("damage") - dmg:GetDamage())
	if not self.destroyed and self:GetNWInt("damage") <= 0 then
		self:Destruct()
	end
end

function ENT:SetContents(s, c, w)
	self:SetNWString("contents", s)
	self:SetNWInt("count", c)
	if w and w > 0 then
		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then phys:SetMass(math.floor((((w * c) + 15)*100)+0.5)/100) end
	end
	self:SetNWFloat("itemWt", w)
end

function ENT:Use()
	if not self.locked then
		self.locked = true -- One activation per second
		self:SetNWBool("sparking", true)
		local me = self
		timer.Create(self:EntIndex() .. "crate", 1, 1, function() me:SpawnItem() end)
	end
end

function ENT:SpawnItem()
	if not IsValid(self) then
		return false
	end

	timer.Destroy(self:EntIndex() .. "crate")
	self:SetNWBool("sparking", false)
	local count = self:GetNWInt("count")
	local pos = self:GetPos()
	if count <= 1 then self:Remove() end
	local contents = self:GetNWString("contents")
	local weapon = ents.Create("spawned_weapon")
	weapon:UseModelForClass(weaponClasses[contents])
	weapon:SetNWString("Owner", "Shared")
	weapon:SetPos(pos + Vector(0, 0, 35))
	weapon:Spawn()
	count = count - 1
	self:SetNWInt("count", count)
	local newmass = math.floor((((count*self:GetNWFloat("itemWt")) + 15) * 100) + 0.5) / 100
	if newmass and newmass > 0 then
		local phys = self:GetPhysicsObject()
		if phys and phys:IsValid() then phys:SetMass(newmass) end
	end
	self.locked = false
end

function ENT:Think()
	if self:GetNWBool("sparking") then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:Destruct()
	self.destroyed = true

	local vPoint = self:GetPos()
	local contents = self:GetNWString("contents")
	local count = self:GetNWInt("count")
	self:Remove()
	
	for i=1, count, 1 do
		local weapon = ents.Create("spawned_weapon")
		weapon:UseModelForClass(weaponClasses[contents])
		weapon:SetNWString("Owner", "Shared")
		weapon:SetPos(Vector(vPoint.x, vPoint.y, vPoint.z + (i*5)))
		weapon:Spawn()
	end
end
