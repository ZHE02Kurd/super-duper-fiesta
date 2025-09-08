-- services

local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

local HORN_SIZE		= Vector3.new(1.8, 2, 2)
local HORN_CENTER	= Vector3.new(0, 1.1, 0.1)
local HORN_SCALE	= 0.3

local WING_SIZE		= Vector3.new(2, 2, 2)
local WING_CENTER	= Vector3.new(0, 0.7, 0.9)
local WING_SCALE	= 0.3

-- function

return function(character)
	local effects	= character.Effects
	local level, wings, horns	= effects:FindFirstChild("DemonLevel"), effects:FindFirstChild("DemonWings"), effects:FindFirstChild("DemonHorns")
	
	if not level then
		level	= Instance.new("IntValue")
			level.Name		= "DemonLevel"
			level.Value		= 0
			level.Parent	= effects
	end
	if not wings then
		wings	= script.DemonWings:Clone()
			wings.Mesh.Offset	= Vector3.new()
			wings.Mesh.Scale	= Vector3.new()
			wings.Parent	= effects
			
		local weld	= Instance.new("Weld")
			weld.Part0	= character.UpperTorso
			weld.Part1	= wings
			weld.Parent	= wings
	end
	if not horns then
		horns	= script.DemonHorns:Clone()
			horns.Mesh.Offset	= Vector3.new()
			horns.Mesh.Scale	= Vector3.new()
			horns.Parent	= effects
			
		local weld	= Instance.new("Weld")
			weld.Part0	= character.Head
			weld.Part1	= horns
			weld.Parent	= horns
	end
	
	local info	= TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	
	level.Value	= level.Value + 1
	
	local hornScale	= 1 + (level.Value - 1) * HORN_SCALE
	local wingScale	= 1 + (level.Value - 1) * WING_SCALE
	
	local hTween	= TweenService:Create(horns.Mesh, info, {Scale = HORN_SIZE * hornScale; Offset = HORN_CENTER * hornScale})
	hTween:Play()
	
	local wTween	= TweenService:Create(wings.Mesh, info, {Scale = WING_SIZE * wingScale; Offset = WING_CENTER * wingScale})
	wTween:Play()
	
	horns.GrowEmitter:Emit(20)
	wings.GrowEmitter:Emit(20)
	
	wait(8)
	
	level.Value	= level.Value - 1
	
	if level.Value <= 0 then
		level:Destroy()
		wings:Destroy()
		horns:Destroy()
	else
		local hornScale	= 1 + (level.Value - 1) * HORN_SCALE
		local wingScale	= 1 + (level.Value - 1) * WING_SCALE
		
		local hTween	= TweenService:Create(horns.Mesh, info, {Scale = HORN_SIZE * hornScale; Offset = HORN_CENTER * hornScale})
		hTween:Play()
		
		local wTween	= TweenService:Create(wings.Mesh, info, {Scale = WING_SIZE * wingScale; Offset = WING_CENTER * wingScale})
		wTween:Play()
	end
end