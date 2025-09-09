---
--- DB Creation
---

if not ToDoErDB then
    ToDoErDB = {}
end

ToDoEr = ToDoEr or {}

---
--- Frame Creation
--- 

local listFrame = CreateFrame("Frame","ToDoErFrame",UIParent,"BasicFrameTemplateWithInset")
listFrame:SetSize(350,500)
listFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
listFrame.TitleBg:SetHeight(30)
listFrame.title = listFrame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
listFrame.title:SetPoint("TOPLEFT",listFrame.TitleBg,"TOPLEFT",5,-3)
listFrame.title:SetText("ToDo 'Er")
listFrame:Hide()
listFrame:EnableMouse(true)
listFrame:SetMovable(true)
listFrame:RegisterForDrag("LeftButton")
listFrame:SetScript("OnDragStart",function(self)
    self:StartMoving()
end)
listFrame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
end)

listFrame.player = listFrame:CreateFontString(nil,"OVERLAY","GameFontNormal")
listFrame.player:SetPoint("TOPLEFT",listFrame,"TOPLEFT",15,-35)
listFrame.player:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")

---
--- Button to Add Tasks
---

local addButton = CreateFrame("Button","ToDoErAddButton",listFrame, "UIPanelButtonTemplate")
addButton:SetSize(100,30)
addButton:SetPoint("TOPLEFT",listFrame.player,"TOPLEFT",0,-15)
addButton:SetText("Add Task")

---
--- Slash Commands
---

SLASH_TODOER1 = "/todoer"
SLASH_TODOER2 = "/tde"
SlashCmdList["TODOER"] = function()
    if listFrame:IsShown() then
        listFrame:Hide()
    else
        listFrame:Show()
    end
end

function ToDoEr:ToggleListFrame()
    if not listFrame:IsShown() then
        listFrame:Show()
    else
        listFrame:Hide()
    end
end

table.insert(UISpecialFrames, "ToDoErFrame")

---
--- Minimap Button
---

local addon = LibStub("AceAddon-3.0"):NewAddon("ToDoEr")
ToDoErMinimapButton = LibStub("LibDBIcon-1.0",true)

local minibutton = LibStub("LibDataBroker-1.1"):NewDataObject("ToDoEr",{
    type = "data source",
    text = "ToDoEr",
    icon = "Interface\\Addons\\ToDoEr\\minimap.tga",
    OnClick = function(self,btn)
        if btn == "LeftButton" then
            ToDoEr:ToggleListFrame()
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then
            return
        end
        tooltip:AddLine("ToDoEr\n\nLeft-Click: Open ToDoEr",nil,nil,nil,nil)
    end,
})

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("ToDoErMinimapPOS",{
        profile = {
            minimap = {
                hide = false,
            },
        },
    })
    ToDoErMinimapButton:Register("ToDoEr",minibutton,self.db.profile.minimap)
end

--ToDoErMinimapButton:Show("ToDoEr")