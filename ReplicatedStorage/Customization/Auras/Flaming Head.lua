-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local RunService	= game:GetService("RunService")
local Debris		= game:GetService("Debris")

-- constants

return function(character)
	local effects	= character.Effects
	local emitters	= {}
	
	local emitter1	= script.BaseEmitter:Clone()
		emitter1.Parent	= character.Head
		
	local emitter2	= script.FlameEmitter:Clone()
		emitter2.Parent	= character.Head
		
	wait(5)
	
	emitter1.Enabled	= false
	emitter2.Enabled	= false
	
	Debris:AddItem(emitter1, 2)
	Debris:AddItem(emitter2, 1)
end