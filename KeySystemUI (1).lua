-- Carrega a library (troque pelo seu link se estiver no GitHub)
local KeySystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/hid1ey/credential-request/refs/heads/main/SpeedHubX_KeySystem.lua"))()

local CONFIG = {
    HubName = "Speed Hub X",
    SubTitle = "Key System",

    -- Dimensões da UI
    Width = 404,
    Height = 288,

    -- Keys locais (opcional se usar remoto)
    ValidKeys = {
        "FREE-2026",
        "NINJA-VIP",
        "BETA-ACCESS"
    },

    SaveKey = true, -- salva a key
    KeylessWeekend = false, -- liberar sem key se quiser

    DiscordLink = "https://discord.gg/seulink",

    Providers = {
        {
            Name = "Get Key",
            Link = "https://loot-link.com/sua_key"
        },
        {
            Name = "Backup Key",
            Link = "https://linkvertise.com/seulink"
        }
    },

    Callback = function(key)
        print("Key validada:", key)

        -- Carrega seu HUB após validar
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/SEUUSER/SEUREPO/main/hub.lua"
        ))()
    end,
}

KeySystem.new(CONFIG)