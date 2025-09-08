-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local RunService	= game:GetService("RunService")
local Debris		= game:GetService("Debris")

-- constants

local SPARKLE_AMOUNT	= 4

return function(character)
	local effects	= character.Effects
	local parts		= {}
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency ~= 1 then
			local rate	= math.floor((v.Size.X + v.Size.Y + v.Size.Z) * SPARKLE_AMOUNT)
			
			local emitter	= script.SparkleEmitter:Clone()
				emitter.Parent	= v
				
			emitter:Emit(rate)
				
			Debris:AddItem(emitter, 0.8)
		end
	end
end