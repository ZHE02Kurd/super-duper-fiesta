-- services

local MarketplaceService	= game:GetService("MarketplaceService")
local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local Players				= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local PLAYER_DATA	= ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(PLAYER.Name)
local EVENTS		= ReplicatedStorage:WaitForChild("Events")
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")
local MODULES		= ReplicatedStorage:WaitForChild("Modules")
	local PREVIEWS		= require(MODULES:WaitForChild("Previews"))

local GUI			= script.Parent
local BUNDLE_GUI	= GUI:WaitForChild("Bundle")

local TICKETS_ICON	= "🎟"

-- variables

local currentIndex, currentFeatured, currentBundle

-- events

EVENTS.BuyBundle.Event:Connect(function(bundle, index, featured)
	currentBundle	= bundle
	currentIndex	= index
	currentFeatured	= featured
	
	BUNDLE_GUI.PriceLabel.Text	= tostring(bundle.Price) .. " " .. TICKETS_ICON
	BUNDLE_GUI.BuyButton.TextLabel.Text				= PLAYER_DATA.Currency.Tickets.Value >= bundle.Price and "BUY" or "GET " .. TICKETS_ICON
	BUNDLE_GUI.BuyButton.TextLabel.TextTransparency	= PLAYER_DATA.Currency.Tickets.Value >= bundle.Price and 0 or 0.5
	
	for _, v in pairs(BUNDLE_GUI.Frame:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	
	for slot, items in pairs(bundle.Items) do
		for _, item in pairs(items) do
			local frame		= script.ItemFrame:Clone()
				frame.TitleLabel.Text	= string.upper(item)
				frame.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
				frame.Parent			= BUNDLE_GUI.Frame
				
			local preview	= PREVIEWS:GetItemPreview(slot, item)
			if preview then
				preview.Parent	= frame.ViewportFrame
			end
		end
	end
	
	GUI.Visible	= true
end)

PLAYER_DATA.Currency.Tickets.Changed:Connect(function()
	if currentBundle then
		BUNDLE_GUI.BuyButton.TextLabel.Text				= PLAYER_DATA.Currency.Tickets.Value >= currentBundle.Price and "BUY" or "GET " .. TICKETS_ICON
		BUNDLE_GUI.BuyButton.TextLabel.TextTransparency	= PLAYER_DATA.Currency.Tickets.Value >= currentBundle.Price and 0 or 0.5
	end
end)

BUNDLE_GUI.CloseButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	GUI.Visible	= false
end)

BUNDLE_GUI.BuyButton.MouseButton1Click:Connect(function()
	if PLAYER_DATA.Currency.Tickets.Value >= currentBundle.Price then
		script.BuySound:Play()
		REMOTES.BuyShopBundle:FireServer(currentIndex, currentFeatured)
		GUI.Visible	= false
	else
		EVENTS.BuyCurrency:Fire()
		script.ClickSound:Play()
	end
end)

-- initiate