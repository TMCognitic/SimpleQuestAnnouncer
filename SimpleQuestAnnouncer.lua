local SQA = CreateFrame("Frame")

local cache = {}
local initialized = false

----------------------------------------------------
-- Configuration
----------------------------------------------------

local function Msg(text)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff33ff99SimpleQuestAnnouncer|r " .. text
    )
end

----------------------------------------------------
-- Group detection
----------------------------------------------------

local function GetOutputChannel()

    if IsInRaid() then
        return "RAID"
    end

    if IsInGroup() then
        return "PARTY"
    end

    -- SAY/YELL sont bloqués hors d'un clic joueur : pas d'annonce en solo
    return nil
end

local function Announce(text)

    if not SimpleQuestAnnouncerDB.enabled then
        return
    end

    local channel = GetOutputChannel()

    -- Solo : on affiche l'annonce localement (utile pour tester)
    if not channel then
        Msg(text)
        return
    end

    SendChatMessage(text, channel)
end

----------------------------------------------------
-- Quest scan
----------------------------------------------------

local function GetObjectiveTexts(questID)
    local texts = {}
    local objectives = C_QuestLog.GetQuestObjectives(questID)

    if objectives then
        for _, objective in ipairs(objectives) do
            if objective.text and objective.text ~= "" then
                table.insert(texts, objective.text)
            end
        end
    end

    return texts
end

local function Scan()
    local numEntries = C_QuestLog.GetNumQuestLogEntries()

    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)

        if info and not info.isHeader then
            local title = info.title
            local texts = GetObjectiveTexts(info.questID)
            local complete = C_QuestLog.IsComplete(info.questID) and true or false
            local previous = cache[info.questID]

            -- Après le premier scan, on annonce les objectifs qui ont changé
            if initialized and previous then
                for _, text in ipairs(texts) do
                    if not previous.texts[text] then
                        Announce("[" .. title .. "] " .. text)
                    end
                end

                -- Tous les objectifs viennent d'être remplis
                if complete and not previous.complete then
                    Announce("[" .. title .. "] Objectives completed")
                end
            end

            local state = { texts = {}, complete = complete }
            for _, text in ipairs(texts) do
                state.texts[text] = true
            end
            cache[info.questID] = state
        end
    end

    initialized = true
end

-- QUEST_LOG_UPDATE se déclenche en rafale : on regroupe les scans
local SCAN_DELAY = 0.2
local scanPending = false

local function ScheduleScan()
    if scanPending then
        return
    end

    scanPending = true
    C_Timer.After(SCAN_DELAY, function()
        scanPending = false
        Scan()
    end)
end

----------------------------------------------------
-- Events
----------------------------------------------------

SQA:RegisterEvent("ADDON_LOADED")
SQA:RegisterEvent("PLAYER_ENTERING_WORLD")
SQA:RegisterEvent("QUEST_LOG_UPDATE")
SQA:RegisterEvent("QUEST_ACCEPTED")
SQA:RegisterEvent("QUEST_REMOVED")

SQA:SetScript("OnEvent",
function(self, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= "SimpleQuestAnnouncer" then
            return
        end
        -- Les SavedVariables sont chargées à ce moment : valeurs par défaut
        SimpleQuestAnnouncerDB = SimpleQuestAnnouncerDB or {}
        if SimpleQuestAnnouncerDB.enabled == nil then
            SimpleQuestAnnouncerDB.enabled = true
        end
        SQA:UnregisterEvent("ADDON_LOADED")
    elseif event == "QUEST_ACCEPTED" then
        local title = C_QuestLog.GetTitleForQuestID(arg1)
        Msg("New quest accepted: " .. (title or "no title"))
    elseif event == "QUEST_REMOVED" then
        local title = C_QuestLog.GetTitleForQuestID(arg1)
        Msg("Quest removed: " .. (title or "no title"))
        cache[arg1] = nil
    elseif event == "PLAYER_ENTERING_WORLD" or event == "QUEST_LOG_UPDATE" then
        ScheduleScan()
    end
end)

----------------------------------------------------
-- Commands
----------------------------------------------------

SLASH_SIMPLEQUESTANNOUNCER1 = "/sqa"

SlashCmdList["SIMPLEQUESTANNOUNCER"] = function(msg)
    msg = msg:lower()
    if msg == "on" then
        SimpleQuestAnnouncerDB.enabled = true
        Msg("enabled")

    elseif msg == "off" then
        SimpleQuestAnnouncerDB.enabled = false
        Msg("disabled")

    elseif msg == "status" then
        if SimpleQuestAnnouncerDB.enabled then
            Msg("state: enabled")
        else
            Msg("state: disabled")
        end
    else
        Msg("/sqa on")
        Msg("/sqa off")
        Msg("/sqa status")
    end
end

Msg("loaded")