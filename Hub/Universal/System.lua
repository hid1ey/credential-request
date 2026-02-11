--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║         PREMIUM KEY SYSTEM - EXEMPLO DE USO               ║
    ╚═══════════════════════════════════════════════════════════╝
]]

local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/hid1ey/credential-request/refs/heads/main/KeySystemLibrary%20(1).lua"))()

-- ═══════════════════════════════════════════════════════════
-- EXEMPLO 1: CONFIGURAÇÃO BÁSICA
-- ═══════════════════════════════════════════════════════════
local BasicKeySystem = KeySystem.new({
    HubName = "Speed Hub X",
    WelcomeText = "Welcome to",
    DiscordLink = "https://discord.gg/yourdiscord",
    KeyLinks = {
        "https://loot-labs.com/your-link",
        "https://linkvertise.com/your-link"
    }
})

-- ═══════════════════════════════════════════════════════════
-- EXEMPLO 2: CONFIGURAÇÃO AVANÇADA COM CALLBACKS
-- ═══════════════════════════════════════════════════════════
local AdvancedKeySystem = KeySystem.new({
    HubName = "Premium Hub V2",
    WelcomeText = "Welcome to the",
    DiscordLink = "https://discord.gg/premiumhub",
    
    KeyLinks = {
        "https://loot-labs.com/premium-key-1",
        "https://linkvertise.com/premium-key-2",
        "https://work.ink/premium-key-3"
    },
    
    FooterText = "🎁 Free access every weekend | Premium 24/7",
    
    -- Callback quando a key for submetida
    OnSubmit = function(key)
        print("🔑 Key recebida:", key)
        
        -- Exemplo de verificação
        local validKeys = {
            "PREMIUM-KEY-123",
            "SPEEDHUB-2025",
            "VIP-ACCESS-999"
        }
        
        local isValid = false
        for _, validKey in ipairs(validKeys) do
            if key == validKey then
                isValid = true
                break
            end
        end
        
        if isValid then
            print("✅ Key válida! Carregando hub...")
            
            -- Esconder o key system
            AdvancedKeySystem:Hide()
            
            -- Aguardar animação
            task.wait(0.3)
            
            -- Destruir o key system
            AdvancedKeySystem:Destroy()
            
            -- Carregar seu script principal aqui
            loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
        else
            print("❌ Key inválida!")
            
            -- Opcional: mostrar notificação de erro
            game.StarterGui:SetCore("SendNotification", {
                Title = "Invalid Key",
                Text = "Please get a valid key from our links.",
                Duration = 3
            })
        end
    end,
    
    -- Callback quando o key system for fechado
    OnClose = function()
        print("Key System foi fechado")
    end
})

-- ═══════════════════════════════════════════════════════════
-- EXEMPLO 3: SISTEMA COM VERIFICAÇÃO DE API
-- ═══════════════════════════════════════════════════════════
local APIKeySystem = KeySystem.new({
    HubName = "API Hub",
    WelcomeText = "Welcome to",
    DiscordLink = "https://discord.gg/apihub",
    
    KeyLinks = {
        "https://your-key-link.com/get-key"
    },
    
    OnSubmit = function(key)
        print("Verificando key na API...")
        
        -- Exemplo de verificação com API
        local HttpService = game:GetService("HttpService")
        local success, response = pcall(function()
            return HttpService:JSONDecode(
                game:HttpGet("https://your-api.com/verify?key=" .. key)
            )
        end)
        
        if success and response.valid then
            print("✅ Key verificada pela API!")
            APIKeySystem:Hide()
            task.wait(0.3)
            APIKeySystem:Destroy()
            
            -- Carregar hub
            loadstring(game:HttpGet(response.scriptUrl))()
        else
            print("❌ Key inválida!")
            game.StarterGui:SetCore("SendNotification", {
                Title = "Invalid Key",
                Text = "This key is not valid or has expired.",
                Duration = 3
            })
        end
    end
})

-- ═══════════════════════════════════════════════════════════
-- EXEMPLO 4: CONTROLES MANUAIS
-- ═══════════════════════════════════════════════════════════

-- Mostrar o key system
-- AdvancedKeySystem:Show()

-- Esconder o key system (com animação)
-- AdvancedKeySystem:Hide()

-- Destruir completamente o key system
-- AdvancedKeySystem:Destroy()

-- ═══════════════════════════════════════════════════════════
-- EXEMPLO 5: SISTEMA COM SALVAMENTO LOCAL
-- ═══════════════════════════════════════════════════════════
local function checkSavedKey()
    if isfile and readfile then
        if isfile("premium_key.txt") then
            local savedKey = readfile("premium_key.txt")
            print("Key salva encontrada:", savedKey)
            return savedKey
        end
    end
    return nil
end

local function saveKey(key)
    if writefile then
        writefile("premium_key.txt", key)
        print("Key salva localmente!")
    end
end

-- Verificar se já tem key salva
local savedKey = checkSavedKey()

if savedKey then
    print("Usando key salva, pulando verificação...")
    -- Carregar diretamente
    loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
else
    -- Mostrar key system
    local SavedKeySystem = KeySystem.new({
        HubName = "Auto-Save Hub",
        WelcomeText = "Welcome to",
        DiscordLink = "https://discord.gg/autosave",
        KeyLinks = {"https://get-key.com/autosave"},
        
        OnSubmit = function(key)
            -- Verificar key
            if key == "VALID-KEY-123" then
                -- Salvar key
                saveKey(key)
                
                SavedKeySystem:Hide()
                task.wait(0.3)
                SavedKeySystem:Destroy()
                
                loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
            end
        end
    })
end

-- ═══════════════════════════════════════════════════════════
-- EXEMPLO 6: KEYLESS EM FINS DE SEMANA
-- ═══════════════════════════════════════════════════════════
local function isWeekend()
    local dayOfWeek = os.date("*t").wday
    -- 1 = Domingo, 7 = Sábado
    return dayOfWeek == 1 or dayOfWeek == 7
end

if isWeekend() then
    print("🎉 É fim de semana! Acesso livre!")
    loadstring(game:HttpGet("YOUR_MAIN_SCRIPT_URL"))()
else
    print("Necessário key para acesso durante a semana")
    
    local WeekendKeySystem = KeySystem.new({
        HubName = "Weekend Free Hub",
        WelcomeText = "Welcome to",
        DiscordLink = "https://discord.gg/weekend",
        KeyLinks = {"https://get-key.com/weekday"},
        FooterText = "🎁 Free access every weekend!",
        
        OnSubmit = function(key)
            -- Sua lógica de verificação
        end
    })
end

-- ═══════════════════════════════════════════════════════════
-- NOTAS IMPORTANTES
-- ═══════════════════════════════════════════════════════════
--[[
    ✅ RECURSOS INCLUÍDOS:
    - Design premium dark/red
    - Animações suaves (fade, scale, hover)
    - Sistema de drag otimizado para mobile
    - Botão de copiar links automaticamente
    - Campo de input com botão paste
    - Link do Discord clicável
    - Totalmente configurável
    - Performance otimizada
    - Callbacks customizáveis
    
    📱 MOBILE OPTIMIZED:
    - Touch events funcionam perfeitamente
    - Drag suave e responsivo
    - Botões com tamanho adequado
    - Sem problemas de input
    
    🎨 PERSONALIZÁVEL:
    - Todos os textos configuráveis
    - Múltiplos links suportados
    - Callbacks customizáveis
    - Footer text customizável
    
    ⚡ PERFORMANCE:
    - Zero memory leaks
    - Animações otimizadas
    - Código limpo e organizado
    - Sem loops pesados
]]
