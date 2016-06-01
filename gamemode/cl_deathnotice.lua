local hud_deathnotice_time = CreateConVar("hud_deathnotice_time", "6", FCVAR_REPLICATED)

-- These are our kill icons
local Color_Icon = Color(255, 80, 0, 255)
local NPC_Color = Color(250, 50, 50, 255)

killicon.AddFont("prop_physics", "HL2MPTypeDeath", "9", Color_Icon)
killicon.AddFont("weapon_smg1", "HL2MPTypeDeath", "/", Color_Icon)
killicon.AddFont("weapon_357", "HL2MPTypeDeath", ".", Color_Icon)
killicon.AddFont("weapon_ar2", "HL2MPTypeDeath", "2", Color_Icon)
killicon.AddFont("crossbow_bolt", "HL2MPTypeDeath", "1", Color_Icon)
killicon.AddFont("weapon_shotgun", "HL2MPTypeDeath", "0", Color_Icon)
killicon.AddFont("rpg_missile", "HL2MPTypeDeath", "3", Color_Icon)
killicon.AddFont("npc_grenade_frag", "HL2MPTypeDeath", "4", Color_Icon)
killicon.AddFont("weapon_pistol", "HL2MPTypeDeath", "-", Color_Icon)
killicon.AddFont("prop_combine_ball", "HL2MPTypeDeath", "8", Color_Icon)
killicon.AddFont("grenade_ar2", "HL2MPTypeDeath", "7", Color_Icon)
killicon.AddFont("weapon_stunstick", "HL2MPTypeDeath", "!", Color_Icon)
killicon.AddFont("weapon_slam", "HL2MPTypeDeath", "*", Color_Icon)
killicon.AddFont("weapon_crowbar", "HL2MPTypeDeath", "6", Color_Icon)

local Deaths = {}

local function PlayerIDOrNameToString(var)
	if type(var) == "string" then
		if var == "" then return "" end
		return "#" .. var
	end
	local ply = Entity(var)
	if not IsValid(ply) then return "NULL!" end
	return ply:Name()
end

local function RecvPlayerKilledByPlayer(message)
	local victim = message:ReadEntity()
	local inflictor = message:ReadString()
	local attacker = message:ReadEntity()
	if IsValid(victim) and IsValid(attacker) then
		GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim:Name(), victim:Team())
	end
end
usermessage.Hook("PlayerKilledByPlayer", RecvPlayerKilledByPlayer)

local function RecvPlayerKilledSelf(message)
	local victim = message:ReadEntity()
	if IsValid(victim) then
		GAMEMODE:AddDeathNotice(nil, 0, "suicide", victim:Name(), victim:Team())
	end
end
usermessage.Hook("PlayerKilledSelf", RecvPlayerKilledSelf)

local function RecvPlayerKilled(message)
	local victim = message:ReadEntity()
	local inflictor = message:ReadString()
	local attacker = "#" .. message:ReadString()
	if IsValid(victim) then
		GAMEMODE:AddDeathNotice(attacker, -1, inflictor, victim:Name(), victim:Team())
	end
end
usermessage.Hook("PlayerKilled", RecvPlayerKilled)

local function RecvPlayerKilledNPC(message)
	local victim = "#" .. message:ReadString()
	local inflictor = message:ReadString()
	local attacker = message:ReadEntity()
	if IsValid(attacker) then
		GAMEMODE:AddDeathNotice(attacker:Name(), attacker:Team(), inflictor, victim, -1)
	end
end
usermessage.Hook("PlayerKilledNPC", RecvPlayerKilledNPC)

local function RecvNPCKilledNPC(message)
	local victim = "#" .. message:ReadString()
	local inflictor = message:ReadString()
	local attacker = "#" .. message:ReadString()
	GAMEMODE:AddDeathNotice(attacker, -1, inflictor, victim, -1)
end
usermessage.Hook("NPCKilledNPC", RecvNPCKilledNPC)

--   Name: gamemode:AddDeathNotice(Victim, Attacker, Weapon)
--   Desc: Adds an death notice entry
function GM:AddDeathNotice(Victim, team1, Inflictor, Attacker, team2)
	local Death = {}
	Death.victim = Victim
	Death.attacker = Attacker
	Death.time = CurTime()
	Death.left = Victim
	Death.right = Attacker
	Death.icon = Inflictor

	if team1 == -1 then
		Death.color1 = table.Copy(NPC_Color)
	else
		Death.color1 = table.Copy(team.GetColor(team1))
	end

	if team2 == -1 then
		Death.color2 = table.Copy(NPC_Color)
	else
		Death.color2 = table.Copy(team.GetColor(team2))
	end

	if Death.left == Death.right then
		Death.left = nil
		Death.icon = "suicide"
	end
	table.insert( Deaths, Death )
end

local function DrawDeath(x, y, death, hud_deathnotice_time)
	local w, h = killicon.GetSize(death.icon)
	local fadeout = (death.time + hud_deathnotice_time) - CurTime()
	local alpha = math.Clamp(fadeout * 255, 0, 255)

	death.color1.a = alpha
	death.color2.a = alpha

	-- Draw Icon
	killicon.Draw(x, y, death.icon, alpha)

	-- Draw KILLER
	if death.left then draw.SimpleText(death.left, "ChatFont", x - (w/2) - 16, y, death.color1, TEXT_ALIGN_RIGHT) end

	-- Draw VICTIM
	draw.SimpleText(death.right, "ChatFont", x + (w/2) + 16, y, death.color2, TEXT_ALIGN_LEFT)
	return y + h * 0.70
end

function GM:DrawDeathNotice(x, y)
	if GetGlobalInt("deathnotice") ~= 1 then return end
	local hud_deathnotice_time = hud_deathnotice_time:GetFloat()

	x = x * ScrW()
	y = y * ScrH()

	-- Draw
	for k, Death in pairs(Deaths) do
		if Death.time + hud_deathnotice_time > CurTime() then
			if Death.lerp then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end

			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y

			y = DrawDeath(x, y, Death, hud_deathnotice_time)
		end
	end

	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for k, Death in pairs(Deaths) do
		if Death.time + hud_deathnotice_time > CurTime() then
			return
		end
	end

	Deaths = {}
end
