local timeLeft = 10
local timeLeft2 = 10
local stormOn = false
local zombieOn = false
local maxZombie = 10

VoteCopOn = false
VoteMayorOn = false

function ControlZombie()
	timeLeft2 = timeLeft2 - 1

	if timeLeft2 < 1 then
		if zombieOn then
			timeLeft2 = math.random(300,500)
			zombieOn = false
			timer.Stop("start2")
			ZombieEnd()
		else
			timeLeft2 = math.random(150,300)
			zombieOn = true
			timer.Start("start2")
			DB.RetrieveZombies()
			ZombieStart()
		end
	end
end

function ZombieStart()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "WARNING: Zombies are approaching!")
			v:PrintMessage(HUD_PRINTTALK, "WARNING: Zombies are approaching!")
		end
	end
end

function ZombieEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "Zombies are leaving.")
			v:PrintMessage(HUD_PRINTTALK, "Zombies are leaving.")
		end
	end
end

function StormStart()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "WARNING: Meteor storm approaching!")
			v:PrintMessage(HUD_PRINTTALK, "WARNING: Meteor storm approaching!")
		end
	end
end

function StormEnd()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			v:PrintMessage(HUD_PRINTCENTER, "Meteor storm passing.")
			v:PrintMessage(HUD_PRINTTALK, "Meteor storm passing.")
		end
	end
end

function ControlStorm()
	timeLeft = timeLeft - 1

	if timeLeft < 1 then
		if stormOn then
			timeLeft = math.random(300,500)
			stormOn = false
			timer.Stop("start")
			StormEnd()
		else
			timeLeft = math.random(60,90)
			stormOn = true
			timer.Start("start")
			StormStart()
		end
	end
end

function StartShower()
	timer.Adjust("start", math.random(.5,1.5), 0, StartShower)
	for k, v in pairs(player.GetAll()) do
		if math.random(0, 2) == 0 then
			if v:Alive() then
				AttackEnt(v)
			end
		end
	end
end

function DrugPlayer(pl)
	pl:ConCommand("pp_motionblur 1")
	pl:ConCommand("pp_motionblur_addalpha 0.05")
	pl:ConCommand("pp_motionblur_delay 0.035")
	pl:ConCommand("pp_motionblur_drawalpha 1.00")
	pl:ConCommand("pp_dof 1")
	pl:ConCommand("pp_dof_initlength 9")
	pl:ConCommand("pp_dof_spacing 8")

	local IDSteam = string.gsub(pl:SteamID(), ":", "")

	timer.Create(IDSteam, 40, 1, function() UnDrugPlayer(pl) end)
end

function UnDrugPlayer(pl)
	pl:ConCommand("pp_motionblur 0")
	pl:ConCommand("pp_dof 0")
end

function AttackEnt(ent)
	meteor = ents.Create("meteor")
	meteor:Spawn()
	meteor:SetTarget(ent)
end

function PlayerDist(npcPos)
	local playDis
	local currPlayer
	for k, v in pairs(player.GetAll()) do
		local tempPlayDis = v:GetPos():Distance(npcPos:GetPos())

		if playDis == nil then
			playDis = tempPlayDis
			currPlayer = v
		end

		if tempPlayDis < playDis then
			playDis = tempPlayDis
			currPlayer = v
		end
	end

	return currPlayer
end

function MoveZombie()
	local activePlayers = false

	for k, v in pairs(player.GetAll()) do
		activePlayers = true
	end

	if activePlayers then
		local tb1 = table.Add(ents.FindByClass("npc_antlion"),ents.FindByClass("npc_fastzombie"))
		local tb2 = table.Add(ents.FindByClass("npc_zombie"),ents.FindByClass("npc_headcrab_fast"))
		local tb3 = table.Add(tb1,tb2)
		local tb4 = table.Add(tb3,ents.FindByClass("npc_headcrab"))

		for a, b in pairs(tb4) do
			local newpos = b:GetPos() + ((PlayerDist(b):GetPos()-b:GetPos()):Normalize()*500)

			if PlayerDist(b):GetPos():Distance(b:GetPos()) > 500 then
				b:AddEntityRelationship(PlayerDist(b), 1, 99)
				b:SetLastPosition(newpos)
				b:SetSchedule(71)
			end
		end
	end
	timer.Create("move", .5, 0, MoveZombie)
	timer.Stop("move")
end

function LoadTable(ply)
	ply:SetNWInt("numPoints", table.getn(zombieSpawns))

	for k, v in pairs(zombieSpawns) do
		local Sep = (string.Explode(" " ,v))
		ply:SetNWVector("zPoints" .. k, Vector(tonumber(Sep[1]),tonumber(Sep[2]),tonumber(Sep[3])))
	end
end

function ReMoveZombie(ply, index)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		if not index or zombieSpawns[tonumber(index)] == nil then
			Notify(ply, 1, 4, "Zombie Spawn " .. tostring(index) .. " does not exist.")
		else
			DB.RetrieveZombies()
			Notify(ply, 1, 4, "Zombie spawn removed.")
			table.remove(zombieSpawns,index)
			DB.StoreZombies()
			if ply:GetNWBool("zombieToggle") then
				LoadTable(ply)
			end
		end
	else
		Notify(ply, 1, 4, "Must be an admin.")
	end
	return ""
end
AddChatCommand("/removezombie", ReMoveZombie)

function AddZombie(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		DB.RetrieveZombies()
		table.insert(zombieSpawns, tostring(ply:GetPos()))
		DB.StoreZombies()
		if ply:GetNWBool("zombieToggle") then LoadTable(ply) end
		Notify(ply, 1, 4, "Zombie spawn added.")
	else
		Notify(ply, 1, 4, "Must be an admin.")
	end
	return ""
end
AddChatCommand("/addzombie", AddZombie)

function ToggleZombie(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		if not ply:GetNWBool("zombieToggle") then
			DB.RetrieveZombies()
			ply:SetNWBool("zombieToggle", true)
			LoadTable(ply)
			Notify(ply, 1, 4, "Show Zombies Enabled")
		else
			ply:SetNWBool("zombieToggle", false)
			Notify(ply, 1, 4, "Show Zombies Disabled")
		end
	else
		Notify(ply, 1, 4, "Must be an admin.")
	end
	return ""
end
AddChatCommand("/showzombie", ToggleZombie)

function SpawnZombie()
	timer.Start("move")
	if GetAliveZombie() < maxZombie then
		if table.getn(zombieSpawns) > 0 then
			local zombieType = math.random(2, 2)
			if zombieType == 1 then
				local zombie1 = ents.Create("npc_zombie")
				zombie1:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie1:Spawn()
				zombie1:Activate()
			elseif zombieType == 2 then
				local zombie2 = ents.Create("npc_fastzombie")
				zombie2:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie2:Spawn()
				zombie2:Activate()
			elseif zombieType == 3 then
				local zombie3 = ents.Create("npc_antlion")
				zombie3:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie3:Spawn()
				zombie3:Activate()
			elseif zombieType == 4 then
				local zombie4 = ents.Create("npc_headcrab_fast")
				zombie4:SetPos(DB.RetrieveRandomZombieSpawnPos())
				zombie4:Spawn()
				zombie4:Activate()
			end
		end
	end
end

function GetAliveZombie()
	local zombieCount = 0

	for k, v in pairs(ents.FindByClass("npc_zombie")) do
		zombieCount = zombieCount + 1
	end

	for k, v in pairs(ents.FindByClass("npc_fastzombie")) do
		zombieCount = zombieCount + 1
	end

	for k, v in pairs(ents.FindByClass("npc_antlion")) do
		zombieCount = zombieCount + 1
	end

	for k, v in pairs(ents.FindByClass("npc_headcrab_fast")) do
		zombieCount = zombieCount + 1
	end

	return zombieCount
end

function DropWeapon(ply)
	local trace = {}
	
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	local ent = ply:GetActiveWeapon()
	if not IsValid(ent) then return "" end
	local class = ent:GetClass()

	if class ~= "weapon_real_cs_ak47" and
		class ~= "weapon_real_cs_m4a1" and
		class ~= "weapon_real_cs_desert_eagle" and
		class ~= "weapon_real_cs_five-seven" and
		class ~= "weapon_real_cs_g3sg1" and
		class ~= "weapon_real_cs_glock18" and
		class ~= "weapon_real_cs_mac10" and
		class ~= "weapon_real_cs_mp5a4" and
		class ~= "weapon_real_cs_p228" and
		class ~= "weapon_real_cs_pumpshotgun" then

		Notify(ply, 1, 4, "Non - RP weapons can not be dropped!")
		return ""
	end

	ply:StripWeapon(class)
	local weapon = ents.Create("spawned_weapon")
	weapon:UseModelForClass(class)
	weapon:SetPos(tr.HitPos)
	weapon:SetNWString("Owner", "Shared")
	weapon:Spawn()
	return ""
end
AddChatCommand("/drop", DropWeapon)
AddChatCommand("/dropweapon", DropWeapon)
AddChatCommand("/weapondrop", DropWeapon)

function ZombieMax(ply, args)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		maxZombie = tonumber(args)
		Notify(ply, 1, 4, "Max zombies set.")
	end

	return ""
end
AddChatCommand("/zombiemax", ZombieMax)

function UnWarrant(ply, target)
	target:SetNWBool("warrant", false)
	Notify(ply, 1, 4, "Search warrant for " .. target:Nick() .. " has expired!")
end

function SetWarrant(ply, target)
	target:SetNWBool("warrant", true)
	timer.Simple(CfgVars["searchtime"], function() UnWarrant(ply, target) end)
	for a, b in pairs(player.GetAll()) do
		b:PrintMessage(HUD_PRINTCENTER, "Search warrant approved for " .. target:Nick() .. "!")
	end
	Notify(ply, 1, 4, "Warrant set.")
end

function FinishWarrant(choice, mayor, initiator, target)
	if choice == 1 then
		SetWarrant(initiator, target)
	else
		Notify(initiator, 1, 4, "Mayor " .. mayor:Nick() .. " has denied your search warrant request.")
	end
	return ""
end

function SearchWarrant(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, "You must be a Cop or the Mayor.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			-- If we're the Mayor, set the search warrant
			if t == TEAM_MAYOR then
				SetWarrant(ply, p)
			else -- If we're CP or Chief
				-- Find the mayor
				local m = nil
				for k, v in pairs(player.GetAll()) do
					if v:Team() == TEAM_MAYOR then
						m = v
						break
					end
				end
				-- If we found the mayor
				if m ~= nil then
					-- request a search warrent for player "p"
					ques:Create(ply:Nick() .. " wants a search warrant for " .. p:Nick(), p:EntIndex() .. "warrant", m, 40, FinishWarrant, ply, p)
					Notify(ply, 1, 4, "Search warrant request sent to Mayor " .. m:Nick() .. "!")
				else
					-- there is no mayor, CPs can set warrants.
					SetWarrant(ply, p)
				end
			end
		else
			Notify(ply, 1, 4, "Player is dead or does not exist.")
		end
	end
	return ""
end
AddChatCommand("/warrant", SearchWarrant)
AddChatCommand("/warrent", SearchWarrant) -- Most players can't spell for some reason

function PlayerWanted(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, "You must be a Cop or the Mayor.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			p:SetNWBool("wanted", true)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, p:Nick() .. " is wanted by the Police!")
			end
		else
			Notify(ply, 1, 4, "Player is dead or does not exist.")
		end
	end
	return ""
end
AddChatCommand("/wanted", PlayerWanted)

function PlayerUnWanted(ply, args)
	local t = ply:Team()
	if not (t == TEAM_POLICE or t == TEAM_MAYOR or t == TEAM_CHIEF) then
		Notify(ply, 1, 4, "You must be a Cop or the Mayor.")
	else
		local p = FindPlayer(args)
		if p and p:Alive() then
			p:SetNWBool("wanted", false)
			for a, b in pairs(player.GetAll()) do
				b:PrintMessage(HUD_PRINTCENTER, p:Nick() .. " is no longer wanted by the Police.")
			end
		else
			Notify(ply, 1, 4, "Player is dead or does not exist.")
		end
	end
	return ""
end
AddChatCommand("/unwanted", PlayerUnWanted)

function SetSpawnPos(ply, args)
	if not ply:IsAdmin() and not ply:IsSuperAdmin() then return "" end

	local pos = string.Explode(" ", tostring(ply:GetPos()))
	local selection = "citizen"
	local t = 99

	if args == "citizen" then
		t = TEAM_CITIZEN
		Notify(ply, 1, 4,  "Citizen Spawn Position set.")
	elseif args == "cp" then
		t = TEAM_POLICE
		Notify(ply, 1, 4,  "CP Spawn Position set.")
	elseif args == "mayor" then
		t = TEAM_MAYOR
		Notify(ply, 1, 4,  "Mayor Spawn Position set.")
	elseif args == "gangster" then
		t = TEAM_GANG
		Notify(ply, 1, 4,  "Gangster Spawn Position set.")
	elseif args == "mobboss" then
		t = TEAM_MOB
		Notify(ply, 1, 4,  "Mob Boss Spawn Position set.")
	elseif args == "gundealer" then
		t = TEAM_GUN
		Notify(ply, 1, 4,  "Gun Dealer Spawn Position set.")
	elseif args == "medic" then
		t = TEAM_MEDIC
		Notify(ply, 1, 4,  "Medic Spawn Position set.")
	elseif args == "cook" then
		t = TEAM_COOK
		Notify(ply, 1, 4,  "Cook Spawn Position set.")
	elseif args == "chief" then
		t = TEAM_CHIEF
		Notify(ply, 1, 4,  "Chief Spawn Position set.")
	end

	if t ~= 99 then
		DB.StoreTeamSpawnPos(t, pos)
	end

	return ""
end
AddChatCommand("/setspawn", SetSpawnPos)

function StartStorm(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		timer.Start("stormControl")
		Notify(ply, 1, 4, "Meteor Storm enabled.")
	end
	return ""
end
AddChatCommand("/enablestorm", StartStorm)

function HelpCop(ply)
	ply:SetNWBool("helpCop", not ply:GetNWBool("helpCop"))
	return ""
end
AddChatCommand("/cophelp", HelpCop)

function HelpMayor(ply)
	ply:SetNWBool("helpMayor", not ply:GetNWBool("helpMayor"))
	return ""
end
AddChatCommand("/mayorhelp", HelpMayor)

function HelpZombie(ply)
	ply:SetNWBool("helpZombie", not ply:GetNWBool("helpZombie"))
	return ""
end
AddChatCommand("/zombiehelp", HelpZombie)

function HelpBoss(ply)
	ply:SetNWBool("helpBoss", not ply:GetNWBool("helpBoss"))
	return ""
end
AddChatCommand("/mobbosshelp", HelpBoss)

function HelpAdmin(ply)
	ply:SetNWBool("helpAdmin", not ply:GetNWBool("helpAdmin"))
	return ""
end
AddChatCommand("/adminhelp", HelpAdmin)

function closeHelp(ply)
	ply:SetNWBool("helpCop", false)
	ply:SetNWBool("helpBoss", false)
	ply:SetNWBool("helpMayor", false)
	ply:SetNWBool("helpZombie", false)
	ply:SetNWBool("helpAdmin", false)
	return ""
end
AddChatCommand("/x", closeHelp)

function RemoveItem(ply)
	local trace = ply:GetEyeTrace()
	if IsValid(trace.Entity) and trace.Entity.SID and (trace.Entity.SID == ply.SID or ply:IsAdmin() or ply:IsSuperAdmin()) then
		trace.Entity:Remove()
	end
	return ""
end
AddChatCommand("/rm", RemoveItem)

function RemoveLetters(ply)
	for k, v in pairs(ents.FindByClass("letter")) do
		if v.SID == ply.SID then v:Remove() end
	end
	Notify(ply, 1, 4, "Your letters were cleaned up.")
	return ""
end
AddChatCommand("/removeletters", RemoveLetters)

function StopStorm(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		timer.Stop("stormControl")
		stormOn = false
		timer.Stop("start")
		StormEnd()
		Notify(ply, 1, 4, "Meteor Storm disabled.")
		return ""
	end
end
AddChatCommand("/disablestorm", StopStorm)

function StartZombie(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		timer.Start("zombieControl")
		Notify(ply, 1, 4, "Zombies enabled.")
	end
	return ""
end
AddChatCommand("/enablezombie", StartZombie)

function StopZombie(ply)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		timer.Stop("zombieControl")
		zombieOn = false
		timer.Stop("start2")
		ZombieEnd()
		Notify(ply, 1, 4, "Zombies disabled.")
		return ""
	end
end
AddChatCommand("/disablezombie", StopZombie)

function QueryVar(ply, args)
	if not CfgVars[args] then
		Notify(ply, 1, 4, "CfgVar " .. args .. " not found.")
	else
		Notify(ply, 1, 4, args .. " = " .. CfgVars[args])
	end
	return ""
end
AddChatCommand("/queryvar", QueryVar)

function SetPrice(ply, args)
	if args == "" then return "" end

	local a = tonumber(args)
	if not a then return "" end
	local b = math.floor(a)
	if b < 0 or b > 99999999 then return "" end
	local trace = {}

	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if IsValid(tr.Entity) and (tr.Entity:GetNWBool("gunlab") or tr.Entity:GetNWBool("microwave")) and tr.Entity.SID == ply.SID then
		tr.Entity:SetNWInt("price", b)
	else
		Notify(ply, 1, 4, "Must be looking at a Gun Lab or Microwave!")
	end
	return ""
end
AddChatCommand("/price", SetPrice)

local buyPistols = {}
buyPistols["deagle"] = "weapon_real_cs_desert_eagle"
buyPistols["fiveseven"] = "weapon_real_cs_five-seven"
buyPistols["glock"] = "weapon_real_cs_glock18"
buyPistols["p228"] = "weapon_real_cs_p228"

function BuyPistol(ply, args)
	if args == "" then return "" end

	if CfgVars["noguns"] == 1 then
		Notify(ply, 1, 4, "Guns are disabled!")
		return ""
	end

	if CfgVars["restrictbuypistol"] ~= 0 and ply:Team() ~= TEAM_GUN and team.NumPlayers(TEAM_GUN) > 0 then
		Notify(ply, 1, 4, "/buypistol is disabled because there are Gun Dealers.")
		return ""
	end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	if ply:GetTable().Arrested then return "" end
	
	local found = nil
	for k, v in pairs(buyPistols) do
		if k == args then
			found = true
		end
	end
	
	if not found then
		Notify(ply, 1, 4, "Weapon not available!")
		return ""
	end
	
	local price = 0
	if ply:Team() == TEAM_GUN then
		price = math.ceil(GetGlobalInt(args .. "cost") * 0.88)
	else
		price = GetGlobalInt(args .. "cost")
	end
	
	if not ply:CanAfford(price) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	
	ply:AddMoney(-price)
	
	Notify(ply, 1, 4, "You bought a " .. args .. " for " .. CUR .. tostring(price))
	
	local weapon = ents.Create("spawned_weapon")
	weapon:UseModelForClass(buyPistols[args])
	weapon:SetNWString("Owner", "Shared")
	weapon:SetPos(tr.HitPos)
	weapon:Spawn()

	return ""
end
AddChatCommand("/buypistol", BuyPistol)

local rifleWeights = {}
rifleWeights["ak47"] = 4.0
rifleWeights["mp5"] = 3.0
rifleWeights["m4"] = 3.0
rifleWeights["mac10"] = 2.5
rifleWeights["shotgun"] = 3.3
rifleWeights["sniper"] = 5.9

function BuyShipment(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if ply:GetTable().Arrested then return "" end

	if ply:Team() ~= TEAM_GUN then
		Notify(ply, 1, 4, "Must be a Gun Dealer to buy gun shipments!")
		return ""
	end
	
	local found = false
	for k, v in pairs(rifleWeights) do
		if k == args then found = true end
	end
	
	if not found then
		Notify(ply, 1, 4, "Weapon not available!")
		return ""
	end

	local cost = GetGlobalInt(args .. "cost")
	
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You bought a Shipment of " .. args .. "s for " .. CUR .. tostring(cost))
	local crate = ents.Create("spawned_shipment")
	crate:SetContents(args, 10, rifleWeights[args])
	crate:SetPos(Vector(tr.HitPos.x, tr.HitPos.y, tr.HitPos.z))
	crate:Spawn()
	
	return ""
end
AddChatCommand("/buyshipment", BuyShipment)

function BuyDrugLab(ply)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	if ply:GetTable().Arrested then return "" end

	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("druglabcost")
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	if ply:GetNWInt("maxDrug") == CfgVars["maxdruglabs"] then
		Notify(ply, 1, 4, "Max Drug Labs reached!")
		return ""
	end
	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You bought a Drug Lab for " .. CUR .. tostring(cost))
	local druglab = ents.Create("drug_lab")
	druglab:SetNWEntity("owning_ent", ply)
	druglab:SetNWString("Owner", ply:Nick())
	druglab:SetPos(tr.HitPos)
	druglab.SID = ply.SID
	druglab.onlyremover = true
	druglab:Spawn()
	return ""
end
AddChatCommand("/buydruglab", BuyDrugLab)

function BuyMicrowave(ply)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	if ply:GetTable().Arrested then return "" end
	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("microwavecost")

	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	if ply:GetNWInt("maxmicrowaves") == CfgVars["maxmicrowaves"] then
		Notify(ply, 1, 4, "Max Microwaves reached!")
		return ""
	end

	if ply:Team() == TEAM_COOK then
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You bought a Microwave for " .. CUR .. tostring(cost))
		local microwave = ents.Create("microwave")
		microwave:SetNWInt("price", GetGlobalInt("microwavefoodcost"))
		microwave:SetNWEntity("owning_ent", ply)
		microwave:SetNWString("Owner", ply:Nick())
		microwave:SetNWBool("microwave", true)
		microwave:SetPos(tr.HitPos)
		microwave:Spawn()
		microwave.SID = ply.SID
		return ""
	else
		Notify(ply, 1, 4, "You must be a Cook to buy this!")
	end
	return ""
end
AddChatCommand("/buymicrowave", BuyMicrowave)

function BuyGunlab(ply)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	if ply:GetTable().Arrested then return "" end
	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("gunlabcost")

	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	if ply:GetNWInt("maxgunlabs") == CfgVars["maxgunlabs"] then
		Notify(ply, 1, 4, "Max Gun Labs reached!")
		return ""
	end
	if ply:Team() == TEAM_GUN then
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You bought a Gun Lab for " .. CUR .. tostring(cost))
		local gunlab = ents.Create("gunlab")
		gunlab:SetNWEntity("owning_ent", ply)
		gunlab:SetNWString("Owner", ply:Nick())
		gunlab:SetNWInt("price", GetGlobalInt("p228cost"))
		gunlab:SetNWBool("gunlab", true)
		gunlab:SetPos(tr.HitPos)
		gunlab:Spawn()
		gunlab.SID = ply.SID
		return ""
	else
		Notify(ply, 1, 4, "Must be a Gun Dealer!")
	end
	return ""
end
AddChatCommand("/buygunlab", BuyGunlab)

function BuyMoneyPrinter(ply, args)
	if ply:GetTable().Arrested then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply
	local tr = util.TraceLine(trace)

	local cost = GetGlobalInt("mprintercost")

	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	if ply:GetNWInt("maxmprinters") >= CfgVars["maxmprinters"] then
		Notify(ply, 1, 4, "Max Money Printers reached!")
		return ""
	end

	ply:AddMoney(-cost)
	Notify(ply, 1, 4, "You bought a Money Printer for " .. CUR .. tostring(cost))
	local moneyprinter = ents.Create("money_printer")
	moneyprinter:SetNWEntity("owning_ent", ply)
	moneyprinter:SetNWString("Owner", "Shared") -- So people can run off with them!
	moneyprinter:SetPos(tr.HitPos)
	moneyprinter.onlyremover = true
	moneyprinter.SID = ply.SID
	moneyprinter:Spawn()
	return ""
end
AddChatCommand("/buymoneyprinter", BuyMoneyPrinter)

function BuyAmmo(ply, args)
	if args == "" then return "" end

	if ply:GetTable().Arrested then return "" end

	if CfgVars["noguns"] == 1 then
		Notify(ply, 1, 4, "Guns are disabled so why buy ammo?!")
		return ""
	end
	
	if args ~= "rifle" and args ~= "shotgun" and args ~= "pistol" then
		Notify(ply, 1, 4, "That ammo is not available!")
	end
	
	if not ply:CanAfford(GetGlobalInt("ammo" .. args .. "cost")) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	
	if args == "rifle" then
		ply:GiveAmmo(80, "smg1")
	elseif args == "shotgun" then
		ply:GiveAmmo(50, "buckshot")
	elseif args == "pistol" then
		ply:GiveAmmo(50, "pistol")
	end

	local cost = GetGlobalInt("ammo" .. args .. "cost")

	Notify(ply, 1, 4, "You bought some " .. args .. " ammo for " .. CUR .. tostring(cost))
	ply:AddMoney(-cost)

	return ""
end
AddChatCommand("/buyammo", BuyAmmo)

function BuyHealth(ply)
	local cost = GetGlobalInt("healthcost")
	if not ply:CanAfford(cost) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end
	if ply:Team() ~= TEAM_MEDIC and team.NumPlayers(TEAM_MEDIC) > 0 then
		Notify(ply, 1, 4, "/buyhealth is disabled because there are Medics.")
		return ""
	else
		ply:AddMoney(-cost)
		Notify(ply, 1, 4, "You bought Health for " .. CUR .. tostring(cost))
		ply:SetHealth(100)
		return ""
	end
	return ""
end
AddChatCommand("/buyhealth", BuyHealth)

function BuyFood(ply, args)
	if args == "" then return "" end

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)

	if GetGlobalInt("hungermod") == 0 then
		Notify(ply, 1, 4, "/buyfood is disabled unless Hunger Mod is enabled.")
		return ""
	end

	if ply:Team() ~= TEAM_COOK and team.NumPlayers(TEAM_COOK) > 0 then
		Notify(ply, 1, 4, "/buyfood is disabled because there are Cooks.")
		return ""
	end

	if args == "melon" then
		if not ply:CanAfford(CfgVars["foodcost"]) then
			Notify(ply, 1, 4, "Can not afford this!")
			return ""
		end
		ply:AddMoney(-CfgVars["foodcost"])
		Notify(ply, 1, 4, "You bought a Melon for " .. CUR .. tostring(CfgVars["foodcost"]))
		local food = ents.Create("melon")
		food:SetModel("models/props_junk/watermelon01.mdl")
		food:SetNWString("Owner", "Shared")
		food:SetPos(tr.HitPos)
		food:Spawn()
	else
		Notify(ply, 1, 4, "Food type not available!")
	end
	return ""
end
AddChatCommand("/buyfood", BuyFood)

function JailPos(ply)
	-- Admin or Chief can set the Jail Position
	if (ply:Team() == TEAM_CHIEF and CfgVars["chiefjailpos"] == 1) or ply:IsAdmin() or ply:IsSuperAdmin() then
		DB.StoreJailPos(ply)
	else
		local str = "Admin only!"
		if CfgVars["chiefjailpos"] == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/jailpos", JailPos)

function AddJailPos(ply)
	-- Admin or Chief can add Jail Positions
	if (ply:Team() == TEAM_CHIEF and CfgVars["chiefjailpos"] == 1) or ply:IsAdmin() or ply:IsSuperAdmin() then
		DB.StoreJailPos(ply, true)
	else
		local str = "Admin only!"
		if CfgVars["chiefjailpos"] == 1 then
			str = "Chief or " .. str
		end

		Notify(ply, 1, 4, str)
	end
	return ""
end
AddChatCommand("/addjailpos", AddJailPos)

function MakeGangster(ply)
	ply:ChangeTeam(TEAM_GANG)
	return ""
end
AddChatCommand("/gangster", MakeGangster)

function MakeMobBoss(ply)
	ply:ChangeTeam(TEAM_MOB)
	return ""
end
AddChatCommand("/mobboss", MakeMobBoss)

function CreateAgenda(ply, args)
	if ply:Team() == TEAM_MOB then
		CfgVars["mobagenda"] = string.gsub(args, "//", "\n")

		for k, v in pairs(player.GetAll()) do
			local t = v:Team()
			if t == TEAM_GANG or t == TEAM_MOB then
				v:PrintMessage(HUD_PRINTTALK, "Mob Boss updated the agenda!")
				v:SetNWString("agenda", CfgVars["mobagenda"])
			else
				Notify(ply, 1, 4, "Mob Boss updated the agenda!")
			end
		end
	else
		Notify(ply, 1, 4, "Must be a Mob Boss to use this command.")
	end
	return ""
end
AddChatCommand("/agenda", CreateAgenda)

timer.Create("start", 1, 0, StartShower)
timer.Create("stormControl", 1, 0, ControlStorm)
timer.Create("start2", 1, 0, SpawnZombie)
timer.Create("zombieControl", 1, 0, ControlZombie)
timer.Stop("start")
timer.Stop("stormControl")
timer.Stop("start2")
timer.Stop("zombieControl")

function GetHelp(ply, args)
	umsg.Start("ToggleHelp", ply)
	umsg.End()
	return ""
end
AddChatCommand("/help", GetHelp)

local function MakeLetter(ply, args, type)
	if CfgVars["letters"] == 0 then
		Notify(ply, 1, 4, "Letter writing is disabled.")
		return ""
	end

	if ply:GetNWInt("maxletters") >= CfgVars["maxletters"] then
		Notify(ply, 1, 4, "Max Letters reached!")
		return ""
	end

	if CurTime() - ply:GetTable().LastLetterMade < 3 then
		Notify(ply, 1, 4, "Wait another " .. math.ceil(3 - (CurTime() - ply:GetTable().LastLetterMade)) .. " seconds before writing another letter!")
		return ""
	end

	ply:GetTable().LastLetterMade = CurTime()

	-- Instruct the player's letter window to open

	local ftext = string.gsub(args, "//", "\n")
	local length = string.len(ftext)

	local numParts = math.floor(length / 39) + 1

	local tr = {}
	tr.start = ply:EyePos()
	tr.endpos = ply:EyePos() + 95 * ply:GetAimVector()
	tr.filter = ply
	local trace = util.TraceLine(tr)

	local letter = ents.Create("letter")
	letter:SetModel("models/props_c17/paper01.mdl")
	letter:SetNWEntity("owning_ent", ply)
	letter:SetNWString("Owner", "Shared")
	letter:SetPos(trace.HitPos)
	letter:Spawn()

	letter:GetTable().Letter = true
	letter:SetNWInt("type", type)
	letter:SetNWInt("numPts", numParts)

	local startpos = 1
	local endpos = 39
	for k=1, numParts do
		letter:SetNWString("part" .. tostring(k), string.sub(ftext, startpos, endpos))
		startpos = startpos + 39
		endpos = endpos + 39
	end
	letter.SID = ply.SID

	PrintMessageAll(2, ply:Nick() .. " created a letter.")
	ply:SetNWInt("maxletters", ply:GetNWInt("maxletters") + 1)
end

function WriteLetter(ply, args)
	MakeLetter(ply, args, 1)
	return ""
end
AddChatCommand("/write", WriteLetter)

function TypeLetter(ply, args)
	MakeLetter(ply, args, 2)
	return ""
end
AddChatCommand("/type", TypeLetter)

function ChangeJob(ply, args)
	if args == "" then return "" end

	if CfgVars["customjobs"] ~= 1 then
		Notify(ply, 1, 4, "Custom Jobs are disabled!")
		return ""
	end

	local len = string.len(args)

	if len < 3 then
		Notify(ply, 1, 4, "Job must be at least 3 characters!")
		return ""
	end

	if len > 25 then
		Notify(ply, 1, 4, "Job is restricted to 25 characters!")
		return ""
	end

	local jl = string.lower(args)
	local t = ply:Team()

	if (jl == "cp" or jl == "cop" or jl == "police" or jl == "civil protection" or jl == "civilprotection") and t ~= TEAM_POLICE then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if VoteCopOn then
				Notify(ply, 1, 4,  "Please wait for the existing cop vote to finish first.")
			else
				ply:ChangeTeam(TEAM_POLICE)
			end
		else
			Notify(ply, 1, 4, "You have to be on the CP or Mayor List or Admin!")
		end
		return ""
	elseif jl == "mayor" and t ~= TEAM_MAYOR then
		if ply:IsAdmin() or ply:IsSuperAdmin() then
			if VoteMayorOn then
				Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
			else
				ply:ChangeTeam(TEAM_MAYOR)
			end
		else
			Notify(ply, 1, 4, "You Must be on the Mayor List or Admin!")
		end
		return ""
	elseif jl == "gangster" and t ~= TEAM_GANG then
		ply:ChangeTeam(TEAM_GANG)
		return ""
	elseif jl == "citizen" and t ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN)
		return ""
	elseif (jl == "mob boss" or jl == "mobboss") and t ~= TEAM_MOB then
		ply:ChangeTeam(TEAM_MOB)
		return ""
	elseif (jl == "gun dealer" or jl == "gundealer") and t ~= TEAM_GUN then
		ply:ChangeTeam(TEAM_GUN)
		return ""
	elseif jl == "medic" and t ~= TEAM_MEDIC then
		ply:ChangeTeam(TEAM_MEDIC)
		return ""
	elseif jl == "cook" and t ~= TEAM_COOK then
		ply:ChangeTeam(TEAM_COOK)
		return ""
	elseif (jl == "chief" or jl == "cheif" or jl == "civil protection chief") and t ~= TEAM_CHIEF then
		ply:ChangeTeam(TEAM_CHIEF)
		return ""
	elseif (jl == "hobo" or jl == "bum" or jl == "unemployed") and t ~= TEAM_CITIZEN then
		ply:ChangeTeam(TEAM_CITIZEN)
		-- Don't return here because we want to run the notify below.
	end

	NotifyAll(2, 4, ply:Nick() .. " has set their job to '" .. args .. "'")
	ply:UpdateJob(args)
	return ""
end
AddChatCommand("/job", ChangeJob)

function GroupMsg(ply, args)
	local t = ply:Team()
	local audience = {}

	if t == TEAM_POLICE or t == TEAM_CHIEF or t == TEAM_MAYOR then
		for k, v in pairs(player.GetAll()) do
			local vt = v:Team()
			if vt == TEAM_POLICE or vt == TEAM_CHIEF or vt == TEAM_MAYOR then table.insert(audience, v) end
		end
	elseif t == TEAM_MOB or t == TEAM_GANG then
		for k, v in pairs(player.GetAll()) do
			local vt = v:Team()
			if vt == TEAM_MOB or vt == TEAM_GANG then table.insert(audience, v) end
		end
	end

	for k, v in pairs(audience) do
		v:PrintMessage(2, ply:Nick() .. ": (GROUP) " .. args)
		v:PrintMessage(3, ply:Nick() .. ": (GROUP) " .. args)
	end
	return ""
end
AddChatCommand("/g", GroupMsg)

function PM(ply, args)
	local namepos = string.find(args, " ")
	if not namepos then return "" end

	local name = string.sub(args, 1, namepos - 1)
	local msg = string.sub(args, namepos + 1)

	target = FindPlayer(name)

	if target then
		target:PrintMessage(2, ply:Nick() .. ": (PM) " .. msg)
		target:PrintMessage(3, ply:Nick() .. ": (PM) " .. msg)

		ply:PrintMessage(2, ply:Nick() .. ": (PM) " .. msg)
		ply:PrintMessage(3, ply:Nick() .. ": (PM) " .. msg)
	else
		Notify(ply, 1, 4, "Could not find player: " .. name)
	end

	return ""
end
AddChatCommand("/pm", PM)

function Whisper(ply, args)
	TalkToRange("(WHISPER)" .. ply:Nick() .. ": " .. args, ply:EyePos(), 90)
	return ""
end
AddChatCommand("/w", Whisper)

function Yell(ply, args)
	TalkToRange("(YELL)" .. ply:Nick() .. ": " .. args, ply:EyePos(), 550)
	return ""
end
AddChatCommand("/y", Yell)

function OOC(ply, args)
	if CfgVars["ooc"] == 0 then
		Notify(ply, 1, 4, "OOC is disabled")
		return ""
	end

	return "(OOC) " .. args
end
AddChatCommand("//", OOC, true)
AddChatCommand("/a", OOC, true)
AddChatCommand("/ooc", OOC, true)

function GiveMoney(ply, args)
	if args == "" then return "" end

	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsPlayer() and trace.Entity:GetPos():Distance(ply:GetPos()) < 150 then
		local amount = math.floor(tonumber(args))

		if amount <= 1 then
			Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "2!")
			return
		end

		if not ply:CanAfford(amount) then
			Notify(ply, 1, 4, "Can not afford this!")
			return ""
		end

		DB.PayPlayer(ply, trace.Entity, amount)

		Notify(trace.Entity, 0, 4, ply:Nick() .. " has given you " .. CUR .. tostring(amount))
		Notify(ply, 0, 4, "Gave " .. trace.Entity:Nick() .. " " .. CUR .. tostring(amount))
	else
		Notify(ply, 1, 4, "Must be looking at and standing close to another player!")
	end
	return ""
end
AddChatCommand("/give", GiveMoney)

function DropMoney(ply, args)
	if args == "" or not tonumber(args) then return "" end

	local amount = math.floor(tonumber(args))

	if amount <= 1 then
		Notify(ply, 1, 4, "Invalid amount of money! Must be at least " .. CUR .. "2!")
		return ""
	end

	if not ply:CanAfford(amount) then
		Notify(ply, 1, 4, "Can not afford this!")
		return ""
	end

	ply:AddMoney(-amount)

	local trace = {}
	trace.start = ply:EyePos()
	trace.endpos = trace.start + ply:GetAimVector() * 85
	trace.filter = ply

	local tr = util.TraceLine(trace)
	local moneybag = ents.Create("cash_bundle")
	moneybag:SetPos(tr.HitPos)
	moneybag:Spawn()
	moneybag:GetTable().Amount = amount

	return ""
end
AddChatCommand("/dropmoney", DropMoney)
AddChatCommand("/moneydrop", DropMoney)

function SetDoorTitle(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		if ply:IsSuperAdmin() then
			if trace.Entity:GetNWBool("nonOwnable") then
				DB.StoreNonOwnableDoorTitle(trace.Entity, args)
				return ""
			end
		else
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, "Admin only!")
			end
		end

		if trace.Entity:OwnedBy(ply) then
			trace.Entity:SetNWString("title", args)
		else
			Notify(ply, 1, 4, "You don't own this!")
		end
	end

	return ""
end
AddChatCommand("/title", SetDoorTitle)

function RemoveDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)

		if trace.Entity:GetNWBool("nonOwnable") then
			Notify(ply, 1, 4, "Can not remove owners while Door is non-ownable!")
		end

		if target then
			if trace.Entity:OwnedBy(ply) then
				if trace.Entity:AllowedToOwn(target) then
					trace.Entity:RemoveAllowed(target)
				end

				if trace.Entity:OwnedBy(target) then
					trace.Entity:RemoveOwner(target)
				end
			else
				Notify(ply, 1, 4, "You don't own this!")
			end
		else
			Notify(ply, 1, 4, "Could not find player: " .. args)
		end
	end
	return ""
end
AddChatCommand("/removeowner", RemoveDoorOwner)
AddChatCommand("/ro", RemoveDoorOwner)

function AddDoorOwner(ply, args)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 110 then
		target = FindPlayer(args)
		if target then
			if trace.Entity:GetNWBool("nonOwnable") then
				Notify(ply, 1, 4, "Can not add owners while Door is non-ownable!")
				return ""
			end

			if trace.Entity:OwnedBy(ply) then
				if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
					trace.Entity:AddAllowed(target)
				else
					Notify(ply, 1, 4, "Player already owns (or is allowed to own) this door!")
				end
			else
				Notify(ply, 1, 4, "You don't own this!")
			end
		else
			Notify(ply, 1, 4, "Could not find player: " .. args)
		end
	end
	return ""
end
AddChatCommand("/addowner", AddDoorOwner)
AddChatCommand("/ao", AddDoorOwner)

function Demote(ply, args)
	local p = FindPlayer(args)
	if p then
		if CurTime() - ply:GetTable().LastDemoteVote < 80 then
			Notify(ply, 1, 4, "Please wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastDemoteVote)) .. " seconds before demoting.")
			return ""
		end
		if p:Team() == TEAM_CITIZEN then
			Notify(ply, 1, 4,  p:Nick() .." is a Citizen - can't be demoted any further!")
		else
			NotifyAll(1, 4, ply:Nick() .. " has started a vote for the demotion of " .. p:Nick())
			vote:Create(p:Nick() .. ":\n Demotion Nominee", p:EntIndex() .. "votecop", p, 12, FinishDemote)
			ply:GetTable().LastDemoteVote = CurTime()
		end
		return ""
	else
		Notify(ply, 1, 4, "Player does not exist!")
		return ""
	end
end
AddChatCommand("/demote", Demote)

function FinishDemote(choice, v)
	if choice == 1 then
		v:TeamBan()
		if v:Alive() then
			v:ChangeTeam(TEAM_CITIZEN)
		else
			v.demotedWhileDead = true
		end

		NotifyAll(1, 4, v:Nick() .. " has been demoted!")
	else
		NotifyAll(1, 4, v:Nick() .. " has not been demoted!")
	end
end

function FinishVoteMayor(choice, ply)
	VoteMayorOn = false

	if choice == 1 then
		ply:ChangeTeam(TEAM_MAYOR)
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made Mayor!")
	end
end

function FinishVoteCop(choice, ply)
	VoteCopOn = false

	if choice == 1 then
		ply:ChangeTeam(TEAM_POLICE)
	else
		NotifyAll(1, 4, ply:Nick() .. " has not been made Civil Protection!")
	end
end

function DoVoteMayor(ply, args)
	if CfgVars["mayorvoting"] == 0 then
		Notify(ply, 1, 4,  "Mayor voting is disabled!")
		return ""
	end

	if not ply:ChangeAllowed(TEAM_MAYOR) then
		Notify(ply, 1, 4, "You were demoted! Please wait a while before taking your old job back.")
		return ""
	end

	if CurTime() - ply:GetTable().LastMayorVote < 80 then
		Notify(ply, 1, 4, "Please wait another " .. math.ceil(80 - (CurTime() - ply:GetTable().LastMayorVote)) .. " seconds before using /votemayor again.")
		return ""
	end

	if VoteMayorOn then
		Notify(ply, 1, 4,  "A Mayor Vote is already in progress!")
		return ""
	end

	if CfgVars["cptomayoronly"] == 1 then
		if ply:Team() ~= TEAM_POLICE and ply:Team() ~= TEAM_CHIEF then
			Notify(ply, 1, 4,  "You have to be in the Civil Protection!")
			return ""
		end
	end

	if ply:Team() == TEAM_MAYOR then
		Notify(ply, 1, 4,  "You're already Mayor!")
		return ""
	end

	if team.NumPlayers(TEAM_MAYOR) >= 1 then
		Notify(ply, 1, 4,  "There can only be one Mayor at a time!")
		return ""
	end

	vote:Create(ply:Nick() .. ":\nwants to be Mayor", ply:EntIndex() .. "votecop", ply, 12, FinishVoteMayor)
	ply:GetTable().LastMayorVote = CurTime()

	return ""
end
AddChatCommand("/votemayor", DoVoteMayor)

function DoVoteCop(ply, args)

	if CfgVars["cpvoting"] == 0 then
		Notify(ply, 1, 4,  "Cop voting is disabled!")
		return ""
	end

	if not ply:ChangeAllowed(TEAM_POLICE) then
		Notify(ply, 1, 4, "You were demoted! Please wait a while before taking your old job back.")
		return ""
	end

	if CurTime() - ply:GetTable().LastCopVote < 60 then
		Notify(ply, 1, 4, "Please wait another " .. math.ceil(60 - (CurTime() - ply:GetTable().LastCopVote)) .. " seconds before using /votecop again.")
		return ""
	end

	if VoteCopOn then
		Notify(ply, 1, 4,  "A Cop Vote is already in progress!")
		return ""
	end

	if ply:Team() == TEAM_POLICE then
		Notify(ply, 1, 4,  "You're already in the Civil Protection!")
		return ""
	end

	if team.NumPlayers(TEAM_POLICE) >= CfgVars["maxcps"] then
		Notify(ply, 1, 4,  "Max number of CP's are: " .. CfgVars["maxcps"])
		return ""
	end

	vote:Create(ply:Nick() .. ":\nwants to be a Cop", ply:EntIndex() .. "votecop", ply, 12, FinishVoteCop)
	ply:GetTable().LastCopVote = CurTime()

	return ""
end
AddChatCommand("/votecop", DoVoteCop)

function MakeMayor(ply, args)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		if VoteMayorOn then
			Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
		else
			ply:ChangeTeam(TEAM_MAYOR)
		end
	else
		Notify(ply, 1, 4, "You must be on the Mayor list or Admin!")
	end
	return ""
end
AddChatCommand("/mayor", MakeMayor)

function MakeCitizen(ply, args)
	ply:ChangeTeam(TEAM_CITIZEN)
	return ""
end
AddChatCommand("/citizen", MakeCitizen)

function MakeCP(ply, args)
	if ply:IsAdmin() or ply:IsSuperAdmin() then
		if VoteCopOn then
			Notify(ply, 1, 4,  "Please wait for the vote to finish first.")
		else
			ply:ChangeTeam(TEAM_POLICE)
		end
	else
		Notify(ply, 1, 4, "You must be on the CP or the Mayor list or Admin!")
	end
	return ""
end
AddChatCommand("/cp", MakeCP)

function MakeDealer(ply, args)
	ply:ChangeTeam(TEAM_GUN)
	return ""
end
AddChatCommand("/gundealer", MakeDealer)

function MakePDChief(ply, args)
	ply:ChangeTeam(TEAM_CHIEF)
	return ""
end
AddChatCommand("/chief", MakePDChief)

function MakeMedic(ply, args)
	ply:ChangeTeam(TEAM_MEDIC)
	return ""
end
AddChatCommand("/medic", MakeMedic)

function MakeCook(ply, args)
	ply:ChangeTeam(TEAM_COOK)
	return ""
end
AddChatCommand("/cook", MakeCook)

function CombineRequest(ply, args)
	local t = ply:Team()
	if t ~= TEAM_POLICE and t ~= TEAM_CHIEF then
		ply:ChatPrint(ply:Nick() .. ": (REQUEST!) " .. args)
		ply:PrintMessage(2, ply:Nick() .. ": (REQUEST!) " .. args)
	end

	for k, v in pairs(player.GetAll()) do
		if v:Team() == TEAM_POLICE or v:Team() == TEAM_CHIEF then
			v:ChatPrint(ply:Nick() .. ": (REQUEST!) " .. args)
			v:PrintMessage(2, ply:Nick() .. ": (REQUEST!) " .. args)
		end
	end
	return ""
end
AddChatCommand("/cr", CombineRequest)

function FoodHeal(ply)
	if GetGlobalInt("hungermod") == 0 then
		ply:SetHealth(ply:Health() + (100 - ply:Health()))
	else
		ply:SetNWInt("Energy", math.Clamp(ply:GetNWInt("Energy") + 100, 0, 100))
		umsg.Start("AteFoodIcon")
		umsg.End()
	end
	return ""
end

function Lockdown(ply)
	if GetGlobalInt("lstat") ~= 1 then
		if ply:Team() == TEAM_MAYOR or ply:IsAdmin() or ply:IsSuperAdmin() then
			for k,v in pairs(player.GetAll()) do
				v:ConCommand("play npc/overwatch/cityvoice/f_confirmcivilstatus_1_spkr.wav\n")
			end
			SetGlobalInt("lstat", 1)
			PrintMessageAll(HUD_PRINTTALK , "Lockdown in progress, please return to your homes!")
			NotifyAll(4, 4, ply:Nick() .. " has initiated a Lockdown, please return to your homes!")
		end
	end
	return ""
end
concommand.Add("rp_lockdown", Lockdown)
AddChatCommand("/lockdown", Lockdown)

function UnLockdown(ply)
	if GetGlobalInt("lstat") == 1 and GetGlobalInt("ulstat") == 0 then
		if ply:Team() == TEAM_MAYOR or ply:IsAdmin() or ply:IsSuperAdmin() then
			PrintMessageAll(HUD_PRINTTALK , "Lockdown has ended.")
			NotifyAll(4, 4, ply:Nick() .. " has ended the Lockdown.")
			SetGlobalInt("ulstat", 1)
			timer.Create("spamlock", 20, 1, function() WaitLock("") end)
		end
	end
	return ""
end
concommand.Add("rp_unlockdown", UnLockdown)
AddChatCommand("/unlockdown", UnLockdown)

function WaitLock()
	SetGlobalInt("ulstat", 0)
	SetGlobalInt("lstat", 0)
	timer.Destroy("spamlock")
end

function RefreshGlobals()
	if CfgVars["refreshglobals"] ~= 1 then
		SetGlobalInt("ak47cost", 2450)
		SetGlobalInt("mp5cost", 2200)
		SetGlobalInt("m4cost", 2450)
		SetGlobalInt("mac10cost", 2150)
		SetGlobalInt("shotguncost", 1750)
		SetGlobalInt("snipercost", 3750)
		SetGlobalInt("deaglecost", 215)
		SetGlobalInt("fivesevencost", 205)
		SetGlobalInt("glockcost", 160)
		SetGlobalInt("p228cost", 185)
		SetGlobalInt("druglabcost", 400)
		SetGlobalInt("gunlabcost", 500)
		SetGlobalInt("mprintercost", 1000)
		SetGlobalInt("mprintamount", 250)
		SetGlobalInt("microwavecost", 400)
		SetGlobalInt("drugpayamount", 15)
		SetGlobalInt("ammopistolcost", 30)
		SetGlobalInt("ammoriflecost", 60)
		SetGlobalInt("ammoshotguncost", 70)
		SetGlobalInt("healthcost", 60)
		SetGlobalInt("jailtimer", 120)
		SetGlobalInt("microwavefoodcost", 30)
		SetGlobalInt("maxcopsalary", 100)
		SetGlobalInt("maxdrugfood", 2)
		SetGlobalInt("npckillpay", 10)
		SetGlobalInt("nametag", 1)
		SetGlobalInt("jobtag", 1)
		SetGlobalInt("globalshow", 0)
		SetGlobalInt("deathnotice", 1)
	end
	CfgVars["refreshglobals"] = 1
	timer.Simple(30, refwait)
end

function VerifyGlobals(ply)
	if not (ply:IsAdmin() or ply:IsSuperAdmin()) then
		ply:PrintMessage(2, "Must be an Admin to refresh the Global Variables!")
		return
	else
		local nick = ""
		if ply:EntIndex() == 0 then
			nick = "Console"
		else
			nick = ply:Nick()
		end
		NotifyAll(0, 6, nick .. " refreshed the Global Variables.")
		RefreshGlobals()
	end
end
concommand.Add("refresh_int", VerifyGlobals)

function refwait()
	CfgVars["refreshglobals"] = 0
end

function GM:PhysgunPickup(ply, ent)
	if ent:IsPlayer() or ent:IsDoor() then return false end

	local class = ent:GetClass()

	if ply:IsAdmin() or ply:IsSuperAdmin() then return true end

	if class ~= "func_physbox" and class ~= "prop_physics" and class ~= "prop_physics_multiplayer" and
		class ~= "prop_vehicle_prisoner_pod" then
		return false
	end
	return true
end

function GM:PlayerSpawnProp(ply, model)
	if not self.BaseClass:PlayerSpawnProp(ply, model) then return false end

	local allowed = false

	if ply:GetTable().Arrested then return false end

	-- Banned props take precedence over allowed props
	if CfgVars["banprops"] == 1 then
		for k, v in pairs(BannedProps) do
			if v == model then return false end
		end
	end

	-- If prop spawning is enabled or the user has admin or prop privileges
	if CfgVars["propspawning"] == 1 or ply:IsAdmin() or ply:IsSuperAdmin() then
		-- If we are specifically allowing certain props, if it's not in the list, allowed will remain false
		if CfgVars["allowedprops"] == 1 then
			for k, v in pairs(AllowedProps) do
				if v == model then allowed = true end
			end
		else
			-- allowedprops is not enabled, so assume that if it wasn't banned above, it's allowed
			allowed = true
		end
	end

	if allowed then
		if CfgVars["proppaying"] == 1 then
			if ply:CanAfford(CfgVars["propcost"]) then
				Notify(ply, 1, 4, "Deducted " .. CUR .. CfgVars["propcost"])
				ply:AddMoney(-CfgVars["propcost"])
				return true
			else
				Notify(ply, 1, 4, "Need " .. CUR .. CfgVars["propcost"])
				return false
			end
		else
			return true
		end
	else
		return false
	end
end

function GM:PlayerSpawnSENT(ply, model)
	return self.BaseClass:PlayerSpawnSENT(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnSWEP(ply, model)
	return self.BaseClass:PlayerSpawnSWEP(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnEffect(ply, model)
	return self.BaseClass:PlayerSpawnEffect(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnVehicle(ply, model)
	return self.BaseClass:PlayerSpawnVehicle(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnNPC(ply, model)
	return self.BaseClass:PlayerSpawnNPC(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnRagdoll(ply, model)
	return self.BaseClass:PlayerSpawnRagdoll(ply, model) and not ply:GetTable().Arrested
end

function GM:PlayerSpawnedProp(ply, model, ent)
	self.BaseClass:PlayerSpawnedProp(ply, model, ent)
	ent.SID = ply.SID
end

function GM:PlayerSpawnedSWEP(ply, model, ent)
	self.BaseClass:PlayerSpawnedSWEP(ply, model, ent)
	ent.SID = ply.SID
end

function GM:PlayerSpawnedRagdoll(ply, model, ent)
	self.BaseClass:PlayerSpawnedRagdoll(ply, model, ent)
	ent.SID = ply.SID
end

function GM:SetupMove(ply, move)
	if ply == nil or not ply:Alive() then
		return
	end

	if ply:Crouching() then
		move:SetMaxClientSpeed(CfgVars["cspd"])
		return
	end

	if ply:GetTable().Arrested then
		move:SetMaxClientSpeed(CfgVars["aspd"])
		return
	end

	if ply:KeyDown(IN_SPEED) then
		local t = ply:Team()
		if t == TEAM_POLICE or ply:Team() == TEAM_CHIEF then
			local faster = CfgVars["rspd"] + 8
			move:SetMaxClientSpeed(faster)
		else
			move:SetMaxClientSpeed(CfgVars["rspd"])
			return
		end
	elseif ply:GetVelocity():Length() > 10 then
		move:SetMaxClientSpeed(CfgVars["wspd"])
		return
	end
end

function GM:ShowSpare1(ply)
	umsg.Start("ToggleClicker", ply)
	umsg.End()
end

function GM:ShowSpare2(ply)
	local trace = ply:GetEyeTrace()

	if IsValid(trace.Entity) and trace.Entity:IsOwnable() and ply:GetPos():Distance(trace.Entity:GetPos()) < 115 then
		if ply:GetTable().Arrested then
			Notify(ply, 1, 5, "Can not own or unown things while arrested!")
			return
		end

		if trace.Entity:GetNWBool("nonOwnable") then
			Notify(ply, 1, 5, "This Door can not be owned or unowned!")
			return
		end

		if trace.Entity:OwnedBy(ply) then
			Notify(ply, 1, 4, "Sold for " .. CUR .. math.floor(((CfgVars["doorcost"] * 0.66666666666666)+0.5)) .. "!")
			trace.Entity:Fire("unlock", "", 0)
			trace.Entity:UnOwn(ply)
			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = nil
			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz - 1
			ply:AddMoney(math.floor(((CfgVars["doorcost"] * 0.66666666666666)+0.5)))
		else
			if trace.Entity:IsOwned() and not trace.Entity:AllowedToOwn(ply) then
				Notify(ply, 1, 4, "Already owned!")
				return
			end
			if trace.Entity:GetClass() == "prop_vehicle_jeep" or trace.Entity:GetClass() == "prop_vehicle_airboat" then
				if not ply:CanAfford(CfgVars["vehiclecost"]) then
					Notify(ply, 1, 4, "You can not afford this vehicle!")
					return
				end
			else
				if not ply:CanAfford(CfgVars["doorcost"]) then
					Notify(ply, 1, 4, "You can not afford this door!")
					return
				end
			end

			if trace.Entity:GetClass() == "prop_vehicle_jeep" or trace.Entity:GetClass() == "prop_vehicle_airboat" then
				ply:AddMoney(-CfgVars["vehiclecost"])
				Notify(ply, 1, 4, "You've bought this vehicle for " .. CUR .. math.floor(CfgVars["vehiclecost"]) .. "!")
			else
				ply:AddMoney(-CfgVars["doorcost"])
				Notify(ply, 1, 4, "You've bought this door for " .. CUR .. math.floor(CfgVars["doorcost"]) .. "!")
			end
			trace.Entity:Own(ply)

			if ply:GetTable().OwnedNumz == 0 then
				timer.Create(ply:SteamID() .. "propertytax", 270, 0, function() ply:DoPropertyTax() end)
			end

			ply:GetTable().OwnedNumz = ply:GetTable().OwnedNumz + 1

			ply:GetTable().Ownedz[trace.Entity:EntIndex()] = trace.Entity
		end
	end
end

function GM:OnNPCKilled(victim, ent, weapon)
	-- If something killed the npc
	if ent then
		if ent:IsVehicle() and ent:GetDriver():IsPlayer() then ent = ent:GetDriver() end

		-- if it wasn't a player directly, find out who owns the prop that did the killing
		if not ent:IsPlayer() then
			ent = FindPlayerBySID(ent.SID)
		end

		-- if we know by now who killed the NPC, pay them.
		if ent and CfgVars["npckillpay"] > 0 then
			ent:AddMoney(CfgVars["npckillpay"])
			Notify(ent, 1, 4, CUR .. CfgVars["npckillpay"] .. " For killing an NPC!")
		end
	end
end

function GM:KeyPress(ply, code)
	self.BaseClass:KeyPress(ply, code)

	if code == IN_USE then
		local trace = {}
		trace.start = ply:EyePos()
		trace.endpos = trace.start + ply:GetAimVector() * 95
		trace.filter = ply
		local tr = util.TraceLine(trace)

		if IsValid(tr.Entity) and not ply:KeyDown(IN_ATTACK) then
			if tr.Entity:GetTable().Letter then
				umsg.Start("ShowLetter", ply)
					umsg.Short(tr.Entity:GetNWInt("type"))
					umsg.Vector(tr.Entity:GetPos())
					local numParts = tr.Entity:GetNWInt("numPts")
					umsg.Short(numParts)
					for k=1, numParts do umsg.String(tr.Entity:GetNWString("part" .. tostring(k))) end
				umsg.End()
			end

			if tr.Entity:GetTable().MoneyBag then
				Notify(ply, 0, 4, "You found " .. CUR .. tr.Entity:GetTable().Amount .. "!")
				ply:AddMoney(tr.Entity:GetTable().Amount)
				tr.Entity:Remove()
			end
		else
			umsg.Start("KillLetter", ply)
			umsg.End()
		end
	end
end

function MayorSetSalary(ply, cmd, args)
	if ply:EntIndex() == 0 then
		Msg("Console should use rp_setsalary instead.\n")
		return
	end

	if CfgVars["mayorsetsalary"] == 0 then
		ply:PrintMessage(2, "Mayor SetSalary disabled by Admin!")
		Notify(ply, 1, 4, "Mayor SetSalary disabled by Admin!")
		return "Mayor SetSalary disabled by Admin!"
	end

	if ply:Team() ~= TEAM_MAYOR then
		ply:PrintMessage(2, "You must be the Mayor to use this function!")
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if not amount or amount < 0 then
		ply:PrintMessage(2, "Invalid Salary: " .. args[2])
		return
	end

	if amount > GetGlobalInt("mayorsetsalary") then
		ply:PrintMessage(2, "Salary must be less than or equal to " .. CUR .. CfgVars["maxmayorsetsalary"] .."!")
		return
	end

	local plynick = ply:Nick()
	local target = FindPlayer(args[1])

	if target then
		local targetteam = target:Team()
		local targetnick = target:Nick()

		if targetteam == TEAM_MAYOR then
			Notify(ply, 1, 4, "Can not set your own salary!")
			return
		elseif targetteam == TEAM_POLICE or targetteam == TEAM_CHIEF then
			if amount > GetGlobalInt("maxcopsalary") then
				Notify(ply, 1, 4, "Civil Protection salary limit: " .. CUR .. GetGlobalInt("maxcopsalary") .. "!")
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_CITIZEN or targetteam == TEAM_GUN or targetteam == TEAM_MEDIC or targetteam == TEAM_COOK then
			if amount > GetGlobalInt("maxnormalsalary") then
				Notify(ply, 1, 4, "Normal Player salary limit: " .. CUR .. GetGlobalInt("maxnormalsalary") .. "!")
				return
			else
				DB.StoreSalary(target, amount)
				ply:PrintMessage(2, "Set " .. targetnick .. "'s Salary to: " .. CUR .. amount)
				target:PrintMessage(2, plynick .. " set your Salary to: " .. CUR .. amount)
			end
		elseif targetteam == TEAM_GANG or targetteam == TEAM_MOB then
			Notify(ply, 1, 4, "Mayor can not set the salary of a Mob Boss or a Gang member.")
			return
		end
	else
		ply:PrintMessage(2, "Could not find player: " .. args[1])
	end
	return
end
concommand.Add("mayor_setsalary", MayorSetSalary)
