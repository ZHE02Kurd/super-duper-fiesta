-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local RunService	= game:GetService("RunService")
local Debris		= game:GetService("Debris")

-- constants

local GLITCH_AMOUNT	= 4

return function(character)
	local effects	= character.Effects
	local parts		= {}
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency ~= 1 then
			local rate	= math.floor((v.Size.X + v.Size.Y + v.Size.Z) * GLITCH_AMOUNT)
			
			for i = 1, 4 do
				local emitter	= script["GlitchEmitter" .. tostring(i)]:Clone()
					emitter.Rate	= rate
					emitter.Parent	= v
					
				Debris:AddItem(emitter, 0.4)
			end
			
			RunService.Stepped:Wait()
		end
	end
end