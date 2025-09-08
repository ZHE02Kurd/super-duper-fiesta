-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local DATA			= ReplicatedStorage:WaitForChild("PlayerData")
local PLAYER_DATA	= DATA:WaitForChild(PLAYER.Name)
local STATS			= PLAYER_DATA:WaitForChild("Stats")
	
local GUI			= script.Parent
local STATS_GUI		= GUI:WaitForChild("Stats")
	
-- variables

local stats	= {
	{Stat = "Wins"};
	{Stat = "Losses"};
	{Stat = "GoldMedals"; Title = "Gold Medals"};
	{Stat = "SilverMedals"; Title = "Silver Medals"};
	{Stat = "BronzeMedals"; Title = "Bronze Medals"};
	{Stat = "Kills"};
	{Stat = "Downs"};
	{Stat = "Damage"};
	{Stat = "Deaths"};
	{Stat = "Revives"};
	
	{Stat = "MostKills"; Title = "Most Kills"};
	{Stat = "FurthestKill"; Title = "Furthest Kill"};
	
	{Stat = "PlayTime"; Title = "Play Time"; Format = function(t)
		local hours		= math.floor(t / 60)
		local minutes	= t - hours * 60
		
		return string.format("%d:%02d", hours, minutes)
	end}
}

-- events

-- intiate

for i, info in pairs(stats) do
	if info.Divider then
		local frame	= script.DividerFrame:Clone()
			frame.LayoutOrder		= i
			frame.TitleLabel.Text	= string.upper(info.Divider)
			frame.Parent			= STATS_GUI
	else
		local stat	= STATS:WaitForChild(info.Stat)
	
		local frame	= script.StatFrame:Clone()
			frame.LayoutOrder		= i
			frame.TitleLabel.Text	= info.Title and string.upper(info.Title) or string.upper(info.Stat)
			
			if info.Format then
				frame.StatLabel.Text	= info.Format(stat.Value)
			else
				frame.StatLabel.Text	= tostring(stat.Value)
			end
			
			frame.Parent			= STATS_GUI
			
		stat.Changed:connect(function()
			if info.Format then
				frame.StatLabel.Text	= info.Format(stat.Value)
			else
				frame.StatLabel.Text	= tostring(stat.Value)
			end
		end)
	end
end