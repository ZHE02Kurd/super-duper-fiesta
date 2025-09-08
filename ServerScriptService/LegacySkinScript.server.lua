-- services

local ServerScriptService	= game:GetService("ServerScriptService")
local MarketplaceService	= game:GetService("MarketplaceService")
local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local Players				= game:GetService("Players")

-- constants

local PLAYER_DATA	= ReplicatedStorage.PlayerData
local REMOTES		= ReplicatedStorage.Remotes

-- variables

local skins	= {
	[5712345]	= {Outfits = {"Operator"}; Hats = {"Operator"}; Faces = {"Concerned"}}; -- operator
	[6088388]	= {Outfits = {"Artist"}; Hats = {"Artist"}; Faces = {"Awesome"}}; -- artist
	[6089217]	= {Outfits = {"Wraith"}; Hats = {"Wraith", "Wraith Alt"}; Faces = {"Beast Mode"}}; -- wraith
}

-- functions

local function GiveReward(player, reward)
	local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
	if playerData then
		local inventory	= playerData.Inventory
		for slot, items in pairs(reward) do
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

-- events

Players.PlayerAdded:connect(function(player)
	PLAYER_DATA:WaitForChild(player.Name)
	for id, reward in pairs(skins) do
		if MarketplaceService:UserOwnsGamePassAsync(player.UserId, id) then
			GiveReward(player, reward)
		end
	end
end)