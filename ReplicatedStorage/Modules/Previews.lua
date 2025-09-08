-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local RunService		= game:GetService("RunService")
local Workspace			= game:GetService("Workspace")

-- constants

local CUSTOMIZATION	= ReplicatedStorage:WaitForChild("Customization")

-- variables

local emotes		= {}
local bound			= false

local lastAuraUpdate	= 0

-- module

local PREVIEWS	= {}

function PREVIEWS.GetItemPreview(self, slot, item)
	if item == "None" then
		local preview	= script.PreviewNone:Clone()
		
		return preview
	end
	
	if slot == "Currency" then
		local preview	= script.PreviewCurrency:Clone()
		local tickets	= string.match(item, "%d+")
		
		preview.TicketsLabel.Text	= tostring(tickets)
		
		return preview
	elseif slot == "XPBoost" then
		local preview	= script.PreviewXP:Clone()
		local boost		= string.match(item, "%d+")
		
		preview.BoostLabel.Text	= "+" .. tostring(boost) .. "%"
		
		return preview
	elseif slot == "Face" or slot == "Faces" then
		local preview	= script.PreviewHead:Clone()
		
		local face	= CUSTOMIZATION.Faces:FindFirstChild(item)
		if face then
			face	= face:Clone()
				face.Parent	= preview.Head
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0))
		return preview
	elseif slot == "SkinColor" or slot == "SkinColors" then
		local preview	= script.PreviewHead:Clone()
		
		local skinColor	= CUSTOMIZATION.SkinColors:FindFirstChild(item)
		if skinColor then
			for _, v in pairs(preview:GetChildren()) do
				if v:IsA("BasePart") then
					v.Color	= skinColor.Value
				end
			end
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0))
		return preview
	elseif slot == "Outfit" or slot == "Outfits" then
		local preview	= script.PreviewCharacter:Clone()
		
		local outfit	= CUSTOMIZATION.Outfits:FindFirstChild(item)
		if outfit then
			local shirt	= outfit:FindFirstChild("Shirt")
			if shirt then
				shirt	= shirt:Clone()
					shirt.Parent	= preview
			end
			
			local pants	= outfit:FindFirstChild("Pants")
			if pants then
				pants	= pants:Clone()
					pants.Parent	= preview
			end
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(0, 0, -10) * CFrame.Angles(0.2, math.pi - 0.2, 0))
		return preview
	elseif slot == "Hat" or slot == "Hat2" or slot == "Hats" then
		local preview	= script.PreviewHead:Clone()
		
		local hat	= CUSTOMIZATION.Hats:FindFirstChild(item)
		if hat then
			hat	= hat:Clone()
			
			local attach		= hat.PrimaryPart
			local charAttach	= preview[attach.Name]
			
			for _, v in pairs(hat:GetChildren()) do
				if v:IsA("BasePart") and v ~= attach then
					local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
					v.CFrame		= charAttach.CFrame * offset
					v.Anchored		= true
				end
			end
			
			attach:Destroy()
			hat.Parent	= preview
		end
		
		local center	= preview.PrimaryPart.Position
		local num		= 0
		local average	= Vector3.new()
		
		for _, v in pairs(preview:GetDescendants()) do
			if v:IsA("BasePart") and v ~= preview.PrimaryPart then
				average	= average + (v.Position - center)
				num		= num + 1
			end
		end
		
		if num ~= 0 then
			average	= average / num
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(Vector3.new(0, 0, -4) - average * 0.5) * CFrame.Angles(0.2, math.pi - 0.2, 0))
		return preview
	elseif slot == "Armor" or slot == "Armors" then
		local preview	= script.PreviewCharacter:Clone()
		
		local armor	= CUSTOMIZATION.Armors:FindFirstChild(item)
		if armor then
			armor	= armor.Tier5:Clone()
			
			local attach		= armor.PrimaryPart
			local charAttach	= preview[attach.Name]
			
			for _, v in pairs(armor:GetChildren()) do
				if v:IsA("BasePart") and v ~= attach then
					local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
					v.CFrame		= charAttach.CFrame * offset
					v.Anchored		= true
				end
			end
			
			attach:Destroy()
			armor.Parent	= preview.Attachments
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(0, 0, -10) * CFrame.Angles(0.2, math.pi - 0.2, 0))
		return preview
	elseif slot == "Backpack" or slot == "Backpacks" then
		local preview	= script.PreviewCharacter:Clone()
		
		local backpack	= CUSTOMIZATION.Backpacks:FindFirstChild(item)
		if backpack then
			backpack	= backpack:Clone()
			
			local attach		= backpack.PrimaryPart
			local charAttach	= preview[attach.Name]
			
			for _, v in pairs(backpack:GetChildren()) do
				if v:IsA("BasePart") and v ~= attach then
					local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
					v.CFrame		= charAttach.CFrame * offset
					v.Anchored		= true
				end
			end
			
			attach:Destroy()
			backpack.Parent	= preview.Attachments
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(0, 0, -10) * CFrame.Angles(0.2, -0.2, 0))
		return preview
	elseif slot == "Aura" or slot == "Auras" then
		local preview	= script.PreviewAura:Clone()
		
		return preview
	elseif slot == "Emote" or slot == "Emotes" then
		local preview	= script.PreviewCharacter:Clone()
		
		local emote	= CUSTOMIZATION.Emotes:FindFirstChild(item)
		if emote then
			local animator	= script.EmoteCharacter:Clone()
				animator.Parent	= Workspace
				
			emote	= emote:Clone()
				emote.Parent	= animator
				
			emotes[preview]	= animator
			
			local idle	= animator.Humanoid:LoadAnimation(animator.Idle)
			idle:Play()
				
			local animation		= animator.Humanoid:LoadAnimation(emote)
			animation.Looped	= true
			animation:Play()
			
			preview.AncestryChanged:Connect(function()
				if not preview:IsDescendantOf(game) then
					if emotes[preview] then
						emotes[preview]:Destroy()
						emotes[preview]	= nil
					end
				end
			end)
		end
		
		preview:SetPrimaryPartCFrame(CFrame.new(0, 0, -10) * CFrame.Angles(0.2, math.pi - 0.2, 0))
		return preview
	elseif slot == "KillEffect" or slot == "KillEffects" then
		--local preview	= script.PreviewCharacter:Clone()
		
		local preview	= script.PreviewKillEffect:Clone()
		
		return preview
	end
end

if not bound then
	bound			= true
	local iconCam	= Instance.new("Camera")
		iconCam.Name		= "IconCamera"
		iconCam.CameraType	= Enum.CameraType.Scriptable
		iconCam.FieldOfView	= 40
		iconCam.CFrame		= CFrame.new()
		iconCam.Parent		= Workspace
		
	PREVIEWS.IconCamera	= iconCam
	
	RunService:BindToRenderStep("Previews", 20, function(deltaTime)
		for preview, animator in pairs(emotes) do
			for _, v in pairs(preview:GetChildren()) do
				if v:IsA("BasePart") and v ~= preview.PrimaryPart then
					local offset	= animator.PrimaryPart.CFrame:ToObjectSpace(animator[v.Name].CFrame)
					v.CFrame		= preview.PrimaryPart.CFrame * offset
				end
			end
		end
	end)
end

return PREVIEWS