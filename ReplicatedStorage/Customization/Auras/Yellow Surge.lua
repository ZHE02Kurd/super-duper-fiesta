-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local TweenService	= game:GetService("TweenService")
local Debris		= game:GetService("Debris")

-- constants

return function(character)
	local rootPart	= character.HumanoidRootPart
	
	local attachment	= Instance.new("Attachment")
		attachment.CFrame	= CFrame.new(0, 0.8, 0)
		attachment.Parent	= rootPart
	
	local emitter1	= script.OutlineEmitter:Clone()
		emitter1.Parent	= attachment
		
	local emitter2	= script.GlowEmitter:Clone()
		emitter2.Parent	= attachment
		
	local info	= TweenInfo.new(5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	
	local tween1	= TweenService:Create(emitter1, info, {Rate = 0})
	local tween2	= TweenService:Create(emitter2, info, {Rate = 0})
	
	tween1:Play()
	tween2:Play()
		
	wait(5)
	
	emitter1.Enabled	= false
	emitter2.Enabled	= false
	
	Debris:AddItem(attachment, 0.5)
end