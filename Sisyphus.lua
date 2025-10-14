--- Sisyphus
--- A simple task list creator for your character(s)
--- by CeedTheMediocre
--- https://twitch.tv/CeedTheMediocre
--- https://github.com/phillip-alter

---
--- DB Creation/Verification
---

if not SisyphusDB then
    SisyphusDB = {}
    -- SisyphusDB.IsHidden = true
end

if not SisyphusGlobalDB then
    SisyphusGlobalDB = {}
end

-- print("db's init'd.")

---
--- Frame Creation
--- 

local listFrame = CreateFrame("Frame","SisyphusFrame",UIParent,"BasicFrameTemplateWithInset")
listFrame:SetSize(350,275)
listFrame:SetPoint("CENTER",UIParent,"CENTER",0,0)
listFrame.TitleBg:SetHeight(30)
listFrame.title = listFrame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
listFrame.title:SetPoint("TOPLEFT",listFrame.TitleBg,"TOPLEFT",5,-3)
listFrame.title:SetText("Sisyphus")
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

-- print("ListFrame init'd.")

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

local addButton = CreateFrame("Button","SisyphusAddButton",listFrame, "UIPanelButtonTemplate")
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

-- print("Daily, weekly, add init'd.")

-- Frame for displaying tasks
--- each item in frame:
--- checkbox (may or may not slash-through)
--- textbox (may or may not be editable)
--- delete button
--- up arrow to move up on list
--- down arrow to move down on list

local displayFrame = CreateFrame("Frame","ListDisplayFrame",UIParent)
displayFrame:SetWidth(250)
displayFrame:SetHeight(300)
displayFrame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",10,-150)
displayFrame:EnableMouse(true)
displayFrame:SetMovable(true)
if SisyphusDB.IsHidden == true then
    displayFrame:Hide()
    -- print("hiding at displayFrame!")
else
    displayFrame:Show()
end
displayFrame:RegisterForDrag("LeftButton")
displayFrame:SetScript("OnDragStart",function(self)
    self:StartMoving()
end)
displayFrame:SetScript("OnDragStop",function(self)
    self:StopMovingOrSizing()
end)
displayFrame.taskRows = {}


local backgroundFrame = CreateFrame("Frame","DisplayBackground",displayFrame,"BasicFrameTemplateWithInset")
backgroundFrame:SetAllPoints(true)
backgroundFrame.TitleBg:SetHeight(30)
backgroundFrame.title = backgroundFrame:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
backgroundFrame.title:SetPoint("TOPLEFT",backgroundFrame.TitleBg,"TOPLEFT",5,-3)
backgroundFrame.title:SetText("Tasks for " .. UnitName("player"))


-- print("Display init'd.")

---
--- Scroll frame
--- 

local scrollFrame = CreateFrame("ScrollFrame","DisplayScrollFrame",displayFrame,"UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT",backgroundFrame.TitleBg,"BOTTOMLEFT",0,-5)
scrollFrame:SetPoint("BOTTOMRIGHT",backgroundFrame,"BOTTOMRIGHT",-30,5)

-- print("ScrollFrame init'd.")

-- child frame for scroll
local scrollChild = CreateFrame("Frame","ScrollChildFrame",scrollFrame)
scrollChild:SetWidth(scrollFrame:GetWidth()+30)
scrollChild:SetHeight(1) -- will be adjusted as items are added
scrollFrame:SetScrollChild(scrollChild)

-- print("ScrollChild init'd.")

local showButton = CreateFrame("Button","SisyphusShowButton",listFrame, "UIPanelButtonTemplate")
showButton:SetSize(110,30)
showButton:SetPoint("BOTTOMRIGHT",listFrame,-10,10)
showButton:SetText("Show/Hide List")
showButton:SetScript("OnClick", function()
    if displayFrame:IsShown() then
        displayFrame:Hide()
        SisyphusDB.IsHidden = true
        --print("hiding at showButton!")
    else 
        displayFrame:Show()
        SisyphusDB.IsHidden = false
    end
end)

local uncheckButton = CreateFrame("Button", "SisyphusUncheckButton", listFrame, "UIPanelButtonTemplate")
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

    -- top of list anchors here
    local anchor = scrollChild

    -- loop through database and create a UI row for each task
    for i, taskData in ipairs(SisyphusDB) do
        local row = CreateFrame("Frame", "SisyphusTaskRow" .. i, scrollChild)
        row:SetSize(scrollChild:GetWidth() - 20, 25) 
        -- anchor the very first row to the title, and every row after that to the one that came before it.
        row:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -5)

        local checkBox = CreateFrame("CheckButton", "SisyphusCheckBox" .. i, row, "UICheckButtonTemplate")
        checkBox:SetSize(25, 25)
        checkBox:SetPoint("LEFT", 5, 0)
        checkBox:SetChecked(taskData.checked)

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

        local deleteButton = CreateFrame("Button", "SisyphusDeleteButton" .. i, row)
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("RIGHT", -5, 0)
        deleteButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        deleteButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
        row.delButton = deleteButton
        deleteButton:SetScript("OnClick", function()
            RemoveItem(i) 
        end)

        local moveDownButton = CreateFrame("Button", "SisyphusDownButton" .. i, row)
        moveDownButton:SetSize(20, 20)
        moveDownButton:SetPoint("RIGHT", deleteButton, "LEFT", 0, 0) 
        moveDownButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
        moveDownButton:SetPushedTexture("Interface\\Buttons\\UI-MinusButton-Down")
        row.moveDownButton = moveDownButton
        moveDownButton:SetScript("OnClick", function()
            MoveDown(i)
        end)

        local moveUpButton = CreateFrame("Button", "SisyphusUpButton" .. i, row)
        moveUpButton:SetSize(20, 20)
        moveUpButton:SetPoint("RIGHT", moveDownButton, "LEFT", 0, 0) 
        moveUpButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
        moveUpButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
        row.moveUpButton = moveUpButton
        moveUpButton:SetScript("OnClick", function()
            MoveUp(i)
        end)

        -- add the row to tracking table and set it as the new anchor for the *next* row in the loop
        table.insert(displayFrame.taskRows, row)
        anchor = row
    end
    if SisyphusDB.IsHidden == true then
        displayFrame:Hide()
        --print("hiding at UpdateList!")
    end
end

backgroundFrame:SetAlpha(0.2)

displayFrame:SetScript("OnEnter",function(self)
    backgroundFrame:SetAlpha(1)
    for i,row in ipairs(displayFrame.taskRows) do
        row.delButton:SetAlpha(1)
        row.moveUpButton:SetAlpha(1)
        row.moveDownButton:SetAlpha(1)
    end
end)
displayFrame:SetScript("OnLeave",function(self)
    C_Timer.After(0,function()
        if not self:IsMouseOver() then
            backgroundFrame:SetAlpha(0.2)
        for i,row in ipairs(displayFrame.taskRows) do
            row.delButton:SetAlpha(0.2)
            row.moveUpButton:SetAlpha(0.2)
            row.moveDownButton:SetAlpha(0.2)
        end
        end
    end)
end)

function AddItem(text,isDaily,isWeekly)
    if text and text ~= "" then
        local taskData = {
            text = text,
            checked = false,
            lastChecked = 0
        }
        if isDaily then
            taskData.daily = true
            if not SisyphusDB.lastResetDayUTC then
                SisyphusDB.lastResetDayUTC = tonumber(date("!%j",GetServerTime()))
            end
        end
        if isWeekly then
            taskData.weekly = true
            if not SisyphusDB.lastWeeklyReset then
                SisyphusDB.lastWeeklyReset = GetServerTime()
            end
        end
        table.insert(SisyphusDB,taskData)
        UpdateList()
    end
end

function RemoveItem(id)
    if id then
        table.remove(SisyphusDB,id)
    end
    UpdateList()
end

function MoveUp(id)
    if id and id ~= 1 then
        local temp = SisyphusDB[id-1]
        SisyphusDB[id-1] = SisyphusDB[id]
        SisyphusDB[id] = temp
    end
    UpdateList()
end

function MoveDown(id)
    if id and id ~= table.maxn(SisyphusDB) then
        local temp = SisyphusDB[id+1]
        SisyphusDB[id+1] = SisyphusDB[id]
        SisyphusDB[id] = temp
    end
    UpdateList()
end

function UnCheckAll()
    for _,taskData in ipairs(SisyphusDB) do
        taskData.checked = false
    end
    UpdateList()
end


---
--- QOL Features
---

local function ResetTasks(daily,weekly)
    for _,taskData in ipairs(SisyphusDB) do
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
        resetHour = 14
    elseif region == 2 then
        resetHour = 6
    else 
        resetHour = 14 -- fallthrough for now
    end
    local currTime = GetServerTime()
    local currUTCInfo = date("!*t", currTime)
    if SisyphusDB.lastResetDayUTC == nil then
        SisyphusDB.lastResetDayUTC = 0
    end
    -- reset day is yesterday, minus the current time (to get it to 00:00:00), plus the reset hour for the region
    local lastResetDay = currTime - (86400) - (currUTCInfo.hour * 3600 + currUTCInfo.min * 60 + currUTCInfo.sec) + (resetHour * 3600)
    -- add a day to calc the next reset day
    local nextResetDay = lastResetDay + 86400
    --print("Next reset is " .. date("!*t",nextResetDay))
    -- check if it's been longer than the last reset day, and also check if the last reset day in the DB is older than yesterday
    if currTime >= nextResetDay and SisyphusDB.lastResetDayUTC < nextResetDay then
       ResetTasks(true,false)
       SisyphusDB.lastResetDayUTC = nextResetDay
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
    if SisyphusDB.lastWeeklyReset == nil then
        SisyphusDB.lastWeeklyReset = 0
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
    if currTime >= lastResetTimestamp and SisyphusDB.lastWeeklyReset < lastResetTimestamp then
        ResetTasks(false,true)
        SisyphusDB.lastWeeklyReset = lastResetTimestamp
    end
    --print("lastResetTimestamp: " .. lastResetTimestamp .. " currTime: " .. currTime)
end

--eventframe 
local eventHandlerFrame = CreateFrame("Frame")
eventHandlerFrame:RegisterEvent("ADDON_LOADED")
eventHandlerFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "Sisyphus" then 
        print("Sisyphus initialized. Used /Sisyphus or /sis to open menu.")
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

SLASH_Sisyphus1 = "/Sisyphus"
SLASH_Sisyphus2 = "/sis"
SlashCmdList["Sisyphus"] = function(msg)
    local cmd = strlower(msg)
    if cmd == "reset" then
        SisyphusDB = {}
        UpdateList()
        print("Sisyphus: Cleaned out list!")
    elseif cmd == "hide" then
        SisyphusDB.IsHidden = true
        displayFrame:Hide()
        --print("hiding at slash command!")
    elseif cmd == "show" then
        SisyphusDB.IsHidden = false
        displayFrame:Show()
    elseif cmd == "help" then
        print("Sisyphus: /sis: open main window")
        print("Sisyphus: /sis reset: clear everything out")
        print("Sisyphus: /sis hide: hide list")
        print("Sisyphus: /sis show: show list")
    else    
        if listFrame:IsShown() then
            listFrame:Hide()
        else
            listFrame:Show()
        end
    end
end

--debug funcs
SLASH_TODOREWINDWEEK1 = "/sisrewind"
SlashCmdList["TODOREWINDWEEK"] = function(msg)
    local cmd = strlower(msg)
    if cmd == "lastweek" then
        local secsWeek = 604800
        local weekAgo = GetServerTime() - secsWeek
        SisyphusDB.lastWeeklyReset = weekAgo
    elseif cmd == "yesterday" then
        SisyphusDB.lastResetDayUTC = SisyphusDB.lastResetDayUTC - 86400
    else
        SisyphusDB.lastResetDayUTC = 0
        SisyphusDB.lastWeeklyReset = 0
    end
    print("Sisyphus: Rewound! Do a /reload to see changes.")
end

---
--- Designating special frames
---

table.insert(UISpecialFrames, "SisyphusFrame")

---TODO:
--- * variable width/height?
--- * implement account-wide list
--- ** possibly separate by categories
--- * finished tasks go on bottom?