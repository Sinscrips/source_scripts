-- main module redo

-- Sinsane / veryunhappydoge

if getgenv().MainModule then
    MainModule.MainFrame:Destroy()
	print('old main module destroyed')
end

getgenv().MainModule = { }

MainModule.MainFrame = Instance.new('Folder', game.CoreGui)
MainModule.MainFrame.Name = 'Main_Module'

getgenv().esp = { }
getgenv().Aimbot = { }
getgenv().library = { }
getgenv().Console = { }





-- below this needs to be restructured (and also work with previously made scripts)
getgenv().rainbow_table = { }
getgenv().rainbow_value = Color3.fromRGB()
getgenv().rainbow_speed = 0.01
spawn(function()
	local n = 0
	while true do
		rainbow_value = Color3.fromHSV(n, 1, 1)
		n = (n + rainbow_speed) % 1

		game:GetService('RunService').RenderStepped:wait()
	end
end)	
getgenv().Rainbowify = function(v1, v2)
    rainbow_table[v1] = true
    local old_color = v1[v2]
	spawn(function()
        local old_material
        local s = pcall(function()
            old_material = v1.Material
        end)
        if s then
            v1.Material = 'Neon'
        end
        while rainbow_table[v1] == true do
            v1[v2] = rainbow_value
            
            game:GetService('RunService').RenderStepped:wait()
        end
        v1[v2] = old_color
        if s then
            v1.Material = old_material
        end
	end)
end
getgenv().DeRainbowify = function(v1)
    --print('stopped')
    rainbow_table[v1] = false
end
function RayHit(v1, v2, v3)
	local vector = (game.Players.LocalPlayer.Character.Head.Position - v1.Position).Unit
	local ray = Ray.new(game.Players.LocalPlayer.Character.Head.Position, vector * (v3 or 9e9)*-1)
	local hit = game.Workspace:FindPartOnRayWithIgnoreList(ray, v2)
	
	return hit
end
-- above this needs to be restructured (and also work with previously made scripts)







-- [[ ESP ]]
esp.gui = Instance.new('ScreenGui', MainModule.MainFrame)
esp.gui.Name = 'ESP'

esp.current = { }

function esp.new(instance, color, transp)-- Player executes this line
    local folder = Instance.new('Folder', esp.gui)
    folder.Name = instance.Name

    -- function for creating esp
    local createESP = function(v1, v2, v3, v4)
        local box = Instance.new('BoxHandleAdornment', v3)

		box.AlwaysOnTop = true
		box.Size = v1.Size or Vector3.new(2,2,2)
		box.Color3 = v2 or Color3.new(1,1,1)
		box.Transparency = v4 or 0.75
		box.Adornee = v1
		box.ZIndex = 0
		box.Name = v1.Name
        

        -- parent spy
        v1.AncestryChanged:connect(function(_, z)
            if z == nil then
                v3:FindFirstChild(v1.Name):Destroy()
            end
        end)
    end

    -- searching for parts and placing esp
	
    if instance:IsA('BasePart') then
        createESP(v, color, folder)
	else
        for i,v in pairs(instance:GetDescendants()) do
			if v:IsA('BasePart') then
				createESP(v, color, folder)
			end
        end
    end
    
    instance.ChildAdded:connect(function(v1)
        wait()
        if instance:IsA('BasePart') then
        	createESP(v, color, folder)
		end
    end)

    esp.current[folder] = folder

    self = { }
    function self:Remove()
        esp.current[folder]:Destroy()
    end

    return self
end

function esp:SetTransparency(v1)
	for i,v in pairs(esp.current) do
		for i2,v2 in pairs(v:GetChildren()) do
			v2.Transparency = v1
		end
	end
end

function esp:SetColor(v1)
	for i,v in pairs(esp.current) do
		for i2,v2 in pairs(v:GetChildren()) do
			v2.Color3 = v1
		end
	end
end

function esp:Clear()
	for i,v in pairs(esp.current) do
		v:Destroy()
	end
end

-- [[ Aimbot ]]

function Aimbot.new(settings)
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
	local doaimbot
	if settings['initial'] ~= nil then
		doaimbot = settings['initial']
	else
		doaimbot = true
	end
	local removeaimbot = false

	function getAimPartFromClosestPlayer()
		local closest,curDist = nil, Vector2.new(math.huge, math.huge).magnitude
		for i,v in pairs(settings['folder']:GetChildren()) do
			if v.Name ~= game.Players.LocalPlayer.Name and v:FindFirstChild(settings['target'] or 'Head', true) and v:FindFirstChild('Humanoid') and v:FindFirstChild('Humanoid').Health >= 0 then
				local passedChecks = true
				if settings['visible'] then
					-- local vector = (game.Players.LocalPlayer.Character.Head.Position - v:FindFirstChild(settings['target'] or 'Head').Position).Unit
					-- local ray = Ray.new(game.Players.LocalPlayer.Character.Head.Position, vector * (settings['distance'] or 9e9)*-1)
					-- local hit = game.Workspace:FindPartOnRayWithIgnoreList(ray, {game.Players.LocalPlayer.Character.Head, game.Players.LocalPlayer.Character:FindFirstChild(settings['target'] or 'Head', true)})
					local ignore_list = { game.Players.LocalPlayer.Character.Head, game.Players.LocalPlayer.Character:FindFirstChild(settings['target'] or 'Head', true) }
					for i = 1, 5 do
						local hit = RayHit(v:FindFirstChild(settings['target'] or 'Head', true), ignore_list, settings['distance'] or 9e9)
						if hit and not hit:IsDescendantOf(v) and hit.CanCollide == true and hit.Transparency ~= 1 then
							passedChecks = false
							--print('[AIMBOT] - DID NOT PASS CHECK (visible)')
						else
							table.insert(ignore_list, hit)
						end
					end
				end
				if not settings['team'] then
					if game.Players:FindFirstChild(v.Name) and game.Players:FindFirstChild(v.Name).Team == game.Players.LocalPlayer.Team then
						passedChecks = false
						--print('[AIMBOT] - DID NOT PASS CHECK (team)')
					end
				end
				
				if passedChecks then
					local z = game.Workspace.CurrentCamera:WorldToViewportPoint(v.HumanoidRootPart.Position)
					local mouse = game:GetService('UserInputService'):GetMouseLocation()
					local dist = Vector2.new((z.X - mouse.X), (z.Y - mouse.Y)).magnitude

					if curDist > dist then
						curDist = dist
						closest = v:FindFirstChild(settings['target'] or 'Head')
					end
				end
			end
		end
		return closest,curDist
	end
	function Aim()
		local part,distance = getAimPartFromClosestPlayer()
		local v, isonscreen = game.Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
		local mouse = game:GetService('UserInputService'):GetMouseLocation()
		if isonscreen and doaimbot and not removeaimbot then
			if rawget(settings, 'key') then
				if game:GetService('UserInputService'):IsKeyDown(Enum.KeyCode[settings['key']:upper()]) then
					mousemoverel((v.X/(tonumber(settings['smoothness']) or 1) - mouse.X/(tonumber(settings['smoothness']) or 1)), (v.Y/(tonumber(settings['smoothness']) or 1) - mouse.Y/(tonumber(settings['smoothness']) or 1)))
				end
			else
				if game:GetService('UserInputService'):IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
					mousemoverel((v.X/(tonumber(settings['smoothness']) or 1) - mouse.X/(tonumber(settings['smoothness']) or 1)), (v.Y/(tonumber(settings['smoothness']) or 1) - mouse.Y/(tonumber(settings['smoothness']) or 1)))
				end
			end
		end
	end
	connection = game:GetService('RunService').RenderStepped:Connect(function()
		if removeaimbot then
			connection:Disconnect()
		else
			if #settings['folder']:GetChildren() > 0 then
				pcall(Aim)
			end
		end
	end)

	local Self = { }

	function Self:Toggle(v1)
		if v1 ~= nil then
			if v1 == true or v1 == 'true' or v1 == 'on' then
				doaimbot = true
			elseif v1 == false or v1 == 'false' or v1 == 'off' then
				doaimbot = false
			end
		else
			doaimbot = not doaimbot
		end
	end
	function Self:Remove()
		removeaimbot = true
	end
	function Self:ChangeFolder(v1)
		settings['folder'] = v1
	end
	function Self:ChangeVisible(v1)
		settings['visible'] = v1
	end
	function Self:ChangeTeam(v1)
		settings['team'] = v1 or not settings['team'] or false
	end
	function Self:ChangeDistance(v1)
		settings['distance'] = tonumber(v1) or 9e9
	end
	function Self:ChangeKey(v1)
		settings['key'] = v1
	end
	function Self:ChangeSmoothness(v1)
		settings['smoothness'] = tonumber(v1) or 1
	end
	function Self:ChangeTarget(v1)
		settings['target'] = v1
	end
	function Self:IsToggled()
		if not removeaimbot then
			return doaimbot
		end
		return false
	end

	return Self
end

-- [[ UI LIB ]] -- sinsane
library.main = { 

}
library.gui = Instance.new('ScreenGui', MainModule.MainFrame)
library.gui.Name = 'UI_Lib'

function library:Toggle(v1)
	if v1 ~= nil then
        library.gui.Enabled = v1
	else
		library.gui.Enabled = not library.gui.Enabled
    end
end

function library:AddFrame(data)
	local frame = Instance.new('Frame', library.gui)
	frame.BackgroundTransparency = 0.25
	frame.BackgroundColor3 = Color3.fromRGB(75,75,75)
	frame.BorderColor3 = Color3.fromRGB(130,200,255)
    frame.BorderSizePixel = 2
	frame.Size = UDim2.new(0, 200, 0, 20)
	frame.Position = UDim2.new(0.01 + (#self.main)*0.105, 0, 0.01, 0)
	frame.ClipsDescendants = true

	local frame2 = Instance.new('Frame', frame)
	frame2.BackgroundTransparency = 1
	frame2.BackgroundColor3 = Color3.fromRGB(75,75,75)
	frame2.Size = UDim2.new(1, 0, 0, 0)
	frame2.Position = UDim2.new(0, 0, 0, 20)

	local title = Instance.new('TextLabel', frame)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 20)
	title.Font = 'SourceSansBold'
	title.Text = data['name']
	title.TextScaled = true
	title.TextColor3 = Color3.new(1,1,1)

	table.insert(self.main, frame)

	local library2 = { }

	function library2:AddButton(txt, func)
		frame.Size = frame.Size + UDim2.new(0, 0, 0, 20)
		frame2.Size = frame2.Size + UDim2.new(0, 0, 0, 20)
		
		local button = Instance.new('TextButton', frame2)
		button.Text = txt
		button.Size = UDim2.new(0, 200, 0, 20)
		button.Position = UDim2.new(0.01, 0, 0, frame2.Size.Y.Offset - 20)
		button.BackgroundTransparency = 1
		button.TextColor3 = Color3.new(1,1,1)
		button.TextXAlignment = 'Left'
		button.Font = 'SourceSansBold'
		button.TextSize = 16

		button.MouseButton1Click:connect(function()
			if func() ~= nil then

                button:Destroy()
                frame.Size = frame.Size - UDim2.new(0, 0, 0, 20)
		        frame2.Size = frame2.Size - UDim2.new(0, 0, 0, 20)

                for i,v in pairs(frame2:GetChildren()) do
                    v.Position = UDim2.new(0.01, 0, 0, (i-1)*20)
                end
            end
		end)
	end

	function library2:AddBox(txt, func)
		frame.Size = frame.Size + UDim2.new(0, 0, 0, 20)
		frame2.Size = frame2.Size + UDim2.new(0, 0, 0, 20)
		local box = Instance.new('TextBox', frame2)
		box.PlaceholderText = txt
		box.Text = ''
		box.Size = UDim2.new(0, 200, 0, 20)
		box.Position = UDim2.new(0.01, 0, 0, frame2.Size.Y.Offset - 20)
		box.BackgroundTransparency = 0.5
		box.BackgroundColor3 = Color3.fromRGB(100,100,100)
		box.TextColor3 = Color3.new(1,1,1)
		box.TextXAlignment = 'Left'
		box.BorderSizePixel = 0
		box.Font = 'SourceSansBold'
		box.TextSize = 16

		local placeholder_old = box.PlaceholderText

		box.FocusLost:connect(function()
			func(box.Text)
            box.PlaceholderText = placeholder_old..' ('..box.Text..')'
			box.Text = ''
		end)
	end

	function library2:AddToggle(txt, func)
		frame.Size = frame.Size + UDim2.new(0, 0, 0, 20)
		frame2.Size = frame2.Size + UDim2.new(0, 0, 0, 20)
		
		local toggle1 = Instance.new('TextButton', frame2)
		toggle1.Text = txt
		toggle1.Size = UDim2.new(0, 200, 0, 20)
		toggle1.Position = UDim2.new(0.01, 0, 0, frame2.Size.Y.Offset - 20)
		toggle1.BackgroundTransparency = 1
		toggle1.TextColor3 = Color3.new(1,1,1)
		toggle1.TextXAlignment = 'Left'
		toggle1.Font = 'SourceSansBold'
		toggle1.TextSize = 16

		local toggle2 = Instance.new('TextLabel', toggle1)
		toggle2.Text = 'Off'
		toggle2.Size = toggle1.Size
		toggle2.Position = toggle2.Position - UDim2.new(0.01, 0, 0, 0)
		toggle2.BackgroundTransparency = 1
		toggle2.TextColor3 = Color3.new(1,0,0)
		toggle2.TextXAlignment = 'Right'
		toggle2.Font = 'SourceSansBold'
		toggle2.TextSize = 16

		local tog = false

		toggle1.MouseButton1Click:connect(function()
			tog = not tog
			if tog then
				toggle2.TextColor3 = Color3.new(0,1,0)
				toggle2.Text = 'On'
			elseif not tog then
				toggle2.TextColor3 = Color3.new(1,0,0)
				toggle2.Text = 'Off'
			end
			func(tog)
		end)
	end

	function library2:AddSwitch(txt, tab, func)
		frame.Size = frame.Size + UDim2.new(0, 0, 0, 20)
		frame2.Size = frame2.Size + UDim2.new(0, 0, 0, 20)
		
		local switch1 = Instance.new('TextButton', frame2)
		switch1.Text = txt
		switch1.Size = UDim2.new(0, 200, 0, 20)
		switch1.Position = UDim2.new(0.01, 0, 0, frame2.Size.Y.Offset - 20)
		switch1.BackgroundTransparency = 1
		switch1.TextColor3 = Color3.new(1,1,1)
		switch1.TextXAlignment = 'Left'
		switch1.Font = 'SourceSansBold'
		switch1.TextSize = 16

		local switch2 = Instance.new('TextLabel', frame2)
		switch2.Text = tostring(tab[1]) or 'ERROR'
		switch2.Size = switch1.Size
		switch2.Position = switch1.Position - UDim2.new(0.02, 0, 0, 0)
		switch2.BackgroundTransparency = 1
		switch2.TextColor3 = Color3.fromRGB(150,150,150)
		switch2.TextXAlignment = 'Right'
		switch2.Font = 'SourceSansBold'
		switch2.TextSize = 16

		local tab_int = 1
		switch1.MouseButton1Click:connect(function()
			if tab_int == #tab then
				tab_int = 1
			else
				tab_int = tab_int + 1
			end

			switch2.Text = tostring(tab[tab_int])
			func(tab[tab_int])
		end)
	end

	function library2:Remove()
		local function checkTable(Table, Index)
			for i,v in pairs(Table) do
				if v == Index then
					return i
				end
			end
		end

		table.remove(library.main, checkTable(library.main, frame))
		frame:Destroy()

		for i,v in pairs(library.main) do
			v.Position = v.Position - UDim2.new(0.105, 0, 0, 0)
		end
	end

    function library2:ClearAllChildren()
		frame2:ClearAllChildren()
        frame.Size = UDim2.new(0, 200, 0, 20)
        frame2.Size = UDim2.new(1, 0, 0, 0)
	end

	return library2

end

-- [[ CONSOLE ]] Sinsane
Console.command_list = { }
Console.command_output = { }

Console.gui = Instance.new('ScreenGui', MainModule.MainFrame)
Console.gui.Name = 'CONSOLE_UI'

function Console:Create(console_title, capturekey)
	if Console.gui:FindFirstChild('Frame') then
		Console.gui:FindFirstChild('Frame'):Destroy()
	end
	if Console.gui:FindFirstChild('Folder') then
		Console.gui:FindFirstChild('Folder'):Destroy()
	end

	
	local folder = Instance.new('Folder', Console.gui)

	local Main = Instance.new('Frame', Console.gui)
	Main.BackgroundTransparency = 1
	Main.Size = UDim2.new(1, 0, 0.4, 1)

	local title = Instance.new('TextLabel', Main)
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0.1, 0)
	title.TextColor3 = Color3.fromRGB(75, 75, 75)
	title.TextScaled = true
	title.Font = 'SourceSansBold'
	title.Text = console_title

	local holder = Instance.new('Frame', Main)
	holder.BackgroundTransparency = 0.25
	holder.BorderSizePixel = 1
	holder.BorderColor3 = Color3.fromRGB(130,200,255)
	holder.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
	holder.Size = UDim2.new(1, 0, 0.9, 0)
	holder.ClipsDescendants = true

	local box = Instance.new('TextBox', Main)
	local original = "Press '".. capturekey:upper() .."' to start typing"
	box.Position = UDim2.new(0, 0, 0.9, 0)
	box.Size = UDim2.new(1, 0, 0.1, 0)
	box.BackgroundColor3 = Color3.new(0, 0, 0)
	box.BackgroundTransparency = .5
	box.BorderSizePixel = 1
	box.BorderColor3 = Color3.fromRGB(130,200,255)
	box.Text = original
	box.Font = 'SourceSansBold'
	box.TextColor3 = Color3.new(1,1,1)
	box.TextSize = 20
	box.TextXAlignment = 'Left'

	local ex = Instance.new('TextLabel', folder)
	ex.Visible = false
	ex.BackgroundTransparency = 1
	ex.Position = UDim2.new(0, 0, 0.9, 0)
	ex.Size = UDim2.new(1, 0, 0.1, 0)
	ex.TextSize = 15
	ex.TextXAlignment = 'Left'

	newOutput = function(msg, clr)
		for i,v in pairs(holder:GetChildren()) do
			if v.Position ~= UDim2.new(0, 0, 0, 0) then
				v.Position = UDim2.new(0, 0, v.Position.Y.Scale - .1, 0)
			else
				v:Destroy()
			end
		end
		local newmsg = ex:Clone()
		newmsg.Text = '[Console] '..msg
		newmsg.Parent = holder
		newmsg.Visible = true
		if clr then
			if tostring(clr):lower() == 'rainbow' then
				Rainbowify(newmsg, 'TextColor3')
			else
				newmsg.TextColor3 = clr
			end
		else
			newmsg.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	s = pcall(function()
		if Enum.KeyCode[capturekey:upper()] then
			return
		end
	end)
	if not s then
		box.Text = '[ERROR] - Capture key is nil'
		original = '[ERROR] - Capture key is nil'
	end

	game:GetService('UserInputService').InputBegan:connect(function(key, gpi)
		if gpi then return end
		if pcall(function()if Enum.KeyCode[capturekey:upper()]then return end end) and key.KeyCode == Enum.KeyCode[capturekey:upper()] and Main.Visible and not box:IsFocused() then
			wait()
			box:CaptureFocus()
		end
	end)

	box.FocusLost:connect(function()
		if box.Text ~= original and box.Text ~= '' then
			local input = box.Text
			local inputsep = input:lower():split(' ')

			if rawget(Console.command_list, inputsep[1]) then

				spawn(function()

					v1, v2 = Console.command_list[inputsep[1]](table.concat(inputsep, ' ', 2))
					
					if v1 then
						newOutput(v1, v2 or Color3.fromRGB(255, 255, 255))
					end

				end)

			else

				newOutput("Command '"..input.."' not found", Color3.fromRGB(255, 0, 0))

			end
		end
		box.Text = original
	end)

	local input_commands = { }

	local count = 1
	local cmds_list = { }

	function input_commands:IsFocused()
		return box:IsFocused()
	end
	function input_commands:ChangeCaptureKey(v1)
		s = pcall(function()
			if Enum.KeyCode[v1:upper()] then
				return
			end
		end)
		if not s then
			newOutput('ERROR - Capture key does not exist', Color3.fromRGB(255, 0, 0))
			return
		end
		box.Text = "Press '".. v1:upper() .."' to start typing"
		original = "Press '".. v1:upper() .."' to start typing"
		capturekey = v1
	end
	function input_commands:Output(...)
		newOutput(...)
	end
	function input_commands:AddCommand(command, func)
		Console.command_list[command:lower()] = func
		cmds_list[count] = command
		count = count + 1
	end
	function input_commands:Clear()
		holder:ClearAllChildren()
	end
	function input_commands:Toggle()
		Main.Visible = not Main.Visible
	end
	function input_commands:Commands(v1, v2)
		if not v1 then	
			local str = ''
			for i,v in pairs(Console.command_list) do
				str = str..i..', '
			end

			newOutput('Commands: '..str:sub(1, #str-2))
		else
			if v2 then
				local str = ''
				for i = v1, v2 do
					str = str..cmds_list[i]..', '
				end

				newOutput('Commands: '..str:sub(1, #str-2))
			else
				local str = ''
				for i = v1, count - 1 do
					str = str..tostring(cmds_list[i])..', '
				end

				newOutput('Commands: '..str:sub(1, #str-2))
			end
		end
	end

	return input_commands

end

return {
	['Library'] = library; 
	['Esp'] = esp;
	['Console'] = Console;
	['Aimbot'] = Aimbot
}