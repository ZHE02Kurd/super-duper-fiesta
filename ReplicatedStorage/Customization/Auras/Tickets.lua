-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer

return function(character)
	local rootPart	= character.UpperTorso
	
	local emitter	= script.TicketEmitter:Clone()
		emitter.Parent	= rootPart
		
	emitter:Emit(40)
	
	Debris:AddItem(emitter, 4)
end