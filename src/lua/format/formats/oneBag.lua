local NAME, ADDON = ...

ADDON.formatter[1] = function(container)
    local items = container.items

    if #items == 0 then return end

    local current = nil
    local firstInRow
    local cnt = 0
    for _, item in pairs(items) do
        item:Show()
        if current == nil then
            item:SetPoint('TOPLEFT', container, 'TOPLEFT', 5, -5)
            firstInRow = item
        elseif cnt % 8 ~= 0 then
            item:SetPoint('TOPLEFT', current, 'TOPRIGHT', 5, 0)
        else
            item:SetPoint('TOPLEFT', firstInRow, "BOTTOMLEFT", 0, -5)
            firstInRow = item
        end
        current = item
        cnt = cnt + 1
    end

    local columns = math.ceil(#items / 8)
    container:SetSize(items[1]:GetWidth() * 8 + 5 * 7 + 10, items[1]:GetHeight() * columns + (columns - 1) * 5 + 10)
end