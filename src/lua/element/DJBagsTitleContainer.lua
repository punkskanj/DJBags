local NAME, ADDON = ...

function ADDON:NewTitleContainer(type, title)
    local container = CreateFrame('Frame', string.format('DJBagsTitleContainer_%s_%s', type, title), UIParent, 'DJBagsTitleContainerTemplate')
    container.type = type
    container.vert = false
    container.max = 10
    container.scaled = true
    container.name.text = title

    container.items = {}

    function container:Update()
        self.items = {}
        self.name:SetText(self.name.text)
        self:SetSize(0, 0)
    end

    function container:Add(item)
        if self.name.text == EMPTY and #self.items >= 1 then
            item:Hide()
            self.items[#self.items]:IncrementCount(item.count)
            return
        end
        tinsert(self.items, item)

        local rows = math.ceil(#self.items / self.max)
        local col = (#self.items - 1) % self.max
        local x = col * item:GetWidth() + 5 * (col + 1)
        local y = (rows - 1) * item:GetHeight() + rows * 5

        item:ClearAllPoints()
        item:SetPoint('TOPLEFT', self, 'TOPLEFT', x, -y - self.name:GetHeight() - 5)
        item:Show()

        self:SetSize(math.min(#self.items, self.max) * item:GetWidth() + math.min(#self.items, self.max) * 5 + 5, rows * item:GetHeight() + rows * 5 + 5 + self.name:GetHeight() + 5)
    end

    function container:IsEmpty()
        return #self.items <= 0
    end

    return container
end