-- ╔══════════════════════════════════════════════════╗
-- ║         Speed Hub X — Key System Library         ║
-- ║         Configurações no topo do script          ║
-- ╚══════════════════════════════════════════════════╝

-- ════════════════════════════════════════════════════
--                  ⚙  CONFIGURAÇÕES
-- ════════════════════════════════════════════════════
local CONFIG = {
    HubName         = "Speed Hub X",
    SubTitle        = "Welcome to The,",

    -- Keys válidas
    ValidKeys = {
        "SHX-FREE-2025",
        "SHX-VIP-0001",
    },

    -- Ativa modo sem key nos fins de semana (sáb/dom)
    KeylessWeekend  = true,

    -- Salva a key validada localmente (não pede de novo)
    SaveKey         = true,

    -- Link do Discord (copia para clipboard ao clicar)
    DiscordLink     = "https://discord.gg/XXXXXXX",

    -- Provedores de key (nome + link)
    Providers = {
        { Name = "LootLabs",    Link = "https://loot-link.com/s?XXXXX"    },
        { Name = "Linkvertise", Link = "https://linkvertise.com/XXXXX"    },
        { Name = "Admint.club", Link = "https://admint.club/XXXXX"        },
    },

    -- Callback chamado quando a key é aceita (ou em modo keyless)
    Callback = function(key)
        print("[SpeedHubX] Liberado | Key:", key)
        -- Coloque seu script principal aqui:
        -- loadstring(game:HttpGet("https://raw.githubusercontent.com/.../main.lua"))()
    end,
}
-- ════════════════════════════════════════════════════
--              FIM DAS CONFIGURAÇÕES
-- ════════════════════════════════════════════════════

-- ─── Ícones (rbxassetid) ─────────────────────────────────────────────────────
local Icons = {
    ["arrow-big-right"]        = "rbxassetid://82960676755590",
    ["arrow-big-up-dash"]      = "rbxassetid://99260194327483",
    ["arrow-big-up"]           = "rbxassetid://93136954756149",
    ["arrow-down-0-1"]         = "rbxassetid://120961896217875",
    ["arrow-down-1-0"]         = "rbxassetid://93474255891850",
    ["arrow-down-a-z"]         = "rbxassetid://99554596207900",
    ["arrow-down-from-line"]   = "rbxassetid://132045845807798",
    ["arrow-down-left"]        = "rbxassetid://102899325237364",
    ["arrow-down-narrow-wide"] = "rbxassetid://129105261655061",
    ["arrow-down-right"]       = "rbxassetid://123109928624974",
    ["arrow-down-to-dot"]      = "rbxassetid://101675355931221",
    ["arrow-down-to-line"]     = "rbxassetid://87050478931254",
    ["arrow-down-up"]          = "rbxassetid://85780258549577",
    ["arrow-down-wide-narrow"] = "rbxassetid://88461733425991",
    ["arrow-down-z-a"]         = "rbxassetid://76115279362232",
    ["arrow-down"]             = "rbxassetid://98764963621439",
    ["arrow-left-from-line"]   = "rbxassetid://87857914437603",
    ["arrow-left-right"]       = "rbxassetid://131324733048447",
    ["arrow-left-to-line"]     = "rbxassetid://118645136026970",
    ["arrow-left"]             = "rbxassetid://102531941843733",
    ["arrow-right-from-line"]  = "rbxassetid://74073639809355",
    ["arrow-right-left"]       = "rbxassetid://77015754304300",
    ["arrow-right-to-line"]    = "rbxassetid://78632510329852",
    ["arrow-right"]            = "rbxassetid://113692007244654",
    ["arrow-up-0-1"]           = "rbxassetid://105257823943016",
    ["arrow-up-1-0"]           = "rbxassetid://134175521693798",
}

-- ─── Serviços ────────────────────────────────────────────────────────────────
local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Helpers ─────────────────────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function Make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function MakeIcon(name, size, parent, lo)
    local img = Make("ImageLabel", {
        Size                   = size or UDim2.fromOffset(13, 13),
        BackgroundTransparency = 1,
        Image                  = Icons[name] or "",
        ImageColor3            = Color3.fromRGB(240, 228, 228),
        ScaleType              = Enum.ScaleType.Fit,
        LayoutOrder            = lo or 1,
    }, parent)
    return img
end

local function IsWeekend()
    local d = tonumber(os.date("%w"))
    return d == 0 or d == 6
end

local function Gap(n, lo, parent)
    Make("Frame", { Size=UDim2.new(1,0,0,n), BackgroundTransparency=1, LayoutOrder=lo }, parent)
end

-- ─── Cores ───────────────────────────────────────────────────────────────────
local C = {
    Red     = Color3.fromRGB(228, 46, 40),
    RedDim  = Color3.fromRGB(35, 10, 10),
    BG      = Color3.fromRGB(12, 10, 10),
    Surface = Color3.fromRGB(17, 13, 13),
    Alt     = Color3.fromRGB(24, 18, 18),
    Border  = Color3.fromRGB(58, 20, 18),
    Text    = Color3.fromRGB(240, 228, 228),
    Muted   = Color3.fromRGB(130, 108, 108),
    Link    = Color3.fromRGB(88, 150, 245),
    White   = Color3.fromRGB(255, 255, 255),
}

-- ─── Early exits ─────────────────────────────────────────────────────────────
if CONFIG.KeylessWeekend and IsWeekend() then
    task.spawn(CONFIG.Callback, "KEYLESS_WEEKEND")
    return
end

if CONFIG.SaveKey then
    local saved = LocalPlayer:GetAttribute("SHX_Key")
    if saved and saved ~= "" then
        for _, v in ipairs(CONFIG.ValidKeys) do
            if saved == v then
                task.spawn(CONFIG.Callback, saved)
                return
            end
        end
    end
end

-- ─── Build UI ────────────────────────────────────────────────────────────────
local toastThread
local GUI = {}

local Screen = Make("ScreenGui", {
    Name           = "SHX_KeySystem",
    ResetOnSpawn   = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
}, PlayerGui)

local Overlay = Make("Frame", {
    Size                   = UDim2.fromScale(1, 1),
    BackgroundColor3       = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 1,
    ZIndex                 = 1,
}, Screen)

-- Modal: 404px de largura, 288px de altura
local Modal = Make("Frame", {
    Size             = UDim2.fromOffset(404, 288),
    AutomaticSize    = Enum.AutomaticSize.None,
    Position         = UDim2.new(0.5, 0, 0.58, 0),
    AnchorPoint      = Vector2.new(0.5, 0.5),
    BackgroundColor3 = C.Surface,
    BorderSizePixel  = 0,
    ZIndex           = 2,
}, Screen)
Make("UICorner",  { CornerRadius = UDim.new(0, 16) }, Modal)
Make("UIStroke",  { Color = C.Border, Thickness = 1.2 }, Modal)
Make("UIPadding", {
    PaddingTop    = UDim.new(0, 16),
    PaddingBottom = UDim.new(0, 16),
    PaddingLeft   = UDim.new(0, 24),
    PaddingRight  = UDim.new(0, 24),
}, Modal)
Make("UIListLayout", {
    FillDirection       = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    SortOrder           = Enum.SortOrder.LayoutOrder,
    Padding             = UDim.new(0, 0),
}, Modal)

-- ── Fechar (absoluto, canto superior direito) ────────────────────────────────
local CloseBtn = Make("TextButton", {
    Size             = UDim2.fromOffset(22, 22),
    Position         = UDim2.new(1, -20, 0, 8),
    AnchorPoint      = Vector2.new(0, 0),
    BackgroundColor3 = C.RedDim,
    Text             = "",
    BorderSizePixel  = 0,
    ZIndex           = 6,
}, Modal)
Make("UICorner", { CornerRadius = UDim.new(0, 6) }, CloseBtn)
Make("UIStroke", { Color = C.Border, Thickness = 1 }, CloseBtn)
local ci = MakeIcon("arrow-right-left", UDim2.fromOffset(11, 11), CloseBtn)
ci.Position = UDim2.fromScale(0.5,0.5); ci.AnchorPoint = Vector2.new(0.5,0.5); ci.ImageColor3 = C.Red

CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, { BackgroundColor3 = Color3.fromRGB(65,14,12) }, 0.12) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, { BackgroundColor3 = C.RedDim }, 0.12) end)
CloseBtn.Activated:Connect(function()
    Tween(Modal, { Position = UDim2.new(0.5,0,0.62,0), BackgroundTransparency=1 }, 0.25)
    Tween(Overlay, { BackgroundTransparency=1 }, 0.25)
    task.delay(0.28, function() Screen:Destroy() end)
end)

-- ── Header ───────────────────────────────────────────────────────────────────
local HRow = Make("Frame", { Size=UDim2.new(1,0,0,28), BackgroundTransparency=1, LayoutOrder=1 }, Modal)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,7) }, HRow)

local IBox = Make("Frame", { Size=UDim2.fromOffset(24,24), BackgroundColor3=C.RedDim, BorderSizePixel=0, LayoutOrder=1 }, HRow)
Make("UICorner", { CornerRadius=UDim.new(0,7) }, IBox)
Make("UIStroke", { Color=C.Border, Thickness=1 }, IBox)
local hi = MakeIcon("arrow-big-right", UDim2.fromOffset(13,13), IBox)
hi.Position=UDim2.fromScale(0.5,0.5); hi.AnchorPoint=Vector2.new(0.5,0.5); hi.ImageColor3=C.Red

Make("TextLabel", {
    Size=UDim2.fromOffset(110,24), BackgroundTransparency=1,
    Text="KEY SYSTEM", TextColor3=C.Red,
    Font=Enum.Font.GothamBold, TextSize=10,
    TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=2,
}, HRow)

Gap(8, 2, Modal)

-- ── Títulos ───────────────────────────────────────────────────────────────────
Make("TextLabel", {
    Size=UDim2.new(1,0,0,14), BackgroundTransparency=1,
    Text=CONFIG.SubTitle, TextColor3=C.Muted,
    Font=Enum.Font.GothamSemibold, TextSize=11,
    TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=3,
}, Modal)

Make("TextLabel", {
    Size=UDim2.new(1,0,0,28), BackgroundTransparency=1,
    Text=CONFIG.HubName, TextColor3=C.Red,
    Font=Enum.Font.GothamBold, TextSize=24,
    TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=4,
}, Modal)

Gap(10, 5, Modal)

-- ── Input row ─────────────────────────────────────────────────────────────────
local IRow = Make("Frame", { Size=UDim2.new(1,0,0,36), BackgroundTransparency=1, LayoutOrder=6 }, Modal)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,6) }, IRow)

local PasteBtn = Make("TextButton", { Size=UDim2.fromOffset(66,36), BackgroundColor3=C.RedDim, Text="", BorderSizePixel=0, LayoutOrder=1 }, IRow)
Make("UICorner", { CornerRadius=UDim.new(0,10) }, PasteBtn)
Make("UIStroke", { Color=C.Border, Thickness=1.2 }, PasteBtn)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,5) }, PasteBtn)
MakeIcon("arrow-down-to-line", UDim2.fromOffset(12,12), PasteBtn, 1).ImageColor3 = C.Text
Make("TextLabel", { Size=UDim2.fromOffset(36,36), BackgroundTransparency=1, Text="PASTE", TextColor3=C.Text, Font=Enum.Font.GothamBold, TextSize=10, LayoutOrder=2 }, PasteBtn)

local KeyInput = Make("TextBox", {
    Size=UDim2.new(1,-72,1,0), BackgroundColor3=Color3.fromRGB(8,5,5),
    PlaceholderText="Enter your key here...", PlaceholderColor3=C.Muted,
    Text="", TextColor3=C.Text, Font=Enum.Font.Code, TextSize=11,
    ClearTextOnFocus=false, BorderSizePixel=0, LayoutOrder=2, ClipsDescendants=true,
}, IRow)
Make("UICorner", { CornerRadius=UDim.new(0,10) }, KeyInput)
local KStroke = Make("UIStroke", { Color=C.Border, Thickness=1.2 }, KeyInput)
Make("UIPadding", { PaddingLeft=UDim.new(0,10), PaddingRight=UDim.new(0,10) }, KeyInput)

KeyInput.Focused:Connect(function()   Tween(KStroke, { Color=C.Red, Thickness=1.5 }, 0.15) end)
KeyInput.FocusLost:Connect(function() Tween(KStroke, { Color=C.Border, Thickness=1.2 }, 0.15) end)

PasteBtn.MouseEnter:Connect(function() Tween(PasteBtn, { BackgroundColor3=Color3.fromRGB(55,12,10) }, 0.12) end)
PasteBtn.MouseLeave:Connect(function() Tween(PasteBtn, { BackgroundColor3=C.RedDim }, 0.12) end)
PasteBtn.Activated:Connect(function()
    local ok, clip = pcall(function() return getclipboard() end)
    if ok and clip and clip ~= "" then
        KeyInput.Text = clip
        GUI.Toast("Key colada!")
    else
        GUI.Toast("Use Ctrl+V no campo")
    end
end)

Gap(6, 7, Modal)

-- ── Submit ────────────────────────────────────────────────────────────────────
local SubBtn = Make("TextButton", { Size=UDim2.new(1,0,0,36), BackgroundColor3=C.Red, Text="", BorderSizePixel=0, LayoutOrder=8 }, Modal)
Make("UICorner", { CornerRadius=UDim.new(0,10) }, SubBtn)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,8) }, SubBtn)
Make("TextLabel", { Size=UDim2.fromOffset(72,36), BackgroundTransparency=1, Text="Submit Key", TextColor3=C.White, Font=Enum.Font.GothamBold, TextSize=13, LayoutOrder=1 }, SubBtn)
MakeIcon("arrow-right", UDim2.fromOffset(13,13), SubBtn, 2).ImageColor3 = C.White

SubBtn.MouseEnter:Connect(function() Tween(SubBtn, { BackgroundColor3=Color3.fromRGB(255,55,48) }, 0.12) end)
SubBtn.MouseLeave:Connect(function() Tween(SubBtn, { BackgroundColor3=C.Red }, 0.12) end)

Gap(10, 9, Modal)

-- ── Discord ───────────────────────────────────────────────────────────────────
local DRow = Make("Frame", { Size=UDim2.new(1,0,0,14), BackgroundTransparency=1, LayoutOrder=10 }, Modal)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,4) }, DRow)
Make("TextLabel", { Size=UDim2.fromOffset(88,14), BackgroundTransparency=1, Text="Need support?", TextColor3=C.Muted, Font=Enum.Font.Gotham, TextSize=11, LayoutOrder=1 }, DRow)
local DiscBtn = Make("TextButton", { Size=UDim2.fromOffset(98,14), BackgroundTransparency=1, Text="Join the Discord", TextColor3=C.Link, Font=Enum.Font.GothamSemibold, TextSize=11, LayoutOrder=2 }, DRow)
DiscBtn.Activated:Connect(function()
    pcall(function() setclipboard(CONFIG.DiscordLink) end)
    GUI.Toast("Discord link copiado!")
end)

Gap(10, 11, Modal)

-- ── Separador ─────────────────────────────────────────────────────────────────
local SepRow = Make("Frame", { Size=UDim2.new(1,0,0,10), BackgroundTransparency=1, LayoutOrder=12 }, Modal)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,8) }, SepRow)
local function SL(lo)
    local l = Make("Frame", { Size=UDim2.new(0.36,0,0,1), BackgroundColor3=C.Border, BorderSizePixel=0, LayoutOrder=lo }, SepRow)
    Make("UICorner", { CornerRadius=UDim.new(1,0) }, l)
end
SL(1)
Make("TextLabel", { Size=UDim2.fromOffset(66,10), BackgroundTransparency=1, Text="GET KEY VIA", TextColor3=C.Muted, Font=Enum.Font.GothamBold, TextSize=8, LayoutOrder=2 }, SepRow)
SL(3)

Gap(6, 13, Modal)

-- ── Providers ─────────────────────────────────────────────────────────────────
local PRow = Make("Frame", { Size=UDim2.new(1,0,0,32), BackgroundTransparency=1, LayoutOrder=14 }, Modal)
Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,5) }, PRow)

local pIcons = { "arrow-right-from-line", "arrow-right", "arrow-right-to-line" }

for i, p in ipairs(CONFIG.Providers) do
    local w = (1/#CONFIG.Providers)
    local pb = Make("TextButton", {
        Size=UDim2.new(w, i < #CONFIG.Providers and -4 or 0, 1, 0),
        BackgroundColor3=C.Alt, Text="", BorderSizePixel=0, LayoutOrder=i,
    }, PRow)
    Make("UICorner", { CornerRadius=UDim.new(0,8) }, pb)
    Make("UIStroke",  { Color=Color3.fromRGB(40,26,26), Thickness=1 }, pb)
    Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, HorizontalAlignment=Enum.HorizontalAlignment.Center, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,5) }, pb)

    local pi = MakeIcon(pIcons[i] or "arrow-right", UDim2.fromOffset(11,11), pb, 1)
    pi.ImageColor3 = C.Red

    Make("TextLabel", { Size=UDim2.fromOffset(72,32), BackgroundTransparency=1, Text=p.Name, TextColor3=C.Text, Font=Enum.Font.GothamSemibold, TextSize=11, LayoutOrder=2 }, pb)

    pb.MouseEnter:Connect(function() Tween(pb, { BackgroundColor3=Color3.fromRGB(30,20,20) }, 0.12) end)
    pb.MouseLeave:Connect(function() Tween(pb, { BackgroundColor3=C.Alt }, 0.12) end)
    pb.Activated:Connect(function()
        pcall(function() setclipboard(p.Link) end)
        GUI.Toast(p.Name .. " — link copiado!")
    end)
end

Gap(8, 15, Modal)

-- ── Keyless notice ────────────────────────────────────────────────────────────
if CONFIG.KeylessWeekend then
    local N = Make("Frame", {
        Size=UDim2.new(1,0,0,28), BackgroundColor3=Color3.fromRGB(20,9,9),
        BorderSizePixel=0, LayoutOrder=16,
    }, Modal)
    Make("UICorner", { CornerRadius=UDim.new(0,8) }, N)
    Make("UIStroke", { Color=Color3.fromRGB(55,16,14), Thickness=1 }, N)
    Make("UIPadding", { PaddingLeft=UDim.new(0,11), PaddingRight=UDim.new(0,11) }, N)
    Make("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, VerticalAlignment=Enum.VerticalAlignment.Center, Padding=UDim.new(0,8) }, N)

    local Dot = Make("Frame", { Size=UDim2.fromOffset(5,5), BackgroundColor3=C.Red, BorderSizePixel=0, LayoutOrder=1 }, N)
    Make("UICorner", { CornerRadius=UDim.new(1,0) }, Dot)

    Make("TextLabel", {
        Size=UDim2.new(1,-16,1,0), BackgroundTransparency=1, RichText=true,
        Text="<b>Keyless</b> will be enabled every weekend.",
        TextColor3=C.Muted, Font=Enum.Font.Gotham, TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=2,
    }, N)

    task.spawn(function()
        while N.Parent do
            Tween(Dot, { BackgroundTransparency=0.85 }, 0.85)
            task.wait(0.85)
            Tween(Dot, { BackgroundTransparency=0 }, 0.85)
            task.wait(0.85)
        end
    end)
end

-- ─── Toast ───────────────────────────────────────────────────────────────────
local Toast = Make("TextLabel", {
    Size=UDim2.fromOffset(194, 30),
    Position=UDim2.new(0.5,0,1,6),
    AnchorPoint=Vector2.new(0.5,0),
    BackgroundColor3=Color3.fromRGB(16,10,10),
    BackgroundTransparency=1,
    Text="", TextColor3=C.Red,
    Font=Enum.Font.GothamBold, TextSize=11,
    BorderSizePixel=0, ZIndex=8,
}, Modal)
Make("UICorner", { CornerRadius=UDim.new(0,8) }, Toast)
Make("UIStroke", { Color=C.Border, Thickness=1 }, Toast)

function GUI.Toast(msg)
    if toastThread then task.cancel(toastThread) end
    Toast.Text = msg
    Tween(Toast, { BackgroundTransparency=0.06, Position=UDim2.new(0.5,0,1,10) }, 0.22)
    toastThread = task.delay(2, function()
        Tween(Toast, { BackgroundTransparency=1, Position=UDim2.new(0.5,0,1,4) }, 0.22)
    end)
end

-- ─── Submit logic ────────────────────────────────────────────────────────────
SubBtn.Activated:Connect(function()
    local key = KeyInput.Text:match("^%s*(.-)%s*$")
    if key == "" then GUI.Toast("✘  Digite ou cole sua key"); return end

    local ok = false
    for _, v in ipairs(CONFIG.ValidKeys) do
        if key == v then ok = true; break end
    end

    if ok then
        if CONFIG.SaveKey then LocalPlayer:SetAttribute("SHX_Key", key) end
        GUI.Toast("✔  Key verificada!")
        task.delay(0.7, function()
            Tween(Modal,   { Position=UDim2.new(0.5,0,0.62,0), BackgroundTransparency=1 }, 0.25)
            Tween(Overlay, { BackgroundTransparency=1 }, 0.25)
            task.delay(0.28, function()
                Screen:Destroy()
                task.spawn(CONFIG.Callback, key)
            end)
        end)
    else
        GUI.Toast("✘  Key inválida")
        -- Shake
        local orig = Modal.Position
        for i = 1, 5 do
            Tween(Modal, { Position=UDim2.new(0.5, i%2==0 and 7 or -7, 0.5, 0) }, 0.04)
            task.wait(0.04)
        end
        Tween(Modal, { Position=orig }, 0.07)
    end
end)

-- ─── Animação de entrada ──────────────────────────────────────────────────────
Tween(Overlay, { BackgroundTransparency=0.5 }, 0.3)
Tween(Modal,   { Position=UDim2.new(0.5,0,0.5,0), BackgroundTransparency=0 }, 0.4,
    Enum.EasingStyle.Back, Enum.EasingDirection.Out)
