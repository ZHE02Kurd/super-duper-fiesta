-- services

local ServerScriptService	= game:GetService("ServerScriptService")
local ReplicatedStorage		= game:GetService("ReplicatedStorage")
local Players				= game:GetService("Players")

-- constants

local PLAYER_DATA	= ReplicatedStorage.PlayerData
local REMOTES		= ReplicatedStorage.Remotes

-- functions

local function SetKeybind(player, action, ps, input)
	local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
	if playerData then
		if action == "RESET_ALL" then
			for _, keybind in pairs(ServerScriptService.DataScript.PlayerData.Keybinds:GetChildren()) do
				playerData.Keybinds[keybind.Name].Value	= keybind.Value
			end
		else
			local keybind	= playerData.Keybinds:FindFirstChild(action)
			if keybind then
				local bind	= ""
				if input then
					if input.EnumType == Enum.KeyCode then
						bind	= "KeyCode." .. input.Name
					elseif input.EnumType == Enum.UserInputType then
						bind	= "UserInputType." .. input.Name
					end
				end
				
				if ps == "Primary" then
					if string.match(keybind.Value, ";") then
						local secondary	= string.match(keybind.Value, ";(.+)")
						keybind.Value	= bind .. ";" .. secondary
					else
						keybind.Value	= bind
					end
				elseif ps == "Secondary" then
					if string.match(keybind.Value, ";") then
						local primary	= string.match(keybind.Value, "(.-);")
						keybind.Value	= primary .. ";" .. bind
					else
						keybind.Value	= keybind.Value .. ";" .. bind
					end
				end
				
				if string.match(keybind.Value, ";$") then
					if keybind.Value == ";" then
						keybind.Value	= ""
					else
						keybind.Value	= string.match(keybind.Value, "(.+);")
					end
				end
			end
		end
	end
end

-- events

REMOTES.SetKeybind.OnServerEvent:connect(SetKeybind)