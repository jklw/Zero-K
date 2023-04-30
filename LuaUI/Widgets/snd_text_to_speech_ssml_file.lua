
function widget:GetInfo()
	return {
		name			= "Text To Speech SSML file",
		desc			= "Enables or disables text to speech through Zero-K lobby",
		author		= "dunno",
		date			= "2023-03-20",
		license	= "GNU GPL, v2 or later",
		layer		= 0,
		enabled	= true	--	loaded by default?
	}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local myPlayerID, myPlayerName
local outfile

-- Must be pre-escaped as an XML attribute value if necessary.
local voices = {
    "blizzard_fls-glow_tts",
    "cmu_clb-glow_tts",
    "cmu_slt-glow_tts",
    "harvard-glow_tts",
    "mary_ann-glow_tts",
    "southern_english_female",
}

-- cf. ../chat_preprocess.lua:37
local spokenMsgTypes = {
    player_to_allies = true,
    player_to_player_received = true,
    player_to_player_sent = true,
    player_to_specs = true,
    spec_to_specs = true,
    spec_to_allies = true,
    replay_spec_to_specs = true,
    replay_spec_to_allies = true,
    replay_spec_to_everyone = true,
}

local playerIdToVoiceIndex = {}

function widget:Initialize()
    myPlayerID = Spring.GetMyPlayerID()

    local fileName = "text_to_speech.ssml"
	outfile = io.open(fileName, "w")

    -- file:write(table.concat(header, ';'))
end

function widget:Shutdown()
	outfile:flush()
	outfile:close()
end

local function GetVoiceKey(playerId)
    if not playerId then return nil end
    local customkeys = select(10, Spring.GetPlayerInfo(playerId))
    if not customkeys then return playerId end
    return customkeys.lobbyid or playerId
end

local function GetVoiceIndex(playerId)
    local key = GetVoiceKey(playerId)
    if not key then return 1 end
    return 1 + (key % #voices)
end

local xmlTextEscapes = {
    ["<"] = "&lt;",
    ["&"] = "&amp;",
}

local function EscapeXmlText(text)
    return text:gsub("[<&]", xmlTextEscapes)
end

local function WordPat(word)
    return "%f[%w_]" .. word .. "%f[^%w_]"
end

function TransformMessage(playerId, msg)
    msg = EscapeXmlText(msg)

    local match = msg:match("^I choose: (.*)!")
    if match then
        local playerName = playerId and Spring.GetPlayerInfo(playerId, false)
        return string.format("%s chooses %s.", playerName or "An unknown player", match)
    end

    -- Fix mispronunciation of "nice" as "nees"
    msg = msg:gsub(WordPat("nice"), "nighs")

    msg = msg:gsub(WordPat("aa"), "AA")
    msg = msg:gsub(WordPat("gg"), "GG")
    msg = msg:gsub(WordPat("ty"), "thank you")
    msg = msg:gsub(WordPat("thx"), "thanks")
    msg = msg:gsub(WordPat("plz"), "please")

    -- Add a period to the end of the text if it doesn't already end with a punctuation character.
    if msg:find("%p%s*$") then return msg else return msg.."." end
end

local function CreateVoiceElement(playerId, innerSsml)
    local voiceIx = playerIdToVoiceIndex[playerId]
    if not voiceIx then
        voiceIx = GetVoiceIndex(playerId)
        playerIdToVoiceIndex[playerId] = voiceIx
    end
    return string.format('<voice name="%s">%s</voice>\n', voices[voiceIx], innerSsml)
end

local function Emit(playerId, msg)
	outfile:write(CreateVoiceElement(playerId, TransformMessage(playerId, msg)))
	outfile:flush()
end

function widget:AddConsoleMessage(msg)
    -- outfile:write(Spring.Utilities.TableToString(msg))
    -- outfile:write("\n\n")
	if not (msg and spokenMsgTypes[msg.msgtype] and msg.argument) then
		return
	end

    -- if playerId == myPlayerID then return end

    local msga = msg.argument

    if  msga:find("^%s*I gave %d+ metal to") or
        msga:find("^%s*I gave %d+ energy to") then
        return
    end

    local playerId = msg.player and msg.player.id or nil

    Emit(playerId, msga)
end

function widget:MapDrawCmd(playerId, cmdType, px, py, pz, caption)
	--if (select(1, Spring.GetSpectatingState()) or playerId == myPlayerID) then

	--if (playerId == myPlayerID) then return end

	if cmdType == 'point' and caption and caption ~= ''
        and (not caption:find("^%d+ units received from"))
        and (not caption:find("^Unit received from"))
        then
        -- local playerName = Spring.GetPlayerInfo(playerId, false)
        Emit(playerId, caption)
	end
end
