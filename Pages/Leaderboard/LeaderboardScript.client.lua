-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Players			= game:GetService("Players")

-- constants

local PLAYER	= Players.LocalPlayer
local REMOTES	= ReplicatedStorage:WaitForChild("Remotes")
	
local GUI		= script.Parent
local SEASON_WINS_GUI	= GUI:WaitForChild("SeasonWins")
local SEASON_KILLS_GUI	= GUI:WaitForChild("SeasonKills")
local ALLTIME_WINS_GUI	= GUI:WaitForChild("AllTimeWins")
local ALLTIME_KILLS_GUI	= GUI:WaitForChild("AllTimeKills")

-- variables

local seasonLeaderboard, allTimeLeaderboard	= REMOTES.GetLeaderboardInfo:InvokeServer()

-- events

-- intiate

GUI.LoadingLabel:Destroy()

for i, v in pairs(seasonLeaderboard.Wins) do
	local frame		= script.StatFrame:Clone()
		frame.LayoutOrder		= i
		frame.NameLabel.Text	= v.Name
		frame.StatLabel.Text	= tostring(v.Wins)
		frame.Parent			= SEASON_WINS_GUI
end

for i, v in pairs(seasonLeaderboard.Kills) do
	local frame		= script.StatFrame:Clone()
		frame.LayoutOrder		= i
		frame.NameLabel.Text	= v.Name
		frame.StatLabel.Text	= tostring(v.Kills)
		frame.Parent			= SEASON_KILLS_GUI
end

for i, v in pairs(allTimeLeaderboard.Wins) do
	local frame		= script.StatFrame:Clone()
		frame.LayoutOrder		= i
		frame.NameLabel.Text	= v.Name
		frame.StatLabel.Text	= tostring(v.Wins)
		frame.Parent			= ALLTIME_WINS_GUI
end

for i, v in pairs(allTimeLeaderboard.Kills) do
	local frame		= script.StatFrame:Clone()
		frame.LayoutOrder		= i
		frame.NameLabel.Text	= v.Name
		frame.StatLabel.Text	= tostring(v.Kills)
		frame.Parent			= ALLTIME_KILLS_GUI
end