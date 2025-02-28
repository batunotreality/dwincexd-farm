local isCollecting = false

local function StopCollection()
    isCollecting = false
    ClearPedTasks(PlayerPedId())
    lib.notify({ type = 'inform', description = 'Toplama durduruldu!' })
end

local function LoadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(10000)
    end
end

local function AlanIcerisindeMi()
    local playerCoords = GetEntityCoords(PlayerPedId())
    return #(playerCoords - Config.Toplama.Blip.Koordinat) <= Config.Toplama.Blip.Boyut
end

local function StartCollection()
    LoadAnimDict(Config.Toplama.Anim.Dict)
    TaskPlayAnim(PlayerPedId(), Config.Toplama.Anim.Dict, Config.Toplama.Anim.Clip, 8.0, -8.0, -1, 1, 0, false, false, false)

    local success = lib.progressBar({
        duration = Config.Toplama.Sure,
        label = 'Ot toplanıyor...',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    })

    if success then
        TriggerServerEvent('dw-farm:server:itemEkle', Config.Toplama.Item, 1)
        lib.notify({ type = 'success', description = '1x '..exports.ox_inventory:Items(Config.Toplama.Item).label..' toplandı!' })
    else
        lib.notify({ type = 'error', description = 'İşlem iptal edildi!' })
    end
    
    StopCollection()
end

Citizen.CreateThread(function()
    local blip = AddBlipForRadius(Config.Toplama.Blip.Koordinat.x, Config.Toplama.Blip.Koordinat.y, Config.Toplama.Blip.Koordinat.z, Config.Toplama.Blip.Boyut)
    SetBlipColour(blip, Config.Toplama.Blip.Color)
    SetBlipAlpha(blip, 100)

    local blipNokta = AddBlipForCoord(Config.Toplama.Blip.Koordinat)
    SetBlipSprite(blipNokta, Config.Toplama.Blip.Sprite)
    SetBlipColour(blipNokta, Config.Toplama.Blip.Color)
    SetBlipAsShortRange(blipNokta, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Toplama.Blip.Ad)
    EndTextCommandSetBlipName(blipNokta)
end)

Citizen.CreateThread(function()
    while true do
        if AlanIcerisindeMi() then
            if not isCollecting then
                -- lib.showTextUI('[E] - Ot Toplamayı Başlat')
                if IsControlJustPressed(0, 38) then
                    isCollecting = true
                    StartCollection()
                end
            else
                lib.hideTextUI()
            end
        else
            lib.hideTextUI()
            if isCollecting then StopCollection() end
        end
        Citizen.Wait(15)
    end
end)

Citizen.CreateThread(function()
    local pedModel = Config.Satis.NPC.Model
    local pedCoords = Config.Satis.NPC.Koordinat
    
    -- Model yüklenene kadar bekle
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Citizen.Wait(50000)
    end

    -- NPC oluştur
    local npc = CreatePed(
        4, -- Ped type
        pedModel,
        pedCoords.x,
        pedCoords.y,
        pedCoords.z,
        pedCoords.w,
        false, -- Networked
        true -- Mission entity
    )

    -- NPC ayarları
    SetEntityAsMissionEntity(npc, true, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedFleeAttributes(npc, 0, false)
    SetPedRelationshipGroupHash(npc, `CIVMALE`)
    TaskStartScenarioInPlace(npc, Config.Satis.NPC.Animasyon, 0, true)

    -- QB-Target entegrasyonu
    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                type = "client",
                label = "Otları Sat",
                icon = "fas fa-cannabis",
                action = function()
                    OpenSalesMenu()
                end
            }
        },
        distance = 2.5
    })
end)

-- Ayrı fonksiyon olarak menüyü aç
function OpenSalesMenu()
    local menuItems = {}
    
    for _, product in ipairs(Config.Satis.Urunler) do
        menuItems[#menuItems+1] = {
            title = product.label,
            description = ("Fiyat: $%s"):format(product.fiyat),
            event = 'dw-farm:client:satisYap',
            args = product
        }
    end

    lib.registerContext({
        id = 'satis_menu',
        title = 'Ot Satış',
        options = menuItems
    })
    
    lib.showContext('satis_menu')
end

RegisterNetEvent('dw-farm:client:satisYap', function(data)
    if Config.Debug then 
        print("[DEBUG] Satış tetiklendi - Item:", data.item, "Fiyat:", data.fiyat) 
    end
    TriggerServerEvent('dw-farm:server:satisYap', data.item, data.fiyat)
end)