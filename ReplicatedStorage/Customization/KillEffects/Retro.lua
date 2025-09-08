local Workspace	= game:GetService("Workspace")
local Players	= game:GetService("Players")

--local PLAYER	= Players.LocalPlayer

return function(character)
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Reflectance = 1
			if v:IsA("MeshPart") then
				v.TextureID = ""
			end
			script.SparkleEmitter:Clone().Parent	= v
			
			--if character == PLAYER.Character then
				local bodyForce		= Instance.new("BodyForce")
					bodyForce.Force		= Vector3.new(0, v:GetMass() * Workspace.Gravity * 1.05, 0)
					bodyForce.Parent	= v
			--end
		elseif v:IsA("Shirt") then
			v:Destroy()
		elseif v:IsA("Pants") then
			v:Destroy()
		end
	end
end