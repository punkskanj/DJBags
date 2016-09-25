local NAME, ADDON = ...

local core = {}

function core:ADDON_LOADED(name)
    if name ~= NAME then return end

    DJBagsNewItems = DJBagsNewItems or {}

    ADDON.events:Remove('ADDON_LOADED', self)
end

ADDON.events:Add('ADDON_LOADED', core)

--region Bag commands

ToggleAllBags = function()
    if DJBagsBagContainer:IsVisible() then
        DJBagsBagContainer:Hide()
    else
        DJBagsBagContainer:Show()
    end
end

local oldToggle = ToggleBag
ToggleBag = function(id)
    if id < 5 and id > -1 then
        if DJBagsBagContainer:IsVisible() then
            DJBagsBagContainer:Hide()
        else
            DJBagsBagContainer:Show()
        end
    else
        oldToggle(id)
    end
end

ToggleBackpack = function()
    if DJBagsBagContainer:IsVisible() then
        DJBagsBagContainer:Hide()
    else
        DJBagsBagContainer:Show()
    end
end

OpenAllBags = function()
    DJBagsBagContainer:Show()
end

OpenBackpack = function()
    DJBagsBagContainer:Show()
end

CloseAllBags = function()
    DJBagsBagContainer:Hide()
end

CloseBackpack = function()
    DJBagsBagContainer:Hide()
end

--endregion

SLASH_DJBAGS1, SLASH_DJBAGS2, SLASH_DJBAGS3, SLASH_DJBAGS4 = '/djb', '/dj', '/djbags', '/db';
function SlashCmdList.DJBAGS(msg, editbox)
    for k,v in pairs(_G) do
        if string.match(tostring(v), 'Artifact Power') then
            print(k, v)
        end
    end
end

SLASH_RL1 = '/rl';
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end