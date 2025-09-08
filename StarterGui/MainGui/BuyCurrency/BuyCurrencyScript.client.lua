-- services

local MarketplaceService	= game:GetService("MarketplaceService")
local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local Players				= game:GetService("Players")

-- constants

local EVENTS		= ReplicatedStorage:WaitForChild("Events")
local PLAYER		= Players.LocalPlayer

local GUI			= script.Parent
local CURRENCY_GUI	= GUI:WaitForChild("Currency")

local CURRENCY_IDS	= {
	[508073135]	= 100;
	[508073690]	= 250;
	[508073899]	= 500;
	[508074515]	= 1000;
	[508109510]	= 5000;
	[508109698]	= 10000;
}

-- events

EVENTS.BuyCurrency.Event:Connect(function()
	GUI.Visible	= true
end)

CURRENCY_GUI.CloseButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	GUI.Visible	= false
end)

-- initiate

for id, tickets in pairs(CURRENCY_IDS) do
	local info	= MarketplaceService:GetProductInfo(id, Enum.InfoType.Product)
	
	local currencyGui	= script.CurrencyFrame:Clone()
		currencyGui.LayoutOrder			= tickets / 100
		currencyGui.PriceLabel.Text		= "R$ " .. tostring(info.PriceInRobux)
		currencyGui.TicketsLabel.Text	= tostring(tickets)
		currencyGui.Parent				= CURRENCY_GUI.Frame
		
	currencyGui.Button.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		MarketplaceService:PromptProductPurchase(PLAYER, id)
	end)
end