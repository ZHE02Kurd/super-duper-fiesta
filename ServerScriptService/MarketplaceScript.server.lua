-- services

local MarketplaceService	= game:GetService("MarketplaceService")
local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local Players				= game:GetService("Players")

-- constants

local PLAYER_DATA	= ReplicatedStorage.PlayerData

local TIER_SKIP_ID	= 502947068
local CURRENCY_IDS	= {
	[508073135]	= 100;
	[508073690]	= 250;
	[508073899]	= 500;
	[508074515]	= 1000;
	[508109510]	= 5000;
	[508109698]	= 10000;
}

-- functions

local function ProcessReceipt(receiptInfo)
	local player	= Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if player then
		if receiptInfo.ProductId == TIER_SKIP_ID then
			print(player.Name .. " skipped a tier")
			local success	= script.Parent.Ranking.RankingScript.SkipTier:Invoke(player)
			if success then
				return Enum.ProductPurchaseDecision.PurchaseGranted
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		elseif CURRENCY_IDS[receiptInfo.ProductId] then
			local tickets		= CURRENCY_IDS[receiptInfo.ProductId]
			local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
			
			if playerData then
				print(player, "purchased", tickets, "tickets")
				playerData.Currency.Tickets.Value	= playerData.Currency.Tickets.Value + tickets
				local success	= script.Parent.DataScript.SaveData:Invoke(player)
				if success then
					return Enum.ProductPurchaseDecision.PurchaseGranted
				else
					return Enum.ProductPurchaseDecision.NotProcessedYet
				end
			else
				return Enum.ProductPurchaseDecision.NotProcessedYet
			end
		end
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- callbacks

MarketplaceService.ProcessReceipt	= ProcessReceipt