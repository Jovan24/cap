/*
	Stargate for GarrysMod10
	Copyright (C) 2007  aVoN

	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

--##################################
--###### SControlePanelGate_Group.lua
--##################################

local PANEL = {};
-- To store the mousepos accross sessions
PANEL.Data = {}

--##################################
--###### The Gate Panel (Added by Assassin21)
--##################################

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(225,210);
	self:SetMinimumSize(225,210);
	self:SetPos(10,10);
	--self:Center(); -- Center is gay!
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressPanel = vgui.Create("SAddressPanel_Group",self),
		AddressLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		NameTextEntry = vgui.Create("DTextEntry",self),
		NameLabel = vgui.Create("DLabel",self),
		PrivateImage = vgui.Create("DImage",self),
		PrivateCheckbox = vgui.Create("DCheckBoxLabel",self),
		LocaleCheckbox = vgui.Create("DCheckBoxLabel",self),
		BlockedCheckbox = vgui.Create("DCheckBoxLabel",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(Language.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetWide(200);
	self.VGUI.TitleLabel:SetPos(30,7);
	--###### Set Address
	-- The Topic of this section
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressLabel[i]:SetText(Language.GetMessage("stargate_vgui_settings"));
		self.VGUI.AddressLabel[i]:SetWide(200);
		self.VGUI.AddressLabel[i]:SetPos(30-mul*2,35-mul*2);
		self.VGUI.AddressLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Our AddressPanel (Where we set Addresses with)
	self.VGUI.AddressPanel:SetPos(30,60);
	self.VGUI.AddressPanel.OnAddressSet = function(e,address,group)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateAddress(address);
			e:SetGateGroup(group);
		end
	end
	--###### Name
	-- Name Label
	self.VGUI.NameLabel:SetPos(30,133);
	self.VGUI.NameLabel:SetText(Language.GetMessage("stargate_vgui_name"));

	-- Name TextEntry
	self.VGUI.NameTextEntry:SetPos(75,133);
	self.VGUI.NameTextEntry:SetWide(110);
	self.VGUI.NameTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_nametip"));
	self.VGUI.NameTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.NameTextEntry.OnTextChanged = function(TextEntry)
		local s = TextEntry:GetValue();
		local e = self.Entity;
		local search = self.VGUI.AddressSelect;
		-- Do this within a timer to avoid constant calling of the concommand as soon as someont types in something
		timer.Remove("_StarGate.SetNameTime");
		timer.Create("_StarGate.SetNameTime",1,1,
			function()
				if(IsValid(e)) then
					e:SetGateName(s);
				end
			end
		);
	end

	--###### Private
	-- The Private Image
	self.VGUI.PrivateImage:SetPos(30,165); -- 159
	self.VGUI.PrivateImage:SetSize(16,16);
	self.VGUI.PrivateImage:SetImage("icon16/shield.png");

	-- The Private Checkbox
	self.VGUI.PrivateCheckbox:SetPos(75,160);
	self.VGUI.PrivateCheckbox:SetWide(110);
	self.VGUI.PrivateCheckbox:SetText(Language.GetMessage("stargate_vgui_private"));
	local tip = Language.GetMessage("stargate_vgui_privatetip");
	self.VGUI.PrivateCheckbox:SetTooltip(tip);
	self.VGUI.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.PrivateCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetPrivate(b);
		end
	end

	-- The Local Checkbox
	self.VGUI.LocaleCheckbox:SetPos(75,175);
	self.VGUI.LocaleCheckbox:SetWide(110);
	self.VGUI.LocaleCheckbox:SetText(Language.GetMessage("stargate_vgui_locale"));
	local tip = Language.GetMessage("stargate_vgui_localetip");
	self.VGUI.LocaleCheckbox:SetTooltip(tip);
	self.VGUI.LocaleCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.LocaleCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetLocale(b);
		end
	end

	-- The Blocked Checkbox
	self.VGUI.BlockedCheckbox:SetPos(75,190);
	self.VGUI.BlockedCheckbox:SetWide(150);
	self.VGUI.BlockedCheckbox:SetText(Language.GetMessage("stargate_vgui_blocked"));
	local tip = Language.GetMessage("stargate_vgui_blockedtip");
	self.VGUI.BlockedCheckbox:SetTooltip(tip);
	self.VGUI.BlockedCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.BlockedCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetBlocked(b);
		end
	end

	self:RegisterHooks();
end

--################# Register Hooks @aVoN, AlexALX
function PANEL:RegisterHooks()
	-- This is necessary: Everytime we set this window visible, we will update the address panel and any other necessary object
	self._SetVisible = self.SetVisible;
	self.SetVisible = function(self,b)
		if(b) then
			if(self.OnOpen) then
				local ret = self:OnOpen();
				if(ret ~= nil) then return ret end;
			end
		else
			if(self.OnClose) then
				local ret = self:OnClose();
				if(ret ~= nil) then return ret end;
			end
		end
		self._SetVisible(self,b);
	end
	self._Think = self.Think;
	self.Think = function(self)
		local x,y = gui.MousePos();
		if(x ~= ScrW()/2 and y ~= ScrH() and x > 1 and y > 1) then -- Prevents some resnapping bugs
			self.Data.MouseX,self.Data.MouseY = x,y;
		end
		local x,y = self:GetPos();
		self.Data.PosX, self.Data.PosY = x,y;
		self._Think(self);
	end
	-- for new gmod
	self:MakePopup();
	self:SetSizable(false)
	self:SetDeleteOnClose( false )
	self:SetTitle("")
	self.Logo = vgui.Create("DImage",self);
	self.Logo:SetPos(8,10);
	self.Logo:SetImage("gui/cap_logo");
	self.Logo:SetSize(16,16);
	-- for smaller font from gmod10
	for k,v in pairs(self.VGUI) do
		if (k=="NameTextEntry") then continue end
		if (v.SetFont) then
			v:SetFont("OldDefaultSmall");
		end
		if (v.Label and v.Label.SetFont) then
			v.Label:SetFont("OldDefaultSmall");
		end
		if (type(v)=="table") then
			for k2,v2 in pairs(v) do
				if (v2.SetFont) then
					v2:SetFont("OldDefaultSmall");
				end
			end
		end
	end
end

--################# Open Hook @aVoN
function PANEL:OnOpen()
	self:SetKeyBoardInputEnabled(true);
	self:SetMouseInputEnabled(true);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = nil;
	self:SetAlpha(1); -- We will fade in!
	if(self.Data.MouseX and self.Data.MouseY) then
		gui.SetMousePos(self.Data.MouseX,self.Data.MouseY);
	end
	if (self.Data.PosX!=nil and self.Data.PosY!=nil) then
		self:SetPos(self.Data.PosX,self.Data.PosY);
	end
end

--################# Close Hook @aVoN
function PANEL:OnClose()
	self:SetKeyBoardInputEnabled(false);
	self:SetMouseInputEnabled(false);
	self.AlphaTime = CurTime(); -- For the FadeIn/Out
	self.FadeOut = true;
	return false; -- Override default fadeout
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressPanel:SetEntity(e);
	self.VGUI.NameTextEntry:SetText(e:GetGateName());
	self.VGUI.PrivateCheckbox:SetValue(e:GetPrivate());
	self.VGUI.LocaleCheckbox:SetValue(e:GetLocale());
	if (e:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or e:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and e:GetClass()!="stargate_universe") then
		self.VGUI.BlockedCheckbox:SetVisible(false);
		self.VGUI.PrivateImage:SetPos(30,165);
	else
		self.VGUI.BlockedCheckbox:SetVisible(true);
		self.VGUI.PrivateImage:SetPos(30,172);
		self.VGUI.BlockedCheckbox:SetValue(e:GetBlocked());
	end
end

--################# Paint @aVoN
function PANEL:Paint(w,h)
	-- Fade in!
	local alpha = math.Clamp(CurTime() - (self.AlphaTime or 0),0,0.20)*5;
	if(self.FadeOut) then
		alpha = 1-alpha;
		if(alpha == 0) then
			self:_SetVisible(false);
			self.FadeOut = nil;
		end
	end
	draw.RoundedBox(10,0,0,w,h,Color(16,16,16,160*alpha));
	self:SetAlpha(alpha*255);
	return true;
end

vgui.Register("SControlePanelGate_Group",PANEL,"DFrame");

--##################################
--###### SControlePanelGate_GroupSGU.lua
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--##################################
--###### The Gate Panel (Added by Assassin21)
--##################################

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(225,210);
	self:SetMinimumSize(225,210);
	self:SetPos(10,10);
	--self:Center(); -- Center is gay!
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressPanel = vgui.Create("SAddressPanel_GroupSGU",self),
		AddressLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		NameTextEntry = vgui.Create("DTextEntry",self),
		NameLabel = vgui.Create("DLabel",self),
		PrivateImage = vgui.Create("DImage",self),
		PrivateCheckbox = vgui.Create("DCheckBoxLabel",self),
		LocaleCheckbox = vgui.Create("DCheckBoxLabel",self),
		BlockedCheckbox = vgui.Create("DCheckBoxLabel",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(Language.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetWide(200);
	self.VGUI.TitleLabel:SetPos(30,7);
	--###### Set Address
	-- The Topic of this section
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressLabel[i]:SetText(Language.GetMessage("stargate_vgui_settings"));
		self.VGUI.AddressLabel[i]:SetWide(200);
		self.VGUI.AddressLabel[i]:SetPos(30-mul*2,35-mul*2);
		self.VGUI.AddressLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Our AddressPanel (Where we set Addresses with)
	self.VGUI.AddressPanel:SetPos(30,60);
	self.VGUI.AddressPanel.OnAddressSet = function(e,address,group)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateAddress(address);
			e:SetGateGroup(group);
		end
	end
	--###### Name
	-- Name Label
	self.VGUI.NameLabel:SetPos(30,133);
	self.VGUI.NameLabel:SetText(Language.GetMessage("stargate_vgui_name"));

	-- Name TextEntry
	self.VGUI.NameTextEntry:SetPos(75,133);
	self.VGUI.NameTextEntry:SetWide(110);
	self.VGUI.NameTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_nametip"));
	self.VGUI.NameTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.NameTextEntry.OnTextChanged = function(TextEntry)
		local s = TextEntry:GetValue();
		local e = self.Entity;
		local search = self.VGUI.AddressSelect;
		-- Do this within a timer to avoid constant calling of the concommand as soon as someont types in something
		timer.Remove("_StarGate.SetNameTime");
		timer.Create("_StarGate.SetNameTime",1,1,
			function()
				if(IsValid(e)) then
					e:SetGateName(s);
				end
			end
		);
	end

	--###### Private
	-- The Private Image
	self.VGUI.PrivateImage:SetPos(30,172); -- 159
	self.VGUI.PrivateImage:SetSize(16,16);
	self.VGUI.PrivateImage:SetImage("icon16/shield.png");

	-- The Private Checkbox
	self.VGUI.PrivateCheckbox:SetPos(75,160);
	self.VGUI.PrivateCheckbox:SetWide(110);
	self.VGUI.PrivateCheckbox:SetText(Language.GetMessage("stargate_vgui_private"));
	local tip = Language.GetMessage("stargate_vgui_privatetip");
	self.VGUI.PrivateCheckbox:SetTooltip(tip);
	self.VGUI.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.PrivateCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetPrivate(b);
		end
	end

	-- The Local Checkbox
	self.VGUI.LocaleCheckbox:SetPos(75,175);
	self.VGUI.LocaleCheckbox:SetWide(110);
	self.VGUI.LocaleCheckbox:SetText(Language.GetMessage("stargate_vgui_locale"));
	local tip = Language.GetMessage("stargate_vgui_localetip");
	self.VGUI.LocaleCheckbox:SetTooltip(tip);
	self.VGUI.LocaleCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.LocaleCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetLocale(b);
		end
	end

	-- The Blocked Checkbox
	self.VGUI.BlockedCheckbox:SetPos(75,190);
	self.VGUI.BlockedCheckbox:SetWide(150);
	self.VGUI.BlockedCheckbox:SetText(Language.GetMessage("stargate_vgui_blocked"));
	local tip = Language.GetMessage("stargate_vgui_blockedtip");
	self.VGUI.BlockedCheckbox:SetTooltip(tip);
	self.VGUI.BlockedCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.BlockedCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetBlocked(b);
		end
	end

	self:RegisterHooks();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressPanel:SetEntity(e);
	self.VGUI.NameTextEntry:SetText(e:GetGateName());
	self.VGUI.PrivateCheckbox:SetValue(e:GetPrivate());
	self.VGUI.LocaleCheckbox:SetValue(e:GetLocale());
	if (e:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or e:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and e:GetClass()!="stargate_universe") then
		self.VGUI.BlockedCheckbox:SetVisible(false);
		self.VGUI.PrivateImage:SetPos(30,165);
	else
		self.VGUI.BlockedCheckbox:SetVisible(true);
		self.VGUI.PrivateImage:SetPos(30,172);
		self.VGUI.BlockedCheckbox:SetValue(e:GetBlocked());
	end
end

vgui.Register("SControlePanelGate_GroupSGU",PANEL,"DFrame");

--##################################
--###### SControlePanelGate_Super.lua
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--##################################
--###### The Gate Panel (Added by Assassin21)
--##################################

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(225,210);
	self:SetMinimumSize(225,210);
	self:SetPos(10,10);
	--self:Center(); -- Center is gay!
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressPanel = vgui.Create("SAddressPanel",self),
		AddressLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		NameTextEntry = vgui.Create("DTextEntry",self),
		NameLabel = vgui.Create("DLabel",self),
		PrivateImage = vgui.Create("DImage",self),
		PrivateCheckbox = vgui.Create("DCheckBoxLabel",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(Language.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetWide(200);
	self.VGUI.TitleLabel:SetPos(30,7);
	--###### Set Address
	-- The Topic of this section
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressLabel[i]:SetText(Language.GetMessage("stargate_vgui_settings"));
		self.VGUI.AddressLabel[i]:SetWide(200);
		self.VGUI.AddressLabel[i]:SetPos(30-mul*2,35-mul*2);
		self.VGUI.AddressLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Our AddressPanel (Where we set Addresses with)
	self.VGUI.AddressPanel:SetPos(30,60);
	self.VGUI.AddressPanel.OnAddressSet = function(e,address)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateAddress(address);
		end
	end
	--###### Name
	-- Name Label
	self.VGUI.NameLabel:SetPos(30,103);
	self.VGUI.NameLabel:SetText(Language.GetMessage("stargate_vgui_name"));

	-- Name TextEntry
	self.VGUI.NameTextEntry:SetPos(75,103);
	self.VGUI.NameTextEntry:SetWide(110);
	self.VGUI.NameTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_nametip"));
	self.VGUI.NameTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.NameTextEntry.OnTextChanged = function(TextEntry)
		local s = TextEntry:GetValue();
		local e = self.Entity;
		local search = self.VGUI.AddressSelect;
		-- Do this within a timer to avoid constant calling of the concommand as soon as someont types in something
		timer.Remove("_StarGate.SetNameTime");
		timer.Create("_StarGate.SetNameTime",1,1,
			function()
				if(IsValid(e)) then
					e:SetGateName(s);
				end
			end
		);
	end

	--###### Private
	-- The Private Image
	self.VGUI.PrivateImage:SetPos(30,129);
	self.VGUI.PrivateImage:SetSize(16,16);
	self.VGUI.PrivateImage:SetImage("icon16/shield.png");

	-- The Private Checkbox
	self.VGUI.PrivateCheckbox:SetPos(75,130);
	self.VGUI.PrivateCheckbox:SetWide(110);
	self.VGUI.PrivateCheckbox:SetText(Language.GetMessage("stargate_vgui_private"));
	local tip = Language.GetMessage("stargate_vgui_privatetip");
	self.VGUI.PrivateCheckbox:SetTooltip(tip);
	self.VGUI.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.PrivateCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetPrivate(b);
		end
	end
	self:RegisterHooks();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressPanel:SetEntity(e);
	self.VGUI.NameTextEntry:SetText(e:GetGateName());
	self.VGUI.PrivateCheckbox:SetValue(e:GetPrivate());
end

vgui.Register("SControlePanelSuperGate",PANEL,"DFrame");

--##################################
--###### SControlePanelGate_Galaxy.lua
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(225,210);
	self:SetMinimumSize(225,210);
	self:SetPos(10,10);
	--self:Center(); -- Center is gay!
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressPanel = vgui.Create("SAddressPanel_Galaxy",self),
		AddressLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		NameTextEntry = vgui.Create("DTextEntry",self),
		NameLabel = vgui.Create("DLabel",self),
		PrivateImage = vgui.Create("DImage",self),
		PrivateCheckbox = vgui.Create("DCheckBoxLabel",self),
		GalaxyCheckbox = vgui.Create("DCheckBoxLabel",self),
		BlockedCheckbox = vgui.Create("DCheckBoxLabel",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(Language.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetWide(200);
	self.VGUI.TitleLabel:SetPos(30,7);
	--###### Set Address
	-- The Topic of this section
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressLabel[i]:SetText(Language.GetMessage("stargate_vgui_settings"));
		self.VGUI.AddressLabel[i]:SetWide(200);
		self.VGUI.AddressLabel[i]:SetPos(30-mul*2,35-mul*2);
		self.VGUI.AddressLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Our AddressPanel (Where we set Addresses with)
	self.VGUI.AddressPanel:SetPos(30,60);
	self.VGUI.AddressPanel.OnAddressSet = function(e,address)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateAddress(address);
		end
	end
	--###### Name
	-- Name Label
	self.VGUI.NameLabel:SetPos(30,103);
	self.VGUI.NameLabel:SetText(Language.GetMessage("stargate_vgui_name"));

	-- Name TextEntry
	self.VGUI.NameTextEntry:SetPos(75,103);
	self.VGUI.NameTextEntry:SetWide(110);
	self.VGUI.NameTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_nametip"));
	self.VGUI.NameTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.NameTextEntry.OnTextChanged = function(TextEntry)
		local s = TextEntry:GetValue();
		local e = self.Entity;
		local search = self.VGUI.AddressSelect;
		-- Do this within a timer to avoid constant calling of the concommand as soon as someont types in something
		timer.Remove("_StarGate.SetNameTime");
		timer.Create("_StarGate.SetNameTime",1,1,
			function()
				if(IsValid(e)) then
					e:SetGateName(s);
				end
			end
		);
	end

	--###### Private
	-- The Private Image
	self.VGUI.PrivateImage:SetPos(30,138);
	self.VGUI.PrivateImage:SetSize(16,16);
	self.VGUI.PrivateImage:SetImage("icon16/shield.png");

	-- The Private Checkbox
	self.VGUI.PrivateCheckbox:SetPos(75,130);
	self.VGUI.PrivateCheckbox:SetText(Language.GetMessage("stargate_vgui_private"));
	self.VGUI.PrivateCheckbox:SetWide(110);
	local tip = Language.GetMessage("stargate_vgui_privatetip");
	self.VGUI.PrivateCheckbox:SetTooltip(tip);
	self.VGUI.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.PrivateCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetPrivate(b);
		end
	end

	self.VGUI.GalaxyCheckbox:SetPos(75,145);
	self.VGUI.GalaxyCheckbox:SetText(Language.GetMessage("stargate_galaxy_vgui"));
	self.VGUI.GalaxyCheckbox:SetWide(110);
	local tip = Language.GetMessage("stargate_galaxy_vgui_tip");
	self.VGUI.GalaxyCheckbox:SetTooltip(tip);
	self.VGUI.GalaxyCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.GalaxyCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetGalaxy(b);
		end
	end

	-- The Blocked Checkbox
	self.VGUI.BlockedCheckbox:SetPos(75,160);
	self.VGUI.BlockedCheckbox:SetWide(150);
	self.VGUI.BlockedCheckbox:SetText(Language.GetMessage("stargate_vgui_blocked"));
	local tip = Language.GetMessage("stargate_vgui_blockedtip");
	self.VGUI.BlockedCheckbox:SetTooltip(tip);
	self.VGUI.BlockedCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.BlockedCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetBlocked(b);
		end
	end

	self:RegisterHooks();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressPanel:SetEntity(e);
	self.VGUI.NameTextEntry:SetText(e:GetGateName());
	self.VGUI.PrivateCheckbox:SetValue(e:GetPrivate());
	self.VGUI.GalaxyCheckbox:SetValue(e:GetGalaxy());
	if (e:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or e:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and e:GetClass()!="stargate_universe") then
		self.VGUI.BlockedCheckbox:SetVisible(false);
		self.VGUI.PrivateImage:SetPos(30,136);
	else
		self.VGUI.BlockedCheckbox:SetVisible(true);
		self.VGUI.PrivateImage:SetPos(30,142);
		self.VGUI.BlockedCheckbox:SetValue(e:GetBlocked());
	end
end

vgui.Register("SControlePanelGate_Galaxy",PANEL,"DFrame");

--##################################
--###### SControlePanelGate_GalaxySGU.lua
--##################################

local data = PANEL.Data; -- To store the mousepos accross sessions (And sync it with the main Panel)
local PANEL = table.Copy(PANEL);
PANEL.Data = data;

--################# Init @aVoN
function PANEL:Init()
	self:SetSize(225,210);
	self:SetMinimumSize(225,210);
	self:SetPos(10,10);
	--self:Center(); -- Center is gay!
	self.LastEntity = nil;
	-- Keyboard/Mouse behaviour
	self.Entity = self.Entity or NULL;
	-- VGUI Elements
	self.VGUI = {
		TitleLabel = vgui.Create("DLabel",self),
		AddressPanel = vgui.Create("SAddressPanel_Galaxy",self),
		AddressLabel = {
			vgui.Create("DLabel",self),
			vgui.Create("DLabel",self), -- Black background/Shadow
		},
		NameTextEntry = vgui.Create("DTextEntry",self),
		NameLabel = vgui.Create("DLabel",self),
		PrivateImage = vgui.Create("DImage",self),
		PrivateCheckbox = vgui.Create("DCheckBoxLabel",self),
		BlockedCheckbox = vgui.Create("DCheckBoxLabel",self),
	}
	-- The topic of the whole frame
	self.VGUI.TitleLabel:SetText(Language.GetMessage("stargate_vgui"));
	self.VGUI.TitleLabel:SetWide(200);
	self.VGUI.TitleLabel:SetPos(30,7);
	--###### Set Address
	-- The Topic of this section
	for i=1,2 do
		local mul = (i-1);
		self.VGUI.AddressLabel[i]:SetText(Language.GetMessage("stargate_vgui_settings"));
		self.VGUI.AddressLabel[i]:SetWide(200);
		self.VGUI.AddressLabel[i]:SetPos(30-mul*2,35-mul*2);
		self.VGUI.AddressLabel[i]:SetTextColor(Color(255*mul,255*mul,255*mul,255));
	end

	-- Our AddressPanel (Where we set Addresses with)
	self.VGUI.AddressPanel:SetPos(30,60);
	self.VGUI.AddressPanel.OnAddressSet = function(e,address)
		if((self.AlphaTime or 0)+0.3 < CurTime()) then -- Avoids the VGUI sending "SetGateAddress" everytime we open it!
			e:SetGateAddress(address);
		end
	end
	--###### Name
	-- Name Label
	self.VGUI.NameLabel:SetPos(30,103);
	self.VGUI.NameLabel:SetText(Language.GetMessage("stargate_vgui_name"));

	-- Name TextEntry
	self.VGUI.NameTextEntry:SetPos(75,103);
	self.VGUI.NameTextEntry:SetWide(110);
	self.VGUI.NameTextEntry:SetTooltip(Language.GetMessage("stargate_vgui_nametip"));
	self.VGUI.NameTextEntry:SetAllowNonAsciiCharacters(true);
	self.VGUI.NameTextEntry.OnTextChanged = function(TextEntry)
		local s = TextEntry:GetValue();
		local e = self.Entity;
		local search = self.VGUI.AddressSelect;
		-- Do this within a timer to avoid constant calling of the concommand as soon as someont types in something
		timer.Remove("_StarGate.SetNameTime");
		timer.Create("_StarGate.SetNameTime",1,1,
			function()
				if(IsValid(e)) then
					e:SetGateName(s);
				end
			end
		);
	end

	--###### Private
	-- The Private Image
	self.VGUI.PrivateImage:SetPos(30,136);
	self.VGUI.PrivateImage:SetSize(16,16);
	self.VGUI.PrivateImage:SetImage("icon16/shield.png");

	-- The Private Checkbox
	self.VGUI.PrivateCheckbox:SetPos(75,130);
	self.VGUI.PrivateCheckbox:SetText(Language.GetMessage("stargate_vgui_private"));
	self.VGUI.PrivateCheckbox:SetWide(110);
	local tip = Language.GetMessage("stargate_vgui_privatetip");
	self.VGUI.PrivateCheckbox:SetTooltip(tip);
	self.VGUI.PrivateCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.PrivateCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetPrivate(b);
		end
	end

	-- The Blocked Checkbox
	self.VGUI.BlockedCheckbox:SetPos(75,145);
	self.VGUI.BlockedCheckbox:SetWide(150);
	self.VGUI.BlockedCheckbox:SetText(Language.GetMessage("stargate_vgui_blocked"));
	local tip = Language.GetMessage("stargate_vgui_blockedtip");
	self.VGUI.BlockedCheckbox:SetTooltip(tip);
	self.VGUI.BlockedCheckbox.Label:SetTooltip(tip); -- Workaround/Fix
	self.VGUI.BlockedCheckbox.Button.ConVarChanged = function(CheckBox)
		local b = util.tobool(CheckBox:GetChecked());
		if(IsValid(self.Entity)) then
			self.Entity:SetBlocked(b);
		end
	end

	self:RegisterHooks();
end

--################# To what Entity to we belong to? @aVoN
function PANEL:SetEntity(e)
	self.Entity = e;
	self.VGUI.AddressPanel:SetEntity(e);
	self.VGUI.NameTextEntry:SetText(e:GetGateName());
	self.VGUI.PrivateCheckbox:SetValue(e:GetPrivate());
	if (e:GetNetworkedInt("SG_BLOCK_ADDRESS")<=0 or e:GetNetworkedInt("SG_BLOCK_ADDRESS")==1 and e:GetClass()!="stargate_universe") then
		self.VGUI.BlockedCheckbox:SetVisible(false);
		self.VGUI.PrivateImage:SetPos(30,132);
		self.VGUI.PrivateCheckbox:SetPos(75,133);
	else
		self.VGUI.BlockedCheckbox:SetVisible(true);
		self.VGUI.PrivateImage:SetPos(30,136);
		self.VGUI.BlockedCheckbox:SetValue(e:GetBlocked());
		self.VGUI.PrivateCheckbox:SetPos(75,130);
	end
end

vgui.Register("SControlePanelGate_GalaxySGU",PANEL,"DFrame");