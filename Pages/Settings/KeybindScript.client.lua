-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local DATA			= ReplicatedStorage:WaitForChild("PlayerData")
local PLAYER_DATA	= DATA:WaitForChild(PLAYER.Name)
local KEYBINDS		= PLAYER_DATA:WaitForChild("Keybinds")
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")
local MODULES		= ReplicatedStorage:WaitForChild("Modules")
	local INPUT			= require(MODULES:WaitForChild("Input"))
	
local GUI			= script.Parent
local KEYBIND_GUI	= GUI:WaitForChild("Keybinds")
local RESET_BUTTON	= GUI:WaitForChild("ResetButton")

local BOUND_COLOR	= Color3.fromRGB(255, 255, 255)
local UNBOUND_COLOR	= Color3.fromRGB(255, 51, 51)
	
-- variables

local keybinds	= {
	{Divider = "Movement"};
	{Action = "Sprint"};
	{Action = "Crouch"};
	{Action = "Jump"};
	{Action = "Dash"};
	
	{Divider = "Weapons"};
	{Action = "Primary"; Title = "Shoot"};
	{Action = "Aim"};
	{Action = "AimToggle"; Title = "Aim (Toggle)"};
	{Action = "Reload"};
	
	{Divider = "Backpack"};
	{Action = "Inventory"; Title = "Toggle"};
	{Action = "Backpack1"; Title = "Slot 1"};
	{Action = "Backpack2"; Title = "Slot 2"};
	{Action = "Backpack3"; Title = "Slot 3"};
	{Action = "Backpack4"; Title = "Slot 4"};
	--{Action = "Backpack5"; Title = "Slot 5"};
	{Action = "Pickup"};
	{Action = "Drop"};
	
	{Divider = "Chat"};
	{Action = "Chat"; Title = "Start Chatting"};
	{Action = "ChatScope"; Title = "Switch Channels"};
	
	{Divider = "Misc"};
	{Action = "Heal"};
	{Action = "Ping"};
	{Action = "Emote"; Title = "Taunt"};
}

-- events

RESET_BUTTON.MouseButton1Click:connect(function()
	script.ResetSound:Play()
	REMOTES.SetKeybind:FireServer("RESET_ALL")
end)

-- intiate

for i, info in pairs(keybinds) do
	if info.Divider then
		local frame	= script.DividerFrame:Clone()
			frame.LayoutOrder		= i
			frame.TitleLabel.Text	= string.upper(info.Divider)
			frame.Parent			= KEYBIND_GUI
	else
		local keybind	= KEYBINDS:WaitForChild(info.Action)
	
		local frame	= script.KeybindFrame:Clone()
			frame.LayoutOrder		= i
			frame.ActionLabel.Text	= info.Title and string.upper(info.Title) or string.upper(info.Action)
			frame.Parent			= KEYBIND_GUI
			
		local function Refresh()
			local inputP, inputS	= INPUT:GetAllActionInputs(info.Action)
			
			frame.PrimaryButton.TextLabel.Text		= inputP
			frame.SecondaryButton.TextLabel.Text	= inputS
			
			if inputP == "NIL" and inputS == "NIL" then
				frame.ActionLabel.TextColor3	= UNBOUND_COLOR
			else
				frame.ActionLabel.TextColor3	= BOUND_COLOR
			end
		end
		
		Refresh()
		
		keybind.Changed:connect(function()
			spawn(function()
				Refresh()
			end)
		end)
		
		frame.PrimaryButton.MouseButton1Click:connect(function()
			frame.PrimaryButton.TextLabel.Text	= "..."
			script.ClickSound:Play()
			
			local inputObject	= UserInputService.InputBegan:wait()
			
			script.BindSound:Play()
			
			if inputObject.UserInputType == Enum.UserInputType.Keyboard then
				frame.PrimaryButton.TextLabel.Text	= "SETTING..."
				REMOTES.SetKeybind:FireServer(info.Action, "Primary", inputObject.KeyCode)
			else
				frame.PrimaryButton.TextLabel.Text	= "SETTING..."
				REMOTES.SetKeybind:FireServer(info.Action, "Primary", inputObject.UserInputType)
			end
		end)
		
		frame.PrimaryButton.MouseButton2Click:connect(function()
			script.ClickSound:Play()
			if frame.PrimaryButton.TextLabel.Text ~= "NIL" then
				frame.PrimaryButton.TextLabel.Text	= "UNSETTING..."
			end
			REMOTES.SetKeybind:FireServer(info.Action, "Primary")
		end)
		
		frame.SecondaryButton.MouseButton1Click:connect(function()
			frame.SecondaryButton.TextLabel.Text	= "..."
			script.ClickSound:Play()
			
			local inputObject	= UserInputService.InputBegan:wait()
			
			script.BindSound:Play()
			
			if inputObject.UserInputType == Enum.UserInputType.Keyboard then
				frame.SecondaryButton.TextLabel.Text	= "SETTING..."
				REMOTES.SetKeybind:FireServer(info.Action, "Secondary", inputObject.KeyCode)
			else
				frame.SecondaryButton.TextLabel.Text	= "SETTING..."
				REMOTES.SetKeybind:FireServer(info.Action, "Secondary", inputObject.UserInputType)
			end
		end)
		
		frame.SecondaryButton.MouseButton2Click:connect(function()
			script.ClickSound:Play()
			if frame.SecondaryButton.TextLabel.Text ~= "NIL" then
				frame.SecondaryButton.TextLabel.Text	= "UNSETTING..."
			end
			REMOTES.SetKeybind:FireServer(info.Action, "Secondary")
		end)
	end
end