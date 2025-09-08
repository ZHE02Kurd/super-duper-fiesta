-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer

local NUM_SLASHES		= 10
local SLASH_SIZE		= 10
local SLASH_DISTANCE	= 6
local SLASH_TIME		= 0.1

return function(character)
	local effects	= character.Effects
	local rootPart	= character.HumanoidRootPart
	
	for i = 1, NUM_SLASHES do
		spawn(function()
			local center	= rootPart.Position + Vector3.new(0, 1, 0)
			
			local slice		= script.Slice:Clone()
				slice.CFrame	= CFrame.new(center) * CFrame.Angles(math.rad(math.random(360)), math.rad(math.random(360)), math.rad(math.random(360)))
				slice.Size		= Vector3.new(0.3, 1, 1)
				
				slice.Mesh.Scale	= Vector3.new(1, 0, 0)
				slice.Mesh.Offset	= Vector3.new(0, 0, SLASH_DISTANCE)
				
				slice.Parent	= effects
			
			rootPart.Velocity	= slice.CFrame.LookVector * 50
				
			local infoA	= TweenInfo.new(SLASH_TIME/2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			local infoB	= TweenInfo.new(SLASH_TIME/2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			
			local tweenA	= TweenService:Create(slice.Mesh, infoA, {Scale = Vector3.new(1, 1, SLASH_SIZE); Offset = Vector3.new()})
			tweenA:Play()
			wait(SLASH_TIME/2)
			local tweenB	= TweenService:Create(slice.Mesh, infoA, {Scale = Vector3.new(1, 0, 0); Offset = Vector3.new(0, 0, -SLASH_DISTANCE)})
			tweenB:Play()
			wait(SLASH_TIME/2)
			slice:Destroy()
		end)
		
		wait(SLASH_TIME/2)
	end
end