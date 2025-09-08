-- services

local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local TweenService		= game:GetService("TweenService")
local RunService		= game:GetService("RunService")
local Workspace			= game:GetService("Workspace")
local Players			= game:GetService("Players")

-- constants

local PLAYER		= Players.LocalPlayer
local CUSTOMIZATION	= ReplicatedStorage:WaitForChild("Customization")
local PLAYER_DATA	= ReplicatedStorage:WaitForChild("PlayerData")
local SQUADS		= ReplicatedStorage:WaitForChild("Squads")
local REMOTES		= ReplicatedStorage:WaitForChild("Remotes")

local GUI			= script.Parent
local SQUAD_GUI		= GUI:WaitForChild("Squad")
local READY_GUI		= GUI:WaitForChild("Ready")
local INVITE_GUI	= GUI:WaitForChild("Invites")
local SEND_GUI		= GUI:WaitForChild("SendInvite")

local READY_COLOR		= Color3.fromRGB(255, 217, 23)
local NOT_READY_COLOR	= Color3.fromRGB(255, 51, 51)
local CANCEL_COLOR		= Color3.fromRGB(89, 120, 141)

local ICON_CAM	= Instance.new("Camera")
	ICON_CAM.Name			= "MenuIconCamera"
	ICON_CAM.CameraType		= Enum.CameraType.Scriptable
	ICON_CAM.FieldOfView	= 50
	ICON_CAM.CFrame			= CFrame.Angles(-0.2, 0, 0)
	ICON_CAM.Parent			= Workspace

-- variables

local displays	= {}
local currentSquad, currentPlayer

local squadConnections	= {}
local squadPlayers		= {}
local squadFrames		= {}

local joining	= false

local incomingInvites	= 0
local invitesDeclined	= false
local incoming			= {}

local inviteTarget

-- functions

local function RefreshDisplay(index)
	local frame	= squadFrames[index]
	local info
	
	for _, i in pairs(squadPlayers) do
		if i.Index == index then
			info	= i
			break
		end
	end
	
	frame.ViewportFrame:ClearAllChildren()
	local preview	= script.PlayerPreview:Clone()
		preview:SetPrimaryPartCFrame(CFrame.new(ICON_CAM.CFrame.LookVector * 8 + Vector3.new(0, -0.5, 0)) * CFrame.Angles(0, math.pi, 0))
		preview.Parent	= frame.ViewportFrame
		
	if info then
		info.Preview		= preview
		local playerData	= PLAYER_DATA:FindFirstChild(info.Player.Name)
		
		if playerData then
			frame.PlayerInfo.NameLabel.Text		= info.Player.Name
			frame.PlayerInfo.LevelLabel.Text	= "LEVEL " .. tostring(playerData.Ranking.Level.Value)
			frame.PlayerInfo.Visible	= true
			frame.InviteFrame.Visible	= false
			frame.ViewportFrame.ImageTransparency	= 0
			
			local playerValue	= currentSquad.Players:FindFirstChild(info.Player.Name)
			if playerValue.Value then
				frame.PlayerInfo.WaitingLabel.Visible	= false
				
				frame.PlayerInfo.ReadyLabel.Size		= UDim2.new(0.4, 0, 0.06, 0)
				frame.PlayerInfo.ReadyLabel.Visible		= true
			else
				frame.PlayerInfo.WaitingLabel.Visible	= true
				frame.PlayerInfo.ReadyLabel.Visible		= false
			end
			
			local equipped	= playerData.Equipped
			
			local skinColor	= CUSTOMIZATION.SkinColors:FindFirstChild(equipped.SkinColor.Value)
			if skinColor then
				for _, v in pairs(preview:GetChildren()) do
					if v:IsA("BasePart") then
						v.Color	= skinColor.Value
					end
				end
			end
			
			local face	= CUSTOMIZATION.Faces:FindFirstChild(equipped.Face.Value)
			if face then
				face	= face:Clone()
					face.Parent	= preview.Head
			end
			
			local outfit	= CUSTOMIZATION.Outfits:FindFirstChild(equipped.Outfit.Value)
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
			
			local hat	= CUSTOMIZATION.Hats:FindFirstChild(equipped.Hat.Value)
			if hat then
				hat	= hat:Clone()
				
				local attach		= hat.PrimaryPart
				local charAttach	= preview[attach.Name]
				
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
				hat.Parent	= preview.Attachments
			end
			
			local hat2	= CUSTOMIZATION.Hats:FindFirstChild(equipped.Hat2.Value)
			if hat2 then
				hat2	= hat2:Clone()
				
				local attach		= hat2.PrimaryPart
				local charAttach	= preview[attach.Name]
				
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
				hat2.Parent	= preview.Attachments
			end
			
			local backpack	= CUSTOMIZATION.Backpacks:FindFirstChild(equipped.Backpack.Value)
			if backpack then
				backpack	= backpack:Clone()
				
				local attach		= backpack.PrimaryPart
				local charAttach	= preview[attach.Name]
				
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
				backpack.Parent	= preview.Attachments
			end
		end
	else
		frame.PlayerInfo.Visible	= false
		frame.InviteFrame.Visible	= true
		frame.ViewportFrame.ImageTransparency	= 0.5
	end
end

local function RefreshDisplays()
	local players	= {}
	
	for _, info in pairs(squadPlayers) do
		table.insert(players, info.Player)
	end
	
	local index	= 2
	
	for i, player in pairs(players) do
		if player == PLAYER then
			squadPlayers[player.Name].Index	= 1
		else
			squadPlayers[player.Name].Index	= index
			index	= index + 1
		end
	end
	
	for i = 1, 4 do
		RefreshDisplay(i)
	end
end

local function UpdateLeader()
	local isLeader	= currentSquad.Leader.Value == PLAYER.Name
	
	for index = 1, 4 do
		local frame	= squadFrames[index]
		local info
		
		for _, i in pairs(squadPlayers) do
			if i.Index == index then
				info	= i
				break
			end
		end
		
		if info then
			frame.PlayerInfo.LeaderLabel.Visible	= info.Player.Name == currentSquad.Leader.Value
			
			frame.PlayerInfo.KickButton.Visible		= isLeader and info.Player ~= PLAYER
			frame.PlayerInfo.LeaderButton.Visible	= isLeader and info.Player ~= PLAYER
		end
		
		frame.InviteFrame.InviteButton.Visible	= isLeader
	end
	
	READY_GUI.QueueButton.TextLabel.TextTransparency	= isLeader and 0 or 0.5
	READY_GUI.FillButton.TextLabel.TextTransparency		= isLeader and 0 or 0.5
end

local function AddPlayer(name)
	GUI.LeaveButton.Visible	= #currentSquad.Players:GetChildren() > 1
	if not squadPlayers[name] then
		if name ~= PLAYER.Name then
			script.JoinSound:Play()
		end
		local player	= Players:FindFirstChild(name)
		
		local info	= {
			Player		= player;
			Connections	= {};
		}
		
		local animator	= script.PlayerAnimator:Clone()
			animator.Parent	= Workspace
			
		animator.Humanoid:LoadAnimation(animator.Idle):Play()
			
		info.Animator		= animator
		squadPlayers[name]	= info
		
		RefreshDisplays()
		UpdateLeader()
		
		
		local playerData	= PLAYER_DATA:FindFirstChild(player.Name)
		if playerData then
			for _, v in pairs(playerData.Equipped:GetChildren()) do
				table.insert(info.Connections, v.Changed:Connect(function()
					RefreshDisplay(info.Index)
				end))
			end
			
			table.insert(info.Connections, playerData.Ranking.Level.Changed:Connect(function()
				local frame		= squadFrames[info.Index]
				if frame then
					frame.PlayerInfo.LevelLabel.Text	= "LEVEL " .. tostring(playerData.Ranking.Level.Value)
				end
			end))
		end
		
		local playerValue	= currentSquad.Players:FindFirstChild(player.Name)
		if playerValue then
			table.insert(info.Connections, playerValue.Changed:Connect(function()
				local frame		= squadFrames[info.Index]
				if frame then
					if playerValue.Value then
						frame.PlayerInfo.WaitingLabel.Visible	= false
						
						frame.PlayerInfo.ReadyLabel.Size		= UDim2.new(2, 0, 0.2, 0)
						frame.PlayerInfo.ReadyLabel.Visible		= true
						
						local tweenInfo	= TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
						local tween		= TweenService:Create(frame.PlayerInfo.ReadyLabel, tweenInfo, {Size = UDim2.new(0.4, 0, 0.06, 0)})
						tween:Play()
					else
						frame.PlayerInfo.WaitingLabel.Visible	= true
						frame.PlayerInfo.ReadyLabel.Visible		= false
					end
				end
			end))
			
			local frame		= squadFrames[info.Index]
			if frame then
				if playerValue.Value then
					frame.PlayerInfo.WaitingLabel.Visible	= false
					
					frame.PlayerInfo.ReadyLabel.Size		= UDim2.new(0.4, 0, 0.06, 0)
					frame.PlayerInfo.ReadyLabel.Visible		= true
				else
					frame.PlayerInfo.WaitingLabel.Visible	= true
					frame.PlayerInfo.ReadyLabel.Visible		= false
				end
			end
		end
	end
end

local function RemovePlayer(name)
	GUI.LeaveButton.Visible	= #currentSquad.Players:GetChildren() > 1
	if squadPlayers[name] then
		for _, connection in pairs(squadPlayers[name].Connections) do
			connection:Disconnect()
		end
		squadPlayers[name].Animator:Destroy()
		
		squadPlayers[name]	= nil
		
		RefreshDisplays()
	end
end

local function UpdateReady()
	READY_GUI.PlayButton.TextLabel.Text		= currentPlayer.Value and "CANCEL" or "READY UP"
	READY_GUI.PlayButton.ShadowLabel.Text	= READY_GUI.PlayButton.TextLabel.Text
	READY_GUI.PlayButton.ImageColor3		= currentPlayer.Value and CANCEL_COLOR or READY_COLOR
end

local function UpdateQueue()
	READY_GUI.QueueButton.TextLabel.Text		= string.upper(currentSquad.Queue.Value)
	READY_GUI.QueueButton.ShadowLabel.Text		= READY_GUI.QueueButton.TextLabel.Text
end

local function UpdateFill()
	READY_GUI.FillButton.TextLabel.Text		= currentSquad.Fill.Value and "FILL" or "NO FILL"
	READY_GUI.FillButton.ShadowLabel.Text	= READY_GUI.FillButton.TextLabel.Text
end

local function UpdateSquad(squad)
	for _, connection in pairs(squadConnections) do
		connection:Disconnect()
	end
	squadConnections	= {}
	for _, info in pairs(squadPlayers) do
		for _, connection in pairs(info.Connections) do
			connection:Disconnect()
		end
	end
	squadPlayers		= {}
	
	if squad then
		currentSquad	= squad
		currentPlayer	= currentSquad.Players:FindFirstChild(PLAYER.Name)
		
		table.insert(squadConnections, currentSquad.Players.ChildAdded:Connect(function(child)
			AddPlayer(child.Name)
		end))
		
		table.insert(squadConnections, currentSquad.Players.ChildRemoved:Connect(function(child)
			RemovePlayer(child.Name)
		end))
		
		table.insert(squadConnections, currentSquad.Leader.Changed:Connect(UpdateLeader))
		table.insert(squadConnections, currentSquad.Queue.Changed:Connect(UpdateQueue))
		table.insert(squadConnections, currentSquad.Fill.Changed:Connect(UpdateFill))
		
		table.insert(squadConnections, currentPlayer.Changed:Connect(UpdateReady))
		
		for _, p in pairs(currentSquad.Players:GetChildren()) do
			AddPlayer(p.Name)
		end
		
		UpdateLeader()
		UpdateReady()
		UpdateQueue()
		UpdateFill()
	end
end

local function GetSquad()
	for _, squad in pairs(SQUADS:GetChildren()) do
		if squad.Players:FindFirstChild(PLAYER.Name) then
			return squad
		end
	end
end

local function UpdateIncoming()
	GUI.InvitesButton.NotificationLabel.TextLabel.Text	= tostring(incomingInvites)
	GUI.InvitesButton.NotificationLabel.Visible			= incomingInvites > 0
end

-- events

SEND_GUI.TextBox:GetPropertyChangedSignal("Text"):connect(function()
	for _, v in pairs(SEND_GUI.Names:GetChildren()) do
		if v:IsA("GuiObject") then
			v:Destroy()
		end
	end
	
	local search	= string.lower(SEND_GUI.TextBox.Text)
	if search ~= "" then
		local players	= {}
		
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= PLAYER and not currentSquad.Players:FindFirstChild(player.Name) then
				local name	= string.lower(player.Name)
				if string.match(name, "^" .. search) then
					table.insert(players, player)
				end
			end
		end
		
		for i, player in pairs(players) do
			local button	= script.NameButton:Clone()
				button.LayoutOrder			= i
				button.TextLabel.Text		= player.Name
				button.HighlightLabel.Text	= string.sub(player.Name, 1, #search)
				button.Parent				= SEND_GUI.Names
				
			button.MouseButton1Click:Connect(function()
				script.ClickSound:Play()
				inviteTarget			= player
				SEND_GUI.TextBox.Text	= player.Name
			end)
		end
		
		if #players > 0 then
			inviteTarget	= players[#players]
		else
			inviteTarget	= nil
		end
	end
end)

SEND_GUI.TextBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		if inviteTarget then
			SEND_GUI.TextBox.Text	= inviteTarget.Name
		end
	end
end)

SEND_GUI.CloseButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	SEND_GUI.Visible	= false
end)

SEND_GUI.InviteButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	if inviteTarget then
		script.InviteSound:Play()
		REMOTES.SendInvite:FireServer(inviteTarget)
		SEND_GUI.Visible	= false
	end
end)

REMOTES.RespondToInvite.OnClientInvoke = function(name)
	if not incoming[name] then
		incoming[name]	= true
		incomingInvites	= incomingInvites + 1
		script.AlertSound:Play()
		UpdateIncoming()
		
		local frame	= script.IncomingFrame:Clone()
			frame.TextLabel.Text	= name
			frame.Parent			= INVITE_GUI.Invites
			
		local response	= nil
			
		frame.AcceptButton.MouseButton1Click:connect(function()
			response	= true
			script.ClickSound:Play()
		end)
		
		frame.DeclineButton.MouseButton1Click:connect(function()
			response	= false
			script.ClickSound:Play()
		end)	
		
		local start		= tick()
		
		repeat
			RunService.Stepped:wait()
		until response ~= nil or tick() - start > 30 or invitesDeclined
		
		frame:Destroy()
		incomingInvites	= incomingInvites - 1
		incoming[name]	= nil
		UpdateIncoming()
		
		if response then
			GUI.InvitesButton.Visible	= true
			INVITE_GUI.Visible			= false
			return response
		else
			return false
		end
	end
	return false
end

GUI.InvitesButton.MouseButton1Click:connect(function()
	GUI.InvitesButton.Visible	= false
	INVITE_GUI.Visible			= true
	script.ClickSound:Play()
end)

INVITE_GUI.CloseButton.MouseButton1Click:connect(function()
	GUI.InvitesButton.Visible	= true
	INVITE_GUI.Visible			= false
	script.ClickSound:Play()
end)

INVITE_GUI.DeclineAllButton.MouseButton1Click:connect(function()
	GUI.InvitesButton.Visible	= true
	INVITE_GUI.Visible			= false
	script.ClickSound:Play()
	
	invitesDeclined	= true
	wait(0.1)
	invitesDeclined = false
end)

REMOTES.MatchInfo.OnClientEvent:connect(function(action, ...)
	if action == "Players" then
		local queue, inQueue, needed, timer	= ...
		local minutes	= math.floor(timer / 60)
		local seconds	= timer - (minutes * 60)
		local timerText	= tostring(minutes) .. ":" .. string.rep("0", 2 - #tostring(seconds)) .. tostring(seconds)
		
		READY_GUI.InfoLabel.TextLabel.Text	= "IN QUEUE | " .. tostring(inQueue) .. "/" .. tostring(needed) .. " | " .. timerText
		READY_GUI.InfoLabel.Visible		= true
		READY_GUI.QueueButton.Visible	= false
		READY_GUI.FillButton.Visible	= false
	elseif action == "Leave" then
		READY_GUI.InfoLabel.Visible		= false
		READY_GUI.QueueButton.Visible	= true
		READY_GUI.FillButton.Visible	= true
	elseif action == "Join" then
		joining	= true
		READY_GUI.InfoLabel.TextLabel.Text	= "JOINING..."
		READY_GUI.InfoLabel.Visible		= true
		READY_GUI.PlayButton.Visible	= false
		READY_GUI.QueueButton.Visible	= false
		READY_GUI.FillButton.Visible	= false
	end
end)

READY_GUI.PlayButton.MouseButton1Click:Connect(function()
	if not joining then
		script.ClickSound:Play()
		local ready	= not currentPlayer.Value
		if ready then
			script.ReadySound:Play()
		end
		REMOTES.Ready:FireServer(ready)
	end
end)

READY_GUI.QueueButton.MouseButton1Click:Connect(function()
	if currentSquad.Leader.Value == PLAYER.Name then
		script.ClickSound:Play()
		REMOTES.ToggleQueue:FireServer()
	end
end)

READY_GUI.FillButton.MouseButton1Click:Connect(function()
	if currentSquad.Leader.Value == PLAYER.Name then
		script.ClickSound:Play()
		REMOTES.ToggleFill:FireServer()
	end
end)

SQUADS.DescendantAdded:Connect(function(child)
	if child:IsA("BoolValue") and child.Name == PLAYER.Name then
		local squad	= child.Parent.Parent
		UpdateSquad(squad)
	end
end)

GUI.LeaveButton.MouseButton1Click:Connect(function()
	script.ClickSound:Play()
	REMOTES.LeaveSquad:FireServer()
end)

-- initiate

local frame1	= script.PlayerFrame:Clone()
	frame1.ViewportFrame.CurrentCamera	= ICON_CAM
	frame1.Position		= UDim2.new(0.5, 0, 0.5, 0)
	frame1.Size			= UDim2.new(0.8, 0, 1, 0)
	frame1.ZIndex		= 3
	frame1.Parent		= SQUAD_GUI
	table.insert(squadFrames, frame1)
	
local frame2	= script.PlayerFrame:Clone()
	frame2.ViewportFrame.CurrentCamera	= ICON_CAM
	frame2.Position		= UDim2.new(0.25, 0, 0.5, 0)
	frame2.Size			= UDim2.new(0.7, 0, 0.9, 0)
	frame2.ZIndex		= 2
	frame2.Parent		= SQUAD_GUI
	table.insert(squadFrames, frame2)
	
local frame3	= script.PlayerFrame:Clone()
	frame3.ViewportFrame.CurrentCamera	= ICON_CAM
	frame3.Position		= UDim2.new(0.75, 0, 0.5, 0)
	frame3.Size			= UDim2.new(0.7, 0, 0.9, 0)
	frame3.ZIndex		= 2
	frame3.Parent		= SQUAD_GUI
	table.insert(squadFrames, frame3)
	
local frame4	= script.PlayerFrame:Clone()
	frame4.ViewportFrame.CurrentCamera	= ICON_CAM
	frame4.Position		= UDim2.new(0.05, 0, 0.5, 0)
	frame4.Size			= UDim2.new(0.65, 0, 0.8, 0)
	frame4.ZIndex		= 1
	frame4.Parent		= SQUAD_GUI
	table.insert(squadFrames, frame4)
	
for i, frame in pairs(squadFrames) do
	frame.PlayerInfo.KickButton.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		
		local info
		
		for _, v in pairs(squadPlayers) do
			if v.Index == i then
				info	= v
			end
		end
		
		if info then
			REMOTES.Kick:FireServer(info.Player)
		end
	end)
	
	frame.PlayerInfo.LeaderButton.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		
		local info
		
		for _, v in pairs(squadPlayers) do
			if v.Index == i then
				info	= v
			end
		end
		
		if info then
			REMOTES.SetLeader:FireServer(info.Player)
		end
	end)
	
	frame.InviteFrame.InviteButton.MouseButton1Click:Connect(function()
		script.ClickSound:Play()
		SEND_GUI.Visible	= true
		SEND_GUI.TextBox:CaptureFocus()
	end)
end

UpdateSquad(GetSquad())

RunService:BindToRenderStep("LobbyAnimate", 10, function(deltaTime)
	for _, info in pairs(squadPlayers) do
		if info.Preview and info.Animator then
			for _, v in pairs(info.Animator:GetChildren()) do
				if v:IsA("BasePart") and v ~= info.Animator.PrimaryPart then
					info.Preview[v.Name].CFrame	= info.Preview.PrimaryPart.CFrame * info.Animator.PrimaryPart.CFrame:ToObjectSpace(v.CFrame)
				end
			end
			for _, v in pairs(info.Preview.Attachments:GetDescendants()) do
				if v:IsA("Weld") then
					v.Part1.CFrame	= v.Part0.CFrame * v.C0 * v.C1:Inverse()
				end
			end
		end
	end
end)