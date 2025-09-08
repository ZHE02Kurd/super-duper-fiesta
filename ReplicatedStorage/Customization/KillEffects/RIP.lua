-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

local PLAYER	= Players.LocalPlayer
local EFFECTS	= Workspace.Effects

return function(character)
	local rootPart	= character.HumanoidRootPart
	
	local ray		= Ray.new(rootPart.Position, Vector3.new(0, -50, 0))
	local h, p, n	= Workspace:FindPartOnRayWithIgnoreList(ray,	{character, EFFECTS})
	
	if h then
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Transparency	= 1
			elseif v:IsA("Decal") then
				v.Transparency	= 1
			end
		end
		
		local angle	= math.rad(math.random(360))
		
		local gravestone	= script.Gravestone:Clone()
			gravestone.Dirt.CFrame	= CFrame.new(p, p + n) * CFrame.Angles(-math.pi/2, 0, 0) * CFrame.Angles(0, angle, 0)
			gravestone.Stone.CFrame	= CFrame.new(p, p + n) * CFrame.Angles(-math.pi/2, 0, 0) * CFrame.new(0, gravestone.Stone.Size.Y/2, 0) * CFrame.Angles(0, angle, 0)
			gravestone.Parent	= EFFECTS
			
		gravestone.Dirt.DirtEmitter:Emit(10)
		gravestone.Dirt.ImpactEmitter:Emit(10)
	end
end