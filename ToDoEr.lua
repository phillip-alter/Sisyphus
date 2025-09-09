---
--- DB Creation
---

if not ToDoErDB then
    ToDoErDB = {}
end

if not ToDoErGlobalDB then
    ToDoErGlobalDB = {}
end

---
--- init DB counters
---

if not ToDoErDB.Count then
    ToDoErDB.Count = 0
end

if not ToDoErGlobalDB.Count then
    ToDoErGlobalDB.Count = 0
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
--- Button to Add Tasks
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
    GameTooltip:SetText("Add a task to this character.",nil,nil,nil,nil,true)
end)



-- Frame for displaying tasks
--- each item in frame:
--- checkbox (may or may not slash-through)
--- textbox (may or may not be editable)
--- delete button
--- up arrow to move up on list
--- down arrow to move down on list 

local function AddItem(text)
    -- add checkbox 
    -- add text box
    -- add task id and text to db
    -- add delete button
    -- add up arrow
    -- add down arrow
end

local function RemoveItem(id)
    -- remove item from pinned list
    -- remove item from db
    -- update frame
end

local function MoveUp()
    -- swap this item and previous item, ie swap [1] for [0]
    -- update frame
end

local function MoveDown()
    -- swap this item and next item, ie swap [0] for [1]
    -- update frame
end

local function UnCheckAll()
    -- set all items to unchecked
end

---
--- QOL Features
---


local function NewDailyReset()
    -- compare dates of checks to set time (ie next day at 10 AM PT)
    -- uncheck daily checkboxes
end

local function NewWeeklyReset()
    -- compare dates of checks to set time (Tuesday at 9 AM PT)
    -- uncheck weekly checkboxes
end



--- db:
--- item number (for ordering on list)
--- text
--- t/f on whether the checkbox is checked
--- the last time it was checked


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

table.insert(UISpecialFrames, "ToDoErFrame")