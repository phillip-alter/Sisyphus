---
--- DB Creation
---
--- db:
--- item number (for ordering on list)
--- text
--- t/f on whether the checkbox is checked
--- the last time it was checked

if not ToDoErDB then
    ToDoErDB = {}
end

if not ToDoErGlobalDB then
    ToDoErGlobalDB = {}
end

---
--- Init Text 
---

print("ToDoEr initialized. Used /todoer or /tde to open menu.")

---
--- Frame Creation
--- 

local listFrame = CreateFrame("Frame","ToDoErFrame",UIParent,"BasicFrameTemplateWithInset")
listFrame:SetSize(350,200)
listFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
listFrame.TitleBg:SetHeight(30)
listFrame.title = listFrame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
listFrame.title:SetPoint("TOPLEFT",listFrame.TitleBg,"TOPLEFT",5,-3)
listFrame.title:SetText("ToDoEr")
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
listFrame.player:SetPoint("CENTER",listFrame,"TOP",0,-50)
listFrame.player:SetText("Character: " .. UnitName("player") .. " (Level " .. UnitLevel("player") .. ")")

---
--- Add Tasks
---

local textBox = CreateFrame("EditBox","TextAdd",listFrame,"InputBoxTemplate")
textBox:SetSize(275,35)
textBox:SetPoint("CENTER",listFrame.player,"TOP",0,-35)
textBox:SetMovable(false)
textBox:SetMaxLetters(255)
textBox:SetAutoFocus(false)


local addButton = CreateFrame("Button","ToDoErAddButton",listFrame, "UIPanelButtonTemplate")
addButton:SetSize(100,30)
addButton:SetPoint("CENTER",textBox,0,-40)
addButton:SetText("Add Task")
addButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Add a task to this character only.",nil,nil,nil,nil,true)
end)
addButton:SetScript("OnClick",function()
    local text = textBox:GetText()
    AddItem(text)
    textBox:SetText("")
end)



-- Frame for displaying tasks
--- each item in frame:
--- checkbox (may or may not slash-through)
--- textbox (may or may not be editable)
--- delete button
--- up arrow to move up on list
--- down arrow to move down on list 

local displayFrame = CreateFrame("Frame","ListDisplayFrame",UIParent,"BasicFrameTemplateWithInset")
displayFrame:SetSize(200,250)
displayFrame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",0,-150)
displayFrame.TitleBg:SetHeight(30)
displayFrame.title = displayFrame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
displayFrame.title:SetPoint("TOPLEFT",displayFrame.TitleBg,"TOPLEFT",5,-3)
displayFrame.title:SetText("Tasks")
displayFrame:EnableMouse(true)
displayFrame:SetMovable(true)
displayFrame:SetResizable(true)
displayFrame:SetAlpha(0.33)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart",function(self)
    self:StartMoving()
end)
displayFrame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
end)


local showButton = CreateFrame("Button","ToDoErShowButton",listFrame, "UIPanelButtonTemplate")
showButton:SetSize(110,30)
showButton:SetPoint("BOTTOMRIGHT",listFrame,-10,10)
showButton:SetText("Show/Hide List")
showButton:SetScript("OnClick", function()
    if not displayFrame:IsShown() then
        displayFrame:Show()
    else 
        displayFrame:Hide()
    end
end)


function AddItem(text)
    if text and text ~= "" then
        local taskData = {
            text = text,
            checked = false,
            lastChecked = 0
        }
        table.insert(ToDoErDB,taskData)
        --UpdateList()
        -- not yet implemented
    end
end

function RemoveItem(id)
    -- remove item from pinned list
    -- remove item from db
    -- update frame
end

function MoveUp()
    -- swap this item and previous item, ie swap [1] for [0]
    -- update frame
end

function MoveDown()
    -- swap this item and next item, ie swap [0] for [1]
    -- update frame
end

function UnCheckAll()
    -- set all items to unchecked
end


function UpdateList()
    --todo 
end

---
--- QOL Features
---

--Slash commands for adding/deleting/clearing task list

-- local function NewDailyReset()
--     -- compare dates of checks to set time (ie next day at 10 AM PT)
--     -- uncheck daily checkboxes
-- end

-- local function NewWeeklyReset()
--     -- compare dates of checks to set time (Tuesday at 9 AM PT)
--     -- uncheck weekly checkboxes
-- end

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

SLASH_TODOERRESET1 = "/tdereset"
SlashCmdList["TODOERRESET"] = function()
    ToDoErDB = {}
end

table.insert(UISpecialFrames, "ToDoErFrame")