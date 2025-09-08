-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer

return function(character)
	local rootPart	= character.UpperTorso
	
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency	= 1
		elseif v:IsA("Decal") then
			v.Transparency	= 1
		end
	end
	
	local emitter	= script.TicketEmitter:Clone()
		emitter.Parent	= rootPart
		
	emitter:Emit(60)
end