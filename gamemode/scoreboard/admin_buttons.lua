local PANEL = {}
PANEL.BgColorDefault = Color(0, 0, 0, 10)
PANEL.Color1 = Color(0, 200, 255, 255)
PANEL.Color2 = Color(255, 255, 0, 255)
PANEL.Color3 = Color(0, 0, 0, 150)

/*---------------------------------------------------------
Name:
---------------------------------------------------------*/
function PANEL:DoClick()
	if not self:GetParent().Player or LocalPlayer() == self:GetParent().Player then return end

	self:DoCommand(self:GetParent().Player)
	timer.Simple(0.1, function() SCOREBOARD.UpdateScoreboard(SCOREBOARD) end)
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	local bgColor = self.BgColorDefault

	if self.Selected then
		bgColor = self.Color1
	elseif self.Armed then
		bgColor = self.Color2
	end

	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), bgColor)
	draw.SimpleText(self.Text, "Default", self:GetWide() / 2, self:GetTall() / 2, self.Color3, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	return true
end

vgui.Register("SpawnMenuAdminButton", PANEL, "Button")

/*   PlayerKickButton */

PANEL = {}
PANEL.Text = "Kick"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	LocalPlayer():ConCommand("kickid ".. ply:UserID().. " Kicked By "..LocalPlayer():Nick().."\n")
end

vgui.Register("PlayerKickButton", PANEL, "SpawnMenuAdminButton")

/*   PlayerPermBanButton */

PANEL = {}
PANEL.Text = "PermBan"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	LocalPlayer():ConCommand("banid 0 ".. self:GetParent().Player:UserID().. "\n")
	LocalPlayer():ConCommand("kickid ".. ply:UserID().. " Permabanned By "..LocalPlayer():Nick().."\n")
end

vgui.Register("PlayerPermBanButton", PANEL, "SpawnMenuAdminButton")

/*   PlayerPermBanButton */

PANEL = {}
PANEL.Text = "1HRBan"

/*---------------------------------------------------------
Name: DoCommand
---------------------------------------------------------*/
function PANEL:DoCommand(ply)
	LocalPlayer():ConCommand("banid 60 ".. self:GetParent().Player:UserID().. "\n")
	LocalPlayer():ConCommand("kickid ".. ply:UserID().. " Banned for 1 hour By "..LocalPlayer():Nick().."\n")
end

vgui.Register("PlayerBanButton", PANEL, "SpawnMenuAdminButton")
