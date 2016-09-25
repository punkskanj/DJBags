local NAME, ADDON = ...

local containerSorter = function(A, B)
    if A.name.text == EMPTY then
        return false
    elseif B.name.text == EMPTY then
        return true
    elseif A.name.text == NEW then
        return true
    elseif B.name.text == NEW then
        return false
    elseif A.name.text == BAG_FILTER_JUNK then
        return true
    elseif B.name.text == BAG_FILTER_JUNK then
        return false
    else
        return A.name.text < B.name.text
    end
end

local itemSorter = function(A, B)
    if A.quality == B.quality then
        if A.ilevel == B.ilevel then
            if A.name == B.name then
                return A.count > B.count
            end
            return A.name < B.name
        end
        return A.ilevel > B.ilevel
    end
    return A.quality > B.quality
end

ADDON.formatter[2] = function(container)
    table.sort(container.items, itemSorter)

    for cont in pairs(container.containers) do
        cont:Update()
    end

    for _, item in pairs(container.items) do
        local cont = ADDON.cache:GetTitleContainer(container.type, ADDON:GetItemContainerTitle(item))
        if not container.containers[cont] then
            container.containers[cont] = true
            cont:Update()
        end

        cont:Add(item)
    end

    local h = 5
    local x = 5
    local mH = 5
    local mW = 5
    local cnt = 0
    local lastH = 5
    for cont in ADDON:PairsByKey(container.containers, containerSorter) do
        local numItems = cont.name:GetText() == EMPTY and math.min(#cont.items, 1) or #cont.items
        if numItems == 0 then
            cont:Hide()
        else
            if cnt ~= 0 and (cnt + numItems) > 10 then
                x = 5
                h = h + mH + 5
                cnt = 0
                mH = 5
            end

            cont:ClearAllPoints()
            cont:SetPoint('TOPLEFT', x, -h)
            cont:Show()

            mH = math.max(mH, cont:GetHeight())
            mW = math.max(mW, x + cont:GetWidth())
            x = x + 5 + cont:GetWidth()

            cnt = cnt + numItems
            lastH = cont:GetHeight()
        end
    end

    container:SetSize(mW + 5,
        (h + lastH) + 5)
end