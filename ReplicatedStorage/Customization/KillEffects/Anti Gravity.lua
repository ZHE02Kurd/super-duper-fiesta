local Workspace	= game:GetService("Workspace")
local Players	= game:GetService("Players")

local ARROW_AMOUNT	= 1
--local PLAYER	= Players.LocalPlayer

return function(character)
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") then
			local bodyForce		= Instance.new("BodyForce")
				bodyForce.Force		= Vector3.new(0, v:GetMass() * Workspace.Gravity * 1.05, 0)
				bodyForce.Parent	= v
					
			if v.Transparency ~= 1 then
				local rate	= math.floor((v.Size.X + v.Size.Y + v.Size.Z) * ARROW_AMOUNT)
				
				local emitter	= script.ArrowEmitter:Clone()
					emitter.Rate	= rate
					emitter.Parent	= v
			end
		end
	end
end