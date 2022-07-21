if getgenv().main_module then
    main_module.MainFrame:Destroy()
	print('old module removed')
end;

getgenv().main_module = { }

main_module.MainFrame = Instance.new('Folder', game.CoreGui)
main_module.MainFrame.Name = 'Main_Module'

main_module.Library = { }
main_module.Console = { }
main_module.Esp = { }
main_module.Admin = { }
main_module.Aimbot = { }

local plr = game.Players.LocalPlayer
local uis = game:GetService('UserInputService')

local Y_CONSTANT = 22

-- // Function Library // --
getgenv().RayHit = function(v1, v2, v3, v4)
	local vector = (v2.Position - v1.Position).Unit
	local ray = Ray.new(v1.Position, vector * (v4 or 9e9)*-1)
	local hit = game.Workspace:FindPartOnRayWithIgnoreList(ray, v3)
	
	return hit
end;

local current_loops = { }
getgenv().RunLoop = function(v1, v2)
    current_loops[v1] = true
    spawn(function()
        repeat v2() wait() until current_loops[v1] == false
    end);
end;
getgenv().EndLoop = function(v1)
    current_loops[v1] = false
end;
-- // UI Library // --
local library = main_module.Library
library.gui = Instance.new('ScreenGui', main_module.MainFrame)
library.gui.Name = 'UI_Lib'

local MainFrame = Instance.new('Frame', library.gui)
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, 0, 0.025, 0)
MainFrame.Size = UDim2.new(0.95, 0, 0.275, 0)

local listLayout = Instance.new('UIListLayout', MainFrame)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0.01, 0)

function library:AddFrame(settings)
    --[[


    settings = {
        name = 'Title';
    }


    --]]
    local Frame = Instance.new('Frame', MainFrame)
    Frame.BackgroundColor3 = Color3.fromRGB(115, 80, 146)
    Frame.Size = UDim2.fromOffset(265, 0)
    Frame.BorderSizePixel = 0
    Frame.ChildAdded:Connect(function()
        Frame.Size = UDim2.new(0, 265, 0, (#Frame:GetChildren()-1)*Y_CONSTANT)
    end);
    Frame.ChildRemoved:Connect(function()
        Frame.Size = UDim2.new(0, 265, 0, (#Frame:GetChildren()-1)*Y_CONSTANT)
    end);
    
    local UIListLayout = Instance.new('UIListLayout', Frame)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local title = Instance.new('TextLabel', Frame)
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1, 0, 0, Y_CONSTANT)
    title.Font = Enum.Font.SourceSansBold
    title.Text = settings['name']
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(140, 140, 140)
    title.TextXAlignment = Enum.TextXAlignment.Center
    
    title.LayoutOrder = -1

    local Self = { }

    function Self:AddButton(txt, _function)
        local button = Instance.new('TextButton', Frame)
        button.TextColor3 = Color3.new(1,1,1)
        button.Text = txt
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 0, Y_CONSTANT)
        button.Font = Enum.Font.SourceSansItalic
        button.TextXAlignment = 'Left'
        button.TextSize = 14
        button.MouseButton1Click:Connect(function()
            _function()
        end);

        return button
    end;
    function Self:AddToggle(txt, _function)
        local state = false

        local button = Instance.new('TextButton', Frame)
        button.TextColor3 = Color3.new(1,1,1)
        button.Text = txt
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 0, Y_CONSTANT)
        button.Font = Enum.Font.SourceSansItalic
        button.TextXAlignment = 'Left'
        button.TextSize = 14

        local toggle = Instance.new('TextLabel', button)
        toggle.Size = UDim2.new(1, 0, 1, 0)
        toggle.Text = 'Off '
        toggle.TextColor3 = Color3.fromRGB(255, 0, 0)
        toggle.TextXAlignment = 'Right'
        toggle.BackgroundTransparency = 1
        toggle.Font = 'SourceSansBold'
        toggle.TextSize = 14
        
        button.MouseButton1Click:Connect(function()
            state = not state
            
            toggle.Text = state and 'On ' or 'Off '
            toggle.TextColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)

            _function(state)
        end);

        return button
    end;
    function Self:AddBox(txt, _function)
        local state = false

        local textbox = Instance.new('TextBox', Frame)
        textbox.PlaceholderText = txt
		textbox.Text = ''
		textbox.BackgroundTransparency = 0.9
		textbox.BackgroundColor3 = Color3.fromRGB(0,0,0)
		textbox.TextColor3 = Color3.new(1,1,1)
		textbox.TextXAlignment = 'Left'
        textbox.Size = UDim2.new(1, 0, 0, Y_CONSTANT)
		textbox.BorderSizePixel = 0
		textbox.Font = 'SourceSansItalic'
		textbox.TextSize = 14
        
        local placeholder_old = textbox.PlaceholderText

        textbox.FocusLost:Connect(function()
            _function(textbox.Text)
            textbox.PlaceholderText = placeholder_old..' ('..textbox.Text..')'
            textbox.Text = ''
        end);
        
        return textbox
    end;
    function Self:AddSwitch(txt, list, _function) -- add variable for index
        local _index = 1

        local button = Instance.new('TextButton', Frame)
        button.TextColor3 = Color3.new(1,1,1)
        button.Text = txt
        button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        button.BackgroundTransparency = 1
        button.Size = UDim2.new(1, 0, 0, Y_CONSTANT)
        button.Font = Enum.Font.SourceSansItalic
        button.TextXAlignment = 'Left'
        button.TextSize = 14

        local switcher = Instance.new('TextLabel', button)
        switcher.Size = UDim2.new(1, 0, 1, 0)
        switcher.Text = list[1]..' '
        switcher.TextColor3 = Color3.fromRGB(140, 140, 140)
        switcher.TextXAlignment = 'Right'
        switcher.BackgroundTransparency = 1
        switcher.Font = 'SourceSansBold'
        switcher.TextSize = 14

        button.MouseButton1Click:Connect(function()
            _index = (_index + 1) > #list and 1 or (_index + 1)
            switcher.Text = list[_index]..' '
            _function(list[_index])
        end);
        
        return button
    end;

    return Self
end;
function library:Toggle(x)
    MainFrame.Visible = x or not MainFrame.VisibleF
    return MainFrame.Visible;
end;

-- // Console // --
local Console = main_module.Console
Console.gui = Instance.new('ScreenGui', main_module.MainFrame)
Console.gui.Name = 'Console'

Console.commands = { }

function Console:Create(settings)
    --[[
        

    settings = {
        name = 'Title';
        capturekey = Enum.KeyCode.RightShift;
    }


    --]]

	local name = settings['name'] or 'Console'
	local capturekey = settings['capturekey'] or Enum.KeyCode.F1

    local ConsoleFrame = Instance.new('Frame', Console.gui)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(115, 80, 146)
    ConsoleFrame.BorderSizePixel = 0
    ConsoleFrame.Size = UDim2.new(1, 0, 0.3, 0)

	-- ADD TITLE
	local title = Instance.new('TextLabel', ConsoleFrame)
	title.TextColor3 = Color3.fromRGB(120, 120, 120)
	title.TextSize = 40
	title.Font = 'SourceSansBold'
	title.Size = UDim2.new(1, 0, 0.2, 0)
	title.BackgroundTransparency = 1
	title.Text = 'Console'

	local holder = Instance.new('Frame', ConsoleFrame)
	holder.BackgroundTransparency = 1
	holder.Size = UDim2.new(1, 0, 0.9, 0)

	local box = Instance.new('TextBox', ConsoleFrame)
	box.PlaceholderText = ''
	box.Text = ''
	box.BackgroundTransparency = 0.9
	box.BackgroundColor3 = Color3.fromRGB(0,0,0)
	box.TextColor3 = Color3.new(1,1,1)
	box.TextXAlignment = 'Left'
	box.Size = UDim2.new(1, 0, 0.1, 0)
	box.Position = UDim2.new(0, 0, 0.9, 0)
	box.BorderSizePixel = 0
	box.Font = 'SourceSansItalic'
	box.TextSize = 14

	local example = Instance.new('TextLabel', ConsoleFrame)
	example.Position = UDim2.new(0, 0, 0.925, 0)
	example.Size = UDim2.new(1, 0, 0.075, 0)
	example.Text = ''
	example.TextColor3 = Color3.new(1,1,1)
	example.TextXAlignment = 'Left'
	example.BackgroundTransparency = 1
	example.Font = 'SourceSansItalic'
	example.TextSize = 16
    example.Visible = false


	local newOutput = function(msg, clr)
		for i,v in pairs(holder:GetChildren()) do
			if v.Position.Y.Scale > 0 then
				v.Position = UDim2.new(0, 0, v.Position.Y.Scale - .075, 0)
			else
				v:Destroy()
			end;
		end;
		local newmsg = example:Clone()
		newmsg.Text = '[Console] '..msg
		newmsg.Parent = holder
		newmsg.Visible = true
		if clr then
			newmsg.TextColor3 = clr
		else
			newmsg.TextColor3 = Color3.fromRGB(255, 255, 255)
		end;
	end;

	uis.InputBegan:connect(function(key, gpi)
		if key.KeyCode == capturekey then
			if ConsoleFrame.Visible == true then
				ConsoleFrame.Visible = false
				box:ReleaseFocus()
			else
				ConsoleFrame.Visible = true
				wait()
				box:CaptureFocus()
			end;
		end;
	end);


	box.FocusLost:connect(function(_)
		if ConsoleFrame.Visible then
			local input = box.Text
            local rawinput = input:lower()
			local inputsep = rawinput:split(' ')

			local _index
			local foundFunc
			for i,v in pairs(Console.commands) do
				_index = ''
				for i2,v2 in pairs(inputsep) do
					_index = _index..inputsep[i2]
					if _index == i then -- got function

						local _newInput = table.concat(inputsep, ' ', i2+1)

						local v3, v4 = v(_newInput)
						if v3 then
							foundFunc = true
							newOutput(v3, v4 or Color3.fromRGB(255,255,255))
						end

					end
					_index = _index..' '
				end
			end

            if _ and not foundFunc then
				newOutput(input)
			end

			wait()
			box:CaptureFocus()
		end;
	end);


    Self = { }
    function Self:AddCommand(cmd, _function)
        Console.commands[cmd:lower()] = _function
    end;
    function Self:Output(...)
        newOutput(...)
    end;
    function Self:Clear()
        holder:ClearAllChildren()
    end;

	box:CaptureFocus()
    return Self
end;

-- // Esp // -- NEW!!!
local esp = main_module.Esp
esp.gui = Instance.new('ScreenGui', main_module.MainFrame)
esp.gui.Name = 'Esp'

function esp.new(settings)
	local folder = settings['folder']
	local color = settings['color'] or Color3.fromRGB(255, 255, 255)
	local transparency = settings['transparency'] or 0.5

	local newFolder = Instance.new('Folder', esp.gui)

	function makeESP(v1,v2,v3)
		local box = Instance.new('Highlight', newFolder)
		box.Name = v1.Name
		box.Adornee = v1
		box.FillTransparency = 1
		box.OutlineTransparency = v3 
		box.OutlineColor = v2
		
		spawn(function()
			repeat wait() until table.find(folder, v1)
			repeat wait() until not v1 or not table.find(folder, v1)
			box:Destroy()
		end)
	end

	for i,v in pairs(folder) do
		makeESP(v, color, transparency)
	end

	setmetatable(folder, {
		__newindex = function(_, index, value)
			--print(tostring(index) .. " has been added and set to " .. tostring(value))
			makeESP(value, color, transparency)
		end
	})

	local Self = { }

	function Self:SetColor(v1)
		for i,v in pairs(newFolder:GetChildren()) do
			v.OutlineColor = v1
		end
	end
	function Self:SetTransparency(v1)
		for i,v in pairs(newFolder:GetChildren()) do
			v.OutlineTransparency = tonumber(v1) or 0.75
		end
	end
	function Self:Remove()
		newFolder:Destroy()
	end

	return Self

end
-- function esp.new(settings)
	
-- 	local folder = settings['folder']
-- 	local color = settings['color'] or Color3.new(1,1,1)
-- 	local transparency = settings['transparency'] or 0.75
-- 	local parent = settings['parent'] or esp.gui
-- 	local looping = settings['looping'] or false
-- 	local name = settings['name'] or parent.Name

-- 	Self = { }

--     if type(folder) == 'table' then
-- 		local newFolder = Instance.new('Folder', esp.gui)
-- 		newFolder.Name = name
		
-- 		esp.current[newFolder] = { }

--         for i,v in pairs(folder) do
--             esp.new({folder=v, parent=newFolder})
--         end
-- 		function Self:Remove()
-- 			newFolder:Destroy()
-- 			esp.current[newFolder] = nil
-- 		end
--         return Self
--     end
	
-- 	local F = Instance.new('Folder',parent)
-- 	F.Name = folder.Name
	
-- 	if not esp.current[folder] then
-- 		esp.current[folder]= { }
-- 	end
	
	
-- 	local function makeESP(p,c,t)
-- 		if p:IsA('BasePart') then
-- 			local box = Instance.new('BoxHandleAdornment', F)

-- 			box.AlwaysOnTop = true
-- 			box.Size = p.Size or Vector3.new(2,2,2)
-- 			box.Color3 = c or Color3.new(1,1,1)
-- 			box.Transparency = t or 0.75
-- 			box.Adornee = p
-- 			box.ZIndex = 0
-- 			box.Name = p.Name

-- 			esp.current[folder][p]=box
-- 			p:GetPropertyChangedSignal('Parent'):Connect(function(parent)
-- 				if parent==nil and esp.current[folder] and esp.current[folder][p] then
--                     -- print(esp.current[folder][curp])
-- 					esp.current[folder][p]:Destroy()
-- 					esp.current[folder][p]=nil
-- 				end
-- 			end)
-- 		end
-- 	end
	
-- 	for i,v in next,folder:GetDescendants() do
-- 		makeESP(v,color,transparency)
-- 	end
	
-- 	folder.DescendantAdded:Connect(function(p)
-- 		makeESP(p,color,transparency)
-- 	end)
	
-- 	function Self:SetTransparency(trs)
-- 		for i,v in next,esp.current[folder] do
-- 			v.Transparency=trs
-- 		end
-- 	end
	
-- 	function Self:SetColor(clr)
-- 		for i,v in next,esp.current[folder] do
-- 			v.Color3=clr
-- 		end
-- 	end
	
-- 	function Self:Remove()
-- 		F:Destroy()
-- 		esp.current[folder]=nil
-- 	end
	
-- 	return Self
	
-- end

-- // Aimbot // --
local Aimbot = main_module.Aimbot
function Aimbot.new(settings) -- add auto shoot
    --[[ 
	settings = {
		folder = game.Workspace;
		target = 'Head';
		key = 'z';
		initial = false;
		smoothness = 1;
		visible = true;
		distance = 100;
		health = Health;
		team = false;
	} 
	--]]

	local folder = settings['folder'] or game.Workspace:GetChildren()
	local target = settings['target'] or 'Head'
	local initial = settings['initial'] or true
	local smoothness = settings['smoothness'] or 1
	local visible = settings['visible'] or false
	local distance = settings['distance'] or 9e9
	local team = settings['team'] or false
	local key = settings['key']

	local removeaimbot = false
	local doaimbot = initial

	function getAimPartFromClosestPlayer()
		local closest,curDist = nil, Vector2.new(math.huge, math.huge).magnitude
		for i,v in pairs(folder) do
			if v.Name ~= plr.Name and v:FindFirstChild(target, true) and v:FindFirstChildOfClass('Humanoid') and v:FindFirstChildOfClass('Humanoid').Health > 0 then
				local passedChecks = true
				if visible then
					-- local vector = (game.Players.LocalPlayer.Character.Head.Position - v:FindFirstChild(settings['target'] or 'Head').Position).Unit
					-- local ray = Ray.new(game.Players.LocalPlayer.Character.Head.Position, vector * (settings['distance'] or 9e9)*-1)
					-- local hit = game.Workspace:FindPartOnRayWithIgnoreList(ray, {game.Players.LocalPlayer.Character.Head, game.Players.LocalPlayer.Character:FindFirstChild(settings['target'] or 'Head', true)})
					local ignore_list = { game.Players.LocalPlayer.Character.Head, game.Players.LocalPlayer.Character:FindFirstChild(target, true) }
					for i = 1, 5 do
						local hit = RayHit(v:FindFirstChild(target, true), ignore_list, distance)
						if hit and not hit:IsDescendantOf(v) and hit.CanCollide == true and hit.Transparency ~= 1 then
							passedChecks = false
							print('[AIMBOT] - DID NOT PASS CHECK (visible)')
						else
							table.insert(ignore_list, hit)
						end;
					end;
				end;
				if team then
					if game.Players:FindFirstChild(v.Name) and game.Players:FindFirstChild(v.Name).Team == game.Players.LocalPlayer.Team then
						passedChecks = false
						print('[AIMBOT] - DID NOT PASS CHECK (team)')
					end;
				end;
				
				if passedChecks then
					local z = game.Workspace.CurrentCamera:WorldToViewportPoint(v:FindFirstChild(target, true).Position)
					local mouse = game:GetService('UserInputService'):GetMouseLocation()
					local dist = Vector2.new((z.X - mouse.X), (z.Y - mouse.Y)).magnitude

					if curDist > dist then
						curDist = dist
						closest = v:FindFirstChild(target, true)
					end;
				end;
			end;
		end;
		return closest,curDist
	end;
	function Aim()
		local part,distance = getAimPartFromClosestPlayer()
		local v, isonscreen = game.Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
		local mouse = game:GetService('UserInputService'):GetMouseLocation()
		if isonscreen and doaimbot and not removeaimbot then
			if rawget(settings, 'key') then
				if game:GetService('UserInputService'):IsKeyDown(key) then
					mousemoverel((v.X/smoothness - mouse.X/smoothness), (v.Y/smoothness) - mouse.Y/smoothness)
				end;
			else
				if game:GetService('UserInputService'):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
					mousemoverel((v.X/smoothness - mouse.X/smoothness), (v.Y/smoothness - mouse.Y/smoothness))
				end;
			end;
		end;
	end;
	connection = game:GetService('RunService').RenderStepped:Connect(function()
		if removeaimbot then
			connection:Disconnect()
		else
			if #folder > 0 then
				pcall(Aim)
			end;
		end;
	end);

	local Self = { }

	function Self:Toggle(v1)
		if v1 ~= nil then
			if v1 == true or v1 == 'true' or v1 == 'on' then
				doaimbot = true
			elseif v1 == false or v1 == 'false' or v1 == 'off' then
				doaimbot = false
			end;
		else
			doaimbot = not doaimbot
		end;
	end;
	function Self:Remove()
		removeaimbot = true
	end;
	function Self:ChangeFolder(v1)
		folder = v1
	end;
	function Self:ChangeVisible(v1)
		visible = v1
	end;
	function Self:ChangeTeam(v1)
		team = v1 or not team
	end;
	function Self:ChangeDistance(v1)
		distance = tonumber(v1) or 9e9
	end;
	function Self:ChangeKey(v1)
		key = v1
	end;
	function Self:ChangeSmoothness(v1)
		smoothness = tonumber(v1) or 1
	end;
	function Self:ChangeTarget(v1)
		target = v1
	end;
	function Self:IsToggled()
		if not removeaimbot then
			return doaimbot
		end;
		return false
	end;

    return Self
end;


-- // Admin Commands // --
local Admin = main_module.Admin
Admin.commands = { }

function Admin:Create(prefix)
    plr.Chatted:Connect(function(message)
        local msg = message:lower()
        local sep = msg:split(' ')
        local first = sep[1]:sub(2)

        if msg:sub(1,1) == prefix then
            if rawget(Admin.commands, first) then
                rawget(Admin.commands, first)(table.concat(sep, ' ', 2))
            end;
        end;
    end);

    Self = { }

    function Self.newCommand(cmd, _function)
        Admin.commands[cmd] = _function
    end;

    return Self
end;
return getgenv().main_module