--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          PREMIUM KEY SYSTEM LIBRARY V2.0                  ║
    ║          Professional Grade UI Library                    ║
    ║          Created for High-End Hubs                        ║
    ╚═══════════════════════════════════════════════════════════╝
    
    Author: Professional Development Team
    Version: 2.0.0
    Last Updated: 2026
    
    Features:
    - Fully configurable architecture
    - Smooth animations with tweening
    - Mobile-first responsive design
    - Premium visual effects
    - Memory optimized
    - Professional code structure
]]

local KeySystemLibrary = {}
KeySystemLibrary.__index = KeySystemLibrary

-- ═══════════════════════════════════════════════════════════
--                      SERVICES & UTILITIES
-- ═══════════════════════════════════════════════════════════

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- ═══════════════════════════════════════════════════════════
--                      CONFIGURATION DEFAULTS
-- ═══════════════════════════════════════════════════════════

local DEFAULT_CONFIG = {
    -- Branding
    HubName = "Speed Hub X",
    WelcomeText = "Welcome to The,",
    IconAssetId = "rbxassetid://7733955511", -- Default icon
    
    -- Links
    DiscordLink = "https://discord.gg/yourhub",
    KeyLinks = {
        "https://example.com/getkey1",
        "https://example.com/getkey2"
    },
    
    -- UI Text
    InputPlaceholder = "Enter your key here...",
    SubmitButtonText = "Submit Key",
    CopyLinkButtonText = "Copy Link",
    SupportText = "Need support?",
    DiscordLinkText = "Join the Discord",
    FooterNotice = "Keyless will be enabled every weekend.",
    
    -- Visual Theme
    Theme = {
        PrimaryColor = Color3.fromRGB(220, 38, 38),      -- Red
        SecondaryColor = Color3.fromRGB(17, 24, 39),     -- Dark Gray
        BackgroundColor = Color3.fromRGB(10, 10, 10),    -- Near Black
        TextColor = Color3.fromRGB(255, 255, 255),       -- White
        SubtextColor = Color3.fromRGB(156, 163, 175),    -- Light Gray
        GlowColor = Color3.fromRGB(220, 38, 38),         -- Red Glow
        
        -- Transparency
        BackgroundTransparency = 0.1,
        GlowTransparency = 0.7,
    },
    
    -- Dimensions (FIXED AS REQUESTED)
    Size = {
        Width = 404,
        Height = 288
    },
    
    -- Animation Settings
    Animations = {
        TweenSpeed = 0.3,
        HoverScale = 1.05,
        ClickScale = 0.95,
        EasingStyle = Enum.EasingStyle.Quad,
        EasingDirection = Enum.EasingDirection.Out
    },
    
    -- Callbacks
    OnSubmit = nil,
    OnClose = nil,
    OnCopyLink = nil
}

-- ═══════════════════════════════════════════════════════════
--                      UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local Utils = {}

function Utils.CreateTween(instance, properties, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quad
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

function Utils.MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        local targetPosition = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        
        -- Smooth dragging with tween
        Utils.CreateTween(frame, {Position = targetPosition}, 0.05):Play()
    end
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            update(input)
        end
    end)
end

function Utils.AddHoverEffect(button, hoverScale, clickScale, config)
    hoverScale = hoverScale or 1.05
    clickScale = clickScale or 0.95
    
    local originalSize = button.Size
    local isHovering = false
    
    button.MouseEnter:Connect(function()
        isHovering = true
        Utils.CreateTween(button, {
            Size = UDim2.new(
                originalSize.X.Scale * hoverScale,
                originalSize.X.Offset,
                originalSize.Y.Scale * hoverScale,
                originalSize.Y.Offset
            )
        }, config.Animations.TweenSpeed):Play()
        
        -- Intensify glow on hover
        if button:FindFirstChild("Glow") then
            Utils.CreateTween(button.Glow, {
                ImageTransparency = 0.5
            }, config.Animations.TweenSpeed):Play()
        end
    end)
    
    button.MouseLeave:Connect(function()
        isHovering = false
        Utils.CreateTween(button, {
            Size = originalSize
        }, config.Animations.TweenSpeed):Play()
        
        if button:FindFirstChild("Glow") then
            Utils.CreateTween(button.Glow, {
                ImageTransparency = config.Theme.GlowTransparency
            }, config.Animations.TweenSpeed):Play()
        end
    end)
    
    button.MouseButton1Down:Connect(function()
        Utils.CreateTween(button, {
            Size = UDim2.new(
                originalSize.X.Scale * clickScale,
                originalSize.X.Offset,
                originalSize.Y.Scale * clickScale,
                originalSize.Y.Offset
            )
        }, 0.1):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        local targetScale = isHovering and hoverScale or 1
        Utils.CreateTween(button, {
            Size = UDim2.new(
                originalSize.X.Scale * targetScale,
                originalSize.X.Offset,
                originalSize.Y.Scale * targetScale,
                originalSize.Y.Offset
            )
        }, 0.1):Play()
    end)
end

function Utils.CreateGlow(parent, color, transparency)
    local glow = Instance.new("ImageLabel")
    glow.Name = "Glow"
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://5028857084"
    glow.ImageColor3 = color
    glow.ImageTransparency = transparency
    glow.Size = UDim2.new(1, 40, 1, 40)
    glow.Position = UDim2.new(0, -20, 0, -20)
    glow.ZIndex = parent.ZIndex - 1
    glow.Parent = parent
    return glow
end

function Utils.CopyToClipboard(text)
    if setclipboard then
        setclipboard(text)
        return true
    end
    return false
end

-- ═══════════════════════════════════════════════════════════
--                      UI BUILDER
-- ═══════════════════════════════════════════════════════════

local UIBuilder = {}

function UIBuilder.CreateScreenGui(name)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.IgnoreGuiInset = true
    return screenGui
end

function UIBuilder.CreateMainFrame(config)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.Size = UDim2.new(0, config.Size.Width, 0, config.Size.Height)
    mainFrame.BackgroundColor3 = config.Theme.BackgroundColor
    mainFrame.BackgroundTransparency = config.Theme.BackgroundTransparency
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = false
    
    -- Rounded corners
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = mainFrame
    
    -- Background glow
    local bgGlow = Instance.new("ImageLabel")
    bgGlow.Name = "BackgroundGlow"
    bgGlow.BackgroundTransparency = 1
    bgGlow.Image = "rbxassetid://5028857084"
    bgGlow.ImageColor3 = config.Theme.GlowColor
    bgGlow.ImageTransparency = 0.8
    bgGlow.Size = UDim2.new(1, 60, 1, 60)
    bgGlow.Position = UDim2.new(0, -30, 0, -30)
    bgGlow.ZIndex = 0
    bgGlow.Parent = mainFrame
    
    -- Gradient overlay
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 15)),
        ColorSequenceKeypoint.new(0.5, config.Theme.SecondaryColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    })
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    return mainFrame
end

function UIBuilder.CreateHeader(parent, config)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 80)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1
    header.Parent = parent
    
    -- Icon
    local icon = Instance.new("ImageLabel")
    icon.Name = "Icon"
    icon.Size = UDim2.new(0, 32, 0, 32)
    icon.Position = UDim2.new(0, 20, 0, 15)
    icon.BackgroundTransparency = 1
    icon.Image = config.IconAssetId
    icon.ImageColor3 = config.Theme.PrimaryColor
    icon.Parent = header
    
    local iconCorner = Instance.new("UICorner")
    iconCorner.CornerRadius = UDim.new(0, 6)
    iconCorner.Parent = icon
    
    -- Welcome Text
    local welcomeText = Instance.new("TextLabel")
    welcomeText.Name = "WelcomeText"
    welcomeText.Size = UDim2.new(1, -70, 0, 20)
    welcomeText.Position = UDim2.new(0, 60, 0, 15)
    welcomeText.BackgroundTransparency = 1
    welcomeText.Font = Enum.Font.GothamMedium
    welcomeText.Text = config.WelcomeText
    welcomeText.TextColor3 = config.Theme.TextColor
    welcomeText.TextSize = 16
    welcomeText.TextXAlignment = Enum.TextXAlignment.Left
    welcomeText.Parent = header
    
    -- Hub Name
    local hubName = Instance.new("TextLabel")
    hubName.Name = "HubName"
    hubName.Size = UDim2.new(1, -70, 0, 35)
    hubName.Position = UDim2.new(0, 60, 0, 35)
    hubName.BackgroundTransparency = 1
    hubName.Font = Enum.Font.GothamBold
    hubName.Text = config.HubName
    hubName.TextColor3 = config.Theme.PrimaryColor
    hubName.TextSize = 28
    hubName.TextXAlignment = Enum.TextXAlignment.Left
    hubName.Parent = header
    
    return header
end

function UIBuilder.CreateKeyInput(parent, config)
    local container = Instance.new("Frame")
    container.Name = "KeyInputContainer"
    container.Size = UDim2.new(1, -40, 0, 50)
    container.Position = UDim2.new(0, 20, 0, 90)
    container.BackgroundColor3 = config.Theme.SecondaryColor
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 8)
    containerCorner.Parent = container
    
    -- Input glow (hidden by default)
    local inputGlow = Utils.CreateGlow(container, config.Theme.GlowColor, 1)
    inputGlow.Name = "InputGlow"
    
    -- Paste Button
    local pasteButton = Instance.new("TextButton")
    pasteButton.Name = "PasteButton"
    pasteButton.Size = UDim2.new(0, 60, 1, -8)
    pasteButton.Position = UDim2.new(0, 4, 0, 4)
    pasteButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    pasteButton.BorderSizePixel = 0
    pasteButton.Font = Enum.Font.GothamMedium
    pasteButton.Text = "Paste"
    pasteButton.TextColor3 = config.Theme.TextColor
    pasteButton.TextSize = 13
    pasteButton.Parent = container
    
    local pasteCorner = Instance.new("UICorner")
    pasteCorner.CornerRadius = UDim.new(0, 6)
    pasteCorner.Parent = pasteButton
    
    -- Text Input
    local textBox = Instance.new("TextBox")
    textBox.Name = "KeyInput"
    textBox.Size = UDim2.new(1, -80, 1, -8)
    textBox.Position = UDim2.new(0, 72, 0, 4)
    textBox.BackgroundTransparency = 1
    textBox.Font = Enum.Font.Gotham
    textBox.PlaceholderText = config.InputPlaceholder
    textBox.PlaceholderColor3 = config.Theme.SubtextColor
    textBox.Text = ""
    textBox.TextColor3 = config.Theme.TextColor
    textBox.TextSize = 14
    textBox.TextXAlignment = Enum.TextXAlignment.Left
    textBox.ClearTextOnFocus = false
    textBox.Parent = container
    
    -- Focus animations
    textBox.Focused:Connect(function()
        Utils.CreateTween(inputGlow, {ImageTransparency = 0.6}, 0.2):Play()
        Utils.CreateTween(container, {
            BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        }, 0.2):Play()
    end)
    
    textBox.FocusLost:Connect(function()
        Utils.CreateTween(inputGlow, {ImageTransparency = 1}, 0.2):Play()
        Utils.CreateTween(container, {
            BackgroundColor3 = config.Theme.SecondaryColor
        }, 0.2):Play()
    end)
    
    return container, textBox, pasteButton
end

function UIBuilder.CreateSubmitButton(parent, config)
    local button = Instance.new("TextButton")
    button.Name = "SubmitButton"
    button.Size = UDim2.new(1, -40, 0, 48)
    button.Position = UDim2.new(0, 20, 0, 150)
    button.BackgroundColor3 = config.Theme.PrimaryColor
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Text = config.SubmitButtonText .. " →"
    button.TextColor3 = config.Theme.TextColor
    button.TextSize = 16
    button.AutoButtonColor = false
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    -- Button glow
    local buttonGlow = Utils.CreateGlow(button, config.Theme.GlowColor, config.Theme.GlowTransparency)
    
    return button
end

function UIBuilder.CreateCopyLinkButton(parent, config)
    local button = Instance.new("TextButton")
    button.Name = "CopyLinkButton"
    button.Size = UDim2.new(1, -40, 0, 38)
    button.Position = UDim2.new(0, 20, 0, 207)
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamMedium
    button.Text = "📋 " .. config.CopyLinkButtonText
    button.TextColor3 = config.Theme.TextColor
    button.TextSize = 14
    button.AutoButtonColor = false
    button.Parent = parent
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button
    
    return button
end

function UIBuilder.CreateFooter(parent, config)
    local footer = Instance.new("Frame")
    footer.Name = "Footer"
    footer.Size = UDim2.new(1, 0, 0, 30)
    footer.Position = UDim2.new(0, 0, 1, -30)
    footer.BackgroundTransparency = 1
    footer.Parent = parent
    
    -- Support text
    local supportText = Instance.new("TextLabel")
    supportText.Name = "SupportText"
    supportText.Size = UDim2.new(0.5, 0, 1, 0)
    supportText.Position = UDim2.new(0, 20, 0, 0)
    supportText.BackgroundTransparency = 1
    supportText.Font = Enum.Font.Gotham
    supportText.Text = config.SupportText
    supportText.TextColor3 = config.Theme.SubtextColor
    supportText.TextSize = 11
    supportText.TextXAlignment = Enum.TextXAlignment.Left
    supportText.Parent = footer
    
    -- Discord link
    local discordLink = Instance.new("TextButton")
    discordLink.Name = "DiscordLink"
    discordLink.Size = UDim2.new(0, 100, 1, 0)
    discordLink.Position = UDim2.new(0, 100, 0, 0)
    discordLink.BackgroundTransparency = 1
    discordLink.Font = Enum.Font.GothamMedium
    discordLink.Text = config.DiscordLinkText
    discordLink.TextColor3 = config.Theme.PrimaryColor
    discordLink.TextSize = 11
    discordLink.TextXAlignment = Enum.TextXAlignment.Left
    discordLink.AutoButtonColor = false
    discordLink.Parent = footer
    
    -- Footer notice
    local notice = Instance.new("TextLabel")
    notice.Name = "Notice"
    notice.Size = UDim2.new(1, -40, 0, 12)
    notice.Position = UDim2.new(0, 20, 0, -15)
    notice.BackgroundTransparency = 1
    notice.Font = Enum.Font.Gotham
    notice.Text = config.FooterNotice
    notice.TextColor3 = Color3.fromRGB(185, 28, 28)
    notice.TextSize = 10
    notice.TextXAlignment = Enum.TextXAlignment.Center
    notice.Parent = footer
    
    return footer, discordLink
end

-- ═══════════════════════════════════════════════════════════
--                      MAIN LIBRARY CLASS
-- ═══════════════════════════════════════════════════════════

function KeySystemLibrary.new(userConfig)
    local self = setmetatable({}, KeySystemLibrary)
    
    -- Merge user config with defaults
    self.config = {}
    for key, value in pairs(DEFAULT_CONFIG) do
        if type(value) == "table" and userConfig and userConfig[key] then
            self.config[key] = {}
            for subKey, subValue in pairs(value) do
                self.config[key][subKey] = (userConfig[key] and userConfig[key][subKey]) or subValue
            end
        else
            self.config[key] = (userConfig and userConfig[key]) or value
        end
    end
    
    -- Initialize
    self.gui = nil
    self.mainFrame = nil
    self.components = {}
    self.isVisible = false
    
    self:_build()
    
    return self
end

function KeySystemLibrary:_build()
    -- Create ScreenGui
    self.gui = UIBuilder.CreateScreenGui("KeySystemPremium")
    self.gui.Enabled = false
    
    -- Create main frame
    self.mainFrame = UIBuilder.CreateMainFrame(self.config)
    self.mainFrame.Parent = self.gui
    
    -- Build UI components
    local header = UIBuilder.CreateHeader(self.mainFrame, self.config)
    
    local keyInputContainer, keyInput, pasteButton = UIBuilder.CreateKeyInput(self.mainFrame, self.config)
    self.components.keyInput = keyInput
    self.components.pasteButton = pasteButton
    
    local submitButton = UIBuilder.CreateSubmitButton(self.mainFrame, self.config)
    self.components.submitButton = submitButton
    
    local copyLinkButton = UIBuilder.CreateCopyLinkButton(self.mainFrame, self.config)
    self.components.copyLinkButton = copyLinkButton
    
    local footer, discordLink = UIBuilder.CreateFooter(self.mainFrame, self.config)
    self.components.discordLink = discordLink
    
    -- Setup interactions
    self:_setupInteractions()
    
    -- Make draggable
    Utils.MakeDraggable(self.mainFrame, header)
    
    -- Add hover effects
    Utils.AddHoverEffect(submitButton, 1.03, 0.97, self.config)
    Utils.AddHoverEffect(copyLinkButton, 1.02, 0.98, self.config)
    Utils.AddHoverEffect(pasteButton, 1.05, 0.95, self.config)
    
    -- Parent to game
    self.gui.Parent = game:GetService("CoreGui")
end

function KeySystemLibrary:_setupInteractions()
    -- Paste button
    self.components.pasteButton.MouseButton1Click:Connect(function()
        local clipboard = ""
        if getclipboard then
            clipboard = getclipboard()
        end
        self.components.keyInput.Text = clipboard
        
        -- Visual feedback
        local originalText = self.components.pasteButton.Text
        self.components.pasteButton.Text = "✓"
        wait(0.5)
        self.components.pasteButton.Text = originalText
    end)
    
    -- Submit button
    self.components.submitButton.MouseButton1Click:Connect(function()
        local key = self.components.keyInput.Text
        if self.config.OnSubmit then
            self.config.OnSubmit(key)
        end
    end)
    
    -- Copy link button
    self.components.copyLinkButton.MouseButton1Click:Connect(function()
        local allLinks = table.concat(self.config.KeyLinks, "\n")
        
        if Utils.CopyToClipboard(allLinks) then
            -- Visual feedback
            local originalText = self.components.copyLinkButton.Text
            self.components.copyLinkButton.Text = "✓ Copied!"
            Utils.CreateTween(self.components.copyLinkButton, {
                BackgroundColor3 = Color3.fromRGB(34, 197, 94)
            }, 0.2):Play()
            
            wait(1.5)
            
            self.components.copyLinkButton.Text = originalText
            Utils.CreateTween(self.components.copyLinkButton, {
                BackgroundColor3 = Color3.fromRGB(25, 25, 30)
            }, 0.2):Play()
        end
        
        if self.config.OnCopyLink then
            self.config.OnCopyLink(allLinks)
        end
    end)
    
    -- Discord link
    self.components.discordLink.MouseEnter:Connect(function()
        Utils.CreateTween(self.components.discordLink, {
            TextColor3 = Color3.fromRGB(239, 68, 68)
        }, 0.2):Play()
    end)
    
    self.components.discordLink.MouseLeave:Connect(function()
        Utils.CreateTween(self.components.discordLink, {
            TextColor3 = self.config.Theme.PrimaryColor
        }, 0.2):Play()
    end)
    
    self.components.discordLink.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(self.config.DiscordLink)
        end
    end)
end

function KeySystemLibrary:Show()
    if self.isVisible then return end
    
    self.gui.Enabled = true
    self.isVisible = true
    
    -- Entrance animation
    self.mainFrame.Size = UDim2.new(0, self.config.Size.Width * 0.95, 0, self.config.Size.Height * 0.95)
    self.mainFrame.BackgroundTransparency = 1
    
    local entranceTween = Utils.CreateTween(self.mainFrame, {
        Size = UDim2.new(0, self.config.Size.Width, 0, self.config.Size.Height),
        BackgroundTransparency = self.config.Theme.BackgroundTransparency
    }, 0.4, Enum.EasingStyle.Back)
    
    entranceTween:Play()
    
    -- Fade in components
    for _, child in pairs(self.mainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child.Name ~= "BackgroundGlow" then
            child.Visible = false
            task.delay(0.2, function()
                child.Visible = true
            end)
        end
    end
end

function KeySystemLibrary:Hide()
    if not self.isVisible then return end
    
    local exitTween = Utils.CreateTween(self.mainFrame, {
        Size = UDim2.new(0, self.config.Size.Width * 0.95, 0, self.config.Size.Height * 0.95),
        BackgroundTransparency = 1
    }, 0.3)
    
    exitTween:Play()
    exitTween.Completed:Wait()
    
    self.gui.Enabled = false
    self.isVisible = false
    
    if self.config.OnClose then
        self.config.OnClose()
    end
end

function KeySystemLibrary:Destroy()
    if self.gui then
        self.gui:Destroy()
    end
    self.gui = nil
    self.mainFrame = nil
    self.components = {}
    self.isVisible = false
end

function KeySystemLibrary:GetKeyValue()
    return self.components.keyInput.Text
end

function KeySystemLibrary:SetKeyValue(value)
    self.components.keyInput.Text = value
end

function KeySystemLibrary:IsVisible()
    return self.isVisible
end

-- ═══════════════════════════════════════════════════════════
--                      EXPORT
-- ═══════════════════════════════════════════════════════════

return KeySystemLibrary
