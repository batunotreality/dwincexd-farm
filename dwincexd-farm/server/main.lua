RegisterNetEvent('dw-farm:server:itemEkle', function(item, miktar)
    local src = source
    if exports.ox_inventory:CanCarryItem(src, item, miktar) then
        exports.ox_inventory:AddItem(src, item, miktar)
        if Config.Debug then
            print("[DEBUG] "..GetPlayerName(src).." adlı oyuncuya "..miktar.."x "..item.." eklendi.")
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Envanter dolu!' })
    end
end)

RegisterNetEvent('dw-farm:server:satisYap', function(item, fiyat)
    local src = source
    local itemCount = exports.ox_inventory:Search(src, 'count', item)
    
    if itemCount and itemCount >= 1 then
        local success = exports.ox_inventory:RemoveItem(src, item, itemCount)
        if success then
            local toplamKazanc = itemCount * fiyat
            exports.ox_inventory:AddItem(src, 'cash', toplamKazanc)
            
            TriggerClientEvent('ox_lib:notify', src, {
                type = 'success',
                description = itemCount..'x '..exports.ox_inventory:Items(item).label..' satıldı! Kazanç: $'..toplamKazanc
            })
            
            if Config.Debug then
                print("[DEBUG] "..GetPlayerName(src).." adlı oyuncu "..itemCount.."x "..item.." sattı.")
            end
        end
    else
        TriggerClientEvent('ox_lib:notify', src, { 
            type = 'error', 
            description = 'Üzerinde hiç '..exports.ox_inventory:Items(item).label..' yok!' 
        })
    end
end)