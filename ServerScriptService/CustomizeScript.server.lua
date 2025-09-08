-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")

-- constants

local PLAYER_DATA	= ReplicatedStorage.PlayerData
local REMOTES		= ReplicatedStorage.Remotes

-- functions

local function EquipItem(player, slot, item)
	local hasItem		= false
	local playerData	= PLAYER_DATA[player.Name]
	
	if slot == "SkinColor" then
		hasItem	= playerData.Inventory.SkinColors:FindFirstChild(item) ~= nil
	elseif slot == "Face" then
		hasItem	= playerData.Inventory.Faces:FindFirstChild(item) ~= nil
	elseif slot == "Hat" or slot == "Hat2" then
		hasItem	= playerData.Inventory.Hats:FindFirstChild(item) ~= nil
	elseif slot == "Outfit" then
		hasItem	= playerData.Inventory.Outfits:FindFirstChild(item) ~= nil
	elseif slot == "Armor" then
		hasItem	= playerData.Inventory.Armors:FindFirstChild(item) ~= nil
	elseif slot == "Backpack" then
		hasItem	= playerData.Inventory.Backpacks:FindFirstChild(item) ~= nil
	elseif slot == "Aura" then
		hasItem	= playerData.Inventory.Auras:FindFirstChild(item) ~= nil
	elseif slot == "Emote" then
		hasItem	= playerData.Inventory.Emotes:FindFirstChild(item) ~= nil
	elseif slot == "KillEffect" then
		hasItem	= playerData.Inventory.KillEffects:FindFirstChild(item) ~= nil
	end
	
	if hasItem then
		playerData.Equipped[slot].Value	= item
	end
end

-- events

REMOTES.EquipItem.OnServerEvent:Connect(EquipItem)