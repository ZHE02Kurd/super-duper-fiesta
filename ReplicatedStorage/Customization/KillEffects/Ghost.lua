-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

return function(character)
	local parts	= {}
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("MeshPart") then
			
			local glow	= Instance.new("Part")
				glow.Anchored		= true
				glow.CanCollide		= false
				glow.Size			= v.Size
				glow.CFrame			= v.CFrame
				glow.Material		= Enum.Material.ForceField
				glow.Transparency	= -1
				glow.Color			= Color3.new(1, 1, 1)
				
			local mesh	= Instance.new("SpecialMesh")
				mesh.Name		= "Mesh"
				mesh.MeshId		= v.MeshId
				mesh.TextureId	= "rbxassetid://2911686714"
				mesh.Parent		= glow
				
			glow.Parent		= character.Effects
			
			table.insert(parts, glow)
		end
	end
	
	local head	= script.Head:Clone()
		head.CFrame			= character.Head.CFrame
		head.Transparency	= -1
		head.Parent			= character.Effects
		
	table.insert(parts, head)
	
	local info	=  TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	for _, part in pairs(parts) do
		local cframe	= part.CFrame + Vector3.new(0, 10, 0)
		
		local tween		= TweenService:Create(part, info, {CFrame = cframe; Transparency = 1})
		tween:Play()
		
		Debris:AddItem(part, 5)
	end
end