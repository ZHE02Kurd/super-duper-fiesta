-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer

local ELECTROCUTE_AMOUNT	= 2
local VELOCITY_AMOUNT		= 10

return function(character)
	local effects	= character.Effects
	local parts		= {}
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency ~= 1 then
			table.insert(parts, v)
			local rate	= math.floor((v.Size.X + v.Size.Y + v.Size.Z) * ELECTROCUTE_AMOUNT)
			
			local emitter1	= script.ElectricityEmitter1:Clone()
				emitter1.Rate	= rate
				emitter1.Parent	= v
				
			local emitter2	= script.ElectricityEmitter2:Clone()
				emitter2.Rate	= rate
				emitter2.Parent	= v
		end
	end
	
	for i = 1, 100 do
		for _, v in pairs(parts) do
			v.RotVelocity	= Vector3.new(math.random(-VELOCITY_AMOUNT, VELOCITY_AMOUNT), math.random(-VELOCITY_AMOUNT, VELOCITY_AMOUNT), math.random(-VELOCITY_AMOUNT, VELOCITY_AMOUNT))
		end
		wait(0.1)
	end
end