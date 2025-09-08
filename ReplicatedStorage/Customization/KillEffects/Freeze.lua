-- services

local Workspace	= game:GetService("Workspace")
local Players	= game:GetService("Players")

-- constants

local PLAYER	= Players.LocalPlayer

return function(character)
	local effects	= character.Effects
	local rootPart	= character.HumanoidRootPart
	
	wait(0.1)
	
	local sound	= script.FreezeSound:Clone()
		sound.Parent	= rootPart
		sound:Play()
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") and v ~= rootPart then
			local weld	= Instance.new("Weld")
				weld.Part0	= rootPart
				weld.Part1	= v
				weld.C0		= rootPart.CFrame:ToObjectSpace(v.CFrame)
				weld.Parent	= v
			
			if v.Transparency < 0.5 then
				local ice	= script.IcePart:Clone()
					ice.Size	= v.Size + Vector3.new(0.4, 0.4, 0.4)
					ice.CFrame	= v.CFrame
					ice.Parent	= effects
					
				local weld	= Instance.new("Weld")
					weld.Part0	= v
					weld.Part1	= ice
					weld.Parent	= ice
					
				wait(0.05)
			end
		end
	end
end