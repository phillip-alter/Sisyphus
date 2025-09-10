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

if not ToDoErDB.IsHidden then
    ToDoErDB.IsHidden = false
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
textBox:SetMaxLetters(15)
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
displayFrame:SetWidth(250)
displayFrame:SetHeight(300)
displayFrame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",0,-150)
displayFrame.TitleBg:SetHeight(30)
displayFrame.title = displayFrame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
displayFrame.title:SetPoint("TOPLEFT",displayFrame.TitleBg,"TOPLEFT",5,-3)
displayFrame.title:SetText("Tasks")
displayFrame:EnableMouse(true)
displayFrame:SetMovable(true)
if ToDoErDB.IsHidden == true then
    displayFrame:Hide()
else
    displayFrame:Show()
end
--displayFrame:SetResizable(true)
displayFrame:SetAlpha(0.33)
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart",function(self)
    self:StartMoving()
end)
displayFrame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
end)
displayFrame:SetScript("OnEnter",function(self)
    self:SetAlpha(1)
end)
displayFrame:SetScript("OnLeave",function(self)
    self:SetAlpha(0.33)
end)
displayFrame.taskRows = {}

local showButton = CreateFrame("Button","ToDoErShowButton",listFrame, "UIPanelButtonTemplate")
showButton:SetSize(110,30)
showButton:SetPoint("BOTTOMRIGHT",listFrame,-10,10)
showButton:SetText("Show/Hide List")
showButton:SetScript("OnClick", function()
    if not displayFrame:IsShown() then
        displayFrame:Show()
        ToDoErDB.IsHidden = false
    else 
        displayFrame:Hide()
        ToDoErDB.IsHidden = true
    end
end)

local uncheckButton = CreateFrame("Button", "ToDoErUncheckButton", listFrame, "UIPanelButtonTemplate")
uncheckButton:SetSize(110, 30)
uncheckButton:SetPoint("RIGHT", showButton, "LEFT", -10, 0)
uncheckButton:SetText("Uncheck All")
uncheckButton:SetScript("OnClick", function()
    UnCheckAll()
end)
uncheckButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Resets the checked status of all tasks on this character's list.", nil, nil, nil, nil, true)
end)
uncheckButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

function UpdateList()
    -- clear any old task rows that are currently displayed
    for i, row in ipairs(displayFrame.taskRows) do
        -- hide the frame so the game can clean it up
        row:Hide() 
    end

    -- reset tracking table
    displayFrame.taskRows = {} 

    --this is the UI element we will anchor the top of list to.
    local anchor = displayFrame.TitleBg

    -- loop through database and create a UI row for each task
    for i, taskData in ipairs(ToDoErDB) do
        local row = CreateFrame("Frame", "ToDoErTaskRow" .. i, displayFrame)
        row:SetSize(displayFrame:GetWidth() - 20, 25) 
        
        -- anchor the very first row to the title, and every row after that to the one that came before it.
        row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5)

        local checkBox = CreateFrame("CheckButton", "ToDoErCheckBox" .. i, row, "UICheckButtonTemplate")
        checkBox:SetSize(25, 25)
        checkBox:SetPoint("LEFT", 5, 0)
        checkBox:SetChecked(taskData.checked)
        checkBox:SetScript("OnEnter",function()
            displayFrame:SetAlpha(1)
        end)

        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("LEFT", checkBox, "RIGHT", 5, 0)
        text:SetText(taskData.text)
        text:SetJustifyH("LEFT")
        if checkBox:GetChecked() then
            text:SetTextColor(0.5,0.5,0.5)
        else 
            text:SetTextColor(1,1,1)
        end

        checkBox:SetScript("OnClick", function(self)
            -- when clicked, update the data in the database
            taskData.checked = self:GetChecked()
            taskData.lastChecked = time() -- current time
            if self:GetChecked() then
                text:SetTextColor(0.5,0.5,0.5)
            else 
                text:SetTextColor(1,1,1)
            end
            --testing purposes
            --print("Task '" .. taskData.text .. "' checked status is now: " .. tostring(taskData.checked))
        end)

        local deleteButton = CreateFrame("Button", "ToDoErDeleteButton" .. i, row)
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", -5, 0)
        deleteButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        deleteButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
        deleteButton:SetScript("OnClick", function()
            RemoveItem(i) 
        end)
        deleteButton:SetScript("OnEnter", function()
            displayFrame:SetAlpha(1)
        end)

        local moveDownButton = CreateFrame("Button", "ToDoErDownButton" .. i, row)
        moveDownButton:SetSize(20, 20)
        moveDownButton:SetPoint("RIGHT", deleteButton, "LEFT", 0, 0) 
        moveDownButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
        moveDownButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
        moveDownButton:SetScript("OnClick", function()
            MoveDown(i)
        end)
        moveDownButton:SetScript("OnEnter", function()
            displayFrame:SetAlpha(1)
        end)

        local moveUpButton = CreateFrame("Button", "ToDoErUpButton" .. i, row)
        moveUpButton:SetSize(20, 20)
        moveUpButton:SetPoint("RIGHT", moveDownButton, "LEFT", 0, 0) 
        moveUpButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
        moveUpButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
        moveUpButton:SetScript("OnClick", function()
            MoveUp(i)
        end)
        moveUpButton:SetScript("OnEnter", function()
            displayFrame:SetAlpha(1)
        end)

        -- add the row to tracking table and set it as the new anchor for the *next* row in the loop
        table.insert(displayFrame.taskRows, row)
        anchor = row
    end
    if ToDoErDB.IsHidden then
        displayFrame:Hide()
    end
end

function AddItem(text,isDaily,isWeekly)
    if text and text ~= "" then
        local taskData = {
            text = text,
            checked = false,
            lastChecked = 0
        }
        table.insert(ToDoErDB,taskData)
        UpdateList()
    end
end

function RemoveItem(id)
    if id then
        table.remove(ToDoErDB,id)
    end
    UpdateList()
end

function MoveUp(id)
    if id and id ~= 1 then
        local temp = ToDoErDB[id-1]
        ToDoErDB[id-1] = ToDoErDB[id]
        ToDoErDB[id] = temp
    end
    UpdateList()
end

function MoveDown(id)
    if id and id ~= table.maxn(ToDoErDB) then
        local temp = ToDoErDB[id+1]
        ToDoErDB[id+1] = ToDoErDB[id]
        ToDoErDB[id] = temp
    end
    UpdateList()
end

function UnCheckAll()
    for _,taskData in ipairs(ToDoErDB) do
        taskData.checked = false
    end
    UpdateList()
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

---TODO:
--- * scroll bar for more tasks
--- * variable width/height?
--- * add checkbox for daily/weekly
--- * implement account-wide list
--- ** possibly separate by categories
--- * chillax for a min, idk
--- * finished tasks go on bottom?

--eventframe to update list when the addon is fully loaded
local eventHandlerFrame = CreateFrame("Frame")
eventHandlerFrame:RegisterEvent("ADDON_LOADED")
eventHandlerFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "ToDoEr" then 
        print("ToDoEr has loaded. Drawing initial list.")
        UpdateList()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

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
    UpdateList()
end

---
--- Designating special frames
---

table.insert(UISpecialFrames, "ToDoErFrame")