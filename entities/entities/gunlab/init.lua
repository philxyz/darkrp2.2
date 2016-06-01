AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/TrapPropeller_Engine.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()

	if phys and phys:IsValid() then phys:Wake() end

	self:SetNWBool("sparking",false)
	self:SetNWInt("damage",100)
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxgunlabs", ply:GetNWInt("maxgunlabs") + 1)
end

function ENT:OnTakeDamage(dmg)
	self:SetNWInt("damage", self:GetNWInt("damage") - dmg:GetDamage())
	if self:GetNWInt("damage") <= 0 then
		self:Destruct()
		self:Remove()
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
end

function ENT:SalePrice(activator)
	local owner = self:GetNWEntity("owning_ent")
	local discounted = math.ceil(GetGlobalInt("p228cost") * 0.88)

	if activator == owner then
		if activator:Team() == TEAM_GUN then
			return discounted
		else
			return math.floor(GetGlobalInt("p228cost"))
		end
	else
		return self:GetNWInt("price")
	end
end

function ENT:Use(activator)
	self:SetNWEntity("user", activator)
	local owner = self:GetNWEntity("owning_ent")

	if not self.locked then
		self.locked = true

		if not activator:CanAfford(self:SalePrice(activator)) then
			Notify(activator, 1, 4, "Can not afford this!")
			local me = self
			timer.Create(self:EntIndex() .. "gunwait", 1, 1, function() me:GunWait() end)
			return
		end

		local diff = (self:SalePrice(activator) - self:SalePrice(owner))
		if diff < 0 and not owner:CanAfford(math.abs(diff)) then
			Notify(activator, 1, 4, "Gun Lab owner is too poor to subsidize this sale!")
			local me = self
			timer.Create(self:EntIndex() .. "gunwait", 1, 1, function() me:GunWait() end)
			return
		end

		local discounted = math.ceil(GetGlobalInt("p228cost") * 0.88)
	        local cash = self:SalePrice(activator)

		activator:AddMoney(-cash)
		Notify(activator, 1, 4, "You bought a P228 for " .. CUR .. tostring(cash) .. "!")

		if activator ~= owner then
			local gain = 0
			if owner:Team() == TEAM_GUN then
				gain = math.floor(self:GetNWInt("price") - discounted)
			else
				gain = math.floor(self:GetNWInt("price") - GetGlobalInt("p228cost"))
			end

			if gain == 0 then
				Notify(owner, 1, 4, "You sold a P228 but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				Notify(owner, 1, 4, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling a P228 from a Gun Lab!")
			end
		end

		self:SetNWBool("sparking", true)
		local me = self
		timer.Create(self:EntIndex() .. "spawned_weapon", 1, 1, function() me:CreateGun() end)
	end
end

-- Do nothing
function ENT:GunWait()
	self.locked = false
end

function ENT:CreateGun()
	local activator = self:GetNWEntity("user")
	local owner = self:GetNWEntity("owning_ent")

	local gun = ents.Create("spawned_weapon")
	gun:UseModelForClass("weapon_real_cs_p228")
	local gunPos = self:GetPos()
	gun:SetPos(Vector(gunPos.x, gunPos.y, gunPos.z + 27))
	gun:SetNetworkedString("Owner", "Shared")
	gun:Spawn()
	self:SetNWBool("sparking", false)
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

function ENT:OnRemove()
	timer.Destroy(self)
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxgunlabs", ply:GetNWInt("maxgunlabs") - 1)
end
