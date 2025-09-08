-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer

local GLOW_AMOUNT	= 20

return function(character)
	local effects	= character.Effects
	local parts		= {}
	local emitters	= {}
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v.Transparency ~= 1 then
			table.insert(parts, v)
			local rate	= math.floor((v.Size.X + v.Size.Y + v.Size.Z) * GLOW_AMOUNT)
			
			local emitter	= script.GlowEmitter:Clone()
				emitter.Rate	= rate
				emitter.Parent	= v
				
			table.insert(emitters, emitter)
		end
	end
	
	local info	= TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	
	for _, v in pairs(parts) do
		local tween	= TweenService:Create(v, info, {Transparency = 1})
		tween:Play()
	end
	
	wait(0.5)
	for _, v in pairs(emitters) do
		v.Enabled	= false
	end
end