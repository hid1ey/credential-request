--[[
    ╔══════════════════════════════════════════════════════════╗
    ║              VOID KEY SYSTEM UI LIBRARY v1.0             ║
    ║          Dark + Red Premium UI for Roblox Hubs           ║
    ║   Icons: github.com/Footagesus/Icons (Lucide for RBLX)   ║
    ╚══════════════════════════════════════════════════════════╝

    USAGE:
    ─────────────────────────────────────────────────────────────
    local KeySystem = loadstring(game:HttpGet("YOUR_RAW_URL"))()

    local UI = KeySystem.new({
        HubName       = "VOID HUB",
        ValidKeys     = { "VOID-ALPHA-2024", "VOID-BETA-9999" },
        Discord       = "https://discord.gg/yourinvite",
        KeyProviders  = {
            { Name = "LootLabs",    Url = "https://lootlabs.gg/youroffer" },
            { Name = "Linkvertise", Url = "https://linkvertise.com/youroffer" },
            { Name = "Admint.club", Url = "https://admint.club/youroffer" },
        },
        Notification  = "Keyless will be enabled every weekend.",
        ApiValidation = nil,       -- optional: "https://api.yoursite.com/validate?key=%s"
        SaveKey       = true,
        OnSuccess     = function()
            print("Key accepted! Loading hub...")
            -- your hub loadstring here
        end,
    })

    UI:Open()
    ─────────────────────────────────────────────────────────────
--]]

-- ═══════════════════════════════════════════════════
--  SERVICES
-- ═══════════════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")

local LocalPlayer      = Players.LocalPlayer
local PlayerGui        = LocalPlayer:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════
--  ICON LOADER  (Lucide via Footagesus repository)
-- ═══════════════════════════════════════════════════
local Icons = {}
local ICON_MODULE_URL = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua"

local function LoadIcons()
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(ICON_MODULE_URL, true))()
    end)
    if ok and type(result) == "table" then
        Icons = result
    end
end

local function GetIcon(name)
    return Icons[name] or Icons["key"] or ""
end

-- ═══════════════════════════════════════════════════
--  COLOUR PALETTE
-- ═══════════════════════════════════════════════════
local C = {
    -- Backgrounds
    BG_DEEP      = Color3.fromRGB(8,   8,   10),
    BG_MAIN      = Color3.fromRGB(12,  12,  15),
    BG_SURFACE   = Color3.fromRGB(18,  18,  22),
    BG_ELEVATED  = Color3.fromRGB(24,  24,  30),
    BG_INPUT     = Color3.fromRGB(14,  14,  18),

    -- Reds
    RED_VIVID    = Color3.fromRGB(220, 30,  50),
    RED_DEEP     = Color3.fromRGB(160, 15,  30),
    RED_DIM      = Color3.fromRGB(80,  8,   15),
    RED_GLOW     = Color3.fromRGB(255, 50,  80),
    RED_SUBTLE   = Color3.fromRGB(35,  10,  14),

    -- Text
    TEXT_PRIMARY = Color3.fromRGB(240, 240, 245),
    TEXT_MUTED   = Color3.fromRGB(140, 135, 145),
    TEXT_DIMMED  = Color3.fromRGB(80,  78,  85),

    -- Borders
    BORDER_SUBTLE   = Color3.fromRGB(35,  33,  42),
    BORDER_MEDIUM   = Color3.fromRGB(55,  52,  65),
    BORDER_RED_DIM  = Color3.fromRGB(100, 15,  25),

    -- Utility
    WHITE        = Color3.fromRGB(255, 255, 255),
    TRANSPARENT  = Color3.fromRGB(0,   0,   0),
}

-- ═══════════════════════════════════════════════════
--  TWEEN HELPERS
-- ═══════════════════════════════════════════════════
local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration    or 0.25,
        style       or Enum.EasingStyle.Quart,
        direction   or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function TweenIn(obj, props, duration)
    return Tween(obj, props, duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function Spring(obj, props, duration)
    return Tween(obj, props, duration or 0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
end

-- ═══════════════════════════════════════════════════
--  UI BUILDER  (lightweight instance factory)
-- ═══════════════════════════════════════════════════
local function New(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(radius, parent)
    return New("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function Stroke(thickness, color, transparency, parent)
    return New("UIStroke", {
        Thickness    = thickness    or 1,
        Color        = color        or C.BORDER_SUBTLE,
        Transparency = transparency or 0,
    }, parent)
end

local function Gradient(colorSeq, rotation, parent)
    return New("UIGradient", {
        Color    = colorSeq,
        Rotation = rotation or 90,
    }, parent)
end

local function Padding(all, parent)
    local ud = UDim.new(0, all)
    return New("UIPadding", {
        PaddingTop    = ud,
        PaddingBottom = ud,
        PaddingLeft   = ud,
        PaddingRight  = ud,
    }, parent)
end

local function PaddingXY(px, py, parent)
    return New("UIPadding", {
        PaddingTop    = UDim.new(0, py),
        PaddingBottom = UDim.new(0, py),
        PaddingLeft   = UDim.new(0, px),
        PaddingRight  = UDim.new(0, px),
    }, parent)
end

-- ═══════════════════════════════════════════════════
--  KEY PERSISTENCE  (uses writefile / readfile safely)
-- ═══════════════════════════════════════════════════
local KEY_FILE = "VoidKeySystem_SavedKey.txt"

local function SaveKey(key)
    pcall(function()
        writefile(KEY_FILE, key)
    end)
end

local function LoadSavedKey()
    local ok, result = pcall(function()
        return readfile(KEY_FILE)
    end)
    return ok and result or nil
end

local function ClearSavedKey()
    pcall(function()
        writefile(KEY_FILE, "")
    end)
end

-- ═══════════════════════════════════════════════════
--  CLIPBOARD HELPER
-- ═══════════════════════════════════════════════════
local function GetClipboard()
    local ok, text = pcall(function()
        return getclipboard()
    end)
    return ok and text or ""
end

-- ═══════════════════════════════════════════════════
--  HTTP KEY VALIDATION
-- ═══════════════════════════════════════════════════
local function ValidateKeyViaAPI(apiUrl, key, callback)
    local url = apiUrl:format(key)
    task.spawn(function()
        local ok, response = pcall(function()
            return game:HttpGet(url, true)
        end)
        if ok then
            local decoded
            pcall(function()
                decoded = HttpService:JSONDecode(response)
            end)
            if decoded and decoded.valid == true then
                callback(true)
            else
                callback(false)
            end
        else
            callback(false)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--                      MAIN MODULE
-- ═══════════════════════════════════════════════════════════════
local KeySystemUI = {}
KeySystemUI.__index = KeySystemUI

function KeySystemUI.new(config)
    local self = setmetatable({}, KeySystemUI)

    -- ── Config defaults ──────────────────────────────────────────
    self.Config = {
        HubName       = config.HubName       or "VOID HUB",
        ValidKeys     = config.ValidKeys      or {},
        Discord       = config.Discord        or "https://discord.gg/",
        KeyProviders  = config.KeyProviders   or {},
        Notification  = config.Notification   or "Keyless will be enabled every weekend.",
        ApiValidation = config.ApiValidation  or nil,
        SaveKey       = config.SaveKey        ~= false,
        OnSuccess     = config.OnSuccess      or function() end,
    }

    self._gui      = nil
    self._open     = false
    self._loading  = false

    return self
end

-- ── BUILD & OPEN ──────────────────────────────────────────────
function KeySystemUI:Open()
    if self._open then return end
    self._open = true

    -- Load icons async (won't block UI build)
    task.spawn(LoadIcons)

    self:_BuildUI()
    self:_Animate_Open()

    -- Auto-fill saved key
    if self.Config.SaveKey then
        local saved = LoadSavedKey()
        if saved and saved ~= "" then
            self._keyInput.Text = saved
            self:_SetNotification("Saved key loaded — press Submit!", C.RED_GLOW)
        end
    end
end

-- ── DESTROY ──────────────────────────────────────────────────
function KeySystemUI:Close()
    if self._gui then
        self._gui:Destroy()
        self._gui = nil
    end
    self._open = false
end

-- ═══════════════════════════════════════════════════
--  UI CONSTRUCTION
-- ═══════════════════════════════════════════════════
function KeySystemUI:_BuildUI()

    -- ── ScreenGui ─────────────────────────────────────────────
    local gui = New("ScreenGui", {
        Name              = "VoidKeySystemUI",
        ZIndexBehavior    = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn      = false,
        DisplayOrder      = 999,
    }, PlayerGui)
    self._gui = gui

    -- ── Backdrop (full-screen dim) ─────────────────────────────
    local backdrop = New("Frame", {
        Name            = "Backdrop",
        Size            = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.BG_DEEP,
        BackgroundTransparency = 0.3,
        ZIndex          = 1,
    }, gui)

    Gradient(
        ColorSequence.new({
            ColorSequenceKeypoint.new(0,   C.BG_DEEP),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 5, 8)),
            ColorSequenceKeypoint.new(1,   C.BG_DEEP),
        }),
        135,
        backdrop
    )

    -- ── Blur Effect ───────────────────────────────────────────
    local blur = New("BlurEffect", {
        Size   = 18,
        Parent = game:GetService("Lighting"),
    })

    gui.AncestryChanged:Connect(function(_, newParent)
        if not newParent then blur:Destroy() end
    end)

    -- ── Card ──────────────────────────────────────────────────
    local card = New("Frame", {
        Name             = "Card",
        Size             = UDim2.new(0, 420, 0, 620),
        Position         = UDim2.fromScale(0.5, 0.5),
        AnchorPoint      = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.BG_MAIN,
        BackgroundTransparency = 0.05,
        ZIndex           = 2,
    }, gui)
    self._card = card
    Corner(18, card)

    -- Card border gradient
    local cardBorder = Stroke(1.5, C.BORDER_SUBTLE, 0, card)

    -- Card inner glow (top)
    local topGlow = New("Frame", {
        Name             = "TopGlow",
        Size             = UDim2.new(1, 0, 0, 3),
        Position         = UDim2.fromScale(0, 0),
        BackgroundColor3 = C.RED_VIVID,
        BackgroundTransparency = 0,
        ZIndex           = 3,
    }, card)
    Corner(18, topGlow)

    -- ── Mobile responsive (UIAspectRatioConstraint disabled, use SizeConstraint) ──
    New("UISizeConstraint", {
        MinSize = Vector2.new(300, 500),
        MaxSize = Vector2.new(480, 700),
    }, card)

    -- ── ScrollFrame (content) ─────────────────────────────────
    local scroll = New("ScrollingFrame", {
        Name                  = "Content",
        Size                  = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness    = 0,
        CanvasSize            = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
        ZIndex                = 4,
    }, card)
    Padding(24, scroll)

    local layout = New("UIListLayout", {
        FillDirection       = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, 14),
    }, scroll)

    -- ─────────────────────────────────────────────────────────
    --  SECTION 1 — HEADER
    -- ─────────────────────────────────────────────────────────
    local header = New("Frame", {
        Name             = "Header",
        Size             = UDim2.new(1, 0, 0, 110),
        BackgroundColor3 = C.BG_SURFACE,
        BackgroundTransparency = 0.4,
        LayoutOrder      = 1,
        ZIndex           = 5,
    }, scroll)
    Corner(14, header)
    Stroke(1, C.BORDER_SUBTLE, 0, header)

    -- Icon row
    local iconRow = New("Frame", {
        Size             = UDim2.new(1, -24, 0, 28),
        Position         = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        ZIndex           = 6,
    }, header)

    -- Badge
    local badge = New("Frame", {
        Size             = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = C.RED_DIM,
        ZIndex           = 7,
    }, iconRow)
    Corner(6, badge)
    Stroke(1, C.RED_DEEP, 0, badge)

    New("ImageLabel", {
        Size             = UDim2.fromScale(0.72, 0.72),
        Position         = UDim2.fromScale(0.14, 0.14),
        BackgroundTransparency = 1,
        Image            = GetIcon("key"),
        ImageColor3      = C.RED_GLOW,
        ZIndex           = 8,
    }, badge)

    -- KEY SYSTEM label
    local sysLabel = New("TextLabel", {
        Size             = UDim2.new(0, 120, 1, 0),
        Position         = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Text             = "KEY SYSTEM",
        TextColor3       = C.TEXT_MUTED,
        TextSize         = 11,
        Font             = Enum.Font.GothamBold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, iconRow)

    -- Version dot
    New("Frame", {
        Size             = UDim2.new(0, 6, 0, 6),
        Position         = UDim2.new(1, -8, 0.5, -3),
        BackgroundColor3 = C.RED_VIVID,
        ZIndex           = 7,
    }, iconRow):AddTag and nil or Corner(3, (function()
        local dot = New("Frame", {
            Size             = UDim2.new(0, 6, 0, 6),
            Position         = UDim2.new(1, -8, 0.5, -3),
            BackgroundColor3 = C.RED_VIVID,
            ZIndex           = 7,
            Parent           = iconRow,
        })
        Corner(3, dot)
        return dot
    end)())

    -- Welcome text
    New("TextLabel", {
        Size             = UDim2.new(1, -24, 0, 28),
        Position         = UDim2.new(0, 12, 0, 46),
        BackgroundTransparency = 1,
        Text             = "Welcome to",
        TextColor3       = C.TEXT_MUTED,
        TextSize         = 13,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    }, header)

    -- Hub name (red highlight)
    New("TextLabel", {
        Size             = UDim2.new(1, -24, 0, 34),
        Position         = UDim2.new(0, 12, 0, 64),
        BackgroundTransparency = 1,
        Text             = self.Config.HubName,
        TextColor3       = C.RED_GLOW,
        TextSize         = 26,
        Font             = Enum.Font.GothamBlack,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    }, header)

    -- ─────────────────────────────────────────────────────────
    --  SECTION 2 — KEY INPUT AREA
    -- ─────────────────────────────────────────────────────────
    local inputSection = New("Frame", {
        Name             = "InputSection",
        Size             = UDim2.new(1, 0, 0, 112),
        BackgroundColor3 = C.BG_SURFACE,
        BackgroundTransparency = 0.35,
        LayoutOrder      = 2,
        ZIndex           = 5,
    }, scroll)
    Corner(14, inputSection)
    Stroke(1, C.BORDER_SUBTLE, 0, inputSection)
    Padding(14, inputSection)

    local inputLayout = New("UIListLayout", {
        FillDirection    = Enum.FillDirection.Vertical,
        SortOrder        = Enum.SortOrder.LayoutOrder,
        Padding          = UDim.new(0, 8),
    }, inputSection)

    -- Label row
    local labelRow = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        LayoutOrder      = 1,
        ZIndex           = 6,
    }, inputSection)

    New("TextLabel", {
        Size             = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Text             = "Your Key",
        TextColor3       = C.TEXT_PRIMARY,
        TextSize         = 13,
        Font             = Enum.Font.GothamSemibold,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 7,
    }, labelRow)

    -- Paste button
    local pasteBtn = New("TextButton", {
        Size             = UDim2.new(0, 70, 1, 0),
        Position         = UDim2.new(1, -70, 0, 0),
        BackgroundColor3 = C.RED_DIM,
        Text             = "Paste",
        TextColor3       = C.RED_GLOW,
        TextSize         = 11,
        Font             = Enum.Font.GothamSemibold,
        ZIndex           = 7,
    }, labelRow)
    Corner(6, pasteBtn)
    Stroke(1, C.RED_DEEP, 0.3, pasteBtn)

    -- Input wrapper (for glow border)
    local inputWrapper = New("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = C.BG_INPUT,
        LayoutOrder      = 2,
        ZIndex           = 6,
    }, inputSection)
    Corner(10, inputWrapper)
    local inputStroke = Stroke(1.5, C.BORDER_MEDIUM, 0, inputWrapper)
    self._inputStroke = inputStroke

    local keyInput = New("TextBox", {
        Size             = UDim2.new(1, -44, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text             = "",
        PlaceholderText  = "Enter your key here...",
        TextColor3       = C.TEXT_PRIMARY,
        PlaceholderColor3 = C.TEXT_DIMMED,
        TextSize         = 13,
        Font             = Enum.Font.GothamSemibold,
        ClearTextOnFocus = false,
        ZIndex           = 7,
    }, inputWrapper)
    self._keyInput = keyInput

    -- Lock icon inside input
    New("ImageLabel", {
        Size             = UDim2.new(0, 16, 0, 16),
        Position         = UDim2.new(1, -30, 0.5, -8),
        BackgroundTransparency = 1,
        Image            = GetIcon("lock"),
        ImageColor3      = C.TEXT_DIMMED,
        ZIndex           = 7,
    }, inputWrapper)

    -- Focus glow effect
    keyInput.Focused:Connect(function()
        Tween(inputStroke, { Color = C.RED_GLOW, Thickness = 2 }, 0.2)
        Tween(inputWrapper, { BackgroundColor3 = Color3.fromRGB(22, 10, 14) }, 0.2)
    end)
    keyInput.FocusLost:Connect(function()
        Tween(inputStroke, { Color = C.BORDER_MEDIUM, Thickness = 1.5 }, 0.25)
        Tween(inputWrapper, { BackgroundColor3 = C.BG_INPUT }, 0.25)
    end)

    -- Paste logic
    pasteBtn.MouseButton1Click:Connect(function()
        local text = GetClipboard()
        if text and text ~= "" then
            keyInput.Text = text
            Spring(pasteBtn, { BackgroundColor3 = C.RED_DEEP }, 0.3)
            task.delay(0.3, function()
                Tween(pasteBtn, { BackgroundColor3 = C.RED_DIM }, 0.3)
            end)
        end
    end)

    -- Hover effect on paste
    pasteBtn.MouseEnter:Connect(function()
        Tween(pasteBtn, { BackgroundColor3 = C.RED_DEEP }, 0.15)
    end)
    pasteBtn.MouseLeave:Connect(function()
        Tween(pasteBtn, { BackgroundColor3 = C.RED_DIM }, 0.15)
    end)

    -- ─────────────────────────────────────────────────────────
    --  SECTION 3 — SUBMIT BUTTON
    -- ─────────────────────────────────────────────────────────
    local submitBtn = New("TextButton", {
        Name             = "SubmitButton",
        Size             = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = C.RED_VIVID,
        Text             = "Submit Key  →",
        TextColor3       = C.WHITE,
        TextSize         = 15,
        Font             = Enum.Font.GothamBold,
        LayoutOrder      = 3,
        ZIndex           = 5,
    }, scroll)
    Corner(12, submitBtn)
    self._submitBtn = submitBtn

    -- Button gradient overlay
    local btnGrad = Gradient(
        ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(235, 45, 65)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 20, 40)),
        }),
        90,
        submitBtn
    )

    -- Shimmer layer
    local shimmer = New("Frame", {
        Size             = UDim2.new(0.4, 0, 1, 0),
        Position         = UDim2.new(-0.4, 0, 0, 0),
        BackgroundColor3 = C.WHITE,
        BackgroundTransparency = 0.88,
        ZIndex           = 6,
    }, submitBtn)
    Corner(12, shimmer)

    local function PlayShimmer()
        shimmer.Position = UDim2.new(-0.4, 0, 0, 0)
        Tween(shimmer, { Position = UDim2.new(1.4, 0, 0, 0) }, 0.6, Enum.EasingStyle.Sine)
    end

    -- Hover / click animation
    submitBtn.MouseEnter:Connect(function()
        if self._loading then return end
        Tween(submitBtn, {
            BackgroundColor3 = Color3.fromRGB(240, 55, 75),
            Size             = UDim2.new(1, 0, 0, 55),
        }, 0.15)
        PlayShimmer()
    end)
    submitBtn.MouseLeave:Connect(function()
        if self._loading then return end
        Tween(submitBtn, {
            BackgroundColor3 = C.RED_VIVID,
            Size             = UDim2.new(1, 0, 0, 52),
        }, 0.2)
    end)
    submitBtn.MouseButton1Down:Connect(function()
        if self._loading then return end
        Spring(submitBtn, {
            Size = UDim2.new(0.97, 0, 0, 49),
        }, 0.25)
    end)
    submitBtn.MouseButton1Up:Connect(function()
        if self._loading then return end
        Spring(submitBtn, {
            Size = UDim2.new(1, 0, 0, 52),
        }, 0.3)
    end)

    submitBtn.MouseButton1Click:Connect(function()
        if self._loading then return end
        self:_HandleSubmit()
    end)

    -- ─────────────────────────────────────────────────────────
    --  SECTION 4 — NOTIFICATION BANNER
    -- ─────────────────────────────────────────────────────────
    local notifFrame = New("Frame", {
        Name             = "NotifBanner",
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = C.RED_SUBTLE,
        LayoutOrder      = 4,
        ZIndex           = 5,
    }, scroll)
    Corner(10, notifFrame)
    Stroke(1, C.BORDER_RED_DIM, 0, notifFrame)
    self._notifFrame = notifFrame

    -- Icon
    New("ImageLabel", {
        Size             = UDim2.new(0, 14, 0, 14),
        Position         = UDim2.new(0, 12, 0.5, -7),
        BackgroundTransparency = 1,
        Image            = GetIcon("info"),
        ImageColor3      = C.RED_GLOW,
        ZIndex           = 6,
    }, notifFrame)

    local notifLabel = New("TextLabel", {
        Size             = UDim2.new(1, -36, 1, 0),
        Position         = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text             = self.Config.Notification,
        TextColor3       = Color3.fromRGB(255, 160, 170),
        TextSize         = 11,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        TextWrapped      = true,
        ZIndex           = 6,
    }, notifFrame)
    self._notifLabel = notifLabel

    -- ─────────────────────────────────────────────────────────
    --  SECTION 5 — KEY PROVIDERS
    -- ─────────────────────────────────────────────────────────
    if #self.Config.KeyProviders > 0 then
        local providerSection = New("Frame", {
            Name             = "Providers",
            Size             = UDim2.new(1, 0, 0, 80),
            BackgroundColor3 = C.BG_SURFACE,
            BackgroundTransparency = 0.4,
            LayoutOrder      = 5,
            ZIndex           = 5,
        }, scroll)
        Corner(14, providerSection)
        Stroke(1, C.BORDER_SUBTLE, 0, providerSection)
        Padding(12, providerSection)

        New("UIListLayout", {
            FillDirection    = Enum.FillDirection.Vertical,
            SortOrder        = Enum.SortOrder.LayoutOrder,
            Padding          = UDim.new(0, 8),
        }, providerSection)

        -- Label
        New("TextLabel", {
            Size             = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text             = "Get a Key",
            TextColor3       = C.TEXT_MUTED,
            TextSize         = 11,
            Font             = Enum.Font.GothamSemibold,
            TextXAlignment   = Enum.TextXAlignment.Left,
            LayoutOrder      = 1,
            ZIndex           = 6,
        }, providerSection)

        -- Buttons row
        local providerRow = New("Frame", {
            Size             = UDim2.new(1, 0, 0, 36),
            BackgroundTransparency = 1,
            LayoutOrder      = 2,
            ZIndex           = 6,
        }, providerSection)

        New("UIListLayout", {
            FillDirection       = Enum.FillDirection.Horizontal,
            SortOrder           = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            Padding             = UDim.new(0, 8),
        }, providerRow)

        local providerIcons = {
            LootLabs    = GetIcon("link"),
            Linkvertise = GetIcon("external-link"),
            ["Admint.club"] = GetIcon("shield"),
        }

        for idx, provider in ipairs(self.Config.KeyProviders) do
            local btn = New("TextButton", {
                Size             = UDim2.new(0, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                BackgroundColor3 = C.BG_ELEVATED,
                Text             = "",
                LayoutOrder      = idx,
                ZIndex           = 7,
            }, providerRow)
            Corner(8, btn)
            Stroke(1, C.BORDER_SUBTLE, 0, btn)
            PaddingXY(12, 0, btn)

            New("TextLabel", {
                Size             = UDim2.new(0, 0, 1, 0),
                AutomaticSize    = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text             = provider.Name,
                TextColor3       = C.TEXT_MUTED,
                TextSize         = 11,
                Font             = Enum.Font.GothamSemibold,
                ZIndex           = 8,
            }, btn)

            btn.MouseEnter:Connect(function()
                Tween(btn, { BackgroundColor3 = C.RED_DIM }, 0.15)
                Tween(btn:FindFirstChildOfClass("TextLabel"), { TextColor3 = C.RED_GLOW }, 0.15)
                Tween(btn:FindFirstChildOfClass("UIStroke"), { Color = C.RED_DEEP }, 0.15)
            end)
            btn.MouseLeave:Connect(function()
                Tween(btn, { BackgroundColor3 = C.BG_ELEVATED }, 0.15)
                Tween(btn:FindFirstChildOfClass("TextLabel"), { TextColor3 = C.TEXT_MUTED }, 0.15)
                Tween(btn:FindFirstChildOfClass("UIStroke"), { Color = C.BORDER_SUBTLE }, 0.15)
            end)
            btn.MouseButton1Down:Connect(function()
                Tween(btn, { BackgroundTransparency = 0.3 }, 0.1)
            end)
            btn.MouseButton1Click:Connect(function()
                Tween(btn, { BackgroundTransparency = 0 }, 0.15)
                if provider.Url then
                    setclipboard(provider.Url)
                    self:_SetNotification("Link copied! Open in browser: " .. provider.Name, C.RED_GLOW)
                end
            end)
        end
    end

    -- ─────────────────────────────────────────────────────────
    --  SECTION 6 — DISCORD SUPPORT
    -- ─────────────────────────────────────────────────────────
    local discordSection = New("Frame", {
        Name             = "Discord",
        Size             = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = C.BG_SURFACE,
        BackgroundTransparency = 0.4,
        LayoutOrder      = 6,
        ZIndex           = 5,
    }, scroll)
    Corner(12, discordSection)
    Stroke(1, C.BORDER_SUBTLE, 0, discordSection)

    New("TextLabel", {
        Size             = UDim2.new(0.55, -10, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text             = "Need support?",
        TextColor3       = C.TEXT_MUTED,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 6,
    }, discordSection)

    local discordBtn = New("TextButton", {
        Size             = UDim2.new(0, 115, 0, 28),
        Position         = UDim2.new(1, -129, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(88, 101, 242),
        Text             = "Join Discord  ↗",
        TextColor3       = C.WHITE,
        TextSize         = 11,
        Font             = Enum.Font.GothamSemibold,
        ZIndex           = 6,
    }, discordSection)
    Corner(8, discordBtn)

    discordBtn.MouseEnter:Connect(function()
        Tween(discordBtn, { BackgroundColor3 = Color3.fromRGB(108, 121, 255) }, 0.15)
    end)
    discordBtn.MouseLeave:Connect(function()
        Tween(discordBtn, { BackgroundColor3 = Color3.fromRGB(88, 101, 242) }, 0.15)
    end)
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard(self.Config.Discord)
        self:_SetNotification("Discord link copied to clipboard!", Color3.fromRGB(108, 121, 255))
    end)

    -- ─────────────────────────────────────────────────────────
    --  FOOTER
    -- ─────────────────────────────────────────────────────────
    New("TextLabel", {
        Name             = "Footer",
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text             = "v1.0  •  Secured with VoidKeySystem",
        TextColor3       = C.TEXT_DIMMED,
        TextSize         = 10,
        Font             = Enum.Font.Gotham,
        LayoutOrder      = 7,
        ZIndex           = 5,
    }, scroll)

    -- ── Store references ──────────────────────────────────────
    self._blur       = blur
    self._backdrop   = backdrop
    self._submitBtn  = submitBtn
    self._keyInput   = keyInput
end

-- ═══════════════════════════════════════════════════
--  OPEN ANIMATION
-- ═══════════════════════════════════════════════════
function KeySystemUI:_Animate_Open()
    self._card.BackgroundTransparency = 1
    self._card.Position = UDim2.new(0.5, 0, 0.6, 0)
    self._backdrop.BackgroundTransparency = 1
    self._blur.Size = 0

    Tween(self._backdrop, { BackgroundTransparency = 0.3 }, 0.35)
    Tween(self._blur, { Size = 18 }, 0.5)

    TweenIn(self._card, {
        BackgroundTransparency = 0.05,
        Position               = UDim2.fromScale(0.5, 0.5),
    }, 0.5)
end

-- ═══════════════════════════════════════════════════
--  CLOSE ANIMATION
-- ═══════════════════════════════════════════════════
function KeySystemUI:_Animate_Close(callback)
    Tween(self._backdrop, { BackgroundTransparency = 1 }, 0.3)
    Tween(self._blur, { Size = 0 }, 0.3)
    Tween(self._card, {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0.5, 0, 0.35, 0),
    }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

    task.delay(0.35, function()
        self:Close()
        if callback then callback() end
    end)
end

-- ═══════════════════════════════════════════════════
--  NOTIFICATION HELPER
-- ═══════════════════════════════════════════════════
function KeySystemUI:_SetNotification(msg, color)
    if not self._notifLabel then return end
    self._notifLabel.Text = msg
    if color then
        Tween(self._notifLabel, { TextColor3 = color }, 0.2)
    end
    -- flash frame border
    Tween(self._notifFrame, { BackgroundColor3 = Color3.fromRGB(40, 8, 12) }, 0.15)
    task.delay(0.2, function()
        Tween(self._notifFrame, { BackgroundColor3 = C.RED_SUBTLE }, 0.4)
    end)
end

-- ═══════════════════════════════════════════════════
--  LOADING STATE
-- ═══════════════════════════════════════════════════
function KeySystemUI:_SetLoading(active)
    self._loading = active
    local btn     = self._submitBtn
    if active then
        Tween(btn, { BackgroundColor3 = C.RED_DEEP }, 0.2)
        btn.Text = "Validating..."

        -- Pulse while loading
        self._loadingConn = RunService.Heartbeat:Connect(function()
            if not self._loading then return end
        end)

        local pulseActive = true
        self._stopPulse = function() pulseActive = false end

        task.spawn(function()
            while pulseActive and self._loading do
                Tween(btn, { BackgroundTransparency = 0.35 }, 0.45, Enum.EasingStyle.Sine)
                task.wait(0.45)
                Tween(btn, { BackgroundTransparency = 0 }, 0.45, Enum.EasingStyle.Sine)
                task.wait(0.45)
            end
        end)
    else
        if self._stopPulse then self._stopPulse() end
        btn.BackgroundTransparency = 0
        Tween(btn, { BackgroundColor3 = C.RED_VIVID }, 0.2)
        btn.Text = "Submit Key  →"
    end
end

-- ═══════════════════════════════════════════════════
--  KEY SUBMISSION HANDLER
-- ═══════════════════════════════════════════════════
function KeySystemUI:_HandleSubmit()
    local key = self._keyInput.Text
    key = key:match("^%s*(.-)%s*$") -- trim whitespace

    if key == "" then
        self:_SetNotification("⚠  Please enter a key before submitting.", C.RED_GLOW)
        Spring(self._card, { Position = UDim2.new(0.502, 0, 0.5, 0) }, 0.2)
        task.delay(0.1, function()
            Spring(self._card, { Position = UDim2.fromScale(0.5, 0.5) }, 0.4)
        end)
        return
    end

    self:_SetLoading(true)

    -- ── API validation if configured ───────────────────────────
    if self.Config.ApiValidation then
        ValidateKeyViaAPI(self.Config.ApiValidation, key, function(valid)
            self:_SetLoading(false)
            if valid then
                self:_OnKeyAccepted(key)
            else
                self:_OnKeyRejected(key)
            end
        end)
        return
    end

    -- ── Local validation ──────────────────────────────────────
    task.delay(1.2, function()  -- slight artificial delay for UX
        self:_SetLoading(false)
        local valid = false
        for _, v in ipairs(self.Config.ValidKeys) do
            if v == key then
                valid = true
                break
            end
        end
        if valid then
            self:_OnKeyAccepted(key)
        else
            self:_OnKeyRejected(key)
        end
    end)
end

-- ═══════════════════════════════════════════════════
--  ACCEPT / REJECT FLOWS
-- ═══════════════════════════════════════════════════
function KeySystemUI:_OnKeyAccepted(key)
    -- Save key
    if self.Config.SaveKey then
        SaveKey(key)
    end

    -- Success UI
    local btn = self._submitBtn
    Tween(btn, { BackgroundColor3 = Color3.fromRGB(30, 180, 80) }, 0.3)
    btn.Text = "✓  Key Accepted!"
    self:_SetNotification("✓  Key verified! Loading hub...", Color3.fromRGB(80, 220, 130))

    -- Green pulse
    task.spawn(function()
        for _ = 1, 2 do
            Tween(btn, { BackgroundTransparency = 0.3 }, 0.2)
            task.wait(0.2)
            Tween(btn, { BackgroundTransparency = 0 }, 0.2)
            task.wait(0.2)
        end
    end)

    task.delay(1.0, function()
        self:_Animate_Close(function()
            self.Config.OnSuccess()
        end)
    end)
end

function KeySystemUI:_OnKeyRejected(key)
    local btn = self._submitBtn
    Tween(btn, { BackgroundColor3 = Color3.fromRGB(180, 30, 30) }, 0.2)
    btn.Text = "✗  Invalid Key"
    self:_SetNotification("✗  Invalid key. Please get a valid key via the providers.", C.RED_GLOW)

    -- Shake card
    local origPos = UDim2.fromScale(0.5, 0.5)
    local function shake(dx)
        Tween(self._card, { Position = UDim2.new(0.5, dx, 0.5, 0) }, 0.05, Enum.EasingStyle.Linear)
    end
    task.spawn(function()
        local offsets = {6, -6, 5, -5, 3, -3, 0}
        for _, dx in ipairs(offsets) do
            shake(dx)
            task.wait(0.055)
        end
        Tween(self._card, { Position = origPos }, 0.1)
    end)

    -- Reset button after delay
    task.delay(2.0, function()
        if self._loading then return end
        Tween(btn, { BackgroundColor3 = C.RED_VIVID }, 0.3)
        btn.Text = "Submit Key  →"
    end)
end

-- ═══════════════════════════════════════════════════
--  PUBLIC: Reset saved key
-- ═══════════════════════════════════════════════════
function KeySystemUI:ResetSavedKey()
    ClearSavedKey()
    if self._keyInput then
        self._keyInput.Text = ""
    end
    self:_SetNotification("Saved key cleared.", C.TEXT_MUTED)
end

-- ═══════════════════════════════════════════════════
--  PUBLIC: Check if saved key is valid (utility)
-- ═══════════════════════════════════════════════════
function KeySystemUI:HasValidSavedKey()
    local saved = LoadSavedKey()
    if not saved or saved == "" then return false end
    for _, v in ipairs(self.Config.ValidKeys) do
        if v == saved then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════════
--  RETURN MODULE
-- ═══════════════════════════════════════════════════
return KeySystemUI
