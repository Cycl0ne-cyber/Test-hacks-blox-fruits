-- ============================================================
--   BLOX FRUITS HACK GUI  v5.0  (Mobile + 3rd Sea Farm)
--   • Full touch / mobile support
--   • On-screen fly joystick for mobile
--   • 3rd Sea Level Farm: levels 2500 → 2850
--   • Auto Quest, ESP, Speed, NoClip, Raids & more
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")

local LocalPlayer  = Players.LocalPlayer
local PlayerGui    = LocalPlayer:WaitForChild("PlayerGui")
local Character    = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HRP          = Character:WaitForChild("HumanoidRootPart")
local Humanoid     = Character:WaitForChild("Humanoid")

-- detect mobile
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ============================================================
--  CONFIG
-- ============================================================
local Config = {
    -- Farm
    AutoFarm         = false,
    AutoQuest        = false,
    AutoBossKill     = false,
    AutoCollect      = false,
    KillAura         = false,
    KillAuraRange    = 35,
    AutoSkills       = false,
    AutoSword        = false,
    AutoDodge        = false,
    -- 3rd Sea Level Farm
    ThirdSeaFarm     = false,
    FarmTargetLevel  = 2500,   -- selectable: 2500/2550/2600/2650/2700/2750/2800/2850
    -- Player
    SpeedHack        = false,
    SpeedValue       = 50,
    JumpHack         = false,
    JumpValue        = 100,
    FlyHack          = false,
    FlySpeed         = 80,
    NoClip           = false,
    InfStamina       = false,
    InfEnergy        = false,
    AntiAFK          = true,
    AutoStats        = false,
    -- ESP
    PlayerESP        = false,
    MobESP           = false,
    FruitESP         = false,
    ChestESP         = false,
    -- Fruits
    FruitSniper      = false,
    AutoEat          = false,
    -- Raids
    AutoRaid         = false,
    AutoSeaBeast     = false,
    -- UI
    UIOpen           = true,
}

-- ============================================================
--  3RD SEA FARM DATA  (Lvl 2500 – 2850)
-- ============================================================
local ThirdSeaMobs = {
    [2500] = {
        name     = "Longma",
        location = "Floating Turtle",
        pos      = Vector3.new(-24380, 820, -3810),
        quest    = Vector3.new(-24200, 820, -3650),
    },
    [2550] = {
        name     = "Peanut Scout",
        location = "Peanut Island",
        pos      = Vector3.new(-28500, 30,  2400),
        quest    = Vector3.new(-28200, 30,  2200),
    },
    [2600] = {
        name     = "Peanut Staff",
        location = "Peanut Island",
        pos      = Vector3.new(-28700, 30,  2600),
        quest    = Vector3.new(-28200, 30,  2200),
    },
    [2625] = {
        name     = "Ice Cream Chef",
        location = "Ice Cream Island",
        pos      = Vector3.new(-31000, 20,  -1800),
        quest    = Vector3.new(-30700, 20,  -1600),
    },
    [2650] = {
        name     = "Ice Cream Commander",
        location = "Ice Cream Island",
        pos      = Vector3.new(-31200, 20,  -2000),
        quest    = Vector3.new(-30700, 20,  -1600),
    },
    [2700] = {
        name     = "Cake Guard",
        location = "Cake Island",
        pos      = Vector3.new(-34000, 20,   800),
        quest    = Vector3.new(-33700, 20,   600),
    },
    [2750] = {
        name     = "Baking Staff",
        location = "Cake Island",
        pos      = Vector3.new(-34200, 20,   1000),
        quest    = Vector3.new(-33700, 20,   600),
    },
    [2800] = {
        name     = "Chocolatier",
        location = "Chocolate Island",
        pos      = Vector3.new(-37200, 20,  -3000),
        quest    = Vector3.new(-36900, 20,  -2800),
    },
    [2850] = {
        name     = "Candy Pirate",
        location = "Candy Kingdom",
        pos      = Vector3.new(-39500, 20,   1200),
        quest    = Vector3.new(-39200, 20,   1000),
    },
}

-- sorted level keys for dropdown
local LevelKeys = {}
for k in pairs(ThirdSeaMobs) do table.insert(LevelKeys, k) end
table.sort(LevelKeys)

-- ============================================================
--  COLOUR PALETTE
-- ============================================================
local C = {
    BG         = Color3.fromRGB(13,  13,  18),
    Panel      = Color3.fromRGB(20,  20,  28),
    Card       = Color3.fromRGB(28,  28,  40),
    Accent     = Color3.fromRGB(255, 80,   0),
    Accent2    = Color3.fromRGB(255, 160,  0),
    Text       = Color3.fromRGB(240, 240, 250),
    SubText    = Color3.fromRGB(150, 150, 170),
    ON         = Color3.fromRGB(0,   210, 100),
    OFF        = Color3.fromRGB(70,  70,  95),
    Hover      = Color3.fromRGB(45,  45,  65),
    Red        = Color3.fromRGB(220,  50,  50),
    Gold       = Color3.fromRGB(255, 200,  0),
    Blue       = Color3.fromRGB(60,  130, 255),
}

-- ============================================================
--  HELPERS
-- ============================================================
local function Tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quart), props):Play()
end

local function corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function stroke(p, t, col)
    local s = Instance.new("UIStroke", p)
    s.Thickness = t or 1
    s.Color = col or C.Accent
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function notify(title, body, dur)
    dur = dur or 3
    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name  = "BF_Toast"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 99
    local f = Instance.new("Frame", sg)
    f.Size              = UDim2.new(0, 280, 0, 68)
    f.Position          = UDim2.new(1, -290, 1, -80)
    f.BackgroundColor3  = C.Card
    f.BorderSizePixel   = 0
    corner(f, 10)
    stroke(f, 1.5, C.Accent)
    local bar = Instance.new("Frame", f)
    bar.Size            = UDim2.new(0, 4, 1, 0)
    bar.BackgroundColor3 = C.Accent
    bar.BorderSizePixel = 0
    corner(bar, 3)
    local t1 = Instance.new("TextLabel", f)
    t1.Size             = UDim2.new(1,-14,0,22)
    t1.Position         = UDim2.new(0,12,0,8)
    t1.BackgroundTransparency = 1
    t1.Text             = title
    t1.TextColor3       = C.Accent
    t1.Font             = Enum.Font.GothamBold
    t1.TextSize         = 13
    t1.TextXAlignment   = Enum.TextXAlignment.Left
    local t2 = Instance.new("TextLabel", f)
    t2.Size             = UDim2.new(1,-14,0,22)
    t2.Position         = UDim2.new(0,12,0,34)
    t2.BackgroundTransparency = 1
    t2.Text             = body
    t2.TextColor3       = C.Text
    t2.Font             = Enum.Font.Gotham
    t2.TextSize         = 11
    t2.TextXAlignment   = Enum.TextXAlignment.Left
    t2.TextWrapped      = true
    task.delay(dur, function() sg:Destroy() end)
end

-- ============================================================
--  DESTROY OLD GUI
-- ============================================================
local old = PlayerGui:FindFirstChild("BF_HackGUI")
if old then old:Destroy() end

-- ============================================================
--  SCREEN GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "BF_HackGUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder    = 10
ScreenGui.IgnoreGuiInset  = true
ScreenGui.Parent          = PlayerGui

-- ============================================================
--  MAIN WINDOW  (full-width on mobile, fixed on PC)
-- ============================================================
local WIN_W = IsMobile and 360 or 680
local WIN_H = IsMobile and 580 or 480
local TAB_W = IsMobile and 100 or 120
local TITLE_H = IsMobile and 54 or 48

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
MainFrame.Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
corner(MainFrame, 14)
stroke(MainFrame, 1.5, C.Accent)

-- ============================================================
--  TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size             = UDim2.new(1, 0, 0, TITLE_H)
TitleBar.BackgroundColor3 = C.Panel
TitleBar.BorderSizePixel  = 0

local tg = Instance.new("UIGradient", TitleBar)
tg.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0,   C.Accent),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(80,20,0)),
    ColorSequenceKeypoint.new(1,   C.Panel),
}

local TitleIcon = Instance.new("TextLabel", TitleBar)
TitleIcon.Size                = UDim2.new(0, 36, 0, 36)
TitleIcon.Position            = UDim2.new(0, 8, 0.5, -18)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text                = "🍎"
TitleIcon.TextSize            = 26
TitleIcon.Font                = Enum.Font.GothamBold
TitleIcon.TextColor3          = C.Text

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size               = UDim2.new(1, -120, 0, 24)
TitleLbl.Position           = UDim2.new(0, 48, 0, 4)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text               = "BLOX FRUITS  |  HACK GUI"
TitleLbl.Font               = Enum.Font.GothamBold
TitleLbl.TextSize           = IsMobile and 14 or 15
TitleLbl.TextColor3         = C.Text
TitleLbl.TextXAlignment     = Enum.TextXAlignment.Left

local SubLbl = Instance.new("TextLabel", TitleBar)
SubLbl.Size              = UDim2.new(1, -120, 0, 14)
SubLbl.Position          = UDim2.new(0, 48, 0, 30)
SubLbl.BackgroundTransparency = 1
SubLbl.Text              = "v5.0  |  All Seas  |  Mobile Ready"
SubLbl.Font              = Enum.Font.Gotham
SubLbl.TextSize          = 10
SubLbl.TextColor3        = C.SubText
SubLbl.TextXAlignment    = Enum.TextXAlignment.Left

-- Minimize
local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size             = UDim2.new(0, 34, 0, 34)
MinBtn.Position         = UDim2.new(1, -78, 0.5, -17)
MinBtn.BackgroundColor3 = C.Card
MinBtn.Text             = "—"
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.TextSize         = 14
MinBtn.TextColor3       = C.Text
MinBtn.BorderSizePixel  = 0
corner(MinBtn, 8)

-- Close
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size             = UDim2.new(0, 34, 0, 34)
CloseBtn.Position         = UDim2.new(1, -40, 0.5, -17)
CloseBtn.BackgroundColor3 = C.Red
CloseBtn.Text             = "✕"
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 14
CloseBtn.TextColor3       = Color3.fromRGB(255,255,255)
CloseBtn.BorderSizePixel  = 0
corner(CloseBtn, 8)

-- ============================================================
--  SIDEBAR
-- ============================================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Name             = "Sidebar"
Sidebar.Size             = UDim2.new(0, TAB_W, 1, -TITLE_H)
Sidebar.Position         = UDim2.new(0, 0, 0, TITLE_H)
Sidebar.BackgroundColor3 = C.Panel
Sidebar.BorderSizePixel  = 0

local SideScroll = Instance.new("ScrollingFrame", Sidebar)
SideScroll.Size                = UDim2.new(1, 0, 1, 0)
SideScroll.BackgroundTransparency = 1
SideScroll.BorderSizePixel     = 0
SideScroll.ScrollBarThickness  = 0
SideScroll.CanvasSize          = UDim2.new(0, 0, 0, 0)

local SideLayout = Instance.new("UIListLayout", SideScroll)
SideLayout.Padding             = UDim.new(0, 4)
SideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.new(0,0,0, SideLayout.AbsoluteContentSize.Y + 10)
end)
local sidePad = Instance.new("UIPadding", SideScroll)
sidePad.PaddingTop = UDim.new(0,8)

-- Separator
local Sep = Instance.new("Frame", MainFrame)
Sep.Size             = UDim2.new(0, 1, 1, -TITLE_H)
Sep.Position         = UDim2.new(0, TAB_W, 0, TITLE_H)
Sep.BackgroundColor3 = C.Accent
Sep.BorderSizePixel  = 0

-- Content Area
local ContentArea = Instance.new("Frame", MainFrame)
ContentArea.Size             = UDim2.new(1, -TAB_W, 1, -TITLE_H)
ContentArea.Position         = UDim2.new(0, TAB_W, 0, TITLE_H)
ContentArea.BackgroundColor3 = C.BG
ContentArea.BorderSizePixel  = 0

-- ============================================================
--  TAB SYSTEM
-- ============================================================
local Tabs      = {}
local Pages     = {}
local ActiveTab = nil

local TabDefs = {
    { name = "⚔️ Farm",     key = "Farm"     },
    { name = "🌏 3rd Sea",  key = "ThirdSea" },
    { name = "🌍 Teleport", key = "Teleport" },
    { name = "👁 ESP",      key = "ESP"      },
    { name = "⚡ Player",   key = "Player"   },
    { name = "🍎 Fruits",   key = "Fruits"   },
    { name = "🏴 Raids",    key = "Raids"    },
    { name = "🛡 Combat",   key = "Combat"   },
    { name = "⚙️ Settings", key = "Settings" },
}

local function createPage(key)
    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Name                  = key
    page.Size                  = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel       = 0
    page.ScrollBarThickness    = IsMobile and 0 or 4
    page.ScrollBarImageColor3  = C.Accent
    page.Visible               = false
    page.CanvasSize            = UDim2.new(0,0,0,0)
    local lay = Instance.new("UIListLayout", page)
    lay.Padding                = UDim.new(0, IsMobile and 10 or 8)
    lay.HorizontalAlignment    = Enum.HorizontalAlignment.Center
    lay.SortOrder              = Enum.SortOrder.LayoutOrder
    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop    = UDim.new(0,10)
    pad.PaddingLeft   = UDim.new(0,8)
    pad.PaddingRight  = UDim.new(0,8)
    pad.PaddingBottom = UDim.new(0,10)
    lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0, lay.AbsoluteContentSize.Y + 24)
    end)
    Pages[key] = page
    return page
end

local function createTabBtn(label, key)
    local btn = Instance.new("TextButton", SideScroll)
    btn.Size             = UDim2.new(1, -8, 0, IsMobile and 44 or 38)
    btn.BackgroundColor3 = C.Card
    btn.Text             = label
    btn.Font             = Enum.Font.GothamSemibold
    btn.TextSize         = IsMobile and 11 or 11
    btn.TextColor3       = C.SubText
    btn.BorderSizePixel  = 0
    btn.TextWrapped      = true
    btn.TextXAlignment   = Enum.TextXAlignment.Center
    corner(btn, 8)
    return btn
end

for _, td in ipairs(TabDefs) do
    local btn = createTabBtn(td.name, td.key)
    Tabs[td.key] = btn
    createPage(td.key)
end

local function setTab(key)
    if ActiveTab == key then return end
    ActiveTab = key
    for k, b in pairs(Tabs) do
        if k == key then
            Tween(b, 0.15, { BackgroundColor3 = C.Accent, TextColor3 = C.Text })
        else
            Tween(b, 0.15, { BackgroundColor3 = C.Card,   TextColor3 = C.SubText })
        end
    end
    for k, p in pairs(Pages) do
        p.Visible = (k == key)
    end
end

for k, btn in pairs(Tabs) do
    btn.MouseButton1Click:Connect(function() setTab(k) end)
    btn.TouchTap:Connect(function() setTab(k) end)
end

setTab("Farm")

-- ============================================================
--  WIDGET BUILDERS
-- ============================================================
local CARD_H = IsMobile and 62 or 54

local function secHeader(page, txt)
    local h = Instance.new("TextLabel", page)
    h.Size             = UDim2.new(1, -16, 0, IsMobile and 30 or 26)
    h.BackgroundColor3 = C.Panel
    h.Text             = "  " .. txt
    h.Font             = Enum.Font.GothamBold
    h.TextSize         = IsMobile and 12 or 11
    h.TextColor3       = C.Accent
    h.TextXAlignment   = Enum.TextXAlignment.Left
    h.BorderSizePixel  = 0
    corner(h, 6)
    return h
end

-- Toggle widget (supports both touch and mouse)
local function toggleWidget(page, label, sub, cfgKey)
    local card = Instance.new("Frame", page)
    card.Size             = UDim2.new(1, -16, 0, CARD_H)
    card.BackgroundColor3 = C.Card
    card.BorderSizePixel  = 0
    corner(card, 9)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size              = UDim2.new(1, -70, 0, 22)
    lbl.Position          = UDim2.new(0, 12, 0, IsMobile and 10 or 7)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.Font              = Enum.Font.GothamSemibold
    lbl.TextSize          = IsMobile and 13 or 13
    lbl.TextColor3        = C.Text
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    local sub2 = Instance.new("TextLabel", card)
    sub2.Size             = UDim2.new(1, -70, 0, 16)
    sub2.Position         = UDim2.new(0, 12, 0, IsMobile and 34 or 30)
    sub2.BackgroundTransparency = 1
    sub2.Text             = sub or ""
    sub2.Font             = Enum.Font.Gotham
    sub2.TextSize         = 10
    sub2.TextColor3       = C.SubText
    sub2.TextXAlignment   = Enum.TextXAlignment.Left
    sub2.TextWrapped      = true

    -- pill
    local pillW, pillH = IsMobile and 50 or 44, IsMobile and 28 or 24
    local pillBG = Instance.new("Frame", card)
    pillBG.Size             = UDim2.new(0, pillW, 0, pillH)
    pillBG.Position         = UDim2.new(1, -(pillW+10), 0.5, -pillH/2)
    pillBG.BackgroundColor3 = Config[cfgKey] and C.ON or C.OFF
    pillBG.BorderSizePixel  = 0
    corner(pillBG, pillH/2)

    local knobSz = IsMobile and 22 or 18
    local knob = Instance.new("Frame", pillBG)
    knob.Size             = UDim2.new(0, knobSz, 0, knobSz)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
    knob.BorderSizePixel  = 0
    corner(knob, knobSz/2)
    knob.Position = Config[cfgKey]
        and UDim2.new(1, -(knobSz+3), 0.5, -knobSz/2)
         or UDim2.new(0, 3,           0.5, -knobSz/2)

    local function toggle()
        Config[cfgKey] = not Config[cfgKey]
        local on = Config[cfgKey]
        Tween(pillBG, 0.2, { BackgroundColor3 = on and C.ON or C.OFF })
        Tween(knob,   0.2, { Position = on
            and UDim2.new(1, -(knobSz+3), 0.5, -knobSz/2)
             or UDim2.new(0, 3,           0.5, -knobSz/2) })
        notify(label, on and "✅ Enabled" or "❌ Disabled")
    end

    local hitBtn = Instance.new("TextButton", card)
    hitBtn.Size               = UDim2.new(1,0,1,0)
    hitBtn.BackgroundTransparency = 1
    hitBtn.Text               = ""
    hitBtn.ZIndex             = 5
    hitBtn.MouseButton1Click:Connect(toggle)
    hitBtn.TouchTap:Connect(toggle)

    card.MouseEnter:Connect(function() Tween(card, 0.1, { BackgroundColor3 = C.Hover }) end)
    card.MouseLeave:Connect(function() Tween(card, 0.1, { BackgroundColor3 = C.Card  }) end)

    return card
end

-- Slider widget (touch + mouse)
local function sliderWidget(page, label, mn, mx, def, cfgKey, unit)
    local card = Instance.new("Frame", page)
    card.Size             = UDim2.new(1, -16, 0, IsMobile and 74 or 64)
    card.BackgroundColor3 = C.Card
    card.BorderSizePixel  = 0
    corner(card, 9)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size              = UDim2.new(0.65, 0, 0, 20)
    lbl.Position          = UDim2.new(0, 12, 0, 7)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.Font              = Enum.Font.GothamSemibold
    lbl.TextSize          = 13
    lbl.TextColor3        = C.Text
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size           = UDim2.new(0.35, -12, 0, 20)
    valLbl.Position       = UDim2.new(0.65, 0, 0, 7)
    valLbl.BackgroundTransparency = 1
    valLbl.Text           = tostring(def) .. (unit or "")
    valLbl.Font           = Enum.Font.GothamBold
    valLbl.TextSize       = 13
    valLbl.TextColor3     = C.Accent
    valLbl.TextXAlignment = Enum.TextXAlignment.Right

    local trackY = IsMobile and 44 or 38
    local track  = Instance.new("Frame", card)
    track.Size            = UDim2.new(1, -24, 0, IsMobile and 8 or 6)
    track.Position        = UDim2.new(0, 12, 0, trackY)
    track.BackgroundColor3 = C.Panel
    track.BorderSizePixel = 0
    corner(track, 4)

    local fill = Instance.new("Frame", track)
    fill.Size             = UDim2.new((def-mn)/(mx-mn), 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel  = 0
    corner(fill, 4)

    local knobSz = IsMobile and 20 or 14
    local knob   = Instance.new("Frame", track)
    local pct    = (def-mn)/(mx-mn)
    knob.Size             = UDim2.new(0, knobSz, 0, knobSz)
    knob.Position         = UDim2.new(pct, -knobSz/2, 0.5, -knobSz/2)
    knob.BackgroundColor3 = C.Text
    knob.BorderSizePixel  = 0
    corner(knob, knobSz/2)

    local function setFromX(x)
        local abs = track.AbsolutePosition.X
        local w   = track.AbsoluteSize.X
        local rel = math.clamp((x - abs) / w, 0, 1)
        local val = math.floor(mn + rel * (mx - mn))
        Config[cfgKey] = val
        fill.Size       = UDim2.new(rel, 0, 1, 0)
        knob.Position   = UDim2.new(rel, -knobSz/2, 0.5, -knobSz/2)
        valLbl.Text     = tostring(val) .. (unit or "")
    end

    -- Mouse drag
    local mdrag = false
    knob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then mdrag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then mdrag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if mdrag and i.UserInputType == Enum.UserInputType.MouseMovement then
            setFromX(i.Position.X)
        end
    end)

    -- Touch drag
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            setFromX(i.Position.X)
        end
    end)
    track.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch then
            setFromX(i.Position.X)
        end
    end)

    return card
end

-- Teleport card
local function tpCard(page, label, desc, pos)
    local card = Instance.new("Frame", page)
    card.Size             = UDim2.new(1, -16, 0, CARD_H)
    card.BackgroundColor3 = C.Card
    card.BorderSizePixel  = 0
    corner(card, 9)

    local lbl = Instance.new("TextLabel", card)
    lbl.Size              = UDim2.new(1, -82, 0, 22)
    lbl.Position          = UDim2.new(0, 12, 0, IsMobile and 10 or 7)
    lbl.BackgroundTransparency = 1
    lbl.Text              = label
    lbl.Font              = Enum.Font.GothamSemibold
    lbl.TextSize          = 13
    lbl.TextColor3        = C.Text
    lbl.TextXAlignment    = Enum.TextXAlignment.Left

    local sub = Instance.new("TextLabel", card)
    sub.Size              = UDim2.new(1, -82, 0, 16)
    sub.Position          = UDim2.new(0, 12, 0, IsMobile and 34 or 30)
    sub.BackgroundTransparency = 1
    sub.Text              = desc or ""
    sub.Font              = Enum.Font.Gotham
    sub.TextSize          = 10
    sub.TextColor3        = C.SubText
    sub.TextXAlignment    = Enum.TextXAlignment.Left

    local goBtn = Instance.new("TextButton", card)
    goBtn.Size            = UDim2.new(0, IsMobile and 70 or 60, 0, IsMobile and 34 or 28)
    goBtn.Position        = UDim2.new(1, -(IsMobile and 80 or 70), 0.5, IsMobile and -17 or -14)
    goBtn.BackgroundColor3 = C.Accent
    goBtn.Text            = "GO"
    goBtn.Font            = Enum.Font.GothamBold
    goBtn.TextSize        = 13
    goBtn.TextColor3      = Color3.fromRGB(255,255,255)
    goBtn.BorderSizePixel = 0
    corner(goBtn, 7)

    local function doTP()
        local chr = LocalPlayer.Character
        if chr and chr:FindFirstChild("HumanoidRootPart") then
            chr.HumanoidRootPart.CFrame = CFrame.new(pos)
            notify("Teleport", "📍 Warped to " .. label)
        end
    end
    goBtn.MouseButton1Click:Connect(doTP)
    goBtn.TouchTap:Connect(doTP)

    card.MouseEnter:Connect(function() Tween(card, 0.1, { BackgroundColor3 = C.Hover }) end)
    card.MouseLeave:Connect(function() Tween(card, 0.1, { BackgroundColor3 = C.Card  }) end)
    return card
end

-- ============================================================
--  PAGE: FARM
-- ============================================================
local farmPage = Pages["Farm"]
secHeader(farmPage, "🌾  AUTO FARMING")
toggleWidget(farmPage, "Auto Farm",          "Teleports to & kills nearest mobs",    "AutoFarm")
toggleWidget(farmPage, "Auto Quest",         "Auto-accepts & completes quests",       "AutoQuest")
toggleWidget(farmPage, "Auto Boss Kill",     "Targets and kills boss NPCs",           "AutoBossKill")
toggleWidget(farmPage, "Auto Collect Drops", "Picks up Beli, exp orbs & items",       "AutoCollect")
secHeader(farmPage, "⚙️  FARM OPTIONS")
sliderWidget(farmPage, "Kill Aura Range",    5, 120, 35,  "KillAuraRange", " st")
toggleWidget(farmPage, "Kill Aura",          "Insta-kills mobs within range",         "KillAura")
toggleWidget(farmPage, "Auto Skills",        "Automatically fires all equipped skills","AutoSkills")
toggleWidget(farmPage, "Auto Sword",         "Auto swings your melee weapon",         "AutoSword")
toggleWidget(farmPage, "Auto Dodge",         "Dodges enemy attacks automatically",    "AutoDodge")

-- ============================================================
--  PAGE: 3RD SEA LEVEL FARM  (2500 – 2850)
-- ============================================================
local thirdPage = Pages["ThirdSea"]
secHeader(thirdPage, "🌏  3RD SEA LEVEL FARM  (2500–2850)")

-- Level selector dropdown (scrollable list of buttons)
local selCard = Instance.new("Frame", thirdPage)
selCard.Size             = UDim2.new(1,-16,0, IsMobile and 200 or 180)
selCard.BackgroundColor3 = C.Card
selCard.BorderSizePixel  = 0
corner(selCard, 10)

local selTitle = Instance.new("TextLabel", selCard)
selTitle.Size            = UDim2.new(1,0,0,28)
selTitle.Position        = UDim2.new(0,0,0,0)
selTitle.BackgroundTransparency = 1
selTitle.Text            = "  Select Target Level:"
selTitle.Font            = Enum.Font.GothamBold
selTitle.TextSize        = 12
selTitle.TextColor3      = C.Accent
selTitle.TextXAlignment  = Enum.TextXAlignment.Left

local selScroll = Instance.new("ScrollingFrame", selCard)
selScroll.Size               = UDim2.new(1,-8, 1, -34)
selScroll.Position           = UDim2.new(0,4,0,30)
selScroll.BackgroundTransparency = 1
selScroll.BorderSizePixel    = 0
selScroll.ScrollBarThickness = IsMobile and 0 or 3
selScroll.ScrollBarImageColor3 = C.Accent
selScroll.CanvasSize         = UDim2.new(0,0,0,0)

local selLayout = Instance.new("UIListLayout", selScroll)
selLayout.Padding            = UDim.new(0, 4)
selLayout.FillDirection      = Enum.FillDirection.Horizontal
selLayout.Wraps              = true
selLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
selLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    selScroll.CanvasSize = UDim2.new(0,0,0, selLayout.AbsoluteContentSize.Y + 8)
end)
local selPad = Instance.new("UIPadding", selScroll)
selPad.PaddingLeft = UDim.new(0,4)
selPad.PaddingTop  = UDim.new(0,4)

local LevelBtns = {}
for _, lvl in ipairs(LevelKeys) do
    local mob = ThirdSeaMobs[lvl]
    local b = Instance.new("TextButton", selScroll)
    b.Size             = UDim2.new(0, IsMobile and 78 or 72, 0, IsMobile and 36 or 30)
    b.BackgroundColor3 = (Config.FarmTargetLevel == lvl) and C.Accent or C.Panel
    b.Text             = tostring(lvl)
    b.Font             = Enum.Font.GothamBold
    b.TextSize         = 12
    b.TextColor3       = Color3.fromRGB(255,255,255)
    b.BorderSizePixel  = 0
    corner(b, 6)
    LevelBtns[lvl] = b

    local function selectLvl()
        Config.FarmTargetLevel = lvl
        for k2, bb in pairs(LevelBtns) do
            Tween(bb, 0.15, { BackgroundColor3 = (k2==lvl) and C.Accent or C.Panel })
        end
        notify("Level Farm", "Target: Lv "..lvl.." · "..mob.name.." @ "..mob.location)
    end
    b.MouseButton1Click:Connect(selectLvl)
    b.TouchTap:Connect(selectLvl)
end

-- Info card for selected mob
local mobInfoCard = Instance.new("Frame", thirdPage)
mobInfoCard.Size             = UDim2.new(1,-16,0, IsMobile and 110 or 96)
mobInfoCard.BackgroundColor3 = C.Card
mobInfoCard.BorderSizePixel  = 0
corner(mobInfoCard, 10)
stroke(mobInfoCard, 1, C.Accent2)

local mobInfoLbl = Instance.new("TextLabel", mobInfoCard)
mobInfoLbl.Size              = UDim2.new(1,-16,1,0)
mobInfoLbl.Position          = UDim2.new(0,8,0,0)
mobInfoLbl.BackgroundTransparency = 1
mobInfoLbl.Font              = Enum.Font.Gotham
mobInfoLbl.TextSize          = IsMobile and 12 or 12
mobInfoLbl.TextColor3        = C.Text
mobInfoLbl.TextXAlignment    = Enum.TextXAlignment.Left
mobInfoLbl.TextYAlignment    = Enum.TextYAlignment.Center
mobInfoLbl.TextWrapped       = true

local function updateMobInfo()
    local d = ThirdSeaMobs[Config.FarmTargetLevel]
    if d then
        mobInfoLbl.Text =
            "🎯  Mob: " .. d.name .. "\n" ..
            "📍  Location: " .. d.location .. "\n" ..
            "⚔️  Level Range: " .. Config.FarmTargetLevel .. " – " .. (Config.FarmTargetLevel+49) .. "\n" ..
            "✅  Status: " .. (Config.ThirdSeaFarm and "FARMING ACTIVE" or "Idle — enable below")
    end
end
updateMobInfo()

-- Teleport to quest NPC button
local questTPCard = Instance.new("Frame", thirdPage)
questTPCard.Size             = UDim2.new(1,-16,0,CARD_H)
questTPCard.BackgroundColor3 = C.Card
questTPCard.BorderSizePixel  = 0
corner(questTPCard, 9)

local qtLbl = Instance.new("TextLabel", questTPCard)
qtLbl.Size              = UDim2.new(1,-90,0,22)
qtLbl.Position          = UDim2.new(0,12,0, IsMobile and 10 or 7)
qtLbl.BackgroundTransparency = 1
qtLbl.Text              = "Teleport to Quest NPC"
qtLbl.Font              = Enum.Font.GothamSemibold
qtLbl.TextSize          = 13
qtLbl.TextColor3        = C.Text
qtLbl.TextXAlignment    = Enum.TextXAlignment.Left

local qtSub = Instance.new("TextLabel", questTPCard)
qtSub.Size              = UDim2.new(1,-90,0,16)
qtSub.Position          = UDim2.new(0,12,0, IsMobile and 34 or 30)
qtSub.BackgroundTransparency = 1
qtSub.Text              = "Warps to the quest giver for selected level"
qtSub.Font              = Enum.Font.Gotham
qtSub.TextSize          = 10
qtSub.TextColor3        = C.SubText
qtSub.TextXAlignment    = Enum.TextXAlignment.Left

local qtBtn = Instance.new("TextButton", questTPCard)
qtBtn.Size            = UDim2.new(0, IsMobile and 70 or 60, 0, IsMobile and 34 or 28)
qtBtn.Position        = UDim2.new(1, -(IsMobile and 80 or 70), 0.5, IsMobile and -17 or -14)
qtBtn.BackgroundColor3 = C.Blue
qtBtn.Text            = "QUEST"
qtBtn.Font            = Enum.Font.GothamBold
qtBtn.TextSize        = 11
qtBtn.TextColor3      = Color3.fromRGB(255,255,255)
qtBtn.BorderSizePixel = 0
corner(qtBtn, 7)

local function doQuestTP()
    local d = ThirdSeaMobs[Config.FarmTargetLevel]
    if not d then return end
    local chr = LocalPlayer.Character
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = CFrame.new(d.quest)
        notify("Quest NPC", "📍 Warped for Lv " .. Config.FarmTargetLevel .. " quest")
    end
end
qtBtn.MouseButton1Click:Connect(doQuestTP)
qtBtn.TouchTap:Connect(doQuestTP)

-- Teleport to mob spawn button
local mobTPCard = Instance.new("Frame", thirdPage)
mobTPCard.Size             = UDim2.new(1,-16,0,CARD_H)
mobTPCard.BackgroundColor3 = C.Card
mobTPCard.BorderSizePixel  = 0
corner(mobTPCard, 9)

local mtLbl = Instance.new("TextLabel", mobTPCard)
mtLbl.Size              = UDim2.new(1,-90,0,22)
mtLbl.Position          = UDim2.new(0,12,0, IsMobile and 10 or 7)
mtLbl.BackgroundTransparency = 1
mtLbl.Text              = "Teleport to Mob Spawn"
mtLbl.Font              = Enum.Font.GothamSemibold
mtLbl.TextSize          = 13
mtLbl.TextColor3        = C.Text
mtLbl.TextXAlignment    = Enum.TextXAlignment.Left

local mtSub = Instance.new("TextLabel", mobTPCard)
mtSub.Size              = UDim2.new(1,-90,0,16)
mtSub.Position          = UDim2.new(0,12,0, IsMobile and 34 or 30)
mtSub.BackgroundTransparency = 1
mtSub.Text              = "Warps directly to the mob location"
mtSub.Font              = Enum.Font.Gotham
mtSub.TextSize          = 10
mtSub.TextColor3        = C.SubText
mtSub.TextXAlignment    = Enum.TextXAlignment.Left

local mtBtn = Instance.new("TextButton", mobTPCard)
mtBtn.Size            = UDim2.new(0, IsMobile and 70 or 60, 0, IsMobile and 34 or 28)
mtBtn.Position        = UDim2.new(1, -(IsMobile and 80 or 70), 0.5, IsMobile and -17 or -14)
mtBtn.BackgroundColor3 = C.Accent
mtBtn.Text            = "GO"
mtBtn.Font            = Enum.Font.GothamBold
mtBtn.TextSize        = 13
mtBtn.TextColor3      = Color3.fromRGB(255,255,255)
mtBtn.BorderSizePixel = 0
corner(mtBtn, 7)

local function doMobTP()
    local d = ThirdSeaMobs[Config.FarmTargetLevel]
    if not d then return end
    local chr = LocalPlayer.Character
    if chr and chr:FindFirstChild("HumanoidRootPart") then
        chr.HumanoidRootPart.CFrame = CFrame.new(d.pos)
        notify("Mob Spawn", "📍 Warped to " .. d.name .. " spawn")
    end
end
mtBtn.MouseButton1Click:Connect(doMobTP)
mtBtn.TouchTap:Connect(doMobTP)

secHeader(thirdPage, "🤖  AUTO FARM LOOP")
toggleWidget(thirdPage, "3rd Sea Auto Farm",
    "Auto-teleports to mob, kills, quests & loops",
    "ThirdSeaFarm")
toggleWidget(thirdPage, "Auto Quest (3rd Sea)",
    "Auto-accepts quest for selected level mob",
    "AutoQuest")
toggleWidget(thirdPage, "Kill Aura (enable too)",
    "Required for auto-farm to deal damage",
    "KillAura")

local howCard = Instance.new("Frame", thirdPage)
howCard.Size             = UDim2.new(1,-16,0, IsMobile and 120 or 100)
howCard.BackgroundColor3 = C.Card
howCard.BorderSizePixel  = 0
corner(howCard, 10)
local howLbl = Instance.new("TextLabel", howCard)
howLbl.Size              = UDim2.new(1,-16,1,0)
howLbl.Position          = UDim2.new(0,8,0,0)
howLbl.BackgroundTransparency = 1
howLbl.Text =
    "HOW IT WORKS:\n" ..
    "1. Pick your level (2500–2850) above\n" ..
    "2. Enable Kill Aura + 3rd Sea Auto Farm\n" ..
    "3. Script: TP quest → accept → TP mob → kill loop\n" ..
    "4. On quest complete it repeats automatically"
howLbl.Font              = Enum.Font.Gotham
howLbl.TextSize          = IsMobile and 11 or 11
howLbl.TextColor3        = C.SubText
howLbl.TextXAlignment    = Enum.TextXAlignment.Left
howLbl.TextYAlignment    = Enum.TextYAlignment.Center
howLbl.TextWrapped       = true

-- ============================================================
--  PAGE: TELEPORT
-- ============================================================
local tpPage = Pages["Teleport"]
secHeader(tpPage, "🌊  FIRST SEA")
tpCard(tpPage, "Starter Island",    "Spawn island",             Vector3.new(975,  128, 1113))
tpCard(tpPage, "Marine Base",       "Marine Recruits / Cpl.",   Vector3.new(-970, 90,  3879))
tpCard(tpPage, "Jungle",            "Monkeys & Gorillas",       Vector3.new(-1600,70, -1400))
tpCard(tpPage, "Pirate Village",    "Pirates lvl 75+",          Vector3.new(-1420,30,  1070))
tpCard(tpPage, "Skylands",          "Sky Warriors / Knights",   Vector3.new(-5100,800,-1500))
tpCard(tpPage, "Prison",            "Prisoners & Guards",       Vector3.new(4830, 17,   793))
tpCard(tpPage, "Colosseum",         "Gladiators lvl 230+",      Vector3.new(-1320,6,   3640))
tpCard(tpPage, "Magma Village",     "Magma Ninjas",             Vector3.new(-4190,550, 4110))
secHeader(tpPage, "🌊  SECOND SEA")
tpCard(tpPage, "Kingdom of Rose",   "Flower Pirates",           Vector3.new(-220,  15, -1500))
tpCard(tpPage, "Green Zone",        "Forest Pirates",           Vector3.new(4330,  25,  1090))
tpCard(tpPage, "Graveyard",         "Zombie Pirates",           Vector3.new(5750,  17,  -360))
tpCard(tpPage, "Snow Mountain",     "Snowmen / Penguins",       Vector3.new(-1670,250, -5450))
tpCard(tpPage, "Hot & Cold",        "Ice Admiral boss",         Vector3.new(-4440,900, -2640))
secHeader(tpPage, "🌊  THIRD SEA")
tpCard(tpPage, "Port Town",         "Island Pirates (2300+)",   Vector3.new(-16800,140,-4800))
tpCard(tpPage, "Hydra Island",      "Sea Soldiers (2375+)",     Vector3.new(-19000,110,-5600))
tpCard(tpPage, "Great Tree",        "Tree Villagers (2425+)",   Vector3.new(-21700,1050,-3750))
tpCard(tpPage, "Floating Turtle",   "Longma (2500+)",           Vector3.new(-24380,820,-3810))
tpCard(tpPage, "Peanut Island",     "Peanut Scouts (2550+)",    Vector3.new(-28500,30,  2400))
tpCard(tpPage, "Ice Cream Island",  "Ice Cream Chef (2625+)",   Vector3.new(-31000,20, -1800))
tpCard(tpPage, "Cake Island",       "Cake Guard (2700+)",       Vector3.new(-34000,20,   800))
tpCard(tpPage, "Chocolate Island",  "Chocolatier (2800+)",      Vector3.new(-37200,20, -3000))
tpCard(tpPage, "Candy Kingdom",     "Candy Pirate (2850+)",     Vector3.new(-39500,20,  1200))

-- ============================================================
--  PAGE: ESP
-- ============================================================
local espPage = Pages["ESP"]
secHeader(espPage, "👁  ESP OPTIONS")
toggleWidget(espPage, "Player ESP",  "Show name tags above all players",      "PlayerESP")
toggleWidget(espPage, "Mob ESP",     "Highlight enemies with health bars",     "MobESP")
toggleWidget(espPage, "Fruit ESP",   "Highlight spawned Devil Fruits",         "FruitESP")
toggleWidget(espPage, "Chest ESP",   "Show treasure chests through walls",     "ChestESP")

-- ============================================================
--  PAGE: PLAYER
-- ============================================================
local playerPage = Pages["Player"]
secHeader(playerPage, "🚀  MOVEMENT")
toggleWidget(playerPage, "Speed Hack",       "Boost walk speed",            "SpeedHack")
sliderWidget(playerPage, "Walk Speed",        16, 500, 50,  "SpeedValue",  " ws")
toggleWidget(playerPage, "Jump Hack",        "Boost jump power",            "JumpHack")
sliderWidget(playerPage, "Jump Power",        50, 500, 100, "JumpValue",   " jp")
toggleWidget(playerPage, "Fly Hack",         "Fly (use on-screen pad)",     "FlyHack")
sliderWidget(playerPage, "Fly Speed",         10, 300, 80,  "FlySpeed",    " sp")
toggleWidget(playerPage, "NoClip",           "Phase through walls",         "NoClip")
secHeader(playerPage, "💪  STATS")
toggleWidget(playerPage, "Infinite Stamina", "Stamina never depletes",      "InfStamina")
toggleWidget(playerPage, "Infinite Energy",  "Energy stays full",           "InfEnergy")
toggleWidget(playerPage, "Anti AFK",         "Prevents AFK disconnect",     "AntiAFK")
toggleWidget(playerPage, "Auto Stats",       "Auto-assigns stat points",    "AutoStats")

-- ============================================================
--  PAGE: FRUITS
-- ============================================================
local fruitPage = Pages["Fruits"]
secHeader(fruitPage, "🍎  DEVIL FRUIT")
toggleWidget(fruitPage, "Fruit Sniper",      "Auto-buys from Black Market", "FruitSniper")
toggleWidget(fruitPage, "Auto Eat Fruit",    "Eats fruits on pickup",       "AutoEat")
toggleWidget(fruitPage, "Auto Collect",      "TP to & collect map fruits",  "AutoCollect")
toggleWidget(fruitPage, "Fruit ESP",         "Show fruits on map",          "FruitESP")

-- ============================================================
--  PAGE: RAIDS
-- ============================================================
local raidPage = Pages["Raids"]
secHeader(raidPage, "🏴  RAID AUTOMATION")
toggleWidget(raidPage, "Auto Raid",     "Completes raid waves + boss",   "AutoRaid")
toggleWidget(raidPage, "Auto Sea Beast","Farm sea beasts for fragments", "AutoSeaBeast")

-- ============================================================
--  PAGE: COMBAT
-- ============================================================
local combatPage = Pages["Combat"]
secHeader(combatPage, "⚔️  COMBAT")
toggleWidget(combatPage, "Kill Aura",    "Insta-kills mobs in range",      "KillAura")
sliderWidget(combatPage, "Aura Range",   5, 120, 35, "KillAuraRange", " st")
toggleWidget(combatPage, "Auto Dodge",  "Dodges incoming hits",           "AutoDodge")
toggleWidget(combatPage, "Auto Skills", "Fires all skills automatically", "AutoSkills")
toggleWidget(combatPage, "Auto Sword",  "Auto-swings melee weapon",       "AutoSword")
secHeader(combatPage, "💥  BOSSES")
toggleWidget(combatPage, "Auto Boss Kill", "Targets & kills boss NPCs",   "AutoBossKill")

-- ============================================================
--  PAGE: SETTINGS
-- ============================================================
local settingsPage = Pages["Settings"]
secHeader(settingsPage, "⚙️  GENERAL")
toggleWidget(settingsPage, "Anti AFK", "Prevents disconnect",              "AntiAFK")
secHeader(settingsPage, "📱  MOBILE INFO")
local mCard = Instance.new("Frame", settingsPage)
mCard.Size             = UDim2.new(1,-16,0, IsMobile and 130 or 110)
mCard.BackgroundColor3 = C.Card
mCard.BorderSizePixel  = 0
corner(mCard, 9)
local mLbl = Instance.new("TextLabel", mCard)
mLbl.Size              = UDim2.new(1,-16,1,0)
mLbl.Position          = UDim2.new(0,8,0,0)
mLbl.BackgroundTransparency = 1
mLbl.Text =
    "📱  MOBILE CONTROLS:\n" ..
    "• Tap any toggle or button to activate\n" ..
    "• Drag title bar to move the window\n" ..
    "• On-screen FLY PAD appears when Fly is ON\n" ..
    "• Swipe inside tab content to scroll\n" ..
    "• Tap [—] to minimise, [✕] to close"
mLbl.Font              = Enum.Font.Gotham
mLbl.TextSize          = IsMobile and 12 or 11
mLbl.TextColor3        = C.SubText
mLbl.TextXAlignment    = Enum.TextXAlignment.Left
mLbl.TextYAlignment    = Enum.TextYAlignment.Center
mLbl.TextWrapped       = true

secHeader(settingsPage, "ℹ️  ABOUT")
local abCard = Instance.new("Frame", settingsPage)
abCard.Size             = UDim2.new(1,-16,0, IsMobile and 90 or 80)
abCard.BackgroundColor3 = C.Card
abCard.BorderSizePixel  = 0
corner(abCard, 9)
local abLbl = Instance.new("TextLabel", abCard)
abLbl.Size              = UDim2.new(1,-16,1,0)
abLbl.Position          = UDim2.new(0,8,0,0)
abLbl.BackgroundTransparency = 1
abLbl.Text = "🍎 Blox Fruits Hack GUI v5.0\nMobile & PC  |  All Seas  |  Lv 2500–2850 Farm\nAuto Farm, ESP, Fly, NoClip, Raids & more!"
abLbl.Font              = Enum.Font.Gotham
abLbl.TextSize          = 12
abLbl.TextColor3        = C.SubText
abLbl.TextXAlignment    = Enum.TextXAlignment.Left
abLbl.TextYAlignment    = Enum.TextYAlignment.Center
abLbl.TextWrapped       = true

-- ============================================================
--  DRAG (mouse + touch)
-- ============================================================
do
    local dragging  = false
    local dragStart = nil
    local startPos  = nil

    local function beginDrag(pos)
        dragging  = true
        dragStart = pos
        startPos  = MainFrame.Position
    end
    local function moveDrag(pos)
        if not dragging then return end
        local d = pos - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
    local function endDrag() dragging = false end

    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then beginDrag(i.Position) end
        if i.UserInputType == Enum.UserInputType.Touch          then beginDrag(i.Position) end
    end)
    TitleBar.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then endDrag() end
        if i.UserInputType == Enum.UserInputType.Touch          then endDrag() end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then moveDrag(i.Position) end
        if i.UserInputType == Enum.UserInputType.Touch          then moveDrag(i.Position) end
    end)
end

-- ============================================================
--  MINIMIZE / CLOSE
-- ============================================================
local minimised = false
local function doMinimize()
    minimised = not minimised
    local h = minimised and TITLE_H or WIN_H
    Tween(MainFrame, 0.25, { Size = UDim2.new(0, WIN_W, 0, h) })
    MinBtn.Text = minimised and "□" or "—"
end
MinBtn.MouseButton1Click:Connect(doMinimize)
MinBtn.TouchTap:Connect(doMinimize)

local function doClose()
    Tween(MainFrame, 0.3, {
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
    })
    task.delay(0.35, function() ScreenGui:Destroy() end)
end
CloseBtn.MouseButton1Click:Connect(doClose)
CloseBtn.TouchTap:Connect(doClose)

-- Keyboard toggle (PC)
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        Config.UIOpen = not Config.UIOpen
        MainFrame.Visible = Config.UIOpen
    end
end)

-- ============================================================
--  MOBILE FLY PAD  (on-screen virtual joystick)
-- ============================================================
local FlyPad = Instance.new("Frame", ScreenGui)
FlyPad.Name              = "FlyPad"
FlyPad.Size              = UDim2.new(0, 140, 0, 140)
FlyPad.Position          = UDim2.new(1, -160, 1, -160)
FlyPad.BackgroundColor3  = Color3.fromRGB(0,0,0)
FlyPad.BackgroundTransparency = 0.55
FlyPad.BorderSizePixel   = 0
FlyPad.Visible           = false
corner(FlyPad, 70)

local FlyKnob = Instance.new("Frame", FlyPad)
FlyKnob.Size             = UDim2.new(0, 44, 0, 44)
FlyKnob.Position         = UDim2.new(0.5, -22, 0.5, -22)
FlyKnob.BackgroundColor3 = C.Accent
FlyKnob.BorderSizePixel  = 0
corner(FlyKnob, 22)

local FlyUpBtn = Instance.new("TextButton", ScreenGui)
FlyUpBtn.Size             = UDim2.new(0, 54, 0, 44)
FlyUpBtn.Position         = UDim2.new(1, -220, 1, -200)
FlyUpBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
FlyUpBtn.BackgroundTransparency = 0.5
FlyUpBtn.Text             = "↑ UP"
FlyUpBtn.Font             = Enum.Font.GothamBold
FlyUpBtn.TextSize         = 12
FlyUpBtn.TextColor3       = Color3.fromRGB(255,255,255)
FlyUpBtn.BorderSizePixel  = 0
FlyUpBtn.Visible          = false
corner(FlyUpBtn, 8)

local FlyDnBtn = Instance.new("TextButton", ScreenGui)
FlyDnBtn.Size             = UDim2.new(0, 54, 0, 44)
FlyDnBtn.Position         = UDim2.new(1, -160, 1, -200)
FlyDnBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
FlyDnBtn.BackgroundTransparency = 0.5
FlyDnBtn.Text             = "↓ DN"
FlyDnBtn.Font             = Enum.Font.GothamBold
FlyDnBtn.TextSize         = 12
FlyDnBtn.TextColor3       = Color3.fromRGB(255,255,255)
FlyDnBtn.BorderSizePixel  = 0
FlyDnBtn.Visible          = false
corner(FlyDnBtn, 8)

-- virtual joystick state
local flyDir      = Vector3.new()
local flyVertical = 0
local padActive   = false
local padCenter   = Vector2.new()

FlyPad.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        padActive = true
        padCenter = Vector2.new(
            FlyPad.AbsolutePosition.X + FlyPad.AbsoluteSize.X/2,
            FlyPad.AbsolutePosition.Y + FlyPad.AbsoluteSize.Y/2)
    end
end)
FlyPad.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        padActive = false
        flyDir = Vector3.new()
        Tween(FlyKnob, 0.15, { Position = UDim2.new(0.5,-22,0.5,-22) })
    end
end)
FlyPad.InputChanged:Connect(function(i)
    if padActive and i.UserInputType == Enum.UserInputType.Touch then
        local dx = math.clamp(i.Position.X - padCenter.X, -50, 50) / 50
        local dy = math.clamp(i.Position.Y - padCenter.Y, -50, 50) / 50
        flyDir = Vector3.new(dx, 0, dy)
        FlyKnob.Position = UDim2.new(0.5, dx*46-22, 0.5, dy*46-22)
    end
end)

local flyUp, flyDn = false, false
FlyUpBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then flyUp = true end
end)
FlyUpBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then flyUp = false end
end)
FlyDnBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then flyDn = true end
end)
FlyDnBtn.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.Touch then flyDn = false end
end)

-- show/hide fly pad when FlyHack toggled
-- handled in heartbeat visibility block below

-- ============================================================
--  LOGIC LOOPS
-- ============================================================

-- Anti-AFK
task.spawn(function()
    while task.wait(55) do
        if Config.AntiAFK then
            local vrs = LocalPlayer:FindFirstChildOfClass("VirtualUser")
            if vrs then vrs:CaptureController(); vrs:ClickButton2(Vector2.new()) end
        end
    end
end)

-- Speed / Jump
RunService.Heartbeat:Connect(function()
    local chr = LocalPlayer.Character
    if not chr then return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end
    hum.WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16
    hum.JumpPower = Config.JumpHack  and Config.JumpValue  or 50
end)

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    local chr = LocalPlayer.Character
    if not chr or not chr:FindFirstChild("HumanoidRootPart") then return end
    local myPos = chr.HumanoidRootPart.Position
    for _, model in pairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model ~= chr then
            local hum = model:FindFirstChildWhichIsA("Humanoid")
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if (hrp.Position - myPos).Magnitude <= Config.KillAuraRange then
                    hum.Health = 0
                end
            end
        end
    end
end)

-- Infinite Stamina / Energy
RunService.Heartbeat:Connect(function()
    local chr = LocalPlayer.Character
    if not chr then return end
    if Config.InfStamina then
        local s = chr:FindFirstChild("Stamina") or chr:FindFirstChild("stamina")
        if s and s:IsA("NumberValue") then s.Value = s.MaxValue or 100 end
    end
    if Config.InfEnergy then
        local e = chr:FindFirstChild("Energy") or chr:FindFirstChild("energy")
        if e and e:IsA("NumberValue") then e.Value = e.MaxValue or 100 end
    end
end)

-- Fly Hack (PC: WASD, Mobile: joystick pad)
local flyBV, flyBG
RunService.Heartbeat:Connect(function()
    local chr = LocalPlayer.Character
    if not chr then return end
    local hrp = chr:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- show/hide mobile fly pad
    FlyPad.Visible   = Config.FlyHack and IsMobile
    FlyUpBtn.Visible = Config.FlyHack and IsMobile
    FlyDnBtn.Visible = Config.FlyHack and IsMobile

    if Config.FlyHack then
        if not flyBV or not flyBV.Parent then
            flyBV = Instance.new("BodyVelocity", hrp)
            flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
            flyBG = Instance.new("BodyGyro", hrp)
            flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9)
        end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new()

        if IsMobile then
            -- joystick provides flyDir (x/z), up/down buttons provide y
            local fwd  = cam.CFrame.LookVector * -flyDir.Z
            local rgt  = cam.CFrame.RightVector * flyDir.X
            dir = fwd + rgt
            if flyUp then dir = dir + Vector3.new(0,1,0) end
            if flyDn then dir = dir - Vector3.new(0,1,0) end
        else
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then dir = dir + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
        end

        flyBV.Velocity = dir * Config.FlySpeed
        flyBG.CFrame   = cam.CFrame
    else
        if flyBV and flyBV.Parent then flyBV:Destroy() end
        if flyBG and flyBG.Parent then flyBG:Destroy() end
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if not Config.NoClip then return end
    local chr = LocalPlayer.Character
    if not chr then return end
    for _, p in pairs(chr:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = false end
    end
end)

-- Fruit ESP
local espTimer = 0
RunService.Heartbeat:Connect(function(dt)
    espTimer = espTimer + dt
    if espTimer < 1 then return end
    espTimer = 0
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") then
            local isFruit = v.Name:find("Fruit") or v.Name:find("Devil")
            local isChest = v.Name:find("Chest") or v.Name:find("chest")
            local bp = v:FindFirstChildWhichIsA("BasePart")
            if bp then
                if Config.FruitESP and isFruit and not bp:FindFirstChild("BF_FESP") then
                    local bb = Instance.new("BillboardGui", bp)
                    bb.Name = "BF_FESP"; bb.Size = UDim2.new(0,70,0,28)
                    bb.StudsOffset = Vector3.new(0,2.5,0); bb.AlwaysOnTop = true
                    local l = Instance.new("TextLabel", bb)
                    l.Size = UDim2.new(1,0,1,0)
                    l.BackgroundColor3 = C.Gold; l.BackgroundTransparency = 0.2
                    l.Text = "🍎 FRUIT"; l.Font = Enum.Font.GothamBold; l.TextSize = 11
                    l.TextColor3 = Color3.fromRGB(0,0,0); corner(l,4)
                end
                if Config.ChestESP and isChest and not bp:FindFirstChild("BF_CESP") then
                    local bb = Instance.new("BillboardGui", bp)
                    bb.Name = "BF_CESP"; bb.Size = UDim2.new(0,70,0,28)
                    bb.StudsOffset = Vector3.new(0,2.5,0); bb.AlwaysOnTop = true
                    local l = Instance.new("TextLabel", bb)
                    l.Size = UDim2.new(1,0,1,0)
                    l.BackgroundColor3 = Color3.fromRGB(200,160,0); l.BackgroundTransparency = 0.2
                    l.Text = "💰 CHEST"; l.Font = Enum.Font.GothamBold; l.TextSize = 11
                    l.TextColor3 = Color3.fromRGB(0,0,0); corner(l,4)
                end
            end
        end
        if not Config.FruitESP then
            local e = v:FindFirstChild("BF_FESP"); if e then e:Destroy() end
        end
        if not Config.ChestESP then
            local e = v:FindFirstChild("BF_CESP"); if e then e:Destroy() end
        end
    end
end)

-- Player ESP
RunService.Heartbeat:Connect(function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if Config.PlayerESP and not hrp:FindFirstChild("BF_PESP") then
                    local bb = Instance.new("BillboardGui", hrp)
                    bb.Name = "BF_PESP"; bb.Size = UDim2.new(0,90,0,26)
                    bb.StudsOffset = Vector3.new(0,3.5,0); bb.AlwaysOnTop = true
                    local l = Instance.new("TextLabel", bb)
                    l.Size = UDim2.new(1,0,1,0)
                    l.BackgroundColor3 = C.Red; l.BackgroundTransparency = 0.25
                    l.Text = "👤 "..plr.Name; l.Font = Enum.Font.GothamBold; l.TextSize = 11
                    l.TextColor3 = Color3.fromRGB(255,255,255); corner(l,4)
                elseif not Config.PlayerESP then
                    local e = hrp:FindFirstChild("BF_PESP"); if e then e:Destroy() end
                end
            end
        end
    end
end)

-- Generic Auto Farm (nearest mob)
task.spawn(function()
    while task.wait(0.5) do
        if not Config.AutoFarm then continue end
        local chr = LocalPlayer.Character
        if not chr or not chr:FindFirstChild("HumanoidRootPart") then continue end
        local myPos = chr.HumanoidRootPart.Position
        local best, bestD = nil, math.huge
        for _, m in pairs(Workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= chr then
                local h = m:FindFirstChildWhichIsA("Humanoid")
                local r = m:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 then
                    local d = (r.Position - myPos).Magnitude
                    if d < bestD then best = r; bestD = d end
                end
            end
        end
        if best then
            chr.HumanoidRootPart.CFrame = best.CFrame * CFrame.new(0,0,-3.5)
        end
    end
end)

-- 3RD SEA LEVEL FARM LOOP
task.spawn(function()
    local questDone = false
    while task.wait(0.6) do
        if not Config.ThirdSeaFarm then questDone = false; continue end
        local d   = ThirdSeaMobs[Config.FarmTargetLevel]
        local chr = LocalPlayer.Character
        if not chr or not d then continue end
        local hrp = chr:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Step 1: accept quest
        if not questDone then
            hrp.CFrame = CFrame.new(d.quest)
            task.wait(0.4)
            pcall(function()
                local qrem = ReplicatedStorage:FindFirstChild("quests", true)
                    or ReplicatedStorage:FindFirstChild("Quest", true)
                    or ReplicatedStorage:FindFirstChild("GetQuest", true)
                if qrem and qrem:IsA("RemoteEvent") then
                    qrem:FireServer("accept", d.name)
                    questDone = true
                elseif qrem and qrem:IsA("RemoteFunction") then
                    qrem:InvokeServer("accept", d.name)
                    questDone = true
                end
            end)
            -- if we couldn't fire quest remote, still proceed
            questDone = true
        end

        -- Step 2: teleport to mob spawn and let Kill Aura do work
        hrp.CFrame = CFrame.new(d.pos + Vector3.new(math.random(-5,5), 0, math.random(-5,5)))

        -- Step 3: check if quest complete (health-based heuristic)
        local chr2 = LocalPlayer.Character
        if chr2 then
            local hum2 = chr2:FindFirstChildWhichIsA("Humanoid")
            if hum2 and hum2.Health < hum2.MaxHealth * 0.15 then
                -- retreat briefly if taking damage
                hrp.CFrame = CFrame.new(d.quest)
                task.wait(1)
            end
        end

        -- reset quest flag every 90 seconds for re-accept cycle
        task.delay(90, function() questDone = false end)

        -- update info label
        updateMobInfo()
    end
end)

-- Auto Quest
task.spawn(function()
    while task.wait(2) do
        if not Config.AutoQuest then continue end
        pcall(function()
            local qr = ReplicatedStorage:FindFirstChild("quests", true)
                    or ReplicatedStorage:FindFirstChild("Quest", true)
            if qr and qr:IsA("RemoteEvent") then qr:FireServer("accept") end
        end)
    end
end)

-- Auto Skills
task.spawn(function()
    while task.wait(0.12) do
        if not Config.AutoSkills then continue end
        pcall(function()
            local sr = ReplicatedStorage:FindFirstChild("UseSkill", true)
            if sr and sr:IsA("RemoteEvent") then
                for i = 1, 4 do sr:FireServer(i) end
            end
        end)
    end
end)

-- Character respawn
LocalPlayer.CharacterAdded:Connect(function(chr)
    Character = chr
    HRP       = chr:WaitForChild("HumanoidRootPart")
    Humanoid  = chr:WaitForChild("Humanoid")
end)

-- ============================================================
--  OPEN ANIMATION
-- ============================================================
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
Tween(MainFrame, 0.35, {
    Size     = UDim2.new(0, WIN_W, 0, WIN_H),
    Position = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
})

task.delay(0.4, function()
    notify("🍎 Blox Fruits GUI v5.0",
        IsMobile and "Mobile ready! Tap tabs to navigate." or
                     "Loaded! RightShift = toggle window.", 5)
end)

print("[BF GUI v5.0] Loaded | Mobile:", IsMobile)
