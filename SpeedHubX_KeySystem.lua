--[[
    Speed Hub X — Key System Library
    Roblox LocalScript
    
    USO:
        local KeySystem = loadstring(game:HttpGet("..."))()
        local verified = KeySystem.new({
            HubName     = "Speed Hub X",
            KeyLink     = "https://linkvertise.com/...",
            ValidKeys   = {"SHX-FREE-2025", "SHX-VIP-XXXX"},
            DiscordLink = "https://discord.gg/...",
            Providers = {
                { Name = "LootLabs",    Icon = "rbxassetid://...", Link = "https://loot-link.com/..." },
                { Name = "Linkvertise", Icon = "rbxassetid://...", Link = "https://linkvertise.com/..." },
                { Name = "Admint.club", Icon = "rbxassetid://...", Link = "https://admint.club/..."  },
            },
            KeylessWeekend = true,
            SaveKey = true,         -- salva a key no DataStore local (atributo de player)
            Callback = function(key)
                print("Key válida:", key)
                -- Seu script continua aqui
            end
        })
--]]

local KeySystem = {}
KeySystem.__index = KeySystem

-- ─── Serviços ────────────────────────────────────────────────────────────────
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- ─── Utilitários ─────────────────────────────────────────────────────────────
local function Tween(obj, props, duration, style, direction)
    style     = style     or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local info = TweenInfo.new(duration, style, direction)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function IsWeekend()
    -- os.date no Roblox pode variar; usa tick() como fallback simples
    local day = tonumber(os.date("%w")) -- 0=Dom, 6=Sáb
    return day == 0 or day == 6
end

-- ─── Cores ───────────────────────────────────────────────────────────────────
local C = {
    Red        = Color3.fromRGB(232, 48, 42),
    RedDark    = Color3.fromRGB(150, 22, 18),
    RedDim     = Color3.fromRGB(40, 10, 10),
    BG         = Color3.fromRGB(10, 9, 9),
    Surface    = Color3.fromRGB(16, 13, 13),
    SurfaceAlt = Color3.fromRGB(22, 17, 17),
    Border     = Color3.fromRGB(60, 22, 20),
    Text       = Color3.fromRGB(240, 228, 228),
    Muted      = Color3.fromRGB(140, 120, 120),
    White      = Color3.fromRGB(255, 255, 255),
    Link       = Color3.fromRGB(91, 156, 246),
}

-- ─── Construtor principal ─────────────────────────────────────────────────────
function KeySystem.new(config)
    local self = setmetatable({}, KeySystem)
    self.Config    = config
    self.Verified  = false
    self.InputText = ""

    -- Checa keyless weekend
    if config.KeylessWeekend and IsWeekend() then
        if config.Callback then config.Callback("KEYLESS_WEEKEND") end
        return self
    end

    -- Checa key salva
    if config.SaveKey then
        local saved = LocalPlayer:GetAttribute("SHX_SavedKey")
        if saved and saved ~= "" then
            for _, v in ipairs(config.ValidKeys or {}) do
                if saved == v then
                    self.Verified = true
                    if config.Callback then config.Callback(saved) end
                    return self
                end
            end
        end
    end

    self:_BuildUI()
    return self
end

-- ─── Constrói a UI ────────────────────────────────────────────────────────────
function KeySystem:_BuildUI()
    local cfg = self.Config

    -- ScreenGui
    local ScreenGui = Make("ScreenGui", {
        Name             = "SpeedHubX_KeySystem",
        ResetOnSpawn     = false,
        ZIndexBehavior   = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset   = true,
    }, PlayerGui)

    -- Overlay escuro
    local Overlay = Make("Frame", {
        Size            = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 1,
    }, ScreenGui)

    -- Modal principal
    local Modal = Make("Frame", {
        Size             = UDim2.fromOffset(460, 0),  -- altura auto
        AutomaticSize    = Enum.AutomaticSize.Y,
        Position         = UDim2.fromScale(0.5, 0.5),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.Surface,
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, ScreenGui)
    Make("UICorner",  { CornerRadius = UDim.new(0, 18) }, Modal)
    Make("UIStroke",  { Color = C.Border, Thickness = 1.2 }, Modal)
    Make("UIPadding", {
        PaddingTop    = UDim.new(0, 30),
        PaddingBottom = UDim.new(0, 28),
        PaddingLeft   = UDim.new(0, 28),
        PaddingRight  = UDim.new(0, 28),
    }, Modal)
    Make("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 0),
    }, Modal)

    -- ── Header Row (ícone + tag + fechar) ──────────────────────────────────
    local HeaderRow = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder      = 1,
    }, Modal)
    Make("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 10),
    }, HeaderRow)

    -- Ícone
    local IconBox = Make("Frame", {
        Size             = UDim2.fromOffset(34, 34),
        BackgroundColor3 = C.RedDim,
        BorderSizePixel  = 0,
        LayoutOrder      = 1,
    }, HeaderRow)
    Make("UICorner",  { CornerRadius = UDim.new(0, 9) }, IconBox)
    Make("UIStroke",  { Color = C.Border, Thickness = 1 }, IconBox)
    Make("TextLabel", {
        Size             = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text             = "🛡",
        TextScaled       = true,
    }, IconBox)
    Make("UIPadding", {
        PaddingTop = UDim.new(0,4), PaddingBottom = UDim.new(0,4),
        PaddingLeft = UDim.new(0,4), PaddingRight = UDim.new(0,4),
    }, IconBox)

    -- Tag
    Make("TextLabel", {
        Size             = UDim2.fromOffset(100, 34),
        BackgroundTransparency = 1,
        Text             = "KEY SYSTEM",
        TextColor3       = C.Red,
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = 2,
    }, HeaderRow)

    -- Botão fechar (canto direito absoluto)
    local CloseBtn = Make("TextButton", {
        Size             = UDim2.fromOffset(28, 28),
        Position         = UDim2.new(1, -28, 0, 4),
        AnchorPoint      = Vector2.new(0, 0),
        BackgroundColor3 = C.RedDim,
        Text             = "✕",
        TextColor3       = C.Red,
        Font             = Enum.Font.GothamBold,
        TextSize         = 12,
        BorderSizePixel  = 0,
        ZIndex           = 5,
    }, Modal)  -- filho direto do Modal para posicionamento absoluto
    Make("UICorner", { CornerRadius = UDim.new(0, 8) }, CloseBtn)
    Make("UIStroke", { Color = C.Border, Thickness = 1 }, CloseBtn)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = Color3.fromRGB(80, 20, 18) }, 0.15)
    end)
    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, { BackgroundColor3 = C.RedDim }, 0.15)
    end)
    CloseBtn.Activated:Connect(function()
        self:_Hide()
    end)

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,18), BackgroundTransparency=1, LayoutOrder=2 }, Modal)

    -- ── Títulos ──────────────────────────────────────────────────────────────
    Make("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text             = "Welcome to The,",
        TextColor3       = C.Muted,
        Font             = Enum.Font.GothamSemibold,
        TextSize         = 14,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = 3,
    }, Modal)

    Make("TextLabel", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundTransparency = 1,
        Text             = cfg.HubName or "Speed Hub X",
        TextColor3       = C.Red,
        Font             = Enum.Font.GothamBold,
        TextSize         = 36,
        TextXAlignment   = Enum.TextXAlignment.Left,
        LayoutOrder      = 4,
    }, Modal)

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,20), BackgroundTransparency=1, LayoutOrder=5 }, Modal)

    -- ── Input Row ────────────────────────────────────────────────────────────
    local InputRow = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder      = 6,
    }, Modal)
    Make("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 8),
    }, InputRow)

    -- Paste button
    local PasteBtn = Make("TextButton", {
        Size             = UDim2.fromOffset(90, 50),
        BackgroundColor3 = C.RedDim,
        Text             = "PASTE",
        TextColor3       = C.Text,
        Font             = Enum.Font.GothamBold,
        TextSize         = 13,
        BorderSizePixel  = 0,
        LayoutOrder      = 1,
    }, InputRow)
    Make("UICorner", { CornerRadius = UDim.new(0, 12) }, PasteBtn)
    Make("UIStroke", { Color = C.Border, Thickness = 1.2 }, PasteBtn)

    PasteBtn.MouseEnter:Connect(function()
        Tween(PasteBtn, { BackgroundColor3 = Color3.fromRGB(70, 18, 15) }, 0.15)
    end)
    PasteBtn.MouseLeave:Connect(function()
        Tween(PasteBtn, { BackgroundColor3 = C.RedDim }, 0.15)
    end)

    -- Input
    local KeyInput = Make("TextBox", {
        Size             = UDim2.new(1, -98, 1, 0),
        BackgroundColor3 = Color3.fromRGB(8, 6, 6),
        PlaceholderText  = "Enter your key here...",
        PlaceholderColor3 = C.Muted,
        Text             = "",
        TextColor3       = C.Text,
        Font             = Enum.Font.Code,
        TextSize         = 13,
        ClearTextOnFocus = false,
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
    }, InputRow)
    Make("UICorner", { CornerRadius = UDim.new(0, 12) }, KeyInput)
    local KeyStroke = Make("UIStroke", { Color = C.Border, Thickness = 1.2 }, KeyInput)
    Make("UIPadding", {
        PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)
    }, KeyInput)

    KeyInput.Focused:Connect(function()
        Tween(KeyStroke, { Color = C.Red, Thickness = 1.5 }, 0.2)
    end)
    KeyInput.FocusLost:Connect(function()
        Tween(KeyStroke, { Color = C.Border, Thickness = 1.2 }, 0.2)
        self.InputText = KeyInput.Text
    end)

    PasteBtn.Activated:Connect(function()
        -- No executor, getclipboard() existe; no studio usa fallback
        local ok, clip = pcall(function() return getclipboard() end)
        if ok and clip and clip ~= "" then
            KeyInput.Text = clip
            self.InputText = clip
            self:_ShowToast("Key colada!")
        else
            self:_ShowToast("Use Ctrl+V no campo")
        end
    end)

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,10), BackgroundTransparency=1, LayoutOrder=7 }, Modal)

    -- ── Submit Button ─────────────────────────────────────────────────────────
    local SubmitBtn = Make("TextButton", {
        Size             = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = C.Red,
        Text             = "Submit Key  →",
        TextColor3       = C.White,
        Font             = Enum.Font.GothamBold,
        TextSize         = 15,
        BorderSizePixel  = 0,
        LayoutOrder      = 8,
    }, Modal)
    Make("UICorner", { CornerRadius = UDim.new(0, 12) }, SubmitBtn)

    SubmitBtn.MouseEnter:Connect(function()
        Tween(SubmitBtn, { BackgroundColor3 = Color3.fromRGB(255, 60, 52) }, 0.15)
    end)
    SubmitBtn.MouseLeave:Connect(function()
        Tween(SubmitBtn, { BackgroundColor3 = C.Red }, 0.15)
    end)
    SubmitBtn.Activated:Connect(function()
        self:_Submit(KeyInput.Text, ScreenGui)
    end)

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,16), BackgroundTransparency=1, LayoutOrder=9 }, Modal)

    -- ── Suporte ──────────────────────────────────────────────────────────────
    local SupportRow = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        LayoutOrder      = 10,
    }, Modal)
    Make("UIListLayout", {
        FillDirection       = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment   = Enum.VerticalAlignment.Center,
        Padding             = UDim.new(0, 4),
    }, SupportRow)

    Make("TextLabel", {
        Size             = UDim2.fromOffset(110, 18),
        BackgroundTransparency = 1,
        Text             = "Need support?",
        TextColor3       = C.Muted,
        Font             = Enum.Font.Gotham,
        TextSize         = 13,
    }, SupportRow)

    local DiscordBtn = Make("TextButton", {
        Size             = UDim2.fromOffset(110, 18),
        BackgroundTransparency = 1,
        Text             = "Join the Discord",
        TextColor3       = C.Link,
        Font             = Enum.Font.GothamSemibold,
        TextSize         = 13,
    }, SupportRow)
    DiscordBtn.Activated:Connect(function()
        if cfg.DiscordLink then
            setclipboard(cfg.DiscordLink)
            self:_ShowToast("Link copiado!")
        end
    end)

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,16), BackgroundTransparency=1, LayoutOrder=11 }, Modal)

    -- ── Separator ────────────────────────────────────────────────────────────
    local SepRow = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        LayoutOrder      = 12,
    }, Modal)
    Make("UIListLayout", {
        FillDirection     = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding           = UDim.new(0, 10),
    }, SepRow)

    local function MakeLine(lo)
        local l = Make("Frame", {
            Size             = UDim2.new(0.4, 0, 0, 1),
            BackgroundColor3 = C.Border,
            BorderSizePixel  = 0,
            LayoutOrder      = lo,
        }, SepRow)
        Make("UICorner", { CornerRadius = UDim.new(1,0) }, l)
    end
    MakeLine(1)
    Make("TextLabel", {
        Size             = UDim2.fromOffset(70, 14),
        BackgroundTransparency = 1,
        Text             = "GET KEY VIA",
        TextColor3       = C.Muted,
        Font             = Enum.Font.GothamBold,
        TextSize         = 9,
        LayoutOrder      = 2,
    }, SepRow)
    MakeLine(3)

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,10), BackgroundTransparency=1, LayoutOrder=13 }, Modal)

    -- ── Providers ────────────────────────────────────────────────────────────
    local ProvidersRow = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 42),
        BackgroundTransparency = 1,
        LayoutOrder      = 14,
    }, Modal)
    Make("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding       = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
    }, ProvidersRow)

    local providers = cfg.Providers or {
        { Name = "LootLabs",     Icon = "🎁", Link = "" },
        { Name = "Linkvertise",  Icon = "🔗", Link = "" },
        { Name = "Admint.club",  Icon = "🌿", Link = "" },
    }

    for i, p in ipairs(providers) do
        local pBtn = Make("TextButton", {
            Size             = UDim2.new(1/3, i < #providers and -6 or 0, 1, 0),
            BackgroundColor3 = C.SurfaceAlt,
            Text             = (p.Icon or "") .. "  " .. p.Name,
            TextColor3       = C.Text,
            Font             = Enum.Font.GothamSemibold,
            TextSize         = 12,
            BorderSizePixel  = 0,
            LayoutOrder      = i,
        }, ProvidersRow)
        Make("UICorner", { CornerRadius = UDim.new(0, 10) }, pBtn)
        Make("UIStroke", { Color = Color3.fromRGB(45, 35, 35), Thickness = 1 }, pBtn)

        pBtn.MouseEnter:Connect(function()
            Tween(pBtn, { BackgroundColor3 = Color3.fromRGB(35, 26, 26) }, 0.15)
        end)
        pBtn.MouseLeave:Connect(function()
            Tween(pBtn, { BackgroundColor3 = C.SurfaceAlt }, 0.15)
        end)
        pBtn.Activated:Connect(function()
            if p.Link and p.Link ~= "" then
                setclipboard(p.Link)
                self:_ShowToast(p.Name .. " — link copiado!")
            end
        end)
    end

    -- ── Espaço ──────────────────────────────────────────────────────────────
    Make("Frame", { Size = UDim2.new(1,0,0,12), BackgroundTransparency=1, LayoutOrder=15 }, Modal)

    -- ── Keyless Notice ───────────────────────────────────────────────────────
    if cfg.KeylessWeekend then
        local Notice = Make("Frame", {
            Size             = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = Color3.fromRGB(24, 10, 10),
            BorderSizePixel  = 0,
            LayoutOrder      = 16,
        }, Modal)
        Make("UICorner", { CornerRadius = UDim.new(0, 10) }, Notice)
        Make("UIStroke", { Color = Color3.fromRGB(70, 20, 18), Thickness = 1 }, Notice)
        Make("UIPadding", {
            PaddingLeft = UDim.new(0,14), PaddingRight = UDim.new(0,14)
        }, Notice)
        Make("UIListLayout", {
            FillDirection     = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding           = UDim.new(0, 10),
        }, Notice)

        -- Dot piscando
        local Dot = Make("Frame", {
            Size             = UDim2.fromOffset(7, 7),
            BackgroundColor3 = C.Red,
            BorderSizePixel  = 0,
            LayoutOrder      = 1,
        }, Notice)
        Make("UICorner", { CornerRadius = UDim.new(1, 0) }, Dot)

        Make("TextLabel", {
            Size             = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1,
            RichText         = true,
            Text             = '<b>Keyless</b> will be enabled every weekend.',
            TextColor3       = C.Muted,
            Font             = Enum.Font.Gotham,
            TextSize         = 12,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LayoutOrder      = 2,
        }, Notice)

        -- Animação do dot
        task.spawn(function()
            while Notice.Parent do
                Tween(Dot, { BackgroundTransparency = 0.1 }, 1)
                task.wait(1)
                Tween(Dot, { BackgroundTransparency = 0.85 }, 1)
                task.wait(1)
            end
        end)
    end

    -- ── Toast Label (fora do modal) ──────────────────────────────────────────
    self._Toast = Make("TextLabel", {
        Size             = UDim2.fromOffset(220, 36),
        Position         = UDim2.new(0.5, 0, 1, -20),
        AnchorPoint      = Vector2.new(0.5, 1),
        BackgroundColor3 = Color3.fromRGB(20, 15, 15),
        Text             = "",
        TextColor3       = C.Red,
        Font             = Enum.Font.GothamBold,
        TextSize         = 11,
        BorderSizePixel  = 0,
        BackgroundTransparency = 1,
        ZIndex           = 10,
    }, ScreenGui)
    Make("UICorner", { CornerRadius = UDim.new(0, 10) }, self._Toast)
    Make("UIStroke", { Color = C.Border, Thickness = 1 }, self._Toast)

    -- ── Animação de entrada ───────────────────────────────────────────────────
    Modal.Position = UDim2.new(0.5, 0, 0.6, 0)
    Modal.BackgroundTransparency = 1
    Tween(Overlay, { BackgroundTransparency = 0.45 }, 0.35)
    Tween(Modal, { Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 0 }, 0.45,
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    self._ScreenGui = ScreenGui
    self._Modal     = Modal
end

-- ─── Submit / Verificação de key ─────────────────────────────────────────────
function KeySystem:_Submit(key, gui)
    key = key:match("^%s*(.-)%s*$") -- trim
    if key == "" then
        self:_ShowToast("❌  Digite ou cole sua key")
        return
    end

    local cfg = self.Config
    local valid = false

    for _, v in ipairs(cfg.ValidKeys or {}) do
        if key == v then valid = true break end
    end

    if valid then
        if cfg.SaveKey then
            LocalPlayer:SetAttribute("SHX_SavedKey", key)
        end
        self:_ShowToast("✔  Key verificada!")
        task.wait(0.8)
        self:_Hide()
        if cfg.Callback then
            task.spawn(cfg.Callback, key)
        end
    else
        self:_ShowToast("✘  Key inválida")
        -- Shake animation no modal
        local orig = self._Modal.Position
        for i = 1, 4 do
            Tween(self._Modal, { Position = UDim2.new(0.5, i%2==0 and 8 or -8, 0.5, 0) }, 0.05)
            task.wait(0.05)
        end
        Tween(self._Modal, { Position = orig }, 0.1)
    end
end

-- ─── Toast ───────────────────────────────────────────────────────────────────
function KeySystem:_ShowToast(msg)
    if not self._Toast then return end
    self._Toast.Text = msg
    self._Toast.BackgroundTransparency = 0.1
    Tween(self._Toast, { Position = UDim2.new(0.5, 0, 1, -30) }, 0.3)
    task.delay(2.2, function()
        Tween(self._Toast, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 1, -10) }, 0.3)
    end)
end

-- ─── Fechar ───────────────────────────────────────────────────────────────────
function KeySystem:_Hide()
    if not self._Modal then return end
    Tween(self._Modal, { Position = UDim2.new(0.5, 0, 0.6, 0), BackgroundTransparency = 1 }, 0.3)
    task.delay(0.35, function()
        if self._ScreenGui then
            self._ScreenGui:Destroy()
        end
    end)
end

return KeySystem

--[[
════════════════════════════════════════════
  EXEMPLO DE USO RÁPIDO (LocalScript):
════════════════════════════════════════════

local KeySystem = require(script.KeySystem)  -- ou loadstring

KeySystem.new({
    HubName        = "Speed Hub X",
    ValidKeys      = { "SHX-FREE-2025", "SHX-PREMIUM-9999" },
    DiscordLink    = "https://discord.gg/XXXXXXX",
    KeylessWeekend = true,
    SaveKey        = true,
    Providers = {
        { Name = "LootLabs",    Icon = "🎁", Link = "https://loot-link.com/s?XXXXX" },
        { Name = "Linkvertise", Icon = "🔗", Link = "https://linkvertise.com/XXXXX" },
        { Name = "Admint.club", Icon = "🌿", Link = "https://admint.club/XXXXX"     },
    },
    Callback = function(key)
        print("[SpeedHubX] Acesso liberado com key:", key)
        -- carregue o resto do seu script aqui
        loadstring(game:HttpGet("https://raw.githubusercontent.com/.../main.lua"))()
    end
})
--]]
