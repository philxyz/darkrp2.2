include("player_row.lua")
include("player_frame.lua")

SetGlobalString("servertype", "Listen")
surface.CreateFont("ScoreboardHeader",
{
	font = "coolvetica",
	size = 32,
	weight = 500,
	antialias = true
})
surface.CreateFont("ScoreboardSubtitle",
{
	font = "coolvetica",
	size = 20,
	weight = 500,
	antialias = true
})

local texGradient = surface.GetTextureID("gui/center_gradient")

local PANEL = {}
PANEL.PanelColor = Color(255, 255, 255, 98)
PANEL.PanelColor2 = Color(0, 0, 0, 98)
PANEL.PanelColor3 = Color(0, 0, 0, 200)
PANEL.PanelColor4 = Color(0, 0, 0, 255)

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Init()
	SCOREBOARD = self

	self.Hostname = vgui.Create("DLabel", self)
	self.Hostname:SetText(GetGlobalString("ServerName"))

	self.Description = vgui.Create("DLabel", self)
	self.Description:SetText("DarkRP by Rickster, Updated: Pcwizdan, Sibre, philxyz, [GNC] Matt")

	self.PlayerFrame = vgui.Create("PlayerFrame", self)

	self.PlayerRows = {}

	self:UpdateScoreboard()

	-- Update the scoreboard every 1 second
	local me = self
	timer.Create("ScoreboardUpdater", 1, 0, function() me.UpdateScoreboard(me) end)

	self.lblJob = vgui.Create("DLabel", self)
	self.lblJob:SetText("Job")

	self.lblPing = vgui.Create("DLabel", self)
	self.lblPing:SetText("Ping")
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow(ply)
	local button = vgui.Create("ScorePlayerRow", self.PlayerFrame:GetCanvas())
	button:SetPlayer(ply)
	self.PlayerRows[ ply ] = button
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow(ply)
	return self.PlayerRows[ ply ]
end

/*---------------------------------------------------------
Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), self.PanelColor)
	surface.SetTexture(texGradient)
	surface.SetDrawColor(50, 50, 50, 50)
	surface.DrawTexturedRect(0, 0, self:GetWide(), self:GetTall())

	-- White Inner Box
	draw.RoundedBox(4, 4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4, self.PanelColor2)
	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 50)
	surface.DrawTexturedRect(4, self.Description.y - 4, self:GetWide() - 8, self:GetTall() - self.Description.y - 4)

	-- Sub Header
	draw.RoundedBox(4, 5, self.Description.y - 3, self:GetWide() - 10, self.Description:GetTall() + 5, self.PanelColor3)
	surface.SetTexture(texGradient)
	surface.SetDrawColor(0, 0, 0, 50)
	surface.DrawTexturedRect(4, self.Description.y - 4, self:GetWide() - 8, self.Description:GetTall() + 8)
end

/*---------------------------------------------------------
Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()
	self:SetSize(800, ScrH() * 0.95)
	self:SetPos((ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2)

	self.Hostname:SizeToContents()
	self.Hostname:SetPos(16, 16)

	self.Description:SizeToContents()
	self.Description:SetPos(16, 64)

	self.PlayerFrame:SetPos(5, self.Description.y + self.Description:GetTall() + 20)
	self.PlayerFrame:SetSize(self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 10)

	local y = 0

	local PlayerSorted = {}

	for k, v in pairs(self.PlayerRows) do
		table.insert(PlayerSorted, v)
	end

	table.sort(PlayerSorted, function (a , b) return a:HigherOrLower(b) end)

	for k, v in ipairs(PlayerSorted) do
		v:SetPos(0, y)
		v:SetSize(self.PlayerFrame:GetWide(), v:GetTall())

		self.PlayerFrame:GetCanvas():SetSize(self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall())
		y = y + v:GetTall() + 1
	end

	self.Hostname:SetText(GetGlobalString("ServerName"))

	self.lblPing:SizeToContents()
	self.lblJob:SizeToContents()

	self.lblPing:SetPos(self:GetWide() - 50 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
	self.lblJob:SetPos(self:GetWide() - 50*7 - self.lblJob:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3)
end

/*---------------------------------------------------------
Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.Hostname:SetFont("ScoreboardHeader")
	self.Description:SetFont("ScoreboardSubtitle")

	self.Hostname:SetFGColor(self.PanelColor3)
	self.Description:SetFGColor(color_white)

	self.lblPing:SetFont("Default")
	self.lblJob:SetFont("Default")

	self.lblPing:SetFGColor(self.PanelColor4)
	self.lblJob:SetFGColor(self.PanelColor4)
end

function PANEL:UpdateScoreboard(force)
	if not force and not self:IsVisible() then return end

	for k, v in pairs(self.PlayerRows) do
		if not IsValid(k) then
			v:Remove()
			self.PlayerRows[k] = nil
		end
	end

	local PlayerList = player.GetAll()
	for id, pl in pairs(PlayerList) do
		if not self:GetPlayerRow(pl) then
			self:AddPlayerRow(pl)
		end
	end

	-- Always invalidate the layout so the order gets updated
	self:InvalidateLayout()
end

vgui.Register("ScoreBoard", PANEL, "Panel")
