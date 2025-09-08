-- services

local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local MarketplaceService	= game:GetService("MarketplaceService")
local TweenService			= game:GetService("TweenService")
local Players				= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local PLAYER_DATA	= ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(PLAYER.Name)
local RANKING		= PLAYER_DATA:WaitForChild("Ranking")
local BATTLE_PASS	= PLAYER_DATA:WaitForChild("BattlePass")
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")

local GUI			= script.Parent
local LEVEL_GUI		= GUI:WaitForChild("LevelFrame")
local BUY_GUI		= GUI:WaitForChild("BattlePassFrame")

-- variables

local battlePassInfo	= REMOTES.GetBattlePassInfo:InvokeServer(true)

-- functions

local function XPForLevel(level)
	return math.floor(300 + (level/100)^4 * 300)
end

local function UpdateBattlePass()
	if BATTLE_PASS.CurrentPass.Value == battlePassInfo.CurrentPass then
		BUY_GUI.Visible		= false
	else
		BUY_GUI.Visible		= true
	end
end

local function UpdateLevel()
	local requiredXP	= XPForLevel(RANKING.Level.Value + 1)
	
	LEVEL_GUI.LevelLabel.Text	= "LEVEL " .. tostring(RANKING.Level.Value)
	LEVEL_GUI.XPFrame.Bar.Size	= UDim2.new(RANKING.LevelXP.Value / requiredXP, 0, 1, 0)
	LEVEL_GUI.XPLabel.Text		= tostring(RANKING.LevelXP.Value) .. "/" .. tostring(requiredXP)
end

-- events

RANKING.Level.Changed:Connect(UpdateLevel)
RANKING.LevelXP.Changed:Connect(UpdateLevel)
BATTLE_PASS.CurrentPass.Changed:Connect(function()
	UpdateBattlePass()
end)

BUY_GUI.BuyButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	if battlePassInfo then
		MarketplaceService:PromptGamePassPurchase(PLAYER, battlePassInfo.CurrentPass)
	end
end)

-- initiate

UpdateLevel()
UpdateBattlePass()