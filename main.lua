-------------------------------------
-- [1] Infinite Zoom
-------------------------------------
pcall(function()
	game:GetService("Players").LocalPlayer.CameraMaxZoomDistance = math.huge
end)


-------------------------------------
-- [2] Instant Interact
-------------------------------------
pcall(function()

    local function fixPrompt(obj)
        if obj:IsA("ProximityPrompt") then
            obj.HoldDuration = 0          -- Instant Interact
            obj.ClickablePrompt = false   -- ❌ NO permitir click del mouse
        end
    end

    -- Aplicar a todos los objetos que ya existen
    for _, obj in ipairs(workspace:GetDescendants()) do
        fixPrompt(obj)
    end

    -- Aplicar a nuevos objetos que aparezcan
    workspace.DescendantAdded:Connect(fixPrompt)

end)



-------------------------------------
-- [3] CLICK TP (Removido)
-------------------------------------
-- 🟩 NPC NameTag ESP (Tecla: N)
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local npcESPEnabled = true
local npcTags = {}

local NAME_OFFSET = Vector3.new(0, 2.5, 0)
local TAG_SIZE = UDim2.new(0, 150, 0, 35)

-- Detecta si un modelo es un jugador real
local function isPlayerCharacter(model)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr.Character == model then
            return true
        end
    end
    return false
end

-- Crea NameTag
local function createNPCTag(model)
    if npcTags[model] then return end
    if isPlayerCharacter(model) then return end

    local hum = model:FindFirstChild("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head")
    if not hum or not hrp then return end

    local tag = Instance.new("BillboardGui")
    tag.Name = "NPC_Tag"
    tag.Adornee = hrp
    tag.Size = TAG_SIZE
    tag.AlwaysOnTop = true
    tag.StudsOffset = NAME_OFFSET
    tag.Enabled = npcESPEnabled
    tag.Parent = hrp

    local label = Instance.new("TextLabel")
    label.Parent = tag
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = model.Name  -- Aquí puedes poner un nombre personalizado
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.5
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16

    npcTags[model] = tag

    -- Quitar si desaparece
    model.AncestryChanged:Connect(function(_, parent)
        if not parent and npcTags[model] then
            npcTags[model]:Destroy()
            npcTags[model] = nil
        end
    end)
end

-- Buscar NPCs existentes
for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
        createNPCTag(obj)
    end
end

-- Detectar NPCs nuevos
workspace.DescendantAdded:Connect(function(obj)
    -- Si aparece un Humanoid nuevo, el NPC acaba de nacer
    if obj:IsA("Humanoid") then
        local model = obj.Parent
        task.wait(0.1)  -- espera a que cargue Head/HRP
        createNPCTag(model)
    end
end)


-- Toggle con tecla N
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.C then
        npcESPEnabled = not npcESPEnabled
        for _, gui in pairs(npcTags) do
            if gui then gui.Enabled = npcESPEnabled end
        end
    end
end)



-------------------------------------
-- [6] NoSlow Anti-Debuff Funcional
-------------------------------------
pcall(function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local lp = Players.LocalPlayer
    local DEFAULT_SPEED = 16   -- velocidad normal

    RunService.Heartbeat:Connect(function()
        local char = lp.Character
        if not char then return end

        local hum = char:FindFirstChildWhichIsA("Humanoid")
        if not hum then return end

        -- 🟡 Si el juego baja WalkSpeed por una habilidad o debuff
        -- (ejemplo: te lo ponen en 4, 6, 8, etc.)
        if hum.WalkSpeed < DEFAULT_SPEED then
            hum.WalkSpeed = DEFAULT_SPEED
        end
    end)
end)


-------------------------------------
-- [4] Item ESP (Toggle: V)
-------------------------------------
pcall(function()
	local Workspace = game:GetService("Workspace")
	local UserInputService = game:GetService("UserInputService")

	local itemEnabled = true
	local itemBillboards = {}

	local EXCLUDED = {
		["Handle"] = true,
		["am"] = true,
		["saintpart"] = true,
		["Head"] = true,
		["Orb_p"] = true,
        ["Wood_p"] = true,
        ["Shattered Chain_p"] = true,
        ["Holy Chain_p"] = true,
        ["Line Paper_p"] = true,
        ["Metal_p"] = true,
        ["Rusty Metal_p"] = true,
        ["Stone_p"] = true,
        ["Chest_p"] = true,
	}

	local ITEM_SIZE = UDim2.new(0,140,0,30)
	local ITEM_OFFSET = Vector3.new(0,2,0)
	local ITEM_COLOR = Color3.fromRGB(255,255,255)
	local ITEM_STROKE = Color3.fromRGB(0,0,0)
	local ITEM_STROKE_TRANSP = 0.6
	local ITEM_TEXT_SIZE = 15

	local function createItemESP(prompt)
		if not prompt or not prompt.Parent then return end
		if itemBillboards[prompt] then return end

		local parentName = prompt.Parent.Name
		if EXCLUDED[parentName] then return end

		local adornee =
			prompt.Parent:IsA("BasePart") and prompt.Parent or
			prompt.Parent:FindFirstChildWhichIsA("BasePart")

		if not adornee then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ItemESP"
		billboard.Adornee = adornee
		billboard.Size = ITEM_SIZE
		billboard.StudsOffset = ITEM_OFFSET
		billboard.AlwaysOnTop = true
		billboard.Enabled = itemEnabled
		billboard.Parent = adornee

		local label = Instance.new("TextLabel")
		label.Parent = billboard
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.Text = "[".. parentName .."]"
		label.TextColor3 = ITEM_COLOR
		label.TextStrokeColor3 = ITEM_STROKE
		label.TextStrokeTransparency = ITEM_STROKE_TRANSP
		label.Font = Enum.Font.SourceSansBold
		label.TextSize = ITEM_TEXT_SIZE
		label.TextWrapped = true

		itemBillboards[prompt] = billboard

		prompt.AncestryChanged:Connect(function(_, parent)
			if not parent then
				if billboard.Parent then billboard:Destroy() end
				itemBillboards[prompt] = nil
			end
		end)
	end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") then
			createItemESP(obj)
		end
	end

	Workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("ProximityPrompt") then
			task.wait(0.05)
			createItemESP(obj)
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.V then
			itemEnabled = not itemEnabled
			for _, bill in pairs(itemBillboards) do
				if bill then bill.Enabled = itemEnabled end
			end
		end
	end)
end)



-------------------------------------
-- [5] NameTag ESP (Toggle: Z)
-------------------------------------
do
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer

	local NAME_OFFSET = Vector3.new(0, -0.5, 0)
	local BILLBOARD_SIZE = UDim2.new(0, 160, 0, 40)
	local NAME_SIZE = 18
	local TOOL_SIZE = 14
	local NAME_COLOR = Color3.fromRGB(255, 255, 255)
	local TOOL_COLOR = Color3.fromRGB(255, 230, 0)
	local TOOL_STROKE_COLOR = Color3.fromRGB(0, 0, 0)
	local TOOL_STROKE_TRANSP = 0.6

	local espEnabled = true
	local billboards = {}

	local function getAdornee(char)
		return char:FindFirstChild("HumanoidRootPart")
			or char:FindFirstChildWhichIsA("BasePart")
	end

	local function createOrUpdate(player)
		if player == LocalPlayer or not espEnabled then return end

		local char = player.Character
		if not char then return end

		local adornee = getAdornee(char)
		if not adornee then return end

		if billboards[player] then
			billboards[player].Billboard:Destroy()
			billboards[player] = nil
		end

		local bill = Instance.new("BillboardGui")
		bill.Name = "NameTagESP"
		bill.Adornee = adornee
		bill.AlwaysOnTop = true
		bill.Size = BILLBOARD_SIZE
		bill.StudsOffset = NAME_OFFSET
		bill.Enabled = espEnabled
		bill.Parent = adornee

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Parent = bill
		nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = player.DisplayName or player.Name
		nameLabel.TextColor3 = NAME_COLOR
		nameLabel.Font = Enum.Font.SourceSansBold
		nameLabel.TextSize = NAME_SIZE
		nameLabel.AnchorPoint = Vector2.new(0.5, 0)
		nameLabel.Position = UDim2.new(0.5, 0, 0, 0)

		local toolLabel = Instance.new("TextLabel")
		toolLabel.Parent = bill
		toolLabel.Size = UDim2.new(1, 0, 0.4, 0)
		toolLabel.Position = UDim2.new(0.5, 0, 0.6, 0)
		toolLabel.AnchorPoint = Vector2.new(0.5, 0)
		toolLabel.BackgroundTransparency = 1
		toolLabel.TextColor3 = TOOL_COLOR
		toolLabel.TextStrokeColor3 = TOOL_STROKE_COLOR
		toolLabel.TextStrokeTransparency = TOOL_STROKE_TRANSP
		toolLabel.Font = Enum.Font.SourceSansBold
		toolLabel.TextSize = TOOL_SIZE

		billboards[player] = {
			Billboard = bill,
			NameLabel = nameLabel,
			ToolLabel = toolLabel
		}

		local function updateTool()
			if not espEnabled then return end
			local tool = char:FindFirstChildOfClass("Tool")
			toolLabel.Text = tool and ("[" .. tool.Name .. "]") or ""
		end

		char.ChildAdded:Connect(updateTool)
		char.ChildRemoved:Connect(updateTool)
		updateTool()
	end

	local function clearAll()
		for _, data in pairs(billboards) do
			if data.Billboard then
				data.Billboard:Destroy()
			end
		end
		billboards = {}
	end

	local function onPlayer(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.05)
			createOrUpdate(player)
		end)

		player.CharacterRemoving:Connect(function()
			if billboards[player] then
				billboards[player].Billboard:Destroy()
				billboards[player] = nil
			end
		end)

		if player.Character then
			createOrUpdate(player)
		end
	end

	for _, plr in ipairs(Players:GetPlayers()) do
		onPlayer(plr)
	end

	Players.PlayerAdded:Connect(onPlayer)
	Players.PlayerRemoving:Connect(function(player)
		if billboards[player] then
			billboards[player].Billboard:Destroy()
			billboards[player] = nil
		end
	end)

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Z then
			espEnabled = not espEnabled
			if not espEnabled then
				clearAll()
			else
				for _, plr in ipairs(Players:GetPlayers()) do
					createOrUpdate(plr)
				end
			end
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not espEnabled then return end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and not billboards[plr] then
				createOrUpdate(plr)
			end
		end
	end)
end
