-- services

local Workspace		= game:GetService("Workspace")
local Players		= game:GetService("Players")
local StarterGui	= game:GetService("StarterGui")

-- constants

local CAMERA		= Workspace.CurrentCamera
local PLAYER		= Players.LocalPlayer
local PLAYER_GUI	= PLAYER:WaitForChild("PlayerGui")

-- initiate

repeat local success = pcall(function() StarterGui:SetCore("TopbarEnabled", false) end) wait() until success

for _, v in pairs(StarterGui:GetChildren()) do
	v:Clone().Parent	= PLAYER_GUI
end

CAMERA.CameraType	= Enum.CameraType.Scriptable
CAMERA.CFrame		= CFrame.new(0, 0, 100)