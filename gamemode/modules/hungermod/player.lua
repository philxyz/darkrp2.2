local meta = FindMetaTable("Player")

function meta:NewHungerData()
	self:SetNWInt("Energy", 100)
	self:GetTable().LastHungerUpdate = 0
end

function meta:HungerUpdate()
	self:SetNWInt("Energy", math.Clamp(self:GetNWInt("Energy") - CfgVars["hungerspeed"] / 10, 0, 100))
	self:GetTable().LastHungerUpdate = CurTime()

	if self:GetNWInt("Energy") == 0 then
		self:SetHealth(self:Health() - CfgVars["starverate"])
		if self:Health() <= 0 then
			self:GetTable().Slayed = true
			self:Kill()
		end
	end
end
