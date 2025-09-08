-- services

-- constants

local GUI			= script.Parent
local BUTTON_GUI	= GUI:WaitForChild("PageButtons")
local PAGE_GUI		= GUI:WaitForChild("Pages")

-- variables

local currentPage	= ""

-- functions

local function SetPage(newPage)
	if currentPage ~= newPage then
		currentPage	= newPage
		
		for _, button in pairs(BUTTON_GUI:GetChildren()) do
			if button:IsA("GuiButton") then
				if button.Name == currentPage .. "Button" then
					button.Size	= UDim2.new(1, 0, 1, 0)
				else
					button.Size	= UDim2.new(0.8, 0, 0.8, 0)
				end
			end
		end
		
		for _, page in pairs(PAGE_GUI:GetChildren()) do
			page.Visible	= page.Name == currentPage
		end
	end
end

-- events

for _, button in pairs(BUTTON_GUI:GetChildren()) do
	if button:IsA("GuiButton") then
		local page	= string.match(button.Name, "^(.-)Button")
		
		button.MouseButton1Click:connect(function()
			script.TabSound:Play()
			SetPage(page)
		end)
	end
end

-- initiate

SetPage("Lobby")