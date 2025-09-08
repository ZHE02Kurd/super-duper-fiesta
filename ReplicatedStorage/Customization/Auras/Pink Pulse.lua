-- services

local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- function

return function(character)
	local parts	= {}
	local color	= Color3.fromRGB(233, 62, 255)
	
	for _, v in pairs(character:GetChildren()) do
		if v:IsA("MeshPart") then
			
			local glow	= Instance.new("Part")
				glow.Anchored		= false
				glow.CanCollide		= false
				glow.Massless		= true
				glow.Size			= v.Size
				glow.CFrame			= v.CFrame
				glow.Material		= Enum.Material.ForceField
				glow.Transparency	= 1
				glow.Color			= color
				
			local weld	= Instance.new("Weld")
				weld.Part0	= v
				weld.Part1	= glow
				weld.Parent	= glow
				
			local mesh	= Instance.new("SpecialMesh")
				mesh.Name		= "Mesh"
				mesh.Scale		= Vector3.new(5, 5, 5)
				mesh.MeshId		= v.MeshId
				mesh.TextureId	= "rbxassetid://3058314522"
				mesh.Parent		= glow
				
			glow.Parent		= character.Effects
			table.insert(parts, glow)
		end
	end
	
	local infoA	= TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local infoB	= TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
	
	for _, v in pairs(parts) do
		local meshTween	= TweenService:Create(v.Mesh, infoA, {Scale = Vector3.new(1.15, 1.15, 1.15)})
		local partTween	= TweenService:Create(v, infoA, {Transparency = 0})
		meshTween:Play()
		partTween:Play()
	end
	wait(0.2)
	for _, v in pairs(parts) do
		local partTween	= TweenService:Create(v, infoB, {Transparency = 1})
		partTween:Play()
		Debris:AddItem(v, 2)
	end
end