local NAME, ADDON = ...

ADDON.cache = {}
ADDON.cache.__index = ADDON.cache

ADDON.cache.bags = {}
ADDON.cache.container = {}

function ADDON.cache:GetItem(bagIndex, slot)
    local bag = self:GetBagContainer(bagIndex)
    bag.items = bag.items or {}
    bag.items[slot] = bag.items[slot] or ADDON:NewItem(bag, slot)
    return bag.items[slot]
end

function ADDON.cache:GetBagContainer(bag)
    self.bags[bag] = self.bags[bag] or CreateFrame('Frame', string.format('DJBagsBagContainer_%d', bag), UIParent)
    if not self.bags[bag]:GetID() ~= bag then
        self.bags[bag]:SetID(bag)

        if bag < 5 and bag > -1 then
            self.bags[bag]:SetParent(DJBagsBagContainer)
        end
    end
    return self.bags[bag]
end

function ADDON.cache:GetTitleContainer(type, title)
    self.container[type] = self.container[type] or {}
    self.container[type][title] = self.container[type][title] or ADDON:NewTitleContainer(type, title)

    if DJBagsContainerType_BAG == type then
        self.container[type][title]:SetParent(DJBagsBagContainer)
    end

    return self.container[type][title]
end