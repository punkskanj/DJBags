local NAME, ADDON = ...

SLASH_DJBAGS1, SLASH_DJBAGS2, SLASH_DJBAGS3, SLASH_DJBAGS4 = '/djb', '/dj', '/djbags', '/db';
function SlashCmdList.DJBAGS(msg, editbox)
    local item = ADDON.cache:GetItem(0, 1)
    item:Update()
    item:ClearAllPoints()
    item:SetPoint('CENTER', UIParent)
    item:Show()
end

SLASH_RL1 = '/rl';
function SlashCmdList.RL(msg, editbox)
    ReloadUI()
end