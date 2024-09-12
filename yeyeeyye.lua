bot = getBot()
world = bot:getWorld()
inventory = bot:getInventory()
startt, stopp = Bots_Range:match("(%d+)%-(%d+)")
Block_ID = Seed_ID - 1
farms = {}
storages = {}
growIDs = {}
farmlist = {}
storagelist = {}
seedlist = {}
farmindex = 1
storageindex = 1
tileharvest = {0,1,2}
tileharvest2 = {-2,-1,0}
nuked = false
wrongdoor = false
fired = false
toxic = false
plantableTree = 0
totalTree = 0
readyTree = 0
unreadyTree = 0

if bot.index > tonumber(stopp) then
    print(bot.name:upper() .. " : Cannot run that bot please remake the 'Bots_Range'!")
    sleep(50)
    error("Cannot run that bot please remake the 'Bots_Range'!")
end
if Buy_Magnificence and Buy_Pack then
    error("Buy_Magnificence and Buy_Pack cannot be true in the same time!")
end

function getgrowids()
    for i = tonumber(startt), tonumber(stopp) do
        table.insert(growIDs, getBots()[i].name:upper())
    end
end

function getworlds(list, tablee)
    for line in list:gmatch("[^\r\n]+") do
        table.insert(tablee, line)
    end
end

function splitworlds(list, mode)
    if mode == "farm" then
        local farms = {}
    else
        local storages = {}
    end
    local botCount = #growIDs
    local worldCount = #list
    local worldsPerBot = math.floor(worldCount / botCount)
    local extraWorlds = worldCount % botCount
    local worldIndex = 1
    for i = 1, botCount do
        local assignmentCount = worldsPerBot
        if i <= extraWorlds then
            assignmentCount = assignmentCount + 1
        end
        local botName = growIDs[i]
        if mode == "farm" then
            farms[botName] = {}
        else
            storages[botName] = {}
        end
        for j = 1, assignmentCount do
            if mode == "farm" then
                table.insert(farms[botName], list[worldIndex]:upper())
            else
                table.insert(storages[botName], list[worldIndex]:upper())
            end
            worldIndex = worldIndex + 1
        end
    end
    if mode == "farm" then
        return farms
    else
        return storages
    end
end

function splitData(storageType)
    local botsPerWorld = math.ceil(#growIDs / #storageType)
    local splitData = {}
    for i, item in ipairs(storageType) do
        local startIndex = (i - 1) * botsPerWorld + 1
        local endIndex = math.min(startIndex + botsPerWorld - 1, #growIDs)
        for j = startIndex, endIndex do
            splitData[growIDs[j]] = item
        end
    end
    local botName = getBot().name:upper()
    return splitData[botName]
end

-- WORLDLERI TABLEYE AKTAR
getworlds(Farm_List, farmlist)
sleep(100)
getworlds(Storage_Block_List, storagelist)
sleep(100)
getworlds(Storage_Seed_List, seedlist)
sleep(100)
-- WORLDLERI SPLITLE
getgrowids()
sleep(100)
splitworlds(farmlist, "farm")
sleep(100)
splitworlds(storagelist, "storage")
sleep(100)
seedconfig = splitData(seedlist)
worldseed, doorseed = seedconfig:match("([^|]+)|([^|]+)")
if Buy_Pack then
    worldpack = splitData(World_Pack)
    doorpack = Door_Pack
end
worldfarm, doorfarm = farms[bot.name:upper()][farmindex]:match("([^|]+)|([^|]+)")
worldstorage, doorstorage = storages[bot.name:upper()][storageindex]:match("([^|]+)|([^|]+)")

function writeinvalid(desc, pathh)
    local desc_prefix = desc:match("^(.-)|")
    local file = io.open(pathh, "r")
    local exists = false
    if file then
        for line in file:lines() do
            local line_prefix = line:match("^(.-)|")
            if line_prefix == desc_prefix then
                exists = true
                break
            end
        end
        file:close()
    end
    if not exists then
        file = io.open(pathh, "a")
        file:write(desc .. "\n")
        file:close()
    end
end

function AnlikYer()
    Dunyadami = tostring(world.name)
    if Dunyadami ~= "" and Dunyadami ~= "EXIT" then
        localbot = world:getLocal()
        if localbot then
            Botx = math.floor(localbot.posx / 32) 
            Boty = math.floor(localbot.posy / 32)
        end
    end
end

function calculateDuration(startTime)
    local farmDuration = os.time() - startTime
    local hours = math.floor(farmDuration / 3600)
    local minutes = math.floor((farmDuration % 3600) / 60)
    local seconds = farmDuration % 60
    return string.format("%d**H** %d**M** %d**S**", hours, minutes, seconds)
end

function OnVariantList(variant, netid)
    if variant:get(0):getString() == "OnConsoleMessage" then
        if variant:get(1):getString():lower():find("inaccessible") then
            nuked = true
        elseif variant:get(1):getString():lower():find("level ") then
            nuked = true
        end
    end
end

function otw(worldotw, idotw)
    local cok = 0
    nuked = false
    wrongdoor = false
    addEvent(Event.variantlist, OnVariantList)
    while not bot:isInWorld(worldotw:upper()) do
        ::retryleave::
        reconnect(worldotw, idotw, bot.x, bot.y, "simple")
        if world.name ~= "EXIT" and world.name ~= worldotw:upper() then
            bot:leaveWorld()
            sleep(2500)
            while world.name ~= "EXIT" do
                sleep(500)
                cok = cok + 1
                if cok == 10 then
                    cok = 0
                    goto retryleave
                end
            end
            cok = 0
        end
        if bot.status == 1 and bot:getPing() < 150 then
            if idotw ~= "" then
                bot:warp(worldotw:upper(), idotw:upper())
            else
                bot:warp(worldotw:upper())
            end
            listenEvents(5)
            sleep(math.random(3500, 5000))
            if cok == 3 then
                while bot.status == BotStatus.online do
                    bot:disconnect()
                    sleep(5000)
                end
                sleep(60000 * 5)
                cok = 0
                reconnect(worldotw, idotw, bot.x, bot.y, "simple")
            else
                cok = cok + 1
            end
        end
        if nuked then
            break
        end
    end
    if not nuked then
        if idotw ~= "" and (getTile(bot.x,bot.y).fg == 6 or world.name == "EXIT") then
            local retryid = 0
            while getTile(bot.x,bot.y).fg == 6 or world.name == "EXIT" do
                sleep(1500)
                reconnect(worldotw, idotw, bot.x, bot.y, "simple")
                if (getTile(bot.x,bot.y).fg == 6 or world.name == "EXIT") and bot.status == 1 and bot:getPing() < 150 then
                    bot:warp(worldotw:upper(), idotw:upper())
                    sleep(math.random(8500, 10000))
                    if getTile(bot.x, bot.y).fg == 6 then
                        retryid = retryid + 1
                    end
                end
                if retryid >= 3 then
                    print("["..bot.name:upper().."] Bot cannot join to door id! World: "..worldotw:upper())
                    sleep(100)
                    retryid = 0
                    wrongdoor = true
                    break
                end
            end
        end
    end
    removeEvent(Event.variantlist)
    sleep(100)
end

function otwfarm()
    otw(worldfarm, doorfarm)
    sleep(100)
    checkfarm()
end

function otwdrop()
    otw(worldstorage, doorstorage)
    sleep(100)
    checkdrop()
end

function isPlantable(x,y)
    local tempTile = getTile(x, y + 1)
    if not tempTile.fg then 
        return false 
    end
    local collision = getInfo(tempTile.fg).collision_type
    return tempTile and ( collision == 1 or collision == 2 )
end

function checkFire()
    plantableTree = 0
    totalTree = 0
    readyTree = 0
    unreadyTree = 0
    fired = false
    toxic = false
    reconnect(worldfarm, doorfarm, bot.x, bot.y, "normal")
    for _, tile in pairs(bot:getWorld():getTiles()) do
        reconnect(worldfarm, doorfarm, bot.x, bot.y, "normal")
        if getTile(tile.x, tile.y).fg == 0 and isPlantable(tile.x, tile.y) and bot:isInWorld(worldfarm) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 then
            plantableTree = plantableTree + 1
        end
        if tile:hasFlag(4096) then
            fired = true
        end
        if tile.fg == 778 then
            toxic = true
        end
        if tile.fg == Seed_ID then
            if tile:canHarvest() then
                readyTree = readyTree + 1
            else
                unreadyTree = unreadyTree + 1
            end
        end
    end
    totalTree = readyTree + unreadyTree
end

function clearFire(worldd, idd)
    reconnect(worldd, idd, bot.x, bot.y, "normal")
    for _, tile in pairs(bot:getWorld():getTiles()) do
        if tile:hasFlag(4096) then
            local firedd = true
            if inventory:getItemCount(3066) == 0 or inventory:getItemCount(3066) > 1 then
                takeid(World_Hose, Door_Hose, 3066, 1)
                sleep(100)
            end
            if not bot:isInWorld(worldd:upper()) then
                sleep(500)
                otw(worldd, idd)
            end
            bot.anti_fire = true
            sleep(100)
            while firedd do
                sleep(5000)
                firedd = false
                if bot.status == 1 and bot:isInWorld(worldd:upper()) then
                    for _, tile in pairs(bot:getWorld():getTiles()) do
                        if tile:hasFlag(4096) then
                            firedd = true
                        end
                    end
                else
                    bot.anti_fire = false
                    sleep(100)
                    otw(worldd, idd)
                    sleep(100)
                    firedd = true
                    bot.anti_fire = true
                    sleep(100)
                end
            end
            bot.anti_fire = false
            sleep(100)
            if inventory:getItemCount(98) >= 1 and not inventory:getItem(98).isActive then
                bot:wear(98)
                sleep(500)
            end
        end
    end
end

function clearWaste(worldd, idd)
    reconnect(worldd, idd, bot.x, bot.y, "normal")
    for _, tile in pairs(world:getTiles()) do
        if tile.fg == 778 then
            local toxicc = true
            bot.anti_toxic = true
            sleep(100)
            while toxicc do
                sleep(5000)
                toxicc = false
                if bot.status == 1 and bot:isInWorld(worldd:upper()) then
                    for _, tile in pairs(world:getTiles()) do
                        if tile.fg == 778 then
                            toxicc = true
                        end
                    end
                else
                    bot.anti_toxic = false
                    sleep(100)
                    otw(worldd, idd)
                    sleep(100)
                    toxicc = true
                    bot.anti_toxic = true
                    sleep(100)
                end
            end
            bot.anti_toxic = false
            sleep(100)
        end
    end
end

function checkfarm()
    reconnect(worldfarm, doorfarm, bot.x, bot.y, "normal")
    local nextolcak = true
    if bot:isInWorld(worldfarm) and not wrongdoor then
        checkFire()
        sleep(100)
        if fired or toxic then
            if fired then
                if Clear_Fire then
                    clearFire(worldfarm, doorfarm)
                    sleep(100)
                    fired = false
                else
                    fired = true
                end
            end
            if toxic then
                clearWaste(worldfarm, doorfarm)
                sleep(100)
            end
        end
    end
    if not nuked and not wrongdoor and not fired then
        reconnect(worldfarm, doorfarm, bot.x, bot.y, "normal")
        for _,tile in pairs(bot:getWorld():getTiles()) do
            if getTile(tile.x, tile.y).fg == Seed_ID and tile:canHarvest() and bot:isInWorld(worldfarm) and bot:getWorld():hasAccess(tile.x,tile.y) > 0 then
                nextolcak = false
                sleep(100)
                break
            end
        end
    end
    if nuked or wrongdoor or nextolcak or fired then
        if nuked then
            writeinvalid(worldfarm .. "|" .. doorfarm .. " - NUKED", Fail_Path)
        elseif wrongdoor then
            writeinvalid(worldfarm .. "|" .. doorfarm .. " - WRONG DOOR", Fail_Path)
        elseif fired then
            writeinvalid(worldfarm .. "|" .. doorfarm .. " - FIRED", Fail_Path)
        elseif nextolcak then
            append(Save_Path, worldfarm .. "|" .. doorfarm .."\n")
        end
        sleep(100)
        farmindex = farmindex + 1
        if farmindex > #farms[bot.name:upper()] then
            if Looping_Farm then
                farmindex = 1
            else
                bot.auto_collect = false
                sleep(100)
                if inventory:getItemCount(Block_ID) >= 1 and Target_Block < 201 then
                    otwdrop()
                    sleep(100)
                    storeitem("block", worldstorage, doorstorage)
                end
                if inventory:getItemCount(Seed_ID) >= 1 and Target_Seed < 201 then
                    otw(worldseed, doorseed)
                    sleep(100)
                    storeitem("seed", worldseed, doorseed)
                end
                if Fuel_Mode then
                    if inventory:getItemCount(1746) >= 1 then
                        otw(World_Fuel, Door_Fuel)
                        sleep(100)
                        storeitem("fuel", World_Fuel, Door_Fuel)
                    end
                end
                bot:disconnect()
                sleep(2500)
                farmindex = farmindex - 1
                bot.custom_status = farmindex .. "|Finished"
                sleep(500)
                bot:stopScript()
            end
        end
        worldfarm, doorfarm = farms[bot.name:upper()][farmindex]:match("([^|]+)|([^|]+)")
        otwfarm()
        sleep(100)
    end
end

function isPathFindable(x, y)
    if (getBot():isInTile(x, y) or #getBot():getPath(x, y) > 0) then
        return true
    end
    return false
end

function checkdrop()
    dropcount = 0
    reconnect(worldstorage, doorstorage, bot.x, bot.y, "normal")
    if bot:isInWorld(worldstorage) and not wrongdoor then
        for _,obj in pairs(bot:getWorld():getObjects()) do
            if obj.id == Block_ID then
                dropcount = dropcount + obj.count
            end
        end
    end
    if nuked or wrongdoor or dropcount >= Max_Block then
        local removelendi = false
        storageindex = storageindex + 1
        if storageindex > #storages[bot.name:upper()] then
            if #storages[bot.name:upper()] < #storagelist then
                removelendi = true
                storageindex = storageindex - 1
                for i = 1, storageindex do
                    for ii, v in ipairs(storagelist) do
                        if v == storages[bot.name:upper()][i] then
                            table.remove(storagelist, ii)
                        end
                    end
                end
            else
                bot:disconnect()
                sleep(2500)
                bot.custom_status = farmindex.."|Finished Storage"
                sleep(500)
                bot:stopScript()
            end
        end
        if removelendi then
            splitworlds(storagelist, "storage")
            sleep(100)
            storageindex = 1
        end
        worldstorage, doorstorage = storages[bot.name:upper()][storageindex]:match("([^|]+)|([^|]+)")
        otwdrop()
        sleep(100)
    end
end
    
function reconnect(worldd,idd,x,y,sistem)
    if bot.status ~= BotStatus.online or bot:getPing() == 0 then
        local reccok = 0
        sleep(Delay_Reconnect / 2)
        bot.auto_reconnect = true
        sleep(100)
        while bot.status ~= BotStatus.online or bot:getPing() == 0 do
            sleep(Delay_Reconnect)
            if bot.status == BotStatus.account_banned then
                sleep(1000)
                bot:stopScript()
            elseif bot.status == BotStatus.maintenance then
                sleep(600000)
            end 
            if bot.status ~= 1 then
                reccok = reccok + 1
                if reccok >= 5 then
                    bot:connect()
                    sleep(Delay_Reconnect)
                    reccok = 0
                end
            end
        end
        bot.auto_reconnect = false
        sleep(100)
        if sistem ~= "simple" then
            otw(worldd, idd)
            sleep(500)
            if x and y and (bot.x ~= x or bot.y ~= y) then
                bot:findPath(x,y)
                sleep(2500)
            end
        end
    end
end

function takeid(worldd,doorid,itemid,itemtarget)
    otw(worldd, doorid)
    sleep(100)
    AnlikYer()
    while inventory:getItemCount(itemid) < itemtarget do
        for i = 1, 10 do
            print("["..bot.name:upper().."] Searching For ("..itemtarget.."x "..getInfo(itemid).name..") to Collect")
            sleep(1000)
            reconnect(worldd, doorid, Botx, Boty, "normal")
            for _,obj in pairs(bot:getWorld():getObjects()) do
                if obj.id == itemid then
                    local objx = math.floor(obj.x / 32)
                    local objy = math.floor(obj.y / 32)
                    bot:findPath(objx, objy)
                    sleep(100)
                    reconnect(worldd, doorid, Botx, Boty, "normal")
                    bot:collectObject(obj.oid, 1)
                    sleep(2000)
                    break
                end
            end
            if inventory:getItemCount(itemid) >= itemtarget then
                break
            end
            if i == 10 then
                print("["..bot.name:upper().."] There is not Enough ("..getInfo(itemid).name.."**) to Collect! World Name: "..world.name)
                sleep(100)
                otw(worldd, doorid)
                sleep(100)
            end
        end
    end
    print("["..bot.name:upper().."] Successfully Collected ["..getInfo(itemid).name.."]")
    sleep(100)
    reconnect(worldd, doorid, Botx, Boty, "normal")
    if inventory:getItemCount(itemid) > itemtarget then
        bot:findPath(Botx, Boty)
        sleep(500)
        if Botx < 49 then
            bot:setDirection(false)
        else
            bot:setDirection(true)
        end
        sleep(500)
        while inventory:getItemCount(itemid) > itemtarget do
            reconnect(worldd, doorid, Botx, Boty, "normal")
            bot:drop(itemid, inventory:getItemCount(itemid) - itemtarget)
            sleep(2000)
            if inventory:getItemCount(itemid) > itemtarget then
                if Botx < 49 then
                    bot:moveRight()
                else
                    bot:moveLeft()
                end
                sleep(500)
                AnlikYer()
            end
        end
    end
end

function checkTile(x,y,num)
    local count = 0
    for _,obj in pairs(getBot():getWorld():getObjects()) do
        if math.floor((obj.x + 10) / 32) == x and math.floor((obj.y + 10) / 32) == y then
            count = count + obj.count
        end
    end
    if count <= (4000 - num) then
        return true
    end
    return false
end

function storeitem(item, worldd, idd)
    local itemid, selectedacuan
    if Use_Acuan and (item == "block" or item == "seed") then
        if item == "block" then
            selectedacuan = Acuan_Block
            itemid = Block_ID
        elseif item == "seed" then
            selectedacuan = Acuan_Seed
            itemid = Seed_ID
        end
        dropItems(selectedacuan, itemid, worldd, idd)
    elseif not Use_Acuan and (item == "block" or item == "seed") then
        if item == "block" then
            itemid = Block_ID
        elseif item == "seed" then
            itemid = Seed_ID
        end
        dropItems(nil, itemid, worldd, idd)
    elseif Use_Acuan and item == "pack" then
        for _, packid in pairs(List_Pack) do
            dropItems(Acuan_Pack, packid, worldd, idd)
        end
    elseif not Use_Acuan and item == "pack" then
        for _, packid in pairs(List_Pack) do
            dropItems(nil, packid, worldd, idd)
        end
    elseif Use_Acuan and item == "cake" then
        for _, cakeid in pairs(Mooncake_List) do
            dropItems(Acuan_Mooncake, cakeid, worldd, idd)
        end
    elseif not Use_Acuan and item == "cake" then
        for _, cakeid in pairs(Mooncake_List) do
            dropItems(nil, cakeid, worldd, idd)
        end
    elseif item == "fuel" then
        itemid = 1746
        dropItems(nil, itemid, worldd, idd)
    end
end

function dropItems(acuan, itemid, worldd, idd)
    reconnect(worldd, idd, bot.x, bot.y, "normal")
    sleep(100)
    AnlikYer()
    if acuan ~= nil then
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if (tile.fg == acuan or tile.bg == acuan) and inventory:getItemCount(itemid) > 0 then
                if string.lower(Drop_Direction) == "right" then
                    moveAndDrop(tile.x, 99, 1, tile.y, itemid, worldd, idd)
                    break
                else
                    moveAndDrop(tile.x, 0, -1, tile.y, itemid, worldd, idd)
                    break
                end
            end
        end
    elseif acuan == nil then
        if inventory:getItemCount(itemid) > 0 then
            if string.lower(Drop_Direction) == "right" then
                moveAndDrop(Botx + 1, 99, 1, Boty, itemid, worldd, idd)
            else
                moveAndDrop(Botx - 1, 0, -1, Boty, itemid, worldd, idd)
            end
        end
    end
end

function moveAndDrop(startX, endX, step, y, itemid, worldd, idd)
    reconnect(worldd, idd, tilex, y, "normal")
    local targetdrop
    local inventorycount = inventory:getItemCount(itemid)
    if itemid == Block_ID then
        targetdrop = Max_Block - dropcount
        if targetdrop > inventorycount then
            targetdrop = inventorycount
        end
        if targetdrop == 0 then
            return
        end
    else
        targetdrop = inventorycount
    end
    for tilex = startX, endX, step do
        if checkTile(tilex, y, targetdrop) then
            if step == 1 and not bot:isInTile(tilex - 1, y) then
                bot:findPath(tilex - 1, y)
            elseif step == -1 and not bot:isInTile(tilex + 1, y) then
                bot:findPath(tilex + 1, y)
            end
            sleep(300)
            bot:setDirection(step == -1)
            sleep(500)
            while inventory:getItemCount(itemid) == inventorycount do
                bot:drop(itemid, targetdrop)
                sleep(Delay_Drop)
                reconnect(worldd, idd, tilex, y, "normal")
                if inventory:getItemCount(itemid) == inventorycount then
                    if Drop_Direction == "right" then
                        bot:moveRight()
                    else
                        bot:moveLeft()
                    end
                    sleep(500)
                end
            end
        end
        if inventory:getItemCount(itemid) == 0 or inventory:getItemCount(itemid) ~= inventorycount then
            break
        end
    end
end

function tileHarvest(x, y, mode)
    for _, num in ipairs(mode) do
        local tilem = getTile(x + num, y)
        if tilem.fg == Seed_ID and tilem:canHarvest() and world:hasAccess(x + num, y) > 0 then
            return true
        end
    end
    return false
end

function punch(x,y)
    return bot:hit(bot.x+x,bot.y+y)
end

function harvest()
    if not bot:isInWorld(worldfarm) then
        otwfarm()
        sleep(100)
    end
    bot.auto_collect = true
    sleep(100)
    ::againharvest::
    local direction = "right"
    local firststart = false
    local coordinatY = 0
    ::retryharvest::
    reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
    if Fuel_Mode and inventory:getItemCount(1746) <= Minimum_Fuel then
        takeid(World_Fuel, Door_Fuel, 1746, Maximum_Fuel)
        sleep(100)
        while not inventory:getItem(1746).isActive do
            sleep(2000)
            reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
            if bot:isInWorld() then
                bot:wear(1746)
                sleep(2500)
            end
        end
        otwfarm()
        sleep(100)
    end
    if direction == "right" then
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.fg == Seed_ID and tile:canHarvest() and bot:getWorld():hasAccess(tile.x, tile.y) > 0 and bot:isInWorld(worldfarm) and inventory:getItemCount(Block_ID) < Target_Block and (not Fuel_Mode or Fuel_Mode and inventory:getItemCount(1746) > Minimum_Fuel) then
                if not firststart then
                    coordinatY = tile.y
                    sleep(10)
                    firststart = true
                end
                if tile.y > coordinatY then
                    direction = "left"
                    coordinatY = tile.y
                    goto retryharvest
                end
                if HtFest_Mode then
                    if Use_Magnificence then
                        if inventory:getItemCount(10158) <= Minimum_Magnificence then
                            if bot.gem_count >= 5000 and Buy_Magnificence then
                                while inventory:getItemCount(10158) <= Minimum_Magnificence and bot.gem_count >= 5000 do
                                    if not bot:isInWorld() then
                                        otwfarm()
                                        sleep(100)
                                    end
                                    bot:buy("mooncake_mag")
                                    sleep(5000)
                                end
                            elseif bot.gem_count < 5000 or not Buy_Magnificence then
                                bot.auto_collect = false
                                sleep(100)
                                takeid(World_HtFest, Door_HtFest, 10158, Maximum_Magnificence)
                                sleep(100)
                            end
                            while not inventory:getItem(10158).isActive do
                                sleep(2000)
                                reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
                                if bot:isInWorld() then
                                    bot:wear(10158)
                                    sleep(2500)
                                end
                            end
                        end
                    end
                    for _, kek in pairs(Mooncake_List) do
                        reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
                        if kek == 1828 then
                            if inventory:getItemCount(kek) >= Minimum_Balance then
                                bot.auto_collect = false
                                sleep(100)
                                otw(World_HtFest, Door_HtFest)
                                sleep(100)
                                storeitem("cake", World_HtFest, Door_HtFest)
                                sleep(100)
                                break
                            end
                        else
                            if inventory:getItemCount(kek) >= 190 then
                                bot.auto_collect = false
                                sleep(100)
                                otw(World_HtFest, Door_HtFest)
                                sleep(100)
                                storeitem("cake", World_HtFest, Door_HtFest)
                                sleep(100)
                                break
                            end
                        end
                    end
                    if not bot:isInWorld(worldfarm) then
                        otwfarm()
                        sleep(100)
                    end
                    bot.auto_collect = true
                    sleep(100)
                end
                if isPathFindable(tile.x, tile.y) then
                    bot:findPath(tile.x, tile.y)
                    sleep(math.random(0, 50))
                end
                reconnect(worldfarm, worldfarmid, tile.x, tile.y, "normal")
                while tileHarvest(tile.x, tile.y, tileharvest) and bot:isInTile(tile.x, tile.y) and inventory:getItemCount(Block_ID) < Target_Block and (not Fuel_Mode or Fuel_Mode and inventory:getItemCount(1746) > Minimum_Fuel) do
                    for _, i in pairs(tileharvest) do
                        if getTile(bot.x + i, bot.y).fg == Seed_ID and inventory:getItemCount(Block_ID) < Target_Block then
                            punch(i, 0)
                            sleep(Dynamicping())
                        end
                        reconnect(worldfarm, worldfarmid, tile.x, tile.y, "normal")
                    end
                end
            end
        end
    else
        local reverseTiles = {}
        reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.y == coordinatY then
                table.insert(reverseTiles, tile)
            end
        end
        for i = #reverseTiles, 1, -1 do
            local tile = reverseTiles[i]
            if tile.fg == Seed_ID and tile:canHarvest() and bot:getWorld():hasAccess(tile.x, tile.y) > 0 and bot:isInWorld(worldfarm) and inventory:getItemCount(Block_ID) < Target_Block and (not Fuel_Mode or Fuel_Mode and inventory:getItemCount(1746) > Minimum_Fuel) then
                if not firststart then
                    coordinatY = tile.y
                    sleep(10)
                    firststart = true
                end
                if tile.y > coordinatY then
                    direction = "left"
                    coordinatY = tile.y
                    goto retryharvest
                end
                if HtFest_Mode then
                    if Use_Magnificence then
                        if inventory:getItemCount(10158) <= Minimum_Magnificence then
                            if bot.gem_count >= 5000 and Buy_Magnificence then
                                while inventory:getItemCount(10158) <= Minimum_Magnificence and bot.gem_count >= 5000 do
                                    if not bot:isInWorld() then
                                        otwfarm()
                                        sleep(100)
                                    end
                                    bot:buy("mooncake_mag")
                                    sleep(5000)
                                end
                            elseif bot.gem_count < 5000 or not Buy_Magnificence then
                                bot.auto_collect = false
                                sleep(100)
                                takeid(World_HtFest, Door_HtFest, 10158, Maximum_Magnificence)
                                sleep(100)
                            end
                            while not inventory:getItem(10158).isActive do
                                sleep(2000)
                                reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
                                if bot:isInWorld() then
                                    bot:wear(10158)
                                    sleep(2500)
                                end
                            end
                        end
                    end
                    for _, kek in pairs(Mooncake_List) do
                        reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
                        if kek == 1828 then
                            if inventory:getItemCount(kek) >= Minimum_Balance then
                                bot.auto_collect = false
                                sleep(100)
                                otw(World_HtFest, Door_HtFest)
                                sleep(100)
                                storeitem("cake", World_HtFest, Door_HtFest)
                                sleep(100)
                                break
                            end
                        else
                            if inventory:getItemCount(kek) >= 190 then
                                bot.auto_collect = false
                                sleep(100)
                                otw(World_HtFest, Door_HtFest)
                                sleep(100)
                                storeitem("cake", World_HtFest, Door_HtFest)
                                sleep(100)
                                break
                            end
                        end
                    end
                    if not bot:isInWorld(worldfarm) then
                        otwfarm()
                        sleep(100)
                    end
                    bot.auto_collect = true
                    sleep(100)
                end
                if isPathFindable(tile.x, tile.y) then
                    bot:findPath(tile.x, tile.y)
                    sleep(math.random(0, 50))
                end
                reconnect(worldfarm, worldfarmid, tile.x, tile.y, "normal")
                while tileHarvest(tile.x, tile.y, tileharvest2) and bot:isInTile(tile.x, tile.y) and inventory:getItemCount(Block_ID) < Target_Block and (not Fuel_Mode or Fuel_Mode and inventory:getItemCount(1746) > Minimum_Fuel) do
                    for _, i in pairs(tileharvest2) do
                        if getTile(bot.x + i, bot.y).fg == Seed_ID and inventory:getItemCount(Block_ID) < Target_Block then
                            punch(i, 0)
                            sleep(Dynamicping())
                        end
                        reconnect(worldfarm, worldfarmid, tile.x, tile.y, "normal")
                    end
                end
            end
        end
        reconnect(worldfarm, worldfarmid, bot.x, bot.y, "normal")
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.fg == Seed_ID and tile:canHarvest() and bot:getWorld():hasAccess(tile.x, tile.y) > 0 and bot:isInWorld(worldfarm) and inventory:getItemCount(Block_ID) < Target_Block then
                direction = "right"
                coordinatY = tile.y
                goto retryharvest
            end
        end
    end
    bot.auto_collect = false
    sleep(100)
end

function buypack()
    if not bot:isInWorld() then
        otw(worldpack, doorpack)
        sleep(100)
    end
    while bot:getInventory().slotcount < 36 do
        reconnect(worldpack, doorpack, bot.x, bot.y, "normal")
        bot:buy("upgrade_backpack")
        sleep(3200)
    end
    local firstbotgem = bot.gem_count
    while bot.gem_count > Price_Pack do
        reconnect(worldpack, doorpack, bot.x, bot.y, "normal")
        bot:buy(Name_Pack)
        sleep(3200)
        if bot.gem_count < firstbotgem then
            profitpacks = profitpacks + 1
            firstbotgem = bot.gem_count
        end
        if inventory:getItemCount(List_Pack[1]) >= Min_Pack then
            otw(worldpack, doorpack)
            sleep(100)
            storeitem("pack", worldpack, doorpack)
            sleep(100)
        end
    end
end

function Dynamicping()
    local ping = bot:getPing()
    if ping < 70 then
        return math.random(180, 190)
    elseif ping >= 70 and ping <= 79 then
        return 180 + (ping - 70)
    else
        return 180 + (ping - 70)
    end
end

bot.auto_reconnect = false
sleep(50)
bot.auto_expand_inventory = true
sleep(50)
bot.collect_range = 3
sleep(50)
bot.collect_interval = 205
sleep(50)
bot.object_collect_delay = 180
sleep(50)
bot.auto_collect = false
sleep(50)
bot.move_interval = Move_Interval
sleep(50)
bot.move_range = Move_Range
sleep(50)
if Ignore_Gems then
    bot.ignore_gems = true
    sleep(50)
end
while true do
    otwfarm()
    sleep(100)
    if inventory:getItemCount(Seed_ID) >= Target_Seed then
        bot.auto_collect = false
        sleep(100)
        otw(worldseed, doorseed)
        sleep(100)
        storeitem("seed", worldseed, doorseed)
    end
    if inventory:getItemCount(Block_ID) < Target_Block then
        if not bot:isInWorld(worldfarm) then
            otwfarm()
            sleep(100)
        end
        bot.auto_collect = true
        sleep(100)
        harvest(worldfarm, doorfarm)
    end
    if inventory:getItemCount(Block_ID) >= Target_Block then
        bot.auto_collect = false
        sleep(100)
        otwdrop()
        sleep(100)
        storeitem("block", worldDrop, worldDropID)
    end
    if Buy_Pack then
        if bot.gem_count >= Buy_When or inventory:getItemCount(List_Pack[1]) >= Min_Pack then
            bot.auto_collect = false
            sleep(100)
            buypack()
        end
    end
end