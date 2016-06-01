-- RRPX Money Printer reworked for DarkRP by philxyz
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/consolebox01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:Wake() end
	self:SetNWBool("money_printer", true)
	self:SetNWBool("sparking", false)
	self:SetNWInt("damage", 100)
	self.explosionradius = math.random(20, 200)
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxmprinters", ply:GetNWInt("maxmprinters") + 1)
	local me = self
	timer.Simple(30, function() me:CreateMoneybag() end)
end

function ENT:OnTakeDamage(dmg)
	if self.burningup then return end

	self:SetNWInt("damage", self:GetNWInt("damage") - dmg:GetDamage())
	if self:GetNWInt("damage") <= 0 then
		local rnd = math.random(1, 10)
		if rnd < 3 then
			self:BurstIntoFlames()
		else
			self:Destruct()
			self:Remove()
		end
	end
end

function ENT:Destruct()
	local vPoint = self:GetPos()
	local effectdata = EffectData()
	effectdata:SetStart(vPoint)
	effectdata:SetOrigin(vPoint)
	effectdata:SetScale(1)
	util.Effect("Explosion", effectdata)
	Notify(self:GetNWEntity("owning_ent"), 1, 4, "Your money printer has exploded!")
end

function ENT:BurstIntoFlames()
	self:SetNWBool("sparking", false)
	Notify(self:GetNWEntity("owning_ent"), 1, 4, "Your money printer is overheating!")
	self.burningup = true
	local burntime = math.random(8, 18)
	self:Ignite(burntime, 0)
	local me = self
	timer.Simple(burntime, function() me:Fireball() end)
end

function ENT:Fireball()
	self:Destruct()
	for k, v in pairs(ents.FindInSphere(self:GetPos(), self.explosionradius)) do
		if IsFlammable(v) and v:EntIndex() ~= self:EntIndex() then
			v:Ignite(math.random(5, 22), 0)
		end
	end
	self:Remove()
end

local function PrintMore(ent)
	if IsValid(ent) then
		ent:SetNWBool("sparking", true)
		timer.Simple(3, function() ent:CreateMoneybag() end)
	end
end

function ENT:CreateMoneybag()
	if not IsValid(self) then return end
	local MoneyPos = self:GetPos()

	if math.random(1, 22) == 3 then
		self:BurstIntoFlames()
		return
	end

	local moneybag = ents.Create("cash_bundle")
	moneybag:SetPos(Vector(MoneyPos.x + 15, MoneyPos.y, MoneyPos.z + 15))
	moneybag:Spawn()
	moneybag:GetTable().Amount = GetGlobalInt("mprintamount")

	self:SetNWBool("sparking", false)
	local me = self
	timer.Simple(math.random(40, 350), function() PrintMore(me) end) -- Print more cash in 40 to 350 seconds
end

function ENT:Think()
	if not self:GetNWBool("sparking") then return end

	local effectdata = EffectData()
	effectdata:SetOrigin(self:GetPos())
	effectdata:SetMagnitude(1)
	effectdata:SetScale(1)
	effectdata:SetRadius(2)
	util.Effect("Sparks", effectdata)
end

function ENT:OnRemove()
	local ply = self:GetNWEntity("owning_ent")
	ply:SetNWInt("maxmprinters", ply:GetNWInt("maxmprinters") - 1)
end
