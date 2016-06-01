local function GiveHint()
	local hint = math.random(1, 37)

	if hint == 1 then
		PrintMessageAll(HUD_PRINTTALK , "Roleplay according to the Server Rules!")
	elseif hint == 2 then
		PrintMessageAll(HUD_PRINTTALK , "You can be arrested for buying or owning an illegal weapon!")
	elseif hint == 3 then
		PrintMessageAll(HUD_PRINTTALK , "Type /sleep to fall asleep. (Extra weapons will be lost!)")
	elseif hint == 4 then
		PrintMessageAll(HUD_PRINTTALK , "You may own a handgun, but use it only in self defence.")
	elseif hint == 5 then
		PrintMessageAll(HUD_PRINTTALK , "Press F2 to see server rules and view special commands.")
	elseif hint == 6 then
		PrintMessageAll(HUD_PRINTTALK , "All weapons are very inaccurate, unless you right click to see through the sight post.")
	elseif hint == 7 then
		PrintMessageAll(HUD_PRINTTALK , "If you are a cop, do your job properly or you could get demoted.")
	elseif hint == 8 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buyshipment <Weapon name> to buy a shipment of weapons (e.g: /buyshipment ak47).")
	elseif hint == 9 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buypistol <Pistol name> to buy a pistol, e.g: /buypistol glock.")
	elseif hint == 10 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buyammo <Ammo type> to buy ammo. Ammo types are: [rifle | shotgun | pistol]")
	elseif hint == 11 then
		PrintMessageAll(HUD_PRINTTALK , "If you wish to bail a friend out of jail, go to your designated Police Department and negotiate!")
	elseif hint == 12 then
		PrintMessageAll(HUD_PRINTTALK , "Press F1 to see RP help.")
	elseif hint == 13 then
		PrintMessageAll(HUD_PRINTTALK , "If you get arrested, don't worry - you will be auto unarrested in " .. GetGlobalInt("jailtimer") .. " seconds.")
	elseif hint == 14 then
		PrintMessageAll(HUD_PRINTTALK , "If you are a chief or admin, type /jailpos or /addjail to set the positions of the first (and extra) jails.")
	elseif hint == 15 then
		PrintMessageAll(HUD_PRINTTALK , "You will be teleported to jail if you get arrested!")
	elseif hint == 16 then
		PrintMessageAll(HUD_PRINTTALK , "If you see someone with an illegal weapon, arrest them and confiscate it.")
	elseif hint == 17 then
		PrintMessageAll(HUD_PRINTTALK , "Type /sleep to fall asleep.")
	elseif hint == 18 then
		PrintMessageAll(HUD_PRINTTALK , "Your money and RP name are saved by the server.")
	elseif hint == 19 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buyhealth to refil your health to 100%")
	elseif hint == 20 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buydruglab to buy a druglab. It makes you " .. CUR .. GetGlobalInt("drugpayamount") .. " per minute.")
	elseif hint == 21 then
		PrintMessageAll(HUD_PRINTTALK , "Press F2 to see the server rules and view special commands.")
	elseif hint == 22 then
		PrintMessageAll(HUD_PRINTTALK , "You will be teleported to a jail if you get arrested!")
	elseif hint == 23 then
		PrintMessageAll(HUD_PRINTTALK , "Type /price <Price> while looking at a Gun Lab or a Microwave to set the customer purchase price.")
	elseif hint == 24 then
		PrintMessageAll(HUD_PRINTTALK , "Type /warrant [Nick|SteamID|UserID] to get a search warrant for a player.")
	elseif hint == 25 then
		PrintMessageAll(HUD_PRINTTALK , "Type /wanted or /unwanted [Nick|SteamID|UserID] to set a player as wanted/unwanted by the Police.")
	elseif hint == 26 then
		PrintMessageAll(HUD_PRINTTALK , "Type /drop to drop the weapon you are holding.")
	elseif hint == 27 then
		PrintMessageAll(HUD_PRINTTALK , "Type /gangster to become a Gangster.")
	elseif hint == 28 then
		PrintMessageAll(HUD_PRINTTALK , "Type /mobboss to become a Mob Boss.")
	elseif hint == 29 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buymicrowave to buy a Microwave Oven that spawns food.")
	elseif hint == 30 then
		PrintMessageAll(HUD_PRINTTALK , "Type /dropmoney <Amount> to drop a money amount.")
	elseif hint == 31 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buymoneyprinter to buy a Money Printer. Costs " .. CUR .. GetGlobalInt("mprintercost"))
	elseif hint == 32 then
		PrintMessageAll(HUD_PRINTTALK , "Type /medic - To become a Medic.")
	elseif hint == 33 then
		PrintMessageAll(HUD_PRINTTALK , "Type /gundealer - To become a Gun Dealer.")
	elseif hint == 34 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buygunlab - to buy a Gun Lab.")
	elseif hint == 35 then
		PrintMessageAll(HUD_PRINTTALK , "Type /cook - to become a Cook.")
	elseif hint == 36 then
		PrintMessageAll(HUD_PRINTTALK , "Type /cophelp to see what you need to do as a cop.")
	elseif hint == 37 then
		PrintMessageAll(HUD_PRINTTALK , "Type /buyfood <Type> (e.g: /buyfood melon)")
	end
end

timer.Create("hints", 60, 0, GiveHint)
