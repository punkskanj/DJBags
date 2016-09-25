local NAME, ADDON = ...

local MSQ = nil

if LibStub then
    MSQ = LibStub("Masque", true)
end

local item = {}

function ADDON:NewItem(bagContainer, slot)
    local bag = bagContainer:GetID()
    local button = CreateFrame('Button', string.format('DJBagsItemButton_%d_%d', bag, slot), bagContainer,
        bag == BANK_CONTAINER and 'BankItemButtonGenericTemplate' or
                bag == REAGENTBANK_CONTAINER and 'ReagentBankItemButtonGenericTemplate' or
                'ContainerFrameItemButtonTemplate'
    )

    ADDON:CreateAddon(button, item, slot)

    return button
end

function item:Init(slot)
    self:SetID(slot)

    self.quest = _G[self:GetName() .. "IconQuestTexture"]
    self.cooldown = _G[self:GetName() .. "Cooldown"]
    self.itemLevel = self:CreateFontString(self:GetName() .. 'ItemLevel', 'ARTWORK', 'NumberFontNormal')
    self.itemLevel:SetPoint('TOPLEFT', 2, -2)

    if MSQ then
        local myGroup = MSQ:Group(NAME)
        myGroup:AddButton(self, {
            Button = self,
            Border = self.IconBorder,
            Icon = self.icon or _G[self:GetName().."IconTexture"],
        })
    end

    self:HookScript('OnClick', self.OnClick)
end

function item:OnClick(button)
    if self.id then
        if IsAltKeyDown() and button == 'RightButton' and DJBagsNewItems[self:GetParent():GetID()..'_'..self:GetID()] then
            C_NewItems:ClearAll()
            DJBagsNewItems[self:GetParent():GetID()..'_'..self:GetID()] = nil
            ADDON.events:Fire('DJBagsItemCleared')
        elseif IsAltKeyDown() and button == 'RightButton' then

        end
    end
end

--region Update Magic

local function UpdateQuest(self, isQuestItem, questId, isActive)
    if (questId and not isActive) then
        self.quest:SetTexture(TEXTURE_ITEM_QUEST_BANG)
        self.quest:Show()
    elseif (questId or isQuestItem) then
        self.quest:SetTexture(TEXTURE_ITEM_QUEST_BORDER)
        self.quest:Show()
    else
        self.quest:Hide()
    end
end

local function UpdateNewItemAnimations(self, isNewItem, isBattlePayItem, quality)
    if (isNewItem) then
        if (isBattlePayItem) then
            self.NewItemTexture:Hide()
            self.BattlepayItemTexture:Show()
        else
            if (quality and NEW_ITEM_ATLAS_BY_QUALITY[quality]) then
                self.NewItemTexture:SetAtlas(NEW_ITEM_ATLAS_BY_QUALITY[quality]);
            else
                self.NewItemTexture:SetAtlas("bags-glow-white");
            end
            self.BattlepayItemTexture:Hide();
            self.NewItemTexture:Show();
        end
        if (not self.flashAnim:IsPlaying() and not self.newitemglowAnim:IsPlaying()) then
            self.flashAnim:Play();
            self.newitemglowAnim:Play();
        end
    else
        self.BattlepayItemTexture:Hide();
        self.NewItemTexture:Hide();
        if (self.flashAnim:IsPlaying() or self.newitemglowAnim:IsPlaying()) then
            self.flashAnim:Stop();
            self.newitemglowAnim:Stop();
        end
    end
end

local function UpdateFiltered(self, filtered, shouldDoRelicChecks, itemID)
    if (filtered) then
        self.searchOverlay:Show();
    else
        self.searchOverlay:Hide();
        if shouldDoRelicChecks then
            ContainerFrame_ConsiderItemButtonForRelicTutorial(self, itemID);
        end
    end
end

local function UpdateILevel(self, equipable, quality, level)
    if equipable then
        if quality and quality >= LE_ITEM_QUALITY_COMMON then
            self.itemLevel:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b)
        else
            self.itemLevel:SetVertexColor(1, 1, 1, 1)
        end
        self.itemLevel:SetText(level)
        self.itemLevel:Show()
    else
        self.itemLevel:Hide()
    end
end

local function UpdateCooldown(self)
    if not GetContainerItemID(self:GetParent():GetID(), self:GetID()) then
        self.cooldown:Hide()
        return
    end

    local start, duration, enable = GetContainerItemCooldown(self:GetParent():GetID(), self:GetID());
    CooldownFrame_Set(self.cooldown, start, duration, enable);
    if (duration > 0 and enable == 0) then
        SetItemButtonTextureVertexColor(self, 0.4, 0.4, 0.4);
    else
        SetItemButtonTextureVertexColor(self, 1, 1, 1);
    end
end

function item:Update()
    local texture, count, locked, quality, _, _, link, filtered, _, id = GetContainerItemInfo(self:GetParent():GetID(), self:GetID())
    local equipable = IsEquippableItem(id)

    local name, level, classId, class, subClass
    if id then
        name, _, _, level, _, class, subClass, _, _, _, _, classId = GetItemInfo(id)
    end
    local isEquipment = equipable or classId == LE_ITEM_CLASS_ARMOR or classId == LE_ITEM_CLASS_WEAPON

    self.id = id
    self.name = name or ''
    self.quality = quality or 0
    self.ilevel = level or 0
    self.link = link
    self.classId = classId
    self.class = class
    self.subClass = subClass
    self.count = id and (count or 1) or (self.count or 1)
    self.hasItem = nil

    if isEquipment then
        level = DJBagsTooltip:GetItemLevel(self:GetParent():GetID(), self:GetID()) or level
    elseif classId == LE_ITEM_CLASS_CONTAINER then
        -- TODO set count to number of slots
    end

    UpdateILevel(self, equipable, quality, level)
    if ADDON:IsBankBag(self:GetParent():GetID()) then
        BankFrameItemButton_Update(self)
    else
        local isQuestItem, questId, isActive = GetContainerItemQuestInfo(self:GetParent():GetID(), self:GetID())
        local isNewItem = C_NewItems.IsNewItem(self:GetParent():GetID(), self:GetID())
        local isBattlePayItem = IsBattlePayItem(self:GetParent():GetID(), self:GetID())
        local shouldDoRelicChecks = not BagHelpBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH)

        self.hasItem = true

        if quality then
            if quality >= LE_ITEM_QUALITY_COMMON and BAG_ITEM_QUALITY_COLORS[quality] then
                self.IconBorder:Show();
                self.IconBorder:SetVertexColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
            else
                self.IconBorder:Hide();
            end
        else
            self.IconBorder:Hide();
        end

        SetItemButtonTexture(self, texture)
--        SetItemButtonQuality(self, quality, id)
        SetItemButtonCount(self, count)
        SetItemButtonDesaturated(self, locked)
        UpdateQuest(self, isQuestItem, questId, isActive)
        UpdateNewItemAnimations(self, isNewItem, isBattlePayItem, quality)
        UpdateFiltered(self, filtered, shouldDoRelicChecks, id)
        UpdateCooldown(self)
    end
end

function item:UpdateCooldown()
    UpdateCooldown(self)
end

function item:UpdateSearch()
    local _, _, _, _, _, _, _, filtered, _, id = GetContainerItemInfo(self:GetParent():GetID(), self:GetID())
    local shouldDoRelicChecks = not BagHelpBox:IsShown() and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ARTIFACT_RELIC_MATCH)
    self:SetFiltered(filtered, shouldDoRelicChecks)
end

function item:UpdateLock()
    local locked = select(3, GetContainerItemInfo(self:GetParent():GetID(), self:GetID()))
    SetItemButtonDesaturated(self, locked);
end

function item:SetFiltered(filtered, shouldDoRelicChecks)
    UpdateFiltered(self, filtered, shouldDoRelicChecks, self.id)
end

function item:IncrementCount(count)
    if self.count == 0 then
        self.count = 1
    end
    count = count == 0 and 1 or count or 1

    self.count = self.count + count
    SetItemButtonCount(self, self.count)
end

--endregion