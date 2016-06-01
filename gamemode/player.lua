CivModels = {
	"models/player/group01/male_02.mdl"
}

local meta = FindMetaTable("Player")

-- Each time a player connects, they get a new ID
sessionid = 0

function meta:InitSID()
	sessionid = sessionid + 1
	self.SID = sessionid
end

function meta:NewData()
	local function ModuleDelay(ply)
		umsg.Start("LoadModules", ply)
			umsg.Short(#CSFiles)
			for n = 1, #CSFiles do
				umsg.String(CSFiles[n])
			end
		umsg.End()
	end

	local me = self
	timer.Simple(.01, function() ModuleDelay(me) end)

	DB.StoreSalary(self, CfgVars["normalsalary"])

	self:UpdateJob("Citizen")

	self:GetTable().Ownedz = { }
	self:GetTable().OwnedNumz = 0

	self:GetTable().LastLetterMade = CurTime()
	self:GetTable().LastCopVote = CurTime()
	self:GetTable().LastMayorVote = CurTime()
	self:GetTable().LastDemoteVote = CurTime()

	self:SetTeam(TEAM_CITIZEN)

	-- Whether or not a player is being prevented from joining
	-- a specific team for a certain length of time
	self.bannedfrom = {}
	for i = 1, 9 do
		self.bannedfrom[i] = 0
	end
end

function meta:ChangeAllowed(t)
	if self.bannedfrom[t] == 1 then return false else return true end
end

function meta:ChangeTeam(t)
	if self:GetTable().Arrested then
		if not self:Alive() then
			Notify(self, 1, 4, "Can not change your job while dead in jail.")
			return
		else
			Notify(self, 1, 4, "You are in Jail. Get a new job when you have been released.")
			return
		end
	end

	self:SetNWBool("helpBoss",false)
	self:SetNWBool("helpCop",false)
	self:SetNWBool("helpMayor",false)

	if t ~= TEAM_CITIZEN and not self:ChangeAllowed(t) then
		Notify(self, 1, 4, "You were demoted! Please wait a while before taking your old job back.")
		return
	end

	if t == TEAM_CITIZEN then
		self:UpdateJob("Citizen")
		DB.StoreSalary(self, CfgVars["normalsalary"])
		NotifyAll(1, 4, self:Name() .. " is now an ordinary Citizen!")
	elseif t == TEAM_POLICE then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a CP!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxcps"] then
			Notify(self, 1, 4,  "Max CPs reached!")
			return
		end

		self:UpdateJob("Civil Protection")
		DB.StoreSalary(self, CfgVars["normalsalary"] + 20)
		self:SetNWBool("helpCop", true)
		NotifyAll(1, 4, self:Name() .. " has been made a CP!")
	elseif t == TEAM_MAYOR then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already the Mayor!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4,  "Max Mayors reached!")
			return
		end

		if CfgVars["cptomayoronly"] == 1 and (self:Team() ~= TEAM_POLICE and self:Team() ~= TEAM_CHIEF) then
			Notify(self, 1, 4,  "You have to be in the Civil Protection first to become Mayor!")
			return
		end

		self:UpdateJob("Mayor")
		DB.StoreSalary(self, CfgVars["normalsalary"] + 40)
		self:SetNWBool("helpMayor", true)
		NotifyAll(1, 4, self:Name() .. " has been made Mayor!")
	elseif t == TEAM_GANG then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Gangster!")
			return
		end
				
		if CfgVars["allowgang"] == 0 then
			Notify(self, 1, 4, "Gangs are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxgangsters"] then
			Notify(self, 1, 4, "Max Gangsters reached!")
			return
		end

		self:UpdateJob("Gangster")
		DB.StoreSalary(self, CfgVars["normalsalary"] + 10)
		self:SetNWString("agenda", CfgVars["mobagenda"])
		NotifyAll(1, 4, self:Name() .. " has been made a Gangster!")
	elseif t == TEAM_MOB then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already the Mob Boss!")
			return
		end
				
		if CfgVars["allowgang"] == 0 then
			Notify(self, 1, 4, "Gangs are disabled!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4, "Only one Mob Boss is allowed.")
			return
		end

		self:UpdateJob("Mob Boss")
		DB.StoreSalary(self, CfgVars["normalsalary"] + 15)
		self:SetNWBool("helpBoss", true)
		self:SetNWString("agenda", CfgVars["mobagenda"])
		NotifyAll(1, 4, self:Name() .. " has been made Mob Boss!")
	elseif t == TEAM_GUN then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Gun Dealer!")
			return
		end

		if CfgVars["noguns"] == 1 then
			Notify(self, 1, 4, "Guns are disabled!")
			return
		end

		if CfgVars["allowdealers"] == 0 then
			Notify(self, 1, 4, "Gun Dealers are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxgundealers"] then
			Notify(self, 1, 4,  "Max Gun Dealers reached!")
			return
		end

		self:UpdateJob("Gun Dealer")
		DB.StoreSalary(self, CfgVars["normalsalary"])
		NotifyAll(1, 4, self:Name() .. " has been made a Gun Dealer!")
	elseif t == TEAM_MEDIC then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Medic!")
			return
		end

		if CfgVars["allowmedics"] == 0 then
			Notify(self, 1, 4, "Medics are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxmedics"] then
			Notify(self, 1, 4,  "Max Medics reached!")
			return
		end
		self:UpdateJob("Medic")
		DB.StoreSalary(self, CfgVars["normalsalary"] + 15)
		NotifyAll(1, 4, self:Name() .. " has been made a Medic!")
	elseif t == TEAM_COOK then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already a Cook!")
			return
		end

		if CfgVars["allowcooks"] == 0 then
			Notify(self, 1, 4, "Cooks are disabled!")
			return
		end

		if team.NumPlayers(t) >= CfgVars["maxcooks"] then
			Notify(self, 1, 4,  "Max Cooks reached!")
			return
		end

		self:UpdateJob("Cook")
		DB.StoreSalary(self, CfgVars["normalsalary"])
		NotifyAll(1, 4, self:Name() .. " has been made a Cook!")
	elseif t == TEAM_CHIEF then
		if self:Team() == t then
			Notify(self, 1, 4, "You're already the Civil Protection Chief!")
			return
		end

		if self:Team() ~= TEAM_POLICE then
			Notify(self, 1, 4, "You must be a CP first in order to become Chief!")
			return
		end

		if team.NumPlayers(t) >= 1 then
			Notify(self, 1, 4,  "Max Civil Protection Chiefs reached")
			return
		end

		self:UpdateJob("Civil Protection Chief")
		DB.StoreSalary(self, CfgVars["normalsalary"] + 30)
		NotifyAll(1, 4, self:Name() .. " has been made Chief!")
	end

	self:SetTeam(t)
	if self:InVehicle() then self:ExitVehicle() end
	self:KillSilent()
end

function meta:ResetDMCounter()
	self.kills = 0
	return true
end

function meta:CanAfford(amount)
	if math.floor(amount) < 0 or DB.RetrieveMoney(self) - math.floor(amount) < 0 then return false end

	return true
end

function meta:AddMoney(amount)
	DB.StoreMoney(self, DB.RetrieveMoney(self) + math.floor(amount))
end

function meta:PayDay()
	if self:GetTable().Pay == 1 then
		if not self:GetTable().Arrested then
			local amount = math.floor(DB.RetrieveSalary(self))
			if amount == 0 then
				Notify(self, 4, 4, "You are unemployed!")
			else
				self:AddMoney(amount)
				Notify(self, 4, 4, "Payday! You received " .. CUR .. amount .. "!")
			end
		else
			Notify(self, 4, 4, "Pay day missed! (arrested)")
		end
	end
end

function meta:UpdateJob(job)
	self:SetNWString("job", job)
	self:GetTable().Pay = 1
	self:GetTable().LastPayDay = CurTime()

	local l = string.lower(job)

	if l == "unemployed" or l == "bum" or l == "hobo" then
		DB.StoreSalary(self, 0)
	else
		local me = self
		timer.Create(self:SteamID() .. "jobtimer", CfgVars["paydelay"], 0, function() me:PayDay() end)
	end
end

function meta:TeamUnBan(team)
	self.bannedfrom[team] = 0
end

function meta:TeamBan()
	self.bannedfrom[self:Team()] = 1
	local me = self
	timer.Simple(CfgVars["demotetime"], function() me:TeamUnBan(me:Team()) end)
end

function meta:Arrest(time)
	if self:GetNWBool("wanted") then
		self:SetNetworkedBool("wanted", false)
	end
	-- Always get sent to jail when Arrest() is called, even when already under arrest
	if CfgVars["teletojail"] == 1 then
		self:SetPos(DB.RetrieveJailPos())
	end
	if not self:GetTable().Arrested then
		self:StripWeapons()
		self:GetTable().Arrested = true
		self.LastJailed = CurTime()

		-- If the player has no remaining jail time,
		-- set it back to the max for this new sentence
		if not time or time == 0 then
			time = GetGlobalInt("jailtimer")
		end
		DB.StoreJailStatus(self, time)
		self:PrintMessage(HUD_PRINTCENTER, "You have been arrested for " .. time .. " seconds!")
		for k, v in pairs(player.GetAll()) do
			if v ~= self then
				v:PrintMessage(HUD_PRINTCENTER, self:Name() .. " has been arrested for " .. time .. " seconds!")
			end
		end
		local me = self
		timer.Create(self:SteamID() .. "jailtimer", time, 1, function() me:Unarrest() end)
	end
end

function meta:Unarrest()
	if self and self:GetTable().Arrested then
		self:GetTable().Arrested = false
		if CfgVars["telefromjail"] == 1 then
			self:SetPos(GAMEMODE:PlayerSelectSpawn(self):GetPos())
		end
		GAMEMODE:PlayerLoadout(self)
		DB.StoreJailStatus(self, 0)
		timer.Stop(self:SteamID() .. "jailtimer")
		timer.Destroy(self:SteamID() .. "jailtimer")
		NotifyAll(1, 4, self:Name() .. " has been released from jail!")
	end
end

function meta:CompleteSentence()
	if IsValid(self) and self.SteamID ~= nil and self:SteamID() ~= nil then
		local time = DB.RetrieveJailStatus(self)

		if time == 0 or not DB.RetrieveJailPos() then
			-- No outstanding jail time to be done
			return ""
		else
			-- Don't pick up the soap this time
			self:Arrest(time)
			Notify(self, 0, 5, "Punishment for disconnecting! Jailed for: " .. time .. " seconds.")
		end
	end
end

function meta:UnownAll()
	for k, v in pairs(ents.GetAll()) do
		if v:IsOwnable() and v:OwnedBy(self) == true then
			v:Fire("unlock", "", 0.6)
		end
	end

	for k, v in pairs(self:GetTable().Ownedz) do
		v:UnOwn(self)
		self:GetTable().Ownedz[v:EntIndex()] = nil
	end

	for k, v in pairs(player.GetAll()) do
		for n, m in pairs(v:GetTable().Ownedz) do
			if m:AllowedToOwn(self) then
				m:RemoveAllowed(self)
			end
		end
	end

	self:GetTable().OwnedNumz = 0
end

function meta:DoPropertyTax()
	if CfgVars["propertytax"] == 0 then return end
	if self:Team() == TEAM_POLICE or self:Team() == TEAM_MAYOR or self:Team() == TEAM_CHIEF and CfgVars["cit_propertytax"] == 1 then return end

	local numowned = self:GetTable().OwnedNumz

	if numowned <= 0 then return end

	local price = 10
	local tax = price * numowned + math.random(-5, 5)

	if self:CanAfford(tax) then
		if tax == 0 then
			Notify(self, 1, 5, "No Property Tax - You don't own anything.")
		else
			self:AddMoney(-tax)
			Notify(self, 1, 5, "Property tax! " .. CUR .. tax)
		end
	else
		Notify(self, 1, 8, "Can't pay the taxes! Your property has been taken away from you!")
		self:UnownAll()
	end
end

function GM:CanTool(ply, trace, mode)
	if not self.BaseClass:CanTool(ply, trace, mode) then return false end

	if IsValid(trace.Entity) then
		if trace.Entity.onlyremover then
			if mode == "remover" then
				return (ply:IsAdmin() or ply:IsSuperAdmin())
			else
				return false
			end
		end

		if trace.Entity:IsVehicle() and mode == "nocollide" and CfgVars["allowvnocollide"] == 0 then
			return false
		end
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply:GetNWInt("slp") == 1 then
		Notify(ply, 4, 4, "Can not suicide while sleeping!")
		return false
	end
	if ply:GetTable().Arrested then
		Notify(ply, 4, 4, "You are on suicide watch!")
		return false
	end
	return true
end

function GM:PlayerDeath(ply, weapon, killer)
	if ply:HasWeapon("weapon_physcannon") then
		ply:DropWeapon(ply:GetWeapon("weapon_physcannon"))
	end

	if weapon:IsVehicle() and weapon:GetDriver():IsPlayer() then killer = weapon:GetDriver() end
	if GetGlobalInt("deathnotice") == 1 then
		self.BaseClass:PlayerDeath(ply, weapon, killer)
	end

	--if ply:IsOnFire() then ply:Extinguish() end

	if ply:InVehicle() then ply:ExitVehicle() end

	if ply:GetTable().Arrested == true then
		-- If the player died in jail, make sure they can't respawn until their jail sentance is over
		ply.NextSpawnTime = CurTime() + math.ceil(GetGlobalInt("jailtimer") - (CurTime() - ply.LastJailed)) + 1
		for a, b in pairs(player.GetAll()) do
			b:PrintMessage(HUD_PRINTCENTER, ply:Nick() .. " has died in jail!")
		end
		Notify(ply, 4, 4, "You now are dead until your jail time is up!")
	else
		-- Normal death, respawn allowed in 4 seconds
		ply.NextSpawnTime = CurTime() + 4
	end
	ply:GetTable().DeathPos = ply:GetPos()

	if CfgVars["dmautokick"] == 1 and killer:IsPlayer() and killer ~= ply then
		if not killer.kills or killer.kills == 0 then
			killer.kills = 1
			timer.Simple(CfgVars["dmgracetime"], function() killer:ResetDMCounter() end)
		else
			-- if this player is going over their limit, kick their ass
			if killer.kills + 1 > CfgVars["dmmaxkills"] then
				game.ConsoleCommand("kickid " .. killer:UserID() .. " Auto-kicked. Go and play HL2:DM\n")
			else
				-- killed another player
				killer.kills = killer.kills + 1
			end
		end
	end

	if ply ~= killer or ply:GetTable().Slayed then
		ply:SetNetworkedBool("wanted", false)
		ply:GetTable().Arrested = false
		ply:GetTable().DeathPos = nil
		ply:GetTable().Slayed = false
	end
end

function GM:PlayerCanPickupWeapon(ply, class)
	if ply:GetTable().Arrested then return false end

	return true
end

function GM:GravGunPunt(ply, ent)
	if ent:IsVehicle() then return false end

	local entphys = ent:GetPhysicsObject()

	if ply:KeyDown(IN_ATTACK) then
		-- it was launched
		entphys:EnableMotion(false)
		local curpos = ent:GetPos()
		timer.Simple(.01, function() entphys:EnableMotion(true) end)
		timer.Simple(.01, function() entphys:Wake() end)
		timer.Simple(.01, function() ent:SetPos(curpos) end)
	else
		return true
	end
end

function GM:GravGunOnDropped(ply, ent)
	local entphys = ent:GetPhysicsObject()
	if ply:KeyDown(IN_ATTACK) then
		-- it was launched
		entphys:EnableMotion(false)
		local curpos = ent:GetPos()
		timer.Simple(.01, function() entphys:EnableMotion(true) end)
		timer.Simple(.01, function() entphys:Wake() end)
		timer.Simple(.01, function() ent:SetPos(curpos) end)
	else
		return true
	end
end

function GM:PlayerSpawn(ply)
	self.BaseClass:PlayerSpawn(ply)
	ply:CrosshairEnable()

	if CfgVars["crosshair"] == 0 then
		ply:CrosshairDisable()
	end
	ply:ConCommand("pp_colormod 0")

	if CfgVars["strictsuicide"] == 1 and ply:GetTable().DeathPos then
		if not (ply:GetTable().Arrested) then
			ply:SetPos(ply:GetTable().DeathPos)
		end
	end

	-- If the player for some magical reason managed to respawn while jailed then re-jail the bastard.
	if ply:GetTable().Arrested and ply:GetTable().DeathPos then
		-- For when CfgVars["teletojail"] == 0
		ply:SetPos(ply:GetTable().DeathPos)
		-- Not getting away that easily, Sonny Jim.
		if DB.RetrieveJailPos() then
			ply:Arrest()
		else
			Notify(ply, 1, 4, "You're no longer under arrest because no jail positions are set!")
		end
	end

	if CfgVars["enforceplayermodel"] == 1 then
		if ply:Team() == TEAM_CITIZEN then
			local validmodel = false

			for k, v in pairs(CivModels) do
				if ply:GetTable().PlayerModel == v then
					validmodel = true
					break
				end
			end

			if not validmodel then
				ply:GetTable().PlayerModel = nil
			end

			local model = ply:GetModel()

			if model ~= ply:GetTable().PlayerModel then
				for k, v in pairs(CivModels) do
					if v == model then
						ply:GetTable().PlayerModel = model
						validmodel = true
						break
					end
				end

				if not validmodel and not ply:GetTable().PlayerModel then
					ply:GetTable().PlayerModel = CivModels[math.random(1, #CivModels)]
				end

				ply:SetModel(ply:GetTable().PlayerModel)
			end
		elseif ply:Team() == TEAM_POLICE then
			ply:SetModel("models/player/police.mdl")
		elseif ply:Team() == TEAM_MAYOR then
			ply:SetModel("models/player/breen.mdl")
		elseif ply:Team() == TEAM_GANG then
			ply:SetModel("models/player/group03/male_01.mdl")
		elseif ply:Team() == TEAM_MOB  then
			ply:SetModel("models/player/gman_high.mdl")
		elseif ply:Team() == TEAM_GUN then
			ply:SetModel("models/player/monk.mdl")
		elseif ply:Team() == TEAM_MEDIC then
			ply:SetModel("models/player/kleiner.mdl")
		elseif ply:Team() == TEAM_COOK then
			ply:SetModel("models/player/mossman.mdl")
		elseif ply:Team() == TEAM_CHIEF then
			ply:SetModel("models/player/police.mdl")
		end
	end

	if CfgVars["customspawns"] == 1 then
		if not ply:GetTable().Arrested then
			local pos = DB.RetrieveTeamSpawnPos(ply)
			if pos then
				ply:SetPos(pos)
			end
		end
	end

	ply:Extinguish()

	if ply.demotedWhileDead then
		ply.demotedWhileDead = nil
		ply:ChangeTeam(TEAM_CITIZEN)
	end
end

function GM:PlayerLoadout(ply)
	if ply:GetTable().Arrested then return end

	local team = ply:Team()

	ply:Give("keys")
	ply:Give("weapon_physcannon")
	ply:Give("gmod_camera")

	if CfgVars["toolgun"] == 1 or ply:IsAdmin() or ply:IsSuperAdmin() then
		ply:Give("gmod_tool")
	end

	if CfgVars["physgun"] == 1 or ply:IsAdmin() or ply:IsSuperAdmin() then
		ply:Give("weapon_physgun")
	end

	if team == TEAM_POLICE or team == TEAM_CHIEF or ply:IsAdmin() or ply:IsSuperAdmin() then
		ply:Give("door_ram")
	end

	if team == TEAM_POLICE then
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		if CfgVars["noguns"] ~= 1 then
			ply:Give("weapon_real_cs_glock18")
			ply:GiveAmmo(20, "Pistol")
		end
	elseif team == TEAM_MAYOR then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(28, "Pistol") end
	elseif team == TEAM_GANG then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_MOB then
		ply:Give("unarrest_stick")
		ply:Give("lockpick")
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_GUN then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_MEDIC then
		ply:Give("med_kit")
	elseif team == TEAM_COOK then
		if CfgVars["noguns"] ~= 1 then ply:GiveAmmo(1, "Pistol") end
	elseif team == TEAM_CHIEF then
		ply:Give("arrest_stick")
		ply:Give("unarrest_stick")
		ply:Give("stunstick")
		if CfgVars["noguns"] ~= 1 then
			ply:Give("weapon_real_cs_desert_eagle")
			ply:GiveAmmo(30, "Pistol")
		end
	end
end

function GM:PlayerInitialSpawn(ply)
	self.BaseClass:PlayerInitialSpawn(ply)
	ply:NewData()
	ply:InitSID()
	NetworkHelpLabels(ply)
	ply:SetNetworkedBool("helpMenu",false)
	ply:SetNWInt("maxDrug", 0)
	ply:SetNWInt("maxmicrowaves", 0)
	ply:SetNWInt("maxgunlabs", 0)
	ply:SetNWInt("maxDrugs", 0)
	ply:SetNWInt("maxFoods", 0)
	ply:SetNWInt("aspamv", 0)
	ply:SetNWInt("vmutez", 0)
	ply:SetNWInt("slp", 0)
	ply:SetNWInt("maxletters", 0)
	ply:SetNetworkedBool("wanted", false)
	ply:SetNetworkedBool("warrant", false)
	ply:SetNWBool("helpCop", false)
	ply:SetNWBool("zombieToggle", false)
	ply:SetNWBool("helpZombie", false)
	ply:SetNWBool("helpBoss", false)
	ply:SetNWBool("helpAdmin", false)
	DB.RetrieveSalary(ply)
	DB.RetrieveMoney(ply)
	DB.SetUpNonOwnableDoors()
	ply:PrintMessage(HUD_PRINTTALK, "This server is running DarkRP " .. DARKRP_VERSION)
	timer.Simple(10, function() ply:CompleteSentence() end)
end

function GM:PlayerDisconnected(ply)
	self.BaseClass:PlayerDisconnected(ply)
	ply:UnownAll()
	timer.Destroy(ply:SteamID() .. "jobtimer")
	timer.Destroy(ply:SteamID() .. "propertytax")
	for k, v in pairs(ents.FindByClass("money_printer")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("microwave")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("gunlab")) do
		if v.SID == ply.SID then v:Remove() end
	end
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	vote.DestroyVotesWithEnt(ply)
	-- If you're arrested when you disconnect, you will serve your time again when you reconnect!
	if ply:GetTable().Arrested then
		DB.StoreJailStatus(ply, math.ceil(GetGlobalInt("jailtimer")))
	end
end
