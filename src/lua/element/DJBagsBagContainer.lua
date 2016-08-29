local NAME, ADDON = ...

local bag = {}
bag.__index = bag

function DJBagsBagContainer_OnLoad(self)
    self.bags = { 0, 1, 2, 3, 4 }
    self.formatter = 2
    ADDON:MakeMoveable(self)

    self.type = DJBagsContainerType_BAG
    self.items = {}
    self.containers = {}
    ADDON.events:Add('PLAYER_ENTERING_WORLD', bag)
    ADDON.events:Add('DJBagsItemCleared', bag)
end

function DJBagsBagContainer_OnShow(self)
    ADDON:UpdateBag(self)
    bag:BAG_UPDATE_DELAYED()

    ADDON.events:Add('INVENTORY_SEARCH_UPDATE', bag)
    ADDON.events:Add('BAG_UPDATE_COOLDOWN', bag)
    ADDON.events:Add('ITEM_LOCK_CHANGED', bag)
    ADDON.events:Add('BAG_UPDATE_DELAYED', bag)
    ADDON.events:Add('DJBAGS_BAG_HOVER', bag)
end

function DJBagsBagContainer_OnHide(self)
    ADDON.events:Remove('INVENTORY_SEARCH_UPDATE', bag)
    ADDON.events:Remove('BAG_UPDATE_COOLDOWN', bag)
    ADDON.events:Remove('ITEM_LOCK_CHANGED', bag)
    ADDON.events:Remove('BAG_UPDATE_DELAYED', bag)
    ADDON.events:Remove('DJBAGS_BAG_HOVER', bag)
end

function DJBagsMainBar_OnClearNewItems(self)
    C_NewItems:ClearAll()
    DJBagsNewItems = {}
    ADDON:UpdateBag(DJBagsBagContainer)
end

function bag:DJBagsItemCleared()
    ADDON:UpdateBag(DJBagsBagContainer)
end

function bag:PLAYER_ENTERING_WORLD()
    ADDON.events:Add('BAG_UPDATE', self)
end

function bag:BAG_UPDATE(bag)
    if ADDON:UpdateItemsForBags({ bag }) then
        ADDON:UpdateBag(DJBagsBagContainer)
    end
end

function bag:INVENTORY_SEARCH_UPDATE()
    ADDON:UpdateSearchForbags({ 0, 1, 2, 3, 4 })
end

function bag:BAG_UPDATE_COOLDOWN()
    ADDON:UpdateCooldownForBags({ 0, 1, 2, 3, 4 })
end

function bag:ITEM_LOCK_CHANGED(bag, slot)
    if bag then
        if bag >= 0 and bag <= NUM_BAG_SLOTS and slot then
            ADDON.cache:GetItem(bag, slot):UpdateLock()
        end

        if ContainerIDToInventoryID(1) == bag then
            DJBagsBagContainer.mainBar.bagBar['bag1']:Update()
        elseif ContainerIDToInventoryID(2) == bag then
            DJBagsBagContainer.mainBar.bagBar['bag2']:Update()
        elseif ContainerIDToInventoryID(3) == bag then
            DJBagsBagContainer.mainBar.bagBar['bag3']:Update()
        elseif ContainerIDToInventoryID(4) == bag then
            DJBagsBagContainer.mainBar.bagBar['bag4']:Update()
        end
    end
end

function bag:BAG_UPDATE_DELAYED()
    if DJBagsBagContainer.mainBar.bagBar then
        for i = 1, NUM_BAG_SLOTS do
            DJBagsBagContainer.mainBar.bagBar['bag'..i]:Update()
        end
    end
end