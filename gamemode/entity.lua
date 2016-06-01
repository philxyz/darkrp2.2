local meta = FindMetaTable("Entity")

function meta:IsOwnable()
	local class = self:GetClass()

	if (class == "func_door" or class == "func_door_rotating" or class == "prop_door_rotating") or
		class == "prop_vehicle_jeep" or class == "prop_vehicle_airboat" then
			return true
		end
	return false
end

function meta:IsDoor()
	local class = self:GetClass()

	if class == "func_door" or
		class == "func_door_rotating" or
		class == "prop_door_rotating" then

		return true
		end
	return false
end

function meta:IsOwned()
	local num = 0
	for n = 1, self:GetNWInt("OwnerCount") do
		if self:GetNWInt("Ownersz" .. n) > -1 then
			num = num + 1
		end
	end

	if self:GetNWInt("Ownerz") ~= 0 or num > 0 then return true end

	return false
end

function meta:GetDoorOwner()
	return player.GetByID(self:GetNWInt("Ownerz")) or NULL
end

function meta:IsMasterOwner(ply)
	if ply:EntIndex() == self:GetNWInt("Ownerz") then
		return true
	end

	return false
end

function meta:OwnedBy(ply)
	if self:GetNWInt("Ownerz") == ply:EntIndex() then return true end

	local num = self:GetNWInt("OwnerCount")

	for n = 1, num do
		if ply:EntIndex() == self:GetNWInt("Ownersz" .. n) then
			return true
		end
	end

	return false
end

function meta:UnOwn(ply)
	if CLIENT then return end

	if not ply then
		ply = self:GetDoorOwner()

		if not IsValid(ply) then return end
	end

	if self:IsMasterOwner(ply) then
		self:SetNWInt("Ownerz", 0)
	else
		self:RemoveOwner(ply)
	end

	local num = 0

	for n = 1, self:GetNWInt("OwnerCount") do
		if self:GetNWInt("Ownersz" .. n) > -1 then
			num = num + 1
		end
	end

	if self:GetNWInt("Ownerz") == 0 and num == 0 then
		num = self:GetNWInt("AllowedNum")
		for n = 1, num do
			self:SetNWInt("Allowed" .. n, -1)
		end
	end
end

function meta:AllowedToOwn(ply)
	local num = self:GetNWInt("AllowedNum")

	for n = 1, num do
		if self:GetNWInt("Allowed" .. n) == ply:EntIndex() then
			return true
		end
	end

	return false
end

function meta:AddAllowed(ply)
	local num = self:GetNWInt("AllowedNum")
	num = num + 1

	self:SetNWInt("AllowedNum", num)
	self:SetNWInt("Allowed" .. num, ply:EntIndex())
end

function meta:RemoveAllowed(ply)
	local num = self:GetNWInt("AllowedNum")

	for n = 1, num do
		if self:GetNWInt("Allowed" .. n) == ply:EntIndex() then
			self:SetNWInt("Allowed" .. n, -1)
			break
		end
	end
end

function meta:AddOwner(ply)
	local num = self:GetNWInt("OwnerCount")
	num = num + 1

	self:SetNWInt("OwnerCount", num)
	self:SetNWInt("Ownersz" .. num, ply:EntIndex())
	self:RemoveAllowed(ply)
end

function meta:RemoveOwner(ply)

	local num = self:GetNWInt("OwnerCount")

	for n = 1, num do
		if ply:EntIndex() == self:GetNWInt("Ownersz" .. n) then
			self:SetNWInt("Ownersz" .. n, -1)
			break
		end
	end
end

function meta:Own(ply)
	if CLIENT then return end

	if self:AllowedToOwn(ply) then
		self:AddOwner(ply)
		return
	end

	if not self:IsOwned() and not self:OwnedBy(ply) then
		self:SetNWInt("Ownerz", ply:EntIndex())
		self:SetNWInt("OwnerCount", 0)
		self:SetNWString("title", "")
	end
end
