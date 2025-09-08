-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")
local EVENTS		= ReplicatedStorage:WaitForChild("Events")
local PLAYER_DATA	= ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(PLAYER.Name)
local CURRENCY		= PLAYER_DATA:WaitForChild("Currency")
local MODULES		= ReplicatedStorage:WaitForChild("Modules")
	local PREVIEWS		= require(MODULES:WaitForChild("Previews"))
	
local GUI			= script.Parent
local SHOP_GUI		= GUI:WaitForChild("Shop")
local FEATURED_GUI	= SHOP_GUI:WaitForChild("Featured")
local DEFAULT_GUI	= SHOP_GUI:WaitForChild("Default")
local TICKETS_GUI	= GUI:WaitForChild("Tickets")

local TICKETS_ICON	= "🎟"

-- variables

local defaultFrames		= {}
local featuredFrames	= {}
local defaultDisplays	= {}
local featuredDisplays	= {}

local shopInfo	= REMOTES:WaitForChild("GetShopInfo"):InvokeServer()

-- functions

local function PlayerOwnsBundle(bundle)
	for slot, items in pairs(bundle.Items) do
		for _, item in pairs(items) do
			if PLAYER_DATA.Inventory[slot]:FindFirstChild(item) then
				return true
			end
		end
	end
	return false
end

local function UpdateDisplay(index, featured)
	local itemFrame, display
	
	if featured then
		itemFrame	= featuredFrames[index]
		display		= featuredDisplays[index]
	else
		itemFrame	= defaultFrames[index]
		display		= defaultDisplays[index]
	end
	
	if itemFrame then
		itemFrame.ViewportFrame:ClearAllChildren()
		
		if display then
			itemFrame.PriceLabel.Text	= tostring(display.Price) .. " " .. TICKETS_ICON
			if #display.Items > 0 then
				local info	= display.Items[display.CurrentIndex]
				local text	= ""
				if #display.Items > 1 then
					text	= "BUNDLE - "
				end
				itemFrame.TitleLabel.Text	= text .. string.upper(info.Item)
				
				
				local preview	= PREVIEWS:GetItemPreview(info.Slot, info.Item)
				if preview then
					preview.Parent	= itemFrame.ViewportFrame
				end
			end
		end
	end
end

local function UpdateOwned()
	for i = 1, 8 do
		local itemFrame		= defaultFrames[i]
		local bundle		= shopInfo.Default[i]
		local owned			= PlayerOwnsBundle(bundle)
		
		itemFrame.OwnedLabel.Visible			= owned
		itemFrame.PriceLabel.TextTransparency	= owned and 0.5 or 0
	end
	for i = 1, 2 do
		local itemFrame		= featuredFrames[i]
		local bundle		= shopInfo.Featured[i]
		local owned			= PlayerOwnsBundle(bundle)
		
		itemFrame.OwnedLabel.Visible			= owned
		itemFrame.PriceLabel.TextTransparency	= owned and 0.5 or 0
	end
end

local function Refresh()
	defaultDisplays		= {}
	featuredDisplays	= {}
	
	for i = 1, 8 do
		local itemFrame		= defaultFrames[i]
		local defaultInfo	= {
			CurrentIndex	= 1;
			Items			= {};
			Price			= 0;
		}
		
		if shopInfo.Default[i] then
			defaultInfo.Price	= shopInfo.Default[i].Price
			for slot, rewards in pairs(shopInfo.Default[i].Items) do
				for i, item in pairs(rewards) do
					table.insert(defaultInfo.Items, {Slot = slot; Item = item})
				end
			end
		end
		defaultDisplays[i]	= defaultInfo
		
		UpdateDisplay(i)
	end
	for i = 1, 2 do
		local itemFrame		= featuredFrames[i]
		local featuredInfo	= {
			CurrentIndex	= 1;
			Items			= {};
			Price			= 0;
		}
		
		if shopInfo.Featured[i] then
			featuredInfo.Price	= shopInfo.Featured[i].Price
			for slot, rewards in pairs(shopInfo.Featured[i].Items) do
				for i, item in pairs(rewards) do
					table.insert(featuredInfo.Items, {Slot = slot; Item = item})
				end
			end
		end
		featuredDisplays[i]	= featuredInfo
		
		UpdateDisplay(i, true)
	end
	UpdateOwned()
end

local function UpdateTickets()
	TICKETS_GUI.TicketsLabel.Text	= tostring(CURRENCY.Tickets.Value) .. " " .. TICKETS_ICON
end

-- events

CURRENCY.Tickets.Changed:Connect(UpdateTickets)

PLAYER_DATA.Inventory.DescendantAdded:Connect(function()
	spawn(function()
		UpdateOwned()
	end)
end)

TICKETS_GUI.BuyButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	EVENTS.BuyCurrency:Fire()
end)

-- initiate

for i = 1, 8 do
	local itemFrame	= script.ItemFrame:Clone()
		itemFrame.LayoutOrder	= i
		itemFrame.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
		itemFrame.Parent		= DEFAULT_GUI
		
	itemFrame.Button.MouseButton1Click:Connect(function()
		local bundle	= shopInfo.Default[i]
		if not PlayerOwnsBundle(bundle) then
			script.ClickSound:Play()
			EVENTS.BuyBundle:Fire(bundle, i, false)
		end
	end)
	
	table.insert(defaultFrames, itemFrame)
end

for i = 1, 2 do
	local itemFrame	= script.FeaturedFrame:Clone()
		itemFrame.LayoutOrder	= i
		itemFrame.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
		itemFrame.Parent		= FEATURED_GUI
	
	itemFrame.Button.MouseButton1Click:Connect(function()
		local bundle	= shopInfo.Featured[i]
		if not PlayerOwnsBundle(bundle) then
			script.ClickSound:Play()
			EVENTS.BuyBundle:Fire(bundle, i, true)
		end
	end)
	
	table.insert(featuredFrames, itemFrame)
end

Refresh()
UpdateTickets()

while true do
	wait(3)
	for i = 1, 8 do
		local defaultDisplay	= defaultDisplays[i]
		local needsUpdate		= false
		
		if defaultDisplay then
			if #defaultDisplay.Items > 1 then
				needsUpdate	= true
				defaultDisplay.CurrentIndex	= defaultDisplay.CurrentIndex + 1
				
				if defaultDisplay.CurrentIndex > #defaultDisplay.Items then
					defaultDisplay.CurrentIndex	= 1
				end
			end
		end
		
		if needsUpdate then
			UpdateDisplay(i)
		end
	end
	for i = 1, 2 do
		local featuredDisplay	= featuredDisplays[i]
		local needsUpdate		= false
		
		if featuredDisplay then
			if #featuredDisplay.Items > 1 then
				needsUpdate	= true
				featuredDisplay.CurrentIndex	= featuredDisplay.CurrentIndex + 1
				
				if featuredDisplay.CurrentIndex > #featuredDisplay.Items then
					featuredDisplay.CurrentIndex	= 1
				end
			end
		end
		
		if needsUpdate then
			UpdateDisplay(i, true)
		end
	end
end