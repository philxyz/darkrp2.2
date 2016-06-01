local HelpPanel = {}
local LastChatPrefix = ""

HelpPanel.Color1 = Color(255, 255, 255, 200)
HelpPanel.Color2 = Color(255, 255, 255, 255)
HelpPanel.Color3 = Color(150, 50, 50, 255)
HelpPanel.Color4 = Color(0, 0, 0, 150)

function HelpPanel:Init()
	self.StartHelpX = -ScrW()
	self.HelpX = self.StartHelpX

	self.title = vgui.Create("DLabel", self)
	self.title:SetText("DarkRP " .. DARKRP_VERSION)

	self.modinfo = vgui.Create("DLabel", self)
	self.modinfo:SetText("Get the mod at garrysmod.org!")

	self.scrolltext = vgui.Create("DLabel", self)
	self.scrolltext:SetText("Use mousewheel to scroll")

	self.HelpInfo = vgui.Create("Panel", self)

	self.vguiHelpCategories = {}
	self.vguiHelpLabels = {}
	self.Scroll = 0
end

function HelpPanel:FillHelpInfo(force)
	local maxpertable = 11
	local helptable = 1
	local yoffset = 0

	if force then
		for k, v in pairs(self.vguiHelpCategories) do
			v:Remove()
			self.vguiHelpCategories[k] = nil
		end
		for k, v in pairs(self.vguiHelpLabels) do
			v:Remove()
			self.vguiHelpLabels[k] = nil
		end
	end

	for k, v in pairs(HelpCategories) do
		if not self.vguiHelpCategories[v.id] or force then
			local helptext = ""
			local Labels = { }

			self.vguiHelpCategories[v.id] = vgui.Create("DLabel", self.HelpInfo)
			self.vguiHelpCategories[v.id]:SetText(v.text)
			self.vguiHelpCategories[v.id].OrigY = yoffset
			self.vguiHelpCategories[v.id]:SetPos(5, yoffset)
			self.vguiHelpCategories[v.id]:SetFont("GModToolSubtitle")
			self.vguiHelpCategories[v.id]:SetFGColor(HelpPanel.Color1)

			for n, m in pairs(HelpLabels) do
				if m.category == v.id then
					table.insert(Labels, m.text)
				end
			end

			local index = 1
			local HelpText = { }

			for i = 1, math.ceil(#Labels / maxpertable) do
				for n = index, maxpertable * i do
					if n > #Labels then break end
					if not HelpText[i] then HelpText[i] = "" end
					HelpText[i] = HelpText[i] .. Labels[n] .. "\n"
				end

				index = index + maxpertable
			end

			local labelh = GetTextHeight("ChatFont", "A")

			for i = 1, #HelpText do
				self.vguiHelpLabels[i + v.id * 100] = vgui.Create("DLabel", self.HelpInfo)
				self.vguiHelpLabels[i + v.id * 100]:SetText(HelpText[i])
				self.vguiHelpLabels[i + v.id * 100].OrigY = yoffset + 25 + (i - 1) * (maxpertable * labelh)
				self.vguiHelpLabels[i + v.id * 100]:SetPos(5, yoffset + 25 + (i - 1) * (maxpertable * labelh))
				self.vguiHelpLabels[i + v.id * 100]:SetFont("ChatFont")
				self.vguiHelpLabels[i + v.id * 100]:SetFGColor(HelpPanel.Color1)
			end

			local cath = GetTextHeight("GModToolSubtitle", "A")

			yoffset = yoffset + (cath + 15) + #Labels * labelh
		end
	end
end

function HelpPanel:PerformLayout()
	self:FillHelpInfo()
	self:SetSize(-self.StartHelpX, ScrH() - 70)

	for k, v in pairs(self.vguiHelpCategories) do
		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	for k, v in pairs(self.vguiHelpLabels) do
		v:SetPos(5, v.OrigY - self.Scroll)
		v:SizeToContents()
	end

	self.HelpInfo:SetPos(5, 70)
	self.HelpInfo:SetSize(self:GetWide() - 5, self:GetTall() - 5)

	self.title:SetPos(5, 5)
	self.title:SizeToContents()

	self.modinfo:SetPos(5, 50)
	self.modinfo:SizeToContents()

	self.scrolltext:SetPos(250, 25)
	self.scrolltext:SizeToContents()
end

function HelpPanel:ApplySchemeSettings()
	self.title:SetFont("GModToolName")
	self.title:SetFGColor(HelpPanel.Color2)

	self.modinfo:SetFont("TargetID")
	self.modinfo:SetFGColor(HelpPanel.Color2)

	self.scrolltext:SetFont("GModToolSubtitle")
	self.scrolltext:SetFGColor(HelpPanel.Color3)
end

function HelpPanel:OnMouseWheeled(delta)
	self.Scroll = math.Clamp(self.Scroll - delta * FrameTime() * 2000, 0, math.Clamp((#HelpCategories * 25 + #HelpLabels * 14) - 400, 0, 99999))
	self:InvalidateLayout()
end

function HelpPanel:Paint()
	draw.RoundedBox(4, 0, 0, self:GetWide(), self:GetTall(), HelpPanel.Color4)
end

function HelpPanel:Think()
	if self.HelpX < 0 then
		self.HelpX = self.HelpX + 600 * FrameTime()
	end

	if self.HelpX > 0 then
		self.HelpX = 0
	end

	self:SetPos(self.HelpX, 20)
end

vgui.Register("HelpVGUI", HelpPanel, "Panel")
