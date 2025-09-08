-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TeleportService	= game:GetService("TeleportService")
local HttpService		= game:GetService("HttpService")
local Players			= game:GetService("Players")

-- constants

local SQUADS		= ReplicatedStorage.Squads
local REMOTES		= ReplicatedStorage.Remotes

local MATCH_SIZE		= 30
local MAX_QUEUE_TIME	= 60
local MAX_SQUAD_SIZE	= 4

local GAME_ID		= 2609028954

-- variables

local matches	= {}

-- functions

local function NewMatch(queue)
	local match	= {
		Squads		= {};
		Ready		= false;
		ID			= HttpService:GenerateGUID(false);
		Start		= tick();
		Queue		= queue and queue or "Squad";
	}
	
	table.insert(matches, match)
	
	print("Created " .. string.upper(match.Queue) .. " match: " .. match.ID)
	
	return match
end

local function GetMatchSize(match)
	local size	= 0
	
	for _, squad in pairs(match.Squads) do
		size	= size + #squad.Players:GetChildren()
	end
	
	return size
end

local function GetSquadPlayers(squad)
	local players	= {}
	
	for _, p in pairs(squad.Players:GetChildren()) do
		local player	= Players:FindFirstChild(p.Name)
		if player then
			table.insert(players, player)
		end
	end
	
	return players
end

local function SquadReady(squad)
	if #squad.Players:GetChildren() == 0 then
		return false
	end
	
	for _, p in pairs(squad.Players:GetChildren()) do
		if not p.Value then
			return false
		end
	end
	
	return true
end

local function GetMatchPlayers(match)
	local players	= {}
	
	for _, squad in pairs(match.Squads) do
		for _, p in pairs(squad.Players:GetChildren()) do
			local player	= Players:FindFirstChild(p.Name)
			if player then
				table.insert(players, player)
			end
		end
	end
	
	return players
end

local function GetMatch(squad)
	for _, match in pairs(matches) do
		for i, s in pairs(match.Squads) do
			if s == squad then
				return match
			end
		end
	end
end

local function AddSquad(squad)
	local match	= GetMatch(squad)
	
	if not match then
		for _, m in pairs(matches) do
			if m.Queue == squad.Queue.Value and GetMatchSize(m) + #squad.Players:GetChildren() <= MATCH_SIZE then
				if match then
					if GetMatchSize(match) < GetMatchSize(m) then
						match	= m
					end
				else
					match	= m
				end
			end
		end
		
		if not match then
			match	= NewMatch(squad.Queue.Value)
		end
		
		table.insert(match.Squads, squad)
	end
end

local function RemoveSquad(squad)
	for _, match in pairs(matches) do
		for i, s in pairs(match.Squads) do
			if s == squad then
				local players	= GetSquadPlayers(squad)
				
				for _, player in pairs(players) do
					REMOTES.MatchInfo:FireClient(player, "Leave")
				end
				
				table.remove(match.Squads, i)
				break
			end
		end
	end
end

-- events

SQUADS.ChildRemoved:connect(function(squad)
	RemoveSquad(squad)
end)

-- main loop

while true do
	wait(0.5)
	
	for _, squad in pairs(SQUADS:GetChildren()) do
		if SquadReady(squad) then
			AddSquad(squad)
		else
			RemoveSquad(squad)
		end
	end
	
	for i = #matches, 1, -1 do
		local match			= matches[i]
		local numPlayers	= GetMatchSize(match)
		local players		= GetMatchPlayers(match)
		
		for _, squad in pairs(match.Squads) do
			if squad.Queue.Value ~= match.Queue then
				RemoveSquad(squad)
			end
		end
		
		for _, player in pairs(players) do
			REMOTES.MatchInfo:FireClient(player, "Players", match.Queue, numPlayers, MATCH_SIZE, MAX_QUEUE_TIME - math.floor(tick() - match.Start))
		end
		
		if numPlayers == 0 then
			print("Match: " .. match.ID .. " is empty, cleaning up...")
			table.remove(matches, i)
		elseif numPlayers >= MATCH_SIZE or tick() - match.Start > MAX_QUEUE_TIME then
			local success, err = pcall(function()
				print("Match: " .. match.ID .. " is full, sending to game...")
				
				-- combine squads with fill enabled
				for _, squad in pairs(match.Squads) do
					if squad and squad.Parent == SQUADS then
						if squad.Fill.Value then
							print(squad)
							if #squad.Players:GetChildren() < MAX_SQUAD_SIZE then
								for _, other in pairs(match.Squads) do
									if other ~= squad then
										if other.Fill.Value then
											local needed	= MAX_SQUAD_SIZE - #squad.Players:GetChildren()
											if #other.Players:GetChildren() <= needed then
												for _, p in pairs(other.Players:GetChildren()) do
													p:Clone().Parent	= squad.Players
												end
												
												other:Destroy()
											end
										end
									end
								end
							end
						end
					end
				end
				
				-- tell players they're joining
				for _, p in pairs(players) do
					REMOTES.MatchInfo:FireClient(p, "Join")
				end
				
				-- generate access code for new server
				local accessCode	= TeleportService:ReserveServer(GAME_ID)
				
				-- teleport squads
				for _, squad in pairs(match.Squads) do
					if squad and squad.Parent == SQUADS then
						for _, p in pairs(squad.Players:GetChildren()) do
							p.Value	= false
						end
						
						local squadPlayers	= GetSquadPlayers(squad)
						local squadName		= squad.Name
						
						for _, player in pairs(squadPlayers) do
							TeleportService:TeleportToPrivateServer(GAME_ID, accessCode, {player}, nil, squadName)
						end
					end
				end
				
				table.remove(matches, i)
			end)
			if not success then
				warn("oopsie woopsie " .. err)
			end
		end
	end
end