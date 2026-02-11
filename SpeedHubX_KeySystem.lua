--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          EXEMPLO DE USO - KEY SYSTEM LIBRARY              ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- Carregar a biblioteca
local KeySystemLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/hid1ey/credential-request/refs/heads/main/SpeedHubX_KeySystem.lua.txt"))()

-- ═══════════════════════════════════════════════════════════
--                  EXEMPLO 1: CONFIGURAÇÃO BÁSICA
-- ═══════════════════════════════════════════════════════════

local KeySystem = KeySystemLibrary.new({
    -- Branding
    HubName = "Speed Hub X",
    WelcomeText = "Welcome to The,",
    
    -- Links
    DiscordLink = "https://discord.gg/speedhubx",
    KeyLinks = {
        "https://linkvertise.com/speedhubx1",
        "https://lootlabs.com/speedhubx2"
    },
    
    -- Callback quando o usuário submete a key
    OnSubmit = function(key)
        print("Key submitted:", key)
        
        -- Verificar a key aqui
        if key == "VALID_KEY_HERE" then
            KeySystem:Hide()
            print("✓ Key válida! Carregando hub...")
            -- Carregar seu script principal aqui
        else
            print("✗ Key inválida!")
            -- Pode adicionar shake animation ou feedback visual
        end
    end,
    
    OnCopyLink = function(links)
        print("Links copiados:", links)
    end,
    
    OnClose = function()
        print("Key System fechado")
    end
})
 Theme = {
        PrimaryColor = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(59, 130, 246),
    }
    
-- Mostrar o Key System
KeySystem:Show()

-- ═══════════════════════════════════════════════════════════
--                  EXEMPLO 2: CONFIGURAÇÃO AVANÇADA
-- ═══════════════════════════════════════════════════════════

--[[
local KeySystem = KeySystemLibrary.new({
    -- Branding personalizado
    HubName = "Premium Executor",
    WelcomeText = "Access",
    IconAssetId = "rbxassetid://SEU_ICONE_AQUI",
    
    -- Links múltiplos
    DiscordLink = "https://discord.gg/yourserver",
    KeyLinks = {
        "https://link1.com/getkey",
        "https://link2.com/getkey",
        "https://link3.com/getkey"
    },
    
    -- Textos personalizados
    InputPlaceholder = "Cole sua key aqui...",
    SubmitButtonText = "Verificar Key",
    CopyLinkButtonText = "Copiar Links",
    SupportText = "Precisa de ajuda?",
    DiscordLinkText = "Entre no Discord",
    FooterNotice = "Keys resetam a cada 24 horas.",
    
    Theme = {
        PrimaryColor = Color3.fromRGB(139, 92, 246),     -- Roxo
        SecondaryColor = Color3.fromRGB(17, 24, 39),
        BackgroundColor = Color3.fromRGB(10, 10, 10),
        TextColor = Color3.fromRGB(255, 255, 255),
        SubtextColor = Color3.fromRGB(156, 163, 175),
        GlowColor = Color3.fromRGB(139, 92, 246),
        
        BackgroundTransparency = 0.1,
        GlowTransparency = 0.7,
    },
    
    -- Velocidade das animações
    Animations = {
        TweenSpeed = 0.25,
        HoverScale = 1.05,
        ClickScale = 0.95,
    },
    
    -- Callbacks
    OnSubmit = function(key)
        -- Sistema de verificação com loading
        print("Verificando key...")
        
        local function checkKey(key)
            -- Aqui você pode fazer uma requisição HTTP para verificar
            -- ou verificar localmente
            wait(1) -- Simular delay de verificação
            return key == "PREMIUM_2026"
        end
        
        if checkKey(key) then
            KeySystem:Hide()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Key System";
                Text = "✓ Acesso concedido!";
                Duration = 3;
            })
            -- Carregar script principal
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Key System";
                Text = "✗ Key inválida ou expirada!";
                Duration = 3;
            })
        end
    end,
    
    OnCopyLink = function(links)
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Key System";
            Text = "Links copiados para área de transferência!";
            Duration = 2;
        })
    end
})

KeySystem:Show()
]]

-- ═══════════════════════════════════════════════════════════
--                  MÉTODOS DISPONÍVEIS
-- ═══════════════════════════════════════════════════════════

--[[
    KeySystem:Show()              -- Mostrar o Key System com animação
    KeySystem:Hide()              -- Esconder o Key System
    KeySystem:Destroy()           -- Destruir completamente o Key System
    KeySystem:GetKeyValue()       -- Obter o valor atual do input
    KeySystem:SetKeyValue(text)   -- Definir o valor do input
    KeySystem:IsVisible()         -- Verificar se está visível
]]

-- ═══════════════════════════════════════════════════════════
--                  DICAS DE INTEGRAÇÃO
-- ═══════════════════════════════════════════════════════════

--[[
    1. VERIFICAÇÃO DE KEY VIA HTTP:
    
    OnSubmit = function(key)
        local success, result = pcall(function()
            return game:HttpGet("https://seu-backend.com/verify?key=" .. key)
        end)
        
        if success and result == "valid" then
            KeySystem:Hide()
            -- Carregar hub
        end
    end
    
    
    2. SISTEMA DE KEY LOCAL:
    
    local validKeys = {
        ["PREMIUM_2026"] = true,
        ["LIFETIME_KEY"] = true,
        ["TRIAL_123"] = true
    }
    
    OnSubmit = function(key)
        if validKeys[key] then
            KeySystem:Hide()
            -- Carregar hub
        end
    end
    
    
    3. INTEGRAÇÃO COM DATASTORE:
    
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    
    OnSubmit = function(key)
        -- Salvar key no servidor
        game.ReplicatedStorage.ValidateKey:InvokeServer(key)
    end
    
    
    4. KEYLESS MODE (fins de semana):
    
    local function isWeekend()
        local day = os.date("*t").wday
        return day == 1 or day == 7 -- Domingo ou Sábado
    end
    
    if isWeekend() then
        print("Modo keyless ativado!")
        -- Carregar hub diretamente
    else
        KeySystem:Show()
    end
]]

-- ═══════════════════════════════════════════════════════════
--                  PERSONALIZAÇÃO AVANÇADA
-- ═══════════════════════════════════════════════════════════

--[[
    TEMA AZUL:
    Theme = {
        PrimaryColor = Color3.fromRGB(59, 130, 246),
        GlowColor = Color3.fromRGB(59, 130, 246),
    }
    
    TEMA VERDE:
    Theme = {
        PrimaryColor = Color3.fromRGB(34, 197, 94),
        GlowColor = Color3.fromRGB(34, 197, 94),
    }
    
    TEMA ROSA:
    Theme = {
        PrimaryColor = Color3.fromRGB(236, 72, 153),
        GlowColor = Color3.fromRGB(236, 72, 153),
    }
    
    TEMA DOURADO:
    Theme = {
        PrimaryColor = Color3.fromRGB(251, 191, 36),
        GlowColor = Color3.fromRGB(251, 191, 36),
    }
]]