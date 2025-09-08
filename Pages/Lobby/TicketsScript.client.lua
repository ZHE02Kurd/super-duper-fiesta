-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")
local EVENTS		= ReplicatedStorage:WaitForChild("Events")
local PLAYER_DATA	= ReplicatedStorage:WaitForChild("PlayerData"):WaitForChild(PLAYER.Name)
local CURRENCY		= PLAYER_DATA:WaitForChild("Currency")
	
local GUI			= script.Parent
local TICKETS_GUI	= GUI:WaitForChild("Tickets")

local TICKETS_ICON	= "🎟"

-- variables

local lastTickets

-- functions

local function UpdateTickets()
	if lastTickets then
		if CURRENCY.Tickets.Value > lastTickets then
			script.TicketsSound:Play()
		end
		lastTickets	= CURRENCY.Tickets.Value
	else
		lastTickets	= CURRENCY.Tickets.Value
	end
	TICKETS_GUI.TicketsLabel.Text	= tostring(CURRENCY.Tickets.Value) .. " " .. TICKETS_ICON
end

-- events

CURRENCY.Tickets.Changed:Connect(UpdateTickets)

TICKETS_GUI.BuyButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	EVENTS.BuyCurrency:Fire()
end)

-- initiate

UpdateTickets()