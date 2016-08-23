local NAME, ADDON = ...

ADDON.cache = {}
ADDON.cache.__index = ADDON.cache

ADDON.cache.bags = {}

function ADDON.cache:GetItem(bagIndex, slot)
    local bag = self:GetBagContainer(bagIndex)
    bag.items = bag.items or {}
    bag.items[slot] = bag.items[slot] or ADDON:NewItem(bag, slot)
    return bag.items[slot]
end

function ADDON.cache:GetBagContainer(bag)
    self.bags[bag] = self.bags[bag] or CreateFrame('Frame', string.format('DJBagsBagContainer_%d', bag), UIParent)
    if not self.bags[bag]:GetID() then
        self.bags[bag]:SetID(bag)
    end
    return self.bags[bag]
end