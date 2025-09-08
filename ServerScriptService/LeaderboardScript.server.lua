-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local DataStoreService	= game:GetService("DataStoreService")
local Players			= game:GetService("Players")

-- constants

local REMOTES	= ReplicatedStorage.Remotes

local SEASON_WINS_DATA		= DataStoreService:GetOrderedDataStore("Season1Wins")
local SEASON_KILLS_DATA		= DataStoreService:GetOrderedDataStore("Season1Kills")
local ALLTIME_WINS_DATA		= DataStoreService:GetOrderedDataStore("AllTimeWins")
local ALLTIME_KILLS_DATA	= DataStoreService:GetOrderedDataStore("AllTimeKills")

-- variables

local seasonLeaderboard, allTimeLeaderboard

-- functions

local function LoadData()
	print("Loading leaderboard data")
	local seasonWins, seasonKills	= {}, {}
	local allTimeWins, allTimeKills	= {}, {}
	local seasonWinsPage	= SEASON_WINS_DATA:GetSortedAsync(false, 10)
	local seasonKillsPage	= SEASON_KILLS_DATA:GetSortedAsync(false, 10)
	local allTimeWinsPage	= ALLTIME_WINS_DATA:GetSortedAsync(false, 10)
	local allTimeKillsPage	= ALLTIME_KILLS_DATA:GetSortedAsync(false, 10)
	
	for _, p in pairs(seasonWinsPage:GetCurrentPage()) do
		local name	= Players:GetNameFromUserIdAsync(p.key)
		table.insert(seasonWins, {Name = name; Wins = p.value})
	end
	for _, p in pairs(seasonKillsPage:GetCurrentPage()) do
		local name	= Players:GetNameFromUserIdAsync(p.key)
		table.insert(seasonKills, {Name = name; Kills = p.value})
	end
	for _, p in pairs(allTimeWinsPage:GetCurrentPage()) do
		local name	= Players:GetNameFromUserIdAsync(p.key)
		table.insert(allTimeWins, {Name = name; Wins = p.value})
	end
	for _, p in pairs(allTimeKillsPage:GetCurrentPage()) do
		local name	= Players:GetNameFromUserIdAsync(p.key)
		table.insert(allTimeKills, {Name = name; Kills = p.value})
	end
	
	seasonLeaderboard	= {
		Wins	= seasonWins;
		Kills	= seasonKills;
	}
	allTimeLeaderboard	= {
		Wins	= allTimeWins;
		Kills	= allTimeKills;
	}
end

-- events

REMOTES.GetLeaderboardInfo.OnServerInvoke	= function()
	if (not seasonLeaderboard) or (not allTimeLeaderboard) then
		repeat wait() until seasonLeaderboard and allTimeLeaderboard
	end
	
	return seasonLeaderboard, allTimeLeaderboard
end

-- initiate

while true do
	LoadData()
	wait(600)
end