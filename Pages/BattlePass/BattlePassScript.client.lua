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
local MODULES		= ReplicatedStorage:WaitForChild("Modules")
	local PREVIEWS		= require(MODULES:WaitForChild("Previews"))

local GUI			= script.Parent
local LEVEL_GUI		= GUI:WaitForChild("LevelFrame")
local TIERS_GUI		= GUI:WaitForChild("TiersFrame")
local BUY_GUI		= GUI:WaitForChild("BuyFrame")
local SKIP_GUI		= GUI:WaitForChild("SkipFrame")
local PREVIEW_GUI	= GUI:WaitForChild("PreviewFrame")
local XPBOOST_GUI	= GUI:WaitForChild("XPBoostFrame")

local TIER_SKIP_ID	= 502947068

-- variables

local currentPage		= math.max(1, math.ceil(RANKING.Level.Value / 10))
local battlePassInfo	= REMOTES:WaitForChild("GetBattlePassInfo"):InvokeServer()

local tiers		= {}

local defaultDisplays	= {}
local passDisplays		= {}

local levelUpQueued		= false

-- functions

local function XPForLevel(level)
	return math.floor(300 + (level/100)^4 * 300)
end

local function UpdateTierDisplay(index, pass)
	local tierFrame	= tiers[index]
	
	if pass then
		tierFrame.BattlePassViewportFrame:ClearAllChildren()
		
		local passDisplay	= passDisplays[index]
		if passDisplay then
			if #passDisplay.Items > 0 then
				local info	= passDisplay.Items[passDisplay.CurrentIndex]
				
				local preview	= PREVIEWS:GetItemPreview(info.Slot, info.Item)
				if preview then
					preview.Parent	= tierFrame.BattlePassViewportFrame
				end
			end
		end
	else
		tierFrame.DefaultViewportFrame:ClearAllChildren()
	
		local defaultDisplay	= defaultDisplays[index]
		if defaultDisplay then
			if #defaultDisplay.Items > 0 then
				local info	= defaultDisplay.Items[defaultDisplay.CurrentIndex]
				
				local preview	= PREVIEWS:GetItemPreview(info.Slot, info.Item)
				if preview then
					preview.Parent	= tierFrame.DefaultViewportFrame
				end
			end
		end
	end
end

local function UpdateTiers()
	defaultDisplays	= {}
	passDisplays	= {}
	
	for i = 1, 10 do
		local level		= (currentPage - 1) * 10 + i
		local tierFrame	= tiers[i]
		
		tierFrame.TierLabel.Text		= "TIER " .. tostring(level)
		tierFrame.LockLabel.Visible		= RANKING.Level.Value < level
		
		local defaultInfo	= {
			CurrentIndex	= 1;
			Items			= {};
		}
		if battlePassInfo.DefaultRewards[tostring(level)] then
			tierFrame.DefaultButton.ImageTransparency	= 0
			for slot, rewards in pairs(battlePassInfo.DefaultRewards[tostring(level)]) do
				for i, item in pairs(rewards) do
					table.insert(defaultInfo.Items, {Slot = slot; Item = item})
				end
			end
			tierFrame.DefaultOwnedLabel.Visible			= RANKING.Level.Value >= level
		else
			tierFrame.DefaultButton.ImageTransparency	= 0.5
			tierFrame.DefaultOwnedLabel.Visible			= false
		end
		defaultDisplays[i]	= defaultInfo
		
		local passInfo	= {
			CurrentIndex	= 1;
			Items			= {};
		}
		if battlePassInfo.PassRewards[tostring(level)] then
			tierFrame.BattlePassButton.ImageTransparency	= 0
			for slot, rewards in pairs(battlePassInfo.PassRewards[tostring(level)]) do
				for i, item in pairs(rewards) do
					table.insert(passInfo.Items, {Slot = slot; Item = item})
				end
			end
			tierFrame.BattlePassOwnedLabel.Visible	= RANKING.Level.Value >= level and BATTLE_PASS.CurrentPass.Value == battlePassInfo.CurrentPass
		else
			tierFrame.BattlePassButton.ImageTransparency	= 0.5
			tierFrame.BattlePassOwnedLabel.Visible			= false
		end
		passDisplays[i]	= passInfo
		
		UpdateTierDisplay(i)
		UpdateTierDisplay(i, true)
	end
end

local function UpdateBattlePass()
	if BATTLE_PASS.CurrentPass.Value == battlePassInfo.CurrentPass then
		TIERS_GUI.PassFrame.BattlePassLabel.ImageTransparency	= 0
		
		for i, tierFrame in pairs(tiers) do
			--tierFrame.BattlePassViewportFrame.ImageTransparency	= 0
			tierFrame.PassLabel.Visible	= false
			
			local tier	= (currentPage - 1) * 10 + i
			if battlePassInfo.PassRewards[tostring(tier)] then
				tierFrame.BattlePassOwnedLabel.Visible	= RANKING.Level.Value >= tier
			end
		end
		
		BUY_GUI.Visible		= false
		SKIP_GUI.Visible	= true
	else
		TIERS_GUI.PassFrame.BattlePassLabel.ImageTransparency	= 0.5
		
		for _, tierFrame in pairs(tiers) do
			--tierFrame.BattlePassViewportFrame.ImageTransparency	= 0.5
			tierFrame.PassLabel.Visible	= true
		end
		
		BUY_GUI.Visible		= true
		SKIP_GUI.Visible	= false
	end
end

local function UpdateLevel()
	local requiredXP	= XPForLevel(RANKING.Level.Value + 1)
	
	LEVEL_GUI.LevelLabel.Text	= "LEVEL " .. tostring(RANKING.Level.Value)
	LEVEL_GUI.XPFrame.Bar.Size	= UDim2.new(RANKING.LevelXP.Value / requiredXP, 0, 1, 0)
	LEVEL_GUI.XPLabel.Text		= tostring(RANKING.LevelXP.Value) .. "/" .. tostring(requiredXP)
	
	UpdateTiers()
end

local function UpdatePreview(tier)
	PREVIEW_GUI.TitleFrame.TierLabel.Text		= "TIER " .. tostring(tier)
	PREVIEW_GUI.TitleFrame.LockLabel.Visible	= RANKING.Level.Value < tier
	
	for _, v in pairs(PREVIEW_GUI.DefaultItems:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	for _, v in pairs(PREVIEW_GUI.BattlePassItems:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	
	if battlePassInfo.DefaultRewards[tostring(tier)] then
		for slot, items in pairs(battlePassInfo.DefaultRewards[tostring(tier)]) do
			for _, item in pairs(items) do
				local itemFrame		= script.ItemFrame:Clone()
					itemFrame.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
					itemFrame.TitleLabel.Text	= string.upper(item)
					itemFrame.Parent			= PREVIEW_GUI.DefaultItems
					
				local preview	= PREVIEWS:GetItemPreview(slot, item)
				if preview then
					preview.Parent	= itemFrame.ViewportFrame
				end
			end
		end
	end
	
	if #PREVIEW_GUI.DefaultItems:GetChildren() <= 1 then
		local label	= script.NothingLabel:Clone()
			label.Parent	= PREVIEW_GUI.DefaultItems
	end
	
	if battlePassInfo.PassRewards[tostring(tier)] then
		for slot, items in pairs(battlePassInfo.PassRewards[tostring(tier)]) do
			for _, item in pairs(items) do
				local itemFrame		= script.ItemFrame:Clone()
					itemFrame.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
					itemFrame.TitleLabel.Text	= string.upper(item)
					itemFrame.Parent			= PREVIEW_GUI.BattlePassItems
					
				local preview	= PREVIEWS:GetItemPreview(slot, item)
				if preview then
					preview.Parent	= itemFrame.ViewportFrame
				end
			end
		end
	end
	
	if #PREVIEW_GUI.BattlePassItems:GetChildren() <= 1 then
		local label	= script.NothingLabel:Clone()
			label.Parent	= PREVIEW_GUI.BattlePassItems
	end
end

local function UpdateXPBoost()
	XPBOOST_GUI.BoostLabel.Text	= tostring(BATTLE_PASS.XPBoost.Value) .. "%"
end

-- events

RANKING.Level.Changed:Connect(UpdateLevel)
RANKING.LevelXP.Changed:Connect(UpdateLevel)
BATTLE_PASS.CurrentPass.Changed:Connect(function()
	if BATTLE_PASS.CurrentPass.Value == battlePassInfo.CurrentPass then
		script.BuySound:Play()
	end
	UpdateBattlePass()
end)
BATTLE_PASS.XPBoost.Changed:Connect(UpdateXPBoost)

BUY_GUI.BuyButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	if battlePassInfo then
		MarketplaceService:PromptGamePassPurchase(PLAYER, battlePassInfo.CurrentPass)
	end
end)

SKIP_GUI.BuyButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	if RANKING.Level.Value < 100 then
		MarketplaceService:PromptProductPurchase(PLAYER, TIER_SKIP_ID)
	end
end)

TIERS_GUI.PreviousFrame.Button.MouseButton1Click:Connect(function()
	script.TabSound:Play()
	
	if currentPage > 1 then
		currentPage	= currentPage - 1
		UpdateTiers()
	end
end)
	
TIERS_GUI.NextFrame.Button.MouseButton1Click:Connect(function()
	script.TabSound:Play()
	
	if currentPage < 10 then
		currentPage	= currentPage + 1
		UpdateTiers()
	end
end)

-- initiate

for i = 1, 10 do
	local tierFrame		= script.TierFrame:Clone()
		tierFrame.LayoutOrder		= i + 1
		tierFrame.TierLabel.Text	= "TIER " .. tostring(i)
		tierFrame.BattlePassViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
		tierFrame.DefaultViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
		tierFrame.Parent			= TIERS_GUI
		
	tierFrame.BattlePassButton.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		local tier	= (currentPage - 1) * 10 + i
		UpdatePreview(tier)
	end)
	
	tierFrame.DefaultButton.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		local tier	= (currentPage - 1) * 10 + i
		UpdatePreview(tier)
	end)
		
	table.insert(tiers, tierFrame)
end

UpdateLevel()
UpdateBattlePass()
UpdateXPBoost()
UpdatePreview(RANKING.Level.Value + 1)

while true do
	wait(3)
	for i = 1, 10 do
		local defaultDisplay	= defaultDisplays[i]
		local passDisplay		= passDisplays[i]
		local needsUpdate		= false
		local needsPassUpdate	= false
		
		if defaultDisplay then
			if #defaultDisplay.Items > 1 then
				needsUpdate	= true
				defaultDisplay.CurrentIndex	= defaultDisplay.CurrentIndex + 1
				
				if defaultDisplay.CurrentIndex > #defaultDisplay.Items then
					defaultDisplay.CurrentIndex	= 1
				end
			end
		end
		
		if passDisplay then
			if #passDisplay.Items > 1 then
				needsPassUpdate	= true
				passDisplay.CurrentIndex	= passDisplay.CurrentIndex + 1
				
				if passDisplay.CurrentIndex > #passDisplay.Items then
					passDisplay.CurrentIndex	= 1
				end
			end
		end
		
		if needsUpdate then
			UpdateTierDisplay(i)
		end
		if needsPassUpdate then
			UpdateTierDisplay(i, true)
		end
	end
end