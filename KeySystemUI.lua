--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║          UNIVERSAL SYSTEM WITH PREMIUM KEY UI             ║
    ║          Adapted to use KeySystemLibrary v2.0             ║
    ╚═══════════════════════════════════════════════════════════╝
]]

return function(config)
    if not config or not config.HubName or not config.Script then
        error("[Universal System] Setup incorreto!")
    end

    local HUB_NAME = config.HubName
    local MAIN_SCRIPT_URL = config.Script
    local CONFIG_URL = "https://raw.githubusercontent.com/hid1ey/credential-request/refs/heads/main/Hub/Config.json"

    -- ═══════════════════════════════════════════════════════════
    --                   LINKS E SENHAS
    -- ═══════════════════════════════════════════════════════════

    local INTERNAL_CONFIG = {
        Links = {
            ["https://mineurl.com/35d949"] = "Nexor-G4r9k1-y5t2v7-n8m3p6",
            ["https://mineurl.com/37e7ce"] = "Zytron-K8p4x2-q7m9c1-t5v3n6",
            ["https://mineurl.com/807aa0"] = "Vortex-L2n8r5-y4k7d3-p9x1m6",
            ["https://mineurl.com/20dbb8"] = "Aether-X9m2k7-v4p8t1-z6q3n5"
        },
        LinkExpiryTime = 43200,
        DiscordLink = "https://discord.gg/w6q6Mgh339"
    }

    -- ═══════════════════════════════════════════════════════════
    --                   SERVICES
    -- ═══════════════════════════════════════════════════════════

    local HttpService = game:GetService("HttpService")
    local Players = game:GetService("Players")
    local StarterGui = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    
    -- ═══════════════════════════════════════════════════════════
    --                   UTILITY FUNCTIONS
    -- ═══════════════════════════════════════════════════════════
    
    local function notify(title, description, duration)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = title,
                Text = description,
                Duration = duration or 3,
                Icon = "rbxassetid://10709775704"
            })
        end)
    end
    
    local function fetchConfig()
        local success, response = pcall(function()
            return game:HttpGet(CONFIG_URL, true)
        end)
        
        if not success then return nil end
        
        local decodeSuccess, configData = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        
        return decodeSuccess and configData or nil
    end

    local externalConfig = fetchConfig()
    if not externalConfig then return end
    
    -- Se o kernel não estiver habilitado, carrega o script diretamente
    if not externalConfig.KernelEnabled then
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end
    
    -- ═══════════════════════════════════════════════════════════
    --                   DATA MANAGER
    -- ═══════════════════════════════════════════════════════════
    
    local FOLDER_NAME = HUB_NAME:gsub("%s+", "_")
    
    local DataManager = {}
    DataManager.__index = DataManager

    function DataManager.new()
        local self = setmetatable({}, DataManager)
        if not isfolder(FOLDER_NAME) then
            makefolder(FOLDER_NAME)
        end
        return self
    end

    function DataManager:save(fileName, data)
        pcall(function()
            writefile(FOLDER_NAME .. "/" .. fileName, HttpService:JSONEncode(data))
        end)
    end

    function DataManager:load(fileName)
        local filePath = FOLDER_NAME .. "/" .. fileName
        if not isfile(filePath) then return nil end
        
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(filePath))
        end)
        
        return success and result or nil
    end

    local dataManager = DataManager.new()
    
    -- ═══════════════════════════════════════════════════════════
    --                   VALIDATION FUNCTIONS
    -- ═══════════════════════════════════════════════════════════
    
    local function isLinkValid()
        local savedData = dataManager:load("Link.json")
        if not savedData or not savedData.time then return false end
        return (tick() - savedData.time) <= INTERNAL_CONFIG.LinkExpiryTime
    end

    local function validateKey(inputKey, savedLink)
        local expectedKey = INTERNAL_CONFIG.Links[savedLink]
        return expectedKey and inputKey == expectedKey
    end

    local function isPremium()
        if not externalConfig.PremiumUsers then return false end
        for _, user in ipairs(externalConfig.PremiumUsers) do
            if tostring(user):lower() == tostring(LocalPlayer.Name):lower() then
                return true
            end
        end
        return false
    end
    
    -- Verificar se é premium
    if isPremium() then
        notify(HUB_NAME, "Acesso Premium detectado! Carregando...", 3)
        loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
        return
    end

    -- Verificar se já possui link e key válidos salvos
    local savedLink = dataManager:load("Link.json")
    local savedKey = dataManager:load("Key.json")

    if savedLink and savedKey and isLinkValid() then
        if validateKey(savedKey.key, savedLink.link) then
            notify(HUB_NAME, "Sessão válida encontrada! Carregando...", 3)
            loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            return
        end
    end
    
    -- ═══════════════════════════════════════════════════════════
    --                   CARREGAR KEY SYSTEM LIBRARY
    -- ═══════════════════════════════════════════════════════════
    
    local KeySystemLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/hid1ey/credential-request/refs/heads/main/KeySystemLibrary%20(1).lua"))()
    
    -- Obter nome do jogo
    local gameName = ""
    pcall(function()
        gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name or ""
    end)
    
    -- ═══════════════════════════════════════════════════════════
    --                   VARIÁVEIS DE ESTADO
    -- ═══════════════════════════════════════════════════════════
    
    local currentGeneratedLink = nil
    local currentInputKey = ""
    
    -- ═══════════════════════════════════════════════════════════
    --                   FUNÇÃO: GERAR LINK
    -- ═══════════════════════════════════════════════════════════
    
    local function generateLink()
        local links = {}
        for link in pairs(INTERNAL_CONFIG.Links) do
            table.insert(links, link)
        end
        
        if #links == 0 then
            notify("Erro", "Nenhum link disponível", 3)
            return nil
        end
        
        local randomLink = links[math.random(#links)]
        dataManager:save("Link.json", { link = randomLink, time = tick() })
        
        if setclipboard then
            setclipboard(randomLink)
        end
        
        currentGeneratedLink = randomLink
        
        notify("Link Gerado", "Link copiado para sua clipboard!", 5)
        
        return randomLink
    end
    
    -- ═══════════════════════════════════════════════════════════
    --                   FUNÇÃO: VALIDAR SENHA
    -- ═══════════════════════════════════════════════════════════
    
    local function validatePassword(inputKey)
        if not inputKey or inputKey == "" then
            notify("Campo Vazio", "Por favor, digite uma senha", 3)
            return false
        end
        
        local savedLinkData = dataManager:load("Link.json")
        
        if not savedLinkData or not isLinkValid() then
            notify("Link Expirado", "Gere um novo link para continuar", 4)
            return false
        end
        
        if validateKey(inputKey, savedLinkData.link) then
            dataManager:save("Key.json", { key = inputKey, time = tick() })
            
            notify("Validação Completa", "Acesso liberado com sucesso!", 3)
            
            return true
        else
            notify("Senha Incorreta", "Verifique a senha e tente novamente", 4)
            return false
        end
    end
    
    -- ═══════════════════════════════════════════════════════════
    --                   CRIAR KEY SYSTEM UI
    -- ═══════════════════════════════════════════════════════════
    
    -- Preparar todos os links para copiar
    local allKeyLinks = {}
    for link in pairs(INTERNAL_CONFIG.Links) do
        table.insert(allKeyLinks, link)
    end
    
    local KeySystem = KeySystemLibrary.new({
        -- Branding
        HubName = HUB_NAME,
        WelcomeText = "Welcome to",
        IconAssetId = "rbxassetid://7733955511",
        
        -- Links
        DiscordLink = INTERNAL_CONFIG.DiscordLink,
        KeyLinks = allKeyLinks,
        
        -- Textos Customizados
        InputPlaceholder = "Digite sua senha aqui...",
        SubmitButtonText = "Validar Senha",
        CopyLinkButtonText = "Gerar e Copiar Link",
        SupportText = "Precisa de ajuda?",
        DiscordLinkText = "Entre no Discord",
        FooterNotice = "A senha expira em 12 horas após gerar o link",
        
        -- Tema (pode personalizar aqui)
        Theme = {
            PrimaryColor = Color3.fromRGB(220, 38, 38),      -- Vermelho
            SecondaryColor = Color3.fromRGB(17, 24, 39),
            BackgroundColor = Color3.fromRGB(10, 10, 10),
            TextColor = Color3.fromRGB(255, 255, 255),
            SubtextColor = Color3.fromRGB(156, 163, 175),
            GlowColor = Color3.fromRGB(220, 38, 38),
            
            BackgroundTransparency = 0.1,
            GlowTransparency = 0.7,
        },
        
        -- Animações
        Animations = {
            TweenSpeed = 0.3,
            HoverScale = 1.05,
            ClickScale = 0.95,
        },
        
        -- ═══════════════════════════════════════════════════════════
        --                   CALLBACKS
        -- ═══════════════════════════════════════════════════════════
        
        -- Quando o usuário submete a senha
        OnSubmit = function(key)
            currentInputKey = key
            
            if validatePassword(key) then
                -- Aguardar um pouco antes de carregar
                task.wait(1)
                
                -- Fechar o Key System
                KeySystem:Hide()
                
                -- Aguardar a animação de saída
                task.wait(0.5)
                
                -- Destruir completamente
                KeySystem:Destroy()
                
                -- Carregar o script principal
                loadstring(game:HttpGet(MAIN_SCRIPT_URL))()
            end
        end,
        
        -- Quando o usuário clica em "Copy Link"
        OnCopyLink = function(links)
            -- Gerar novo link ao invés de apenas copiar
            generateLink()
            
            -- Nota: O link já foi copiado pela função generateLink()
            -- Esta callback é só para tracking/analytics se necessário
        end,
        
        -- Quando o Key System é fechado
        OnClose = function()
            print("[Universal System] Key System fechado pelo usuário")
        end
    })
    
    -- ═══════════════════════════════════════════════════════════
    --                   MOSTRAR KEY SYSTEM
    -- ═══════════════════════════════════════════════════════════
    
    -- Notificar o usuário
    notify(
        HUB_NAME, 
        "Sistema de Validação Carregado\n" .. (gameName ~= "" and gameName or "Jogo Detectado"), 
        4
    )
    
    -- Mostrar o Key System com animação
    KeySystem:Show()
    
    -- Mensagem informativa no console
    print("╔════════════════════════════════════════╗")
    print("║   " .. HUB_NAME .. " - KEY SYSTEM ATIVO    ║")
    print("╚════════════════════════════════════════╝")
    print("")
    print("📋 Como usar:")
    print("   1. Clique em 'Gerar e Copiar Link'")
    print("   2. Complete o link encurtado")
    print("   3. Copie a senha gerada")
    print("   4. Cole no campo e clique em 'Validar Senha'")
    print("")
    print("💎 Para acesso Premium:")
    print("   - Entre no Discord: " .. INTERNAL_CONFIG.DiscordLink)
    print("")
    print("════════════════════════════════════════")
end