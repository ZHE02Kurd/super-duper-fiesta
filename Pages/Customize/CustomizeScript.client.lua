-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local Workspace			= game:GetService("Workspace")
local Players			= game:GetService("Players")
local RunService		= game:GetService("RunService")

-- constants

local PLAYER		= Players.LocalPlayer
local DATA			= ReplicatedStorage:WaitForChild("PlayerData")
local PLAYER_DATA	= DATA:WaitForChild(PLAYER.Name)
local INVENTORY		= PLAYER_DATA:WaitForChild("Inventory")
local EQUIPPED		= PLAYER_DATA:WaitForChild("Equipped")
local CUSTOMIZATION	= ReplicatedStorage:WaitForChild("Customization")
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")
local MODULES		= ReplicatedStorage:WaitForChild("Modules")
	local PREVIEWS		= require(MODULES:WaitForChild("Previews"))

local GUI			= script.Parent
local PREVIEW_GUI	= GUI:WaitForChild("PreviewFrame")
local SLOT_GUI		= GUI:WaitForChild("SlotFrame")
local TITLE_GUI		= GUI:WaitForChild("TitleFrame")
local SELECTION_GUI	= GUI:WaitForChild("SelectionFrame")

local SLOT_REPLACEMENTS	= {
	["Emote"]		= "Taunt";
	["KillEffect"]	= "Kill Effect";
	["SkinColor"]	= "Skin Color";
}

local PREVIEW_CFRAME	= CFrame.new(0, -0.5, -11) * CFrame.Angles(0.2, math.pi - 0.2, 0)

-- variables

local previewArmor	= false
local previewEmote	= false

local rotation	= CFrame.new()
local dragging	= false
local lastX		= 0
local velocity	= 0

local previewCharacter

local currentSlot

-- functions

local function Lerp(a, b,d) return a + (b - a) * d end

local function RefreshCharacter()
	PREVIEW_GUI:ClearAllChildren()
	
	local character	= script.PreviewCharacter:Clone()
	
	local skinColor	= CUSTOMIZATION.SkinColors:FindFirstChild(EQUIPPED.SkinColor.Value)
	if skinColor then
		for _, v in pairs(character:GetChildren()) do
			if v:IsA("BasePart") then
				v.Color	= skinColor.Value
			end
		end
	end
	
	local face	= CUSTOMIZATION.Faces:FindFirstChild(EQUIPPED.Face.Value)
	if face then
		face	= face:Clone()
			face.Parent	= character.Head
	end
	
	local outfit	= CUSTOMIZATION.Outfits:FindFirstChild(EQUIPPED.Outfit.Value)
	if outfit then
		local shirt	= outfit:FindFirstChild("Shirt")
		if shirt then
			shirt	= shirt:Clone()
				shirt.Parent	= character
		end
		
		local pants	= outfit:FindFirstChild("Pants")
		if pants then
			pants	= pants:Clone()
				pants.Parent	= character
		end
	end
	
	local hat	= CUSTOMIZATION.Hats:FindFirstChild(EQUIPPED.Hat.Value)
	if hat then
		hat	= hat:Clone()
		
		local attach		= hat.PrimaryPart
		local charAttach	= character[attach.Name]
		
		for _, v in pairs(hat:GetChildren()) do
			if v:IsA("BasePart") and v ~= attach then
				local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
				v.CFrame		= charAttach.CFrame * offset
				
				local weld	= Instance.new("Weld")
					weld.Part0		= charAttach
					weld.Part1		= v
					weld.C0			= offset
					weld.Parent		= v
					
				v.Anchored		= false
				v.CanCollide	= false
				v.Massless		= true
			end
		end
		
		attach:Destroy()
		hat.Parent	= character.Attachments
	end
	
	local hat2	= CUSTOMIZATION.Hats:FindFirstChild(EQUIPPED.Hat2.Value)
	if hat2 then
		hat2	= hat2:Clone()
		
		local attach		= hat2.PrimaryPart
		local charAttach	= character[attach.Name]
		
		for _, v in pairs(hat2:GetChildren()) do
			if v:IsA("BasePart") and v ~= attach then
				local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
				v.CFrame		= charAttach.CFrame * offset
				
				local weld	= Instance.new("Weld")
					weld.Part0		= charAttach
					weld.Part1		= v
					weld.C0			= offset
					weld.Parent		= v
					
				v.Anchored		= false
				v.CanCollide	= false
				v.Massless		= true
			end
		end
		
		attach:Destroy()
		hat2.Parent	= character.Attachments
	end
	
	local backpack	= CUSTOMIZATION.Backpacks:FindFirstChild(EQUIPPED.Backpack.Value)
	if backpack then
		backpack	= backpack:Clone()
		
		local attach		= backpack.PrimaryPart
		local charAttach	= character[attach.Name]
		
		for _, v in pairs(backpack:GetChildren()) do
			if v:IsA("BasePart") and v ~= attach then
				local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
				v.CFrame		= charAttach.CFrame * offset
				
				local weld	= Instance.new("Weld")
					weld.Part0		= charAttach
					weld.Part1		= v
					weld.C0			= offset
					weld.Parent		= v
					
				v.Anchored		= false
				v.CanCollide	= false
				v.Massless		= true
			end
		end
		
		attach:Destroy()
		backpack.Parent	= character.Attachments
	end
	
	if previewArmor then
		local armor	= CUSTOMIZATION.Armors:FindFirstChild(EQUIPPED.Armor.Value)
		if armor then
			armor	= armor.Tier5:Clone()
			
			local attach		= armor.PrimaryPart
			local charAttach	= character[attach.Name]
			
			for _, v in pairs(armor:GetChildren()) do
				if v:IsA("BasePart") and v ~= attach then
					local offset	= attach.CFrame:ToObjectSpace(v.CFrame)
					v.CFrame		= charAttach.CFrame * offset
					
					local weld	= Instance.new("Weld")
						weld.Part0		= charAttach
						weld.Part1		= v
						weld.C0			= offset
						weld.Parent		= v
						
					v.Anchored		= false
					v.CanCollide	= false
					v.Massless		= true
				end
			end
			
			attach:Destroy()
			armor.Parent	= character.Attachments
		end
	end
	
	character:SetPrimaryPartCFrame(PREVIEW_CFRAME * rotation)
	character.Parent	= PREVIEW_GUI
	
	previewCharacter	= character
end

local function RefreshSlot(slot)
	local slotGui	= SLOT_GUI[slot .. "Frame"]
	slotGui.ViewportFrame:ClearAllChildren()
	
	local preview	= PREVIEWS:GetItemPreview(slot, EQUIPPED[slot].Value)
	if preview then
		preview.Parent	= slotGui.ViewportFrame
	end
end

local function Return()
	SLOT_GUI.Visible			= true
	SELECTION_GUI.Visible		= false
	TITLE_GUI.TitleLabel.Text	= "CHARACTER"
	
	previewArmor	= false
	previewEmote	= false
	RefreshCharacter()
end

local function SelectItem(slot)
	currentSlot			= slot
	SLOT_GUI.Visible	= false
	
	if SLOT_REPLACEMENTS[slot] then
		TITLE_GUI.TitleLabel.Text	= string.upper(SLOT_REPLACEMENTS[slot])
	else
		TITLE_GUI.TitleLabel.Text	= string.upper(slot)
	end
	
	for _, v in pairs(SELECTION_GUI.ScrollingFrame:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	
	local items	= {}
	
	if slot == "SkinColor" then
		items	= INVENTORY.SkinColors:GetChildren()
	elseif slot == "Face" then
		items	= INVENTORY.Faces:GetChildren()
	elseif slot == "Hat" or slot == "Hat2" then
		items	= INVENTORY.Hats:GetChildren()
	elseif slot == "Outfit" then
		items	= INVENTORY.Outfits:GetChildren()
	elseif slot == "Armor" then
		items	= INVENTORY.Armors:GetChildren()
	elseif slot == "Backpack" then
		items	= INVENTORY.Backpacks:GetChildren()
	elseif slot == "Aura" then
		items	= INVENTORY.Auras:GetChildren()
	elseif slot == "Emote" then
		items	= INVENTORY.Emotes:GetChildren()
	elseif slot == "KillEffect" then
		items	= INVENTORY.KillEffects:GetChildren()
	end
	
	if SELECTION_GUI.FilterBox.Text ~= "" then
		if #items > 0 then
			for i = #items, 1, -1 do
				if not string.match(string.lower(items[i].Name), string.lower(SELECTION_GUI.FilterBox.Text)) then
					table.remove(items, i)
				end
			end
		end
	end
	
	table.sort(items, function(a, b)
		return a.Name < b.Name
	end)
	
	for i, item in pairs(items) do
		local frame		= script.ItemFrame:Clone()
			frame.Name				= item.Name
			frame.LayoutOrder		= (item.Name == "Default" or item.Name == "None") and 0 or i
			frame.TitleLabel.Text	= string.upper(item.Name)
			frame.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
			frame.EquippedLabel.Visible			= EQUIPPED[slot].Value == item.Name
			
		if slot == "SkinColor" then
			frame.TitleLabel.Visible		= false
			frame.BackgroundLabel.Visible	= false
		end
		
		frame.Parent	= SELECTION_GUI.ScrollingFrame
			
		local preview	= PREVIEWS:GetItemPreview(slot, item.Name)
		if preview then
			preview.Parent	= frame.ViewportFrame
		end
		
		frame.Button.MouseButton1Click:Connect(function()
			script.EquipSound:Play()
			script.TabSound:Play()
			EQUIPPED[slot].Value	= item.Name
			REMOTES.EquipItem:FireServer(slot, item.Name)
			
			for _, v in pairs(SELECTION_GUI.ScrollingFrame:GetChildren()) do
				if v:FindFirstChild("EquippedLabel") then
					v.EquippedLabel.Visible	= EQUIPPED[slot].Value == v.Name
				end
			end
		end)
		
		--[[if slot == "Emote" then
			local animator	= emotes[preview]
			frame.Button.MouseEnter:Connect(function()
				emotes[preview]	= animator
			end)
			
			frame.Button.MouseLeave:Connect(function()
				emotes[preview]	= nil
			end)
		end]]
	end
	
	local size			= SELECTION_GUI.ScrollingFrame.AbsoluteSize
	local ratio			= size.X / size.Y
	local maxCells		= SELECTION_GUI.ScrollingFrame.UIGridLayout.FillDirectionMaxCells
	local numLines		= math.ceil(#items / maxCells)
	local canvasSize	= numLines / maxCells * ratio - 0.1
	
	SELECTION_GUI.ScrollingFrame.CanvasSize				= UDim2.new(0, 0, canvasSize, 0)
	SELECTION_GUI.ScrollingFrame.UIGridLayout.CellSize	= UDim2.new(1 / maxCells, 0, canvasSize <= 1 and 1 / maxCells * ratio or 1 / numLines, 0)
	
	SELECTION_GUI.Visible		= true
	
	if slot == "Armor" then
		previewArmor	= true
		RefreshCharacter()
	elseif slot == "Emote" then
		previewEmote	= true
	end
end

-- events

SELECTION_GUI.DoneButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	Return()
end)

SELECTION_GUI.FilterBox:GetPropertyChangedSignal("Text"):Connect(function()
	if SELECTION_GUI.Visible then
		SelectItem(currentSlot)
	end
end)

UserInputService.InputBegan:Connect(function(inputObject, processed)
	if not processed then
		if GUI.Visible then
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
				dragging	= true
				lastX		= UserInputService:GetMouseLocation().X
				velocity	= 0
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(inputObject, processed)
	if inputObject.UserInputType == Enum.UserInputType.MouseButton1 or inputObject.UserInputType == Enum.UserInputType.MouseButton2 then
		dragging	= false
	end
end)

UserInputService.InputChanged:Connect(function(inputObject, processed)
	if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging and GUI.Visible then
			local offset	= inputObject.Position.X - lastX
			lastX			= inputObject.Position.X
			
			local amount	= offset/PREVIEW_GUI.AbsoluteSize.X
			velocity		= amount * 80
			
			rotation	= rotation * CFrame.Angles(0, amount * 4, 0)
		end
	end
end)

-- initiate

PREVIEW_GUI.CurrentCamera	= PREVIEWS.IconCamera

for _, slot in pairs(EQUIPPED:GetChildren()) do
	slot.Changed:Connect(function()
		RefreshCharacter()
		RefreshSlot(slot.Name)
	end)
	
	local slotGui	= SLOT_GUI[slot.Name .. "Frame"]
	slotGui.ViewportFrame.CurrentCamera	= PREVIEWS.IconCamera
	
	slotGui.Button.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		SELECTION_GUI.FilterBox.Text	= ""
		SelectItem(slot.Name)
	end)
	
	RefreshSlot(slot.Name)
end

RefreshCharacter()

local previewAnimator	= script.EmoteCharacter:Clone()
	previewAnimator.Parent	= Workspace

previewAnimator.Humanoid:LoadAnimation(previewAnimator.Idle):Play()

local emoteAnimations	= {}

RunService:BindToRenderStep("CustomizeAnimate", 10, function(deltaTime)
	if not dragging then
		rotation	= rotation * CFrame.Angles(0, velocity * deltaTime, 0)
	end
	if velocity > 0 then
		velocity	= math.max(velocity - deltaTime * 4, 0)
	elseif velocity < 0 then
		velocity	= math.min(velocity + deltaTime * 4, 0)
	end
	
	if previewCharacter then
		previewCharacter.PrimaryPart.CFrame	= PREVIEW_CFRAME * rotation
		
		for _, v in pairs(previewAnimator:GetChildren()) do
			if v:IsA("BasePart") and v ~= previewAnimator.PrimaryPart then
				previewCharacter[v.Name].CFrame	= previewCharacter.PrimaryPart.CFrame * previewAnimator.PrimaryPart.CFrame:ToObjectSpace(v.CFrame)
			end
		end
		for _, v in pairs(previewCharacter.Attachments:GetDescendants()) do
			if v:IsA("Weld") then
				v.Part1.CFrame	= v.Part0.CFrame * v.C0 * v.C1:Inverse()
			end
		end
		
		if previewEmote then
			if not emoteAnimations[EQUIPPED.Emote.Value] then
				local emote	= CUSTOMIZATION.Emotes:FindFirstChild(EQUIPPED.Emote.Value)
				if emote then
					emote	= emote:Clone()
						emote.Parent	= previewAnimator
						
					emoteAnimations[emote.Name]			= previewAnimator.Humanoid:LoadAnimation(emote)
					emoteAnimations[emote.Name].Looped	= true
				end
			end
			for n, anim in pairs(emoteAnimations) do
				if n == EQUIPPED.Emote.Value then
					if not anim.IsPlaying then
						anim:Play()
					end
				elseif anim.IsPlaying then
					anim:Stop()
				end
			end
		else
			for _, v in pairs(emoteAnimations) do
				if v.IsPlaying then
					v:Stop()
				end
			end
		end
	end
end)