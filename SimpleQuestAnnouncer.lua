local QC = CreateFrame("Frame")

SimpleQuestAnnouncerDB = SimpleQuestAnnouncerDB or {}

local cache = {}
local initialized = false

----------------------------------------------------
-- Configuration
----------------------------------------------------

local function Enabled()
    if SimpleQuestAnnouncerDB.enabled == nil then
        SimpleQuestAnnouncerDB.enabled = true
    end

    return SimpleQuestAnnouncerDB.enabled
end

local function Msg(text)
    DEFAULT_CHAT_FRAME:AddMessage(
        "|cff33ff99QuestCrier|r " .. text
    )
end

----------------------------------------------------
-- Group detection
----------------------------------------------------

local function GetOutputChannel()

    if GetNumRaidMembers() > 0 then
        return "RAID"
    end

    if GetNumPartyMembers() > 0 then
        return "PARTY"
    end

    -- return nil -- En Mode prod
    return "SAY" --En Mode dev
end

local function Announce(text)

    if not Enabled() then
        return
    end

    local channel = GetOutputChannel()

    if not channel then
        return
    end

    SendChatMessage(text, channel)
end

----------------------------------------------------
-- Quest scan
----------------------------------------------------

local function BuildQuestState(index)

    SelectQuestLogEntry(index)

    local state = ""

    local objectives = GetNumQuestLeaderBoards()

    for i = 1, objectives do

        local text = GetQuestLogLeaderBoard(i)

        if text then
            state = state .. text .. "|"
        end
    end

    return state
end

local function Scan()

    local numEntries = GetNumQuestLogEntries()

    for i = 1, numEntries do

        local title, level, tag, isHeader =
            GetQuestLogTitle(i)

        if title and not isHeader then

            local currentState =
                BuildQuestState(i)

            local previousState =
                cache[title]

            ------------------------------------------------
            -- First scan
            ------------------------------------------------

            if not initialized then

                cache[title] = currentState

            else

                ------------------------------------------------
                -- Progress detected
                ------------------------------------------------

                if previousState
                    and previousState ~= currentState then

                    local objectives =
                        GetNumQuestLeaderBoards()

                    for j = 1, objectives do

                        local text =
                            GetQuestLogLeaderBoard(j)

                        if text then

                            local old =
                                string.find(
                                    previousState,
                                    text,
                                    1,
                                    true
                                )

                            if not old then

                                Announce(
                                    "[" ..
                                    title ..
                                    "] " ..
                                    text
                                )
                            end
                        end
                    end
                end

                cache[title] = currentState
            end
        end
    end

    initialized = true
end

----------------------------------------------------
-- Quest completion
----------------------------------------------------

local function CheckCompletedQuest()

    local title = GetTitleText()

    if title then
        Announce(
            "Quête terminée : " ..
            title
        )
    end
end

----------------------------------------------------
-- Events
----------------------------------------------------

QC:RegisterEvent("PLAYER_ENTERING_WORLD")
QC:RegisterEvent("QUEST_LOG_UPDATE")
QC:RegisterEvent("QUEST_COMPLETE")

QC:SetScript("OnEvent",

function()

    local event = event

    if event == "PLAYER_ENTERING_WORLD" then

        Scan()

    elseif event == "QUEST_LOG_UPDATE" then

        Scan()

    elseif event == "QUEST_COMPLETE" then

        CheckCompletedQuest()

    end
end)

----------------------------------------------------
-- Commands
----------------------------------------------------

SLASH_QUESTCRIER1 = "/sqa"

SlashCmdList["SimpleQuestAnnouncerDB"] = function(msg)

    msg = string.lower(msg or "")

    if msg == "on" then

        SimpleQuestAnnouncerDB.enabled = true
        Msg("activé")

    elseif msg == "off" then

        SimpleQuestAnnouncerDB.enabled = false
        Msg("désactivé")

    elseif msg == "status" then

        if Enabled() then
            Msg("état : activé")
        else
            Msg("état : désactivé")
        end

    else

        Msg("/qc on")
        Msg("/qc off")
        Msg("/qc status")

    end
end

Msg("chargé")