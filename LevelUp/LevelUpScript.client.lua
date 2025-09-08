-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")

-- constants

local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")

local GUI			= script.Parent
local LEVELUP_GUI	= GUI:WaitForChild("LevelUpFrame")

-- functions

local function LevelUp()
	LEVELUP_GUI.TitleLabel.Size	= UDim2.new(2.4, 0, 1.2, 0)
	
	GUI.Visible		= true
	
	script.MedalSound:Play()
	script.LevelUpSound:Play()
	
	local info	= TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	local tween	= TweenService:Create(LEVELUP_GUI.TitleLabel, info, {Size = UDim2.new(0.8, 0, 0.4, 0)})
	tween:Play()
end

-- events

REMOTES.LevelUp.OnClientEvent:Connect(function()
	LevelUp()
end)

LEVELUP_GUI.CloseButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	GUI.Visible	= false
end)