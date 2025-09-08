-- services

local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local MarketplaceService	= game:GetService("MarketplaceService")
local Players				= game:GetService("Players")

-- constants

local PLAYER_DATA	= ReplicatedStorage.PlayerData
local REMOTES		= ReplicatedStorage.Remotes

local CURRENT_PASS	= 6407948
local PREVIOUS_PASS	= 0

local DEFAULT_REWARDS	= require(script.DefaultRewards)
local PASS_REWARDS		= require(script.BattlePassRewards)
local RETURN_REWARDS	= {}

-- variables

-- functions

local function GiveReward(player, reward)
	local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
	if playerData then
		local inventory	= playerData.Inventory
		for slot, items in pairs(reward) do
			if slot == "Currency" then
				for _, item in pairs(items) do
					local tickets	= string.match(item, "%d+")
					if tickets then
						playerData.Currency.Tickets.Value	= playerData.Currency.Tickets.Value + tickets
					end
				end
			elseif slot == "XPBoost" then
				for _, item in pairs(items) do
					local boost	= string.match(item, "%d+")
					if boost then
						playerData.BattlePass.XPBoost.Value	= playerData.BattlePass.XPBoost.Value + boost
					end
				end
			else
				for _, item in pairs(items) do
					if not inventory[slot]:FindFirstChild(item) then
						local itemValue		= Instance.new("IntValue")
							itemValue.Name		= item
							itemValue.Value		= 0
							itemValue.Parent	= inventory[slot]
					end
				end
			end
		end
	end
end

local function LevelUp(player, level)
	local playerData	= PLAYER_DATA:WaitForChild(player.Name)
	local ranking		= playerData.Ranking
	local battlePass	= playerData.BattlePass
	
	if DEFAULT_REWARDS[tostring(level)] then
		GiveReward(player, DEFAULT_REWARDS[tostring(level)])
	end
	
	if battlePass.CurrentPass.Value == CURRENT_PASS then
		-- give pass rewards
		if PASS_REWARDS[tostring(level)] then
			GiveReward(player, PASS_REWARDS[tostring(level)])
		end
	end
end

local function BattlePassPurchased(player)
	print(player.Name .. " purchased the battle pass")
	local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
	if playerData then
		local ranking		= playerData.Ranking
		local battlePass	= playerData.BattlePass
		
		if battlePass.CurrentPass.Value == CURRENT_PASS then
			-- check for previous pass and give return rewards
			if PREVIOUS_PASS ~= 0 and MarketplaceService:UserOwnsGamePassAsync(player.UserId, PREVIOUS_PASS) then
				print(player.Name .. " owns the previous battle pass, giving rewards")
				-- give return rewards
				for _, reward in pairs(RETURN_REWARDS:GetChildren()) do
					GiveReward(player, reward)
				end
			end
			
			print("giving pass rewards")
			-- give pass rewards
			for level, reward in pairs(PASS_REWARDS) do
				if ranking.Level.Value >= tonumber(level) then
					GiveReward(player, reward)
				end
			end
		end
	end
end

local function GetBattlePassInfo(_, ignoreRewards)
	local info	= {
		CurrentPass		= CURRENT_PASS;
	}
	
	if not ignoreRewards then
		info.DefaultRewards		= DEFAULT_REWARDS;
		info.PassRewards		= PASS_REWARDS;
	end
	
	return info
end

-- events

REMOTES.GetBattlePassInfo.OnServerInvoke	= GetBattlePassInfo

script.LevelUp.Event:Connect(LevelUp)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if passId == CURRENT_PASS then
		if purchased then
			local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
			if playerData then
				playerData.BattlePass.CurrentPass.Value	= CURRENT_PASS
				
				BattlePassPurchased(player)
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	local playerData	= PLAYER_DATA:WaitForChild(player.Name)
	
	if MarketplaceService:UserOwnsGamePassAsync(player.UserId, CURRENT_PASS) then
		if playerData.BattlePass.CurrentPass.Value ~= CURRENT_PASS then
			playerData.BattlePass.CurrentPass.Value	= CURRENT_PASS
			
			BattlePassPurchased(player)
		end
	end
end)