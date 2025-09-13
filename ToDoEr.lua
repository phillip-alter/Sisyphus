--- ToDoEr
--- A simple task list creator for your character(s)
--- by CeedTheMediocre
--- https://twitch.tv/CeedTheMediocre

---
--- DB Creation/Verification
---

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
--- Frame Creation
--- 

local listFrame = CreateFrame("Frame","ToDoErFrame",UIParent,"BasicFrameTemplateWithInset")
listFrame:SetSize(350,275)
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
textBox:SetMaxLetters(20)
textBox:SetAutoFocus(false)

local isDaily = CreateFrame("CheckButton","DailyCheck",listFrame,"UICheckButtonTemplate")
isDaily:SetSize(25,25)
isDaily:SetPoint("BOTTOMLEFT",textBox,"BOTTOMLEFT",0,-25)
isDaily.text = isDaily:CreateFontString(nil,"OVERLAY","GameFontNormal")
isDaily.text:SetPoint("RIGHT",isDaily,"RIGHT",35,1)
isDaily.text:SetText("Daily")
isDaily:SetChecked(false)

local isWeekly = CreateFrame("CheckButton","WeeklyCheck",listFrame,"UICheckButtonTemplate")
isWeekly:SetSize(25,25)
isWeekly:SetPoint("BOTTOM",isDaily,"BOTTOM",0,-30)
isWeekly.text = isWeekly:CreateFontString(nil,"OVERLAY","GameFontNormal")
isWeekly.text:SetPoint("LEFT",isWeekly,"RIGHT",0,1)
isWeekly.text:SetText("Weekly")
isWeekly:SetChecked(false)

isDaily:SetScript("OnClick", function(self)
    if self:GetChecked() then
        isWeekly:SetChecked(false)
    end
end)

isWeekly:SetScript("OnClick", function(self)
    if self:GetChecked() then
        isDaily:SetChecked(false)
    end
end)

local addButton = CreateFrame("Button","ToDoErAddButton",listFrame, "UIPanelButtonTemplate")
addButton:SetSize(100,30)
addButton:SetPoint("CENTER",textBox,0,-100)
addButton:SetText("Add Task")
addButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
    GameTooltip:SetText("Add a task to this character only.",nil,nil,nil,nil,true)
end)
addButton:SetScript("OnClick",function()
    local text = textBox:GetText()
    AddItem(text,isDaily:GetChecked(),isWeekly:GetChecked())
    textBox:SetText("")
    isDaily:SetChecked(false)
    isWeekly:SetChecked(false)
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
displayFrame.title:SetText("Tasks for " .. UnitName("player"))
displayFrame:EnableMouse(true)
displayFrame:SetMovable(true)
if ToDoErDB.IsHidden == true then
    displayFrame:Hide()
else
    displayFrame:Show()
end
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
            if taskData.daily then 
                text:SetTextColor(0,0.44,0.87)
            elseif taskData.weekly then
                text:SetTextColor(0.65,0.25,1.0)
            else 
                text:SetTextColor(0.1,0.8,0.1)
            end
        end

        checkBox:SetScript("OnClick", function(self)
            -- when clicked, update the data in the database
            taskData.checked = self:GetChecked()
            taskData.lastChecked = time() -- current time
            if self:GetChecked() then
                text:SetTextColor(0.5,0.5,0.5)
            else 
                if taskData.daily then 
                    text:SetTextColor(0,0.44,0.87)
                elseif taskData.weekly then
                    text:SetTextColor(0.65,0.25,1.0)
                else 
                    text:SetTextColor(0.1,0.8,0.1)
                end
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
        if isDaily then
            taskData.daily = true
            if not ToDoErDB.lastResetDayUTC then
                ToDoErDB.lastResetDayUTC = tonumber(date("!%j",GetServerTime()))
            end
        end
        if isWeekly then
            taskData.weekly = true
            if not ToDoErDB.lastWeeklyReset then
                ToDoErDB.lastWeeklyReset = GetServerTime()
            end
        end
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

local function ResetTasks(daily,weekly)
    for _,taskData in ipairs(ToDoErDB) do
        if taskData.daily and daily then
            taskData.checked = false
        elseif taskData.weekly and weekly then
            taskData.checked = false
        end
    end
end

function DailyCheckReset()
    local resetHour = 0
    local region = GetCurrentRegion()
    if region == 1 then
        resetHour = 15
    elseif region == 2 then
        resetHour = 7
    else 
        resetHour = 15 -- fallthrough for now
    end
    local currTime = GetServerTime()
    local currUTCInfo = date("!*t", currTime)
    if ToDoErDB.lastResetDayUTC == nil then
        ToDoErDB.lastResetDayUTC = 0
    end
    -- reset day is yesterday, minus the current time (to get it to 00:00:00), plus the reset hour for the region
    local lastResetDay = currTime - (86400) - (currUTCInfo.hour * 3600 + currUTCInfo.min * 60 + currUTCInfo.sec) + (resetHour * 3600)       
    -- check if it's been longer than the last reset day, and also check if the last reset day in the DB is older than yesterday
    if currTime >= lastResetDay and ToDoErDB.lastResetDayUTC < lastResetDay then
       ResetTasks(true,false)
       ToDoErDB.lastResetDayUTC = lastResetDay
    end
end

function WeeklyCheckReset()
    local resetDay = 3 --tuesday
    local resetHour = 0
    local region = GetCurrentRegion()
    if region == 1 then -- na
        resetHour = 15
    elseif region == 2 then -- eu
        resetHour = 7
    end
    local currTime = GetServerTime()
    if ToDoErDB.lastWeeklyReset == nil then
        ToDoErDB.lastWeeklyReset = 0
    end
    local currUTCInfo = date("!*t", currTime)
    local daysSinceReset = (currUTCInfo.wday - resetDay + 7) % 7
    if daysSinceReset == 0 and currUTCInfo.hour < resetHour then
        daysSinceReset = 7
    end
    local secondsInADay = 86400 -- (24 * 60 * 60)
    local lastResetTimestamp = currTime 
                             - (daysSinceReset * secondsInADay) -- go back to the reset day
                             - (currUTCInfo.hour * 3600 + currUTCInfo.min * 60 + currUTCInfo.sec) -- go back to 00:00:00
                             + (resetHour * 3600) -- add hours to get to 15:00:00 (or 7:00:00 for EU)
    if currTime >= lastResetTimestamp and ToDoErDB.lastWeeklyReset < lastResetTimestamp then
        ResetTasks(false,true)
        ToDoErDB.lastWeeklyReset = lastResetTimestamp
    end
    --print("lastResetTimestamp: " .. lastResetTimestamp .. " currTime: " .. currTime)
end

--eventframe 
local eventHandlerFrame = CreateFrame("Frame")
eventHandlerFrame:RegisterEvent("ADDON_LOADED")
eventHandlerFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "ToDoEr" then 
        print("ToDoEr initialized. Used /todoer or /tde to open menu.")
        DailyCheckReset()
        --print("Daily check ran.")
        WeeklyCheckReset()
        --print("Weekly check ran.")
        UpdateList()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

---
--- Slash Commands
---

SLASH_TODOER1 = "/todoer"
SLASH_TODOER2 = "/tde"
SlashCmdList["TODOER"] = function(msg)
    local cmd = strlower(msg)
    if cmd == "reset" then
        ToDoErDB = {}
        UpdateList()
        print("ToDoEr: Cleaned out list!")
    elseif cmd == "hide" then
        ToDoErDB.IsHidden = true
        displayFrame:Hide()
    elseif cmd == "show" then
        ToDoErDB.IsHidden = false
        displayFrame:Show()
    elseif cmd == "help" then
        print("ToDoEr: /tde: open main window")
        print("ToDoEr: /tde reset: clear everything out")
        print("ToDoEr: /tde hide: hide list")
        print("ToDoEr: /tde show: show list")
    else    
        if listFrame:IsShown() then
            listFrame:Hide()
        else
            listFrame:Show()
        end
    end
end

SLASH_TODOREWINDWEEK1 = "/tderewind"
SlashCmdList["TODOREWINDWEEK"] = function(msg)
    local cmd = strlower(msg)
    if cmd == "lastweek" then
        local secsWeek = 604800
        local weekAgo = GetServerTime() - secsWeek
        ToDoErDB.lastWeeklyReset = weekAgo
    elseif cmd == "yesterday" then
        ToDoErDB.lastResetDayUTC = ToDoErDB.lastResetDayUTC - 1
    else
        ToDoErDB.lastResetDayUTC = 0
        ToDoErDB.lastWeeklyReset = 0
    end
    print("ToDoEr: Rewound! Do a /reload to see changes.")
end

---
--- Designating special frames
---

table.insert(UISpecialFrames, "ToDoErFrame")

---TODO:
--- * scroll bar for more tasks
--- * variable width/height?
--- * add checkbox for daily/weekly
--- * implement account-wide list
--- ** possibly separate by categories
--- * chillax for a min, idk
--- * finished tasks go on bottom?