local NAME, ADDON = ...

function ADDON:CreateAddon(obj, tbl, ...)
    for k, v in pairs(tbl) do
        obj[k] = v
    end

    if obj.Init then
        obj:Init(...)
    end
end

function ADDON:PairsByKey(tbl, sorter)
    local keys = {}
    for k in pairs(tbl) do
        tinsert(keys, k)
    end
    table.sort(keys, sorter)
    local index = 0
    return function()
        index = index + 1
        return keys[index], tbl[keys[index]]
    end
end

function ADDON:Count(table)
    local cnt = 0;

    for _ in pairs(table) do
        cnt = cnt + 1
    end

    return cnt
end

function ADDON:IsBankBag(id)
    if id == BANK_CONTAINER or id == REAGENTBANK_CONTAINER then
        return true
    end
    return false
end

function ADDON:MakeMoveable(container)
    table.insert(UISpecialFrames, container:GetName())
    container:RegisterForDrag("LeftButton")
    container:SetScript("OnDragStart", function(self, ...)
        if self:GetParent() == UIParent then
            self:StartMoving()
        elseif self:GetParent():IsMovable() then
            self:GetParent():StartMoving(...)
        end
    end)
    container:SetScript("OnDragStop", function(self, ...)
        if self:GetParent() == UIParent then
            self:StopMovingOrSizing(...)
        elseif self:GetParent():IsMovable() then
            self:GetParent():StopMovingOrSizing(...)
        end
    end)
    if container:GetParent() == UIParent then
        container:SetUserPlaced(true)
    end
end

function ADDON:UpdateBag(container)
    container.items = ADDON:GetAllBagItems(container.bags)
    ADDON.formatter[container.formatter](container)
end

function ADDON:GetAllBagItems(bags)
    local items = {}
    for _, bag in pairs(bags) do
        local bagSlots = GetContainerNumSlots(bag)

        for slot = 1, bagSlots do
            local item = ADDON.cache:GetItem(bag, slot)
            item:Update()
            item:Show()
            if C_NewItems.IsNewItem(bag, slot) then
                DJBagsNewItems[bag..'_'..slot] = true
            end
            tinsert(items, item)
        end
    end
    return items
end

function ADDON:UpdateItemsForBags(bags)
    local newItem = false
    for _, bag in pairs(bags) do
        for slot = 1, GetContainerNumSlots(bag) do
            local item = ADDON.cache:GetItem(bag, slot)
            local prevId = item.id
            item:Update()

            if not prevId and item.id then
                newItem = true
            end
            if C_NewItems.IsNewItem(bag, slot) then
                DJBagsNewItems[bag..'_'..slot] = true
            end
        end
    end
    return newItem
end

function ADDON:UpdateSearchForbags(bags)
    for _, bag in pairs(bags) do
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateSearch()
        end
    end
end

function ADDON:UpdateCooldownForBags(bags)
    for _, bag in pairs(bags) do
        for slot = 1, GetContainerNumSlots(bag) do
            ADDON.cache:GetItem(bag, slot):UpdateCooldown()
        end
    end
end

function ADDON:GetItemContainerTitle(item)
    local bag = item:GetParent():GetID()
    local slot = item:GetID()

    if item.id then
        local isInSet, setName = GetContainerItemEquipmentSetInfo(bag, slot)

        if item.quality == LE_ITEM_QUALITY_POOR then
            return BAG_FILTER_JUNK
        end

        if isInSet then
            return setName
        end

        if bag >= 0 and bag <= NUM_BAG_SLOTS and (C_NewItems.IsNewItem(bag, slot) or DJBagsNewItems[bag..'_'..slot]) then
            return NEW
        end

        if DJBagsTooltip:IsItemArtifactPower(bag, slot) then
            return ARTIFACT_POWER
        end

        return item.class
    end
    return EMPTY
end