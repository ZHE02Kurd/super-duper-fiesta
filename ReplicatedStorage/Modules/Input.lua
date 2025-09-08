-- services

local UserInputService	= game:GetService("UserInputService")
local ReplicatedStorage	= game:GetService("ReplicatedStorage")
local RunService		= game:GetService("RunService")
local Players			= game:GetService("Players")

-- constants

local PLAYER_DATA	= ReplicatedStorage:WaitForChild("PlayerData")
local PLAYER		= Players.LocalPlayer
	
local REPLACEMENTS	= {
	Zero	= "0";
	One		= "1";
	Two		= "2";
	Three	= "3";
	Four	= "4";
	Five	= "5";
	Six		= "6";
	Seven	= "7";
	Eight	= "8";
	Nine	= "9";
	
	MouseButton1	= "MB1";
	MouseButton2	= "MB2";
	MouseButton3	= "MB3";
	Return			= "Enter";
	Slash			= "/";
	Tilde			= "~";
	Backquote		= "`";
}

-- variables

local initialized	= false

local actions		= {}
local defaults		= {}

local actionBegan, actionEnded

-- functions

local function RegisterAction(action, primary, secondary)
	local info	= {
		Primary		= primary;
		Secondary	= secondary;
	}
	
	actions[action]	= info
end

local function ActionFromInputObject(inputObject)
	for action, info in pairs(actions) do
		if info.Primary then
			if info.Primary.EnumType == Enum.KeyCode then
				if inputObject.KeyCode == info.Primary then
					return action
				end
			elseif info.Primary.EnumType == Enum.UserInputType then
				if inputObject.UserInputType == info.Primary then
					return action
				end
			end
		end
		
		if info.Secondary then
			if info.Secondary.EnumType == Enum.KeyCode then
				if inputObject.KeyCode == info.Secondary then
					return action
				end
			elseif info.Secondary.EnumType == Enum.UserInputType then
				if inputObject.UserInputType == info.Secondary then
					return action
				end
			end
		end
	end
end

-- events

UserInputService.InputBegan:connect(function(inputObject, processed)
	local action	= ActionFromInputObject(inputObject)
	
	if action then
		actionBegan:Fire(action, processed)
	end
end)

UserInputService.InputEnded:connect(function(inputObject, processed)
	local action	= ActionFromInputObject(inputObject)
	
	if action then
		actionEnded:Fire(action, processed)
	end
end)

-- module

local INPUT	= {}

function INPUT.GetActionInput(self, action)
	local input	= "nil"
	
	if actions[action] then
		local primary, secondary	= actions[action].Primary, actions[action].Secondary
		
		if primary then
			input	= primary.Name
		elseif secondary then
			input	= secondary.Name
		end
	end
	
	if REPLACEMENTS[input] then
		input	= REPLACEMENTS[input]
	end
	
	return string.upper(input)
end

function INPUT.GetAllActionInputs(self, action)
	local inputP, inputS	= "nil", "nil"
	
	if actions[action] then
		local primary, secondary	= actions[action].Primary, actions[action].Secondary
		
		if primary then
			inputP	= primary.Name
		end
		if secondary then
			inputS	= secondary.Name
		end
	end
	
	if REPLACEMENTS[inputP] then
		inputP	= REPLACEMENTS[inputP]
	end
	if REPLACEMENTS[inputS] then
		inputS	= REPLACEMENTS[inputS]
	end
	
	return string.upper(inputP), string.upper(inputS)
end

if not initialized then
	local keybindChanged	= Instance.new("BindableEvent")
	INPUT.KeybindChanged	= keybindChanged.Event
	
	actionBegan	= Instance.new("BindableEvent")
	actionEnded	= Instance.new("BindableEvent")
	
	INPUT.ActionBegan	= actionBegan.Event
	INPUT.ActionEnded	= actionEnded.Event
	
	-- register actions
	
	local playerData	= PLAYER_DATA:WaitForChild(PLAYER.Name)
	local keybinds		= playerData:WaitForChild("Keybinds")
	
	local function Register(action, bindP, bindS)
		local primary, secondary
		if bindP then
			local A, B	= string.match(bindP, "(.-)%.(.+)")
			
			if A and B then
				primary	= Enum[A][B]
			end
		end
		if bindS then
			local A, B	= string.match(bindS, "(.-)%.(.+)")
			
			if A and B then
				secondary	= Enum[A][B]
			end
		end
		
		RegisterAction(action, primary, secondary)
		keybindChanged:Fire(action)
	end
	
	local function Handle(keybind)
		local action	= keybind.Name
		local bind		= keybind.Value
		
		if string.match(bind, ";") then
			local bindP, bindS	= string.match(bind, "(.-);(.+)")
			
			if bindP and bindS then
				Register(action, bindP, bindS)
			elseif bindP then
				Register(action, bindP)
			elseif bindS then
				Register(action, nil, bindS)
			end
		else
			Register(action, bind)
		end
	end
	
	keybinds.ChildAdded:connect(function(keybind)
		keybind.Changed:connect(function()
			Handle(keybind)
		end)
		
		RunService.Stepped:wait()
		Handle(keybind)
	end)
	
	repeat
		RunService.Stepped:wait()
	until #keybinds:GetChildren() > 0
	
	for _, keybind in pairs(keybinds:GetChildren()) do
		keybind.Changed:connect(function()
			Handle(keybind)
		end)
		
		Handle(keybind)
	end
	
	initialized			= true
end

return INPUT