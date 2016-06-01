AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props/cs_office/microwave.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys and phys:IsValid() then phys:Wake() end
	self:SetNWBool("sparking", false)
	self:SetNWInt("damage", 100)
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxMicrowaves", ply:GetNWInt("maxMicrowaves") + 1)
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
	local discounted = math.ceil(GetGlobalInt("microwavefoodcost") * 0.82)

	if activator == owner then
		-- If they are still a cook, sell them the food at the discounted rate
		if activator:Team() == TEAM_COOK then
			return discounted
		else -- Otherwise, sell it to them at full price
			return math.floor(GetGlobalInt("microwavefoodcost"))
		end
	else
		return self:GetNWInt("price")
	end
end

function ENT:Use(activator, caller)
	self:SetNWEntity("user", activator)
	local owner = self:GetNWEntity("owning_ent")

	if not self.locked then
		self.locked = true

		if not activator:CanAfford(self:SalePrice(activator)) then
			Notify(activator, 1, 4, "Can not afford this!")
			local me = self
			timer.Create(self:EntIndex() .. "foodwait", 1, 1, function() me:MaxFoods() end)
			return
		end

		local diff = self:SalePrice(activator) - self:SalePrice(owner)
		if diff < 0 and not owner:CanAfford(math.abs(diff)) then
			Notify(activator, 1, 4, "Microwave owner is too poor to subsidize this sale!")
			local me = self
			timer.Create(self:EntIndex() .. "foodwait", 1, 1, function() me:MaxFoods() end)
			return
		end

		if activator:GetNWInt("maxFoods") >= CfgVars["maxfoods"] then
			Notify(activator, 1, 4, "Max Food Reached!")
			local me = self
			timer.Create(self:EntIndex() .. "foodwait", 1, 1, function() me:MaxFoods() end)
			return
		end

		local discounted = math.ceil(GetGlobalInt("microwavefoodcost") * 0.82)
		local cash = self:SalePrice(activator)

		activator:AddMoney(-cash)
		Notify(activator, 1, 4, "You bought food for " .. CUR .. tostring(cash) .. "!")

		if activator ~= owner then
			local gain = 0

			if owner:Team() == TEAM_COOK then
				gain = math.floor(self:GetNWInt("price") - discounted)
			else
				gain = math.floor(self:GetNWInt("price") - GetGlobalInt("microwavefoodcost"))
			end

			if gain == 0 then
				Notify(owner, 1, 4, "You sold some food but made no profit!")
			else
				owner:AddMoney(gain)
				local word = "profit"
				if gain < 0 then word = "loss" end
				Notify(owner, 1, 4, "You made a " .. word .. " of " .. CUR .. tostring(math.abs(gain)) .. " by selling food!")
			end
		end

		self:SetNWBool("sparking", true)
		local me = self
		timer.Create(self:EntIndex() .. "food", 1, 1, function() me:CreateFood() end)
	end
end

-- Do nothing
function ENT:MaxFoods()
	self.locked = false
end

function ENT:CreateFood()
	local activator = self:GetNWEntity("user")
	local owner = self:GetNWEntity("owning_ent")

	local foodPos = self:GetPos()
	food = ents.Create("food")
	food:SetPos(Vector(foodPos.x, foodPos.y, foodPos.z + 23))
	food:SetNWEntity("owning_ent", activator)
	food:SetNetworkedString("Owner", "Shared")
	food:Spawn()
	activator:SetNWInt("maxFoods", activator:GetNWInt("maxFoods") + 1)
	self:SetNWBool("sparking", false)
	self.locked = false
end

function ENT:Think()
	if self:GetNWBool("sparking") == true then
		local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(2)
		util.Effect("Sparks", effectdata)
	end
end

function ENT:OnRemove()
	timer.Destroy(self:EntIndex())
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxMicrowaves", ply:GetNWInt("maxMicrowaves") - 1)
end
