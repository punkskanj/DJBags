local NAME, ADDON = ...

function ADDON:CreateAddon(obj, tbl, ...)
    for k, v in pairs(tbl) do
        obj[k] = v
    end

    if obj.Init then
        obj:Init(...)
    end
end

function ADDON:IsBankBag(id)
    if id == BANK_CONTAINER or id == REAGENTBANK_CONTAINER then
        return true
    end
    return false
end