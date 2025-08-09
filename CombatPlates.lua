-- CombatPlates - Nameplate visibility control for combat/non-combat states
-- Author: phrxqt
-- Version: 1.0

local f = CreateFrame("Frame")
local inCombat = false
local hasPrintedWelcome = false
local minimapButton
local addonLoaded = false
local configFrame

-- Default settings
local defaultSettings = {
    combatEnemy = true,
    combatFriend = false,
    nonCombatEnemy = false,
    nonCombatFriend = true,
    minimapPos = 45
}

-- Saved variables table
CombatPlatesConf = {}

-- Utility functions
local function PrintMsg(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[CombatPlates]|r " .. msg)
end

local function LoadSettings()
    if not CombatPlatesConf or type(CombatPlatesConf) ~= "table" then
        CombatPlatesConf = {}
    end
    
    for key, value in pairs(defaultSettings) do
        if CombatPlatesConf[key] == nil then
            CombatPlatesConf[key] = value
        end
    end
end

local function ApplyNameplateSettings(showEnemy, showFriend)
    if showEnemy and showFriend then
        ShowNameplates()
        ShowFriendNameplates()
    elseif showEnemy and not showFriend then
        ShowNameplates()
        HideFriendNameplates()
    elseif not showEnemy and showFriend then
        HideNameplates()
        ShowFriendNameplates()
    else
        HideNameplates()
        HideFriendNameplates()
    end
end

local function UpdatePlates()
    if UnitAffectingCombat("player") then
        if not inCombat then
            inCombat = true
            f:Show()
        end
        ApplyNameplateSettings(CombatPlatesConf.combatEnemy, CombatPlatesConf.combatFriend)
    else
        if inCombat then
            inCombat = false
            f:Hide()
        end
        ApplyNameplateSettings(CombatPlatesConf.nonCombatEnemy, CombatPlatesConf.nonCombatFriend)
    end
end

-- Config Menu
local function CreateConfigMenu()
    if configFrame then
        return configFrame
    end

    configFrame = CreateFrame("Frame", "CombatPlatesConfigFrame", UIParent)
    configFrame:SetWidth(380)
    configFrame:SetHeight(320)
    configFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    configFrame:SetMinResize(350, 300)
    configFrame:SetMaxResize(600, 500)
    configFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    configFrame:SetMovable(true)
    configFrame:SetResizable(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    configFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    configFrame:Hide()

    -- Resize grip
    local resizeGrip = CreateFrame("Button", nil, configFrame)
    resizeGrip:SetWidth(16)
    resizeGrip:SetHeight(16)
    resizeGrip:SetPoint("BOTTOMRIGHT", configFrame, "BOTTOMRIGHT", -2, 2)
    resizeGrip:EnableMouse(true)
    resizeGrip:SetScript("OnMouseDown", function() configFrame:StartSizing("BOTTOMRIGHT") end)
    resizeGrip:SetScript("OnMouseUp", function() configFrame:StopMovingOrSizing() end)
    
    local gripTexture = resizeGrip:CreateTexture(nil, "BACKGROUND")
    gripTexture:SetAllPoints(resizeGrip)
    gripTexture:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")

    -- Title
    local title = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", configFrame, "TOP", 0, -25)
    title:SetText("CombatPlates Configuration")
    title:SetTextColor(0.2, 0.8, 1.0)

    -- Combat section
    local combatLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    combatLabel:SetPoint("TOP", configFrame, "TOP", 0, -70)
    combatLabel:SetText("During Combat")
    combatLabel:SetTextColor(0.8, 0.2, 0.2)

    -- Combat Enemy checkbox
    local combatEnemyCheck = CreateFrame("CheckButton", "CombatPlatesEnemyCheck", configFrame, "UICheckButtonTemplate")
    combatEnemyCheck:SetPoint("TOP", configFrame, "TOP", -60, -100)
    combatEnemyCheck:SetWidth(20)
    combatEnemyCheck:SetHeight(20)
    combatEnemyCheck.text = combatEnemyCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    combatEnemyCheck.text:SetPoint("LEFT", combatEnemyCheck, "RIGHT", 5, 0)
    combatEnemyCheck.text:SetText("Show Enemy Nameplates")
    combatEnemyCheck:SetScript("OnClick", function()
        CombatPlatesConf.combatEnemy = combatEnemyCheck:GetChecked() and true or false
        UpdatePlates()
    end)

    -- Combat Friend checkbox
    local combatFriendCheck = CreateFrame("CheckButton", "CombatPlatesFriendCheck", configFrame, "UICheckButtonTemplate")
    combatFriendCheck:SetPoint("TOP", configFrame, "TOP", -60, -125)
    combatFriendCheck:SetWidth(20)
    combatFriendCheck:SetHeight(20)
    combatFriendCheck.text = combatFriendCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    combatFriendCheck.text:SetPoint("LEFT", combatFriendCheck, "RIGHT", 5, 0)
    combatFriendCheck.text:SetText("Show Friend Nameplates")
    combatFriendCheck:SetScript("OnClick", function()
        CombatPlatesConf.combatFriend = combatFriendCheck:GetChecked() and true or false
        UpdatePlates()
    end)

    -- Non-Combat section
    local nonCombatLabel = configFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    nonCombatLabel:SetPoint("TOP", configFrame, "TOP", 0, -170)
    nonCombatLabel:SetText("Outside Combat")
    nonCombatLabel:SetTextColor(0.6, 1.0, 0.6)

    -- Non-Combat Enemy checkbox
    local nonCombatEnemyCheck = CreateFrame("CheckButton", "CombatPlatesNonEnemyCheck", configFrame, "UICheckButtonTemplate")
    nonCombatEnemyCheck:SetPoint("TOP", configFrame, "TOP", -60, -200)
    nonCombatEnemyCheck:SetWidth(20)
    nonCombatEnemyCheck:SetHeight(20)
    nonCombatEnemyCheck.text = nonCombatEnemyCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nonCombatEnemyCheck.text:SetPoint("LEFT", nonCombatEnemyCheck, "RIGHT", 5, 0)
    nonCombatEnemyCheck.text:SetText("Show Enemy Nameplates")
    nonCombatEnemyCheck:SetScript("OnClick", function()
        CombatPlatesConf.nonCombatEnemy = nonCombatEnemyCheck:GetChecked() and true or false
        UpdatePlates()
    end)

    -- Non-Combat Friend checkbox
    local nonCombatFriendCheck = CreateFrame("CheckButton", "CombatPlatesNonFriendCheck", configFrame, "UICheckButtonTemplate")
    nonCombatFriendCheck:SetPoint("TOP", configFrame, "TOP", -60, -225)
    nonCombatFriendCheck:SetWidth(20)
    nonCombatFriendCheck:SetHeight(20)
    nonCombatFriendCheck.text = nonCombatFriendCheck:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nonCombatFriendCheck.text:SetPoint("LEFT", nonCombatFriendCheck, "RIGHT", 5, 0)
    nonCombatFriendCheck.text:SetText("Show Friend Nameplates")
    nonCombatFriendCheck:SetScript("OnClick", function()
        CombatPlatesConf.nonCombatFriend = nonCombatFriendCheck:GetChecked() and true or false
        UpdatePlates()
    end)

    -- Close button
    local closeButton = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    closeButton:SetWidth(80)
    closeButton:SetHeight(22)
    closeButton:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, 25)
    closeButton:SetText("Close")
    closeButton:SetScript("OnClick", function() configFrame:Hide() end)

    -- Update checkbox states function
    local function UpdateCheckboxes()
        combatEnemyCheck:SetChecked(CombatPlatesConf.combatEnemy)
        combatFriendCheck:SetChecked(CombatPlatesConf.combatFriend)
        nonCombatEnemyCheck:SetChecked(CombatPlatesConf.nonCombatEnemy)
        nonCombatFriendCheck:SetChecked(CombatPlatesConf.nonCombatFriend)
    end

    -- Layout scaling function
    local function UpdateLayout()
        local width = configFrame:GetWidth()
        local baseWidth = 380
        local scale = math.max(0.8, math.min(1.5, width / baseWidth))
        
        local titleY = -25 * scale
        local combatLabelY = -70 * scale
        local combatEnemyY = -100 * scale
        local combatFriendY = -125 * scale
        local nonCombatLabelY = -170 * scale
        local nonCombatEnemyY = -200 * scale
        local nonCombatFriendY = -225 * scale
        local buttonY = 25 * scale
        
        title:SetPoint("TOP", configFrame, "TOP", 0, titleY)
        combatLabel:SetPoint("TOP", configFrame, "TOP", 0, combatLabelY)
        combatEnemyCheck:SetPoint("TOP", configFrame, "TOP", -60, combatEnemyY)
        combatFriendCheck:SetPoint("TOP", configFrame, "TOP", -60, combatFriendY)
        nonCombatLabel:SetPoint("TOP", configFrame, "TOP", 0, nonCombatLabelY)
        nonCombatEnemyCheck:SetPoint("TOP", configFrame, "TOP", -60, nonCombatEnemyY)
        nonCombatFriendCheck:SetPoint("TOP", configFrame, "TOP", -60, nonCombatFriendY)
        closeButton:SetPoint("BOTTOM", configFrame, "BOTTOM", 0, buttonY)
    end
    
    configFrame:SetScript("OnSizeChanged", UpdateLayout)
    configFrame.UpdateCheckboxes = UpdateCheckboxes
    
    UpdateLayout()
    return configFrame
end

local function ShowConfigMenu()
    local menu = CreateConfigMenu()
    if menu.UpdateCheckboxes then
        menu.UpdateCheckboxes()
    end
    
    if menu:IsShown() then
        menu:Hide()
    else
        menu:Show()
    end
end

-- Minimap Button
local function UpdateMinimapButtonPos()
    if not minimapButton then return end
    local angle = math.rad(CombatPlatesConf.minimapPos or 45)
    local x = math.cos(angle) * 80
    local y = math.sin(angle) * 80
    minimapButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function CreateMinimapButton()
    if minimapButton then return minimapButton end

    minimapButton = CreateFrame("Button", "CombatPlatesMinimapButton", Minimap)
    minimapButton:SetWidth(32)
    minimapButton:SetHeight(32)
    minimapButton:SetFrameStrata("MEDIUM")
    minimapButton:SetFrameLevel(8)
    minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    minimapButton:SetMovable(true)
    minimapButton:EnableMouse(true)

    -- Button texture
    local texture = minimapButton:CreateTexture(nil, "BACKGROUND")
    texture:SetWidth(20)
    texture:SetHeight(20)
    texture:SetPoint("CENTER", 0, 1)
    texture:SetTexture("Interface\\Icons\\INV_Misc_ArmorKit_19")

    -- Border
    local overlay = minimapButton:CreateTexture(nil, "OVERLAY")
    overlay:SetWidth(52)
    overlay:SetHeight(52)
    overlay:SetPoint("TOPLEFT", 0, 0)
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- Tooltip
    minimapButton:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("CombatPlates")
        GameTooltip:AddLine("Left-click: Open config menu", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Drag to move", 1, 1, 1)
        GameTooltip:Show()
    end)

    minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- Click handler
    minimapButton:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            ShowConfigMenu()
        end
    end)

    -- Drag functionality
    minimapButton:SetScript("OnDragStart", function()
        this:LockHighlight()
        this:SetScript("OnUpdate", function()
            local mx, my = GetCursorPosition()
            mx = mx / this:GetEffectiveScale()
            my = my / this:GetEffectiveScale()
            
            local minimapX, minimapY = Minimap:GetCenter()
            local dx = mx - minimapX
            local dy = my - minimapY
            
            CombatPlatesConf.minimapPos = math.deg(math.atan2(dy, dx))
            UpdateMinimapButtonPos()
        end)
    end)

    minimapButton:SetScript("OnDragStop", function()
        this:UnlockHighlight()
        this:SetScript("OnUpdate", nil)
    end)

    minimapButton:RegisterForDrag("RightButton")
    return minimapButton
end

-- Event handling
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "CombatPlates" then
        addonLoaded = true
        return
    end
    
    if event == "VARIABLES_LOADED" and addonLoaded then
        LoadSettings()
        CreateMinimapButton()
        UpdateMinimapButtonPos()
        return
    end
    
    if event == "PLAYER_ENTERING_WORLD" and not hasPrintedWelcome then
        PrintMsg("loaded! Type /cp or /combatplates to open configuration menu.")
        hasPrintedWelcome = true
    end
    
    UpdatePlates()
end)

-- Slash commands
SLASH_COMBATPLATES1 = "/cp"
SLASH_COMBATPLATES2 = "/combatplates"
SlashCmdList["COMBATPLATES"] = function()
    ShowConfigMenu()
end