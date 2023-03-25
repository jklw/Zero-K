
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
}

local spokenMsgTypes = {
    player_to_allies = true,
    player_to_player_received = true,
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

-- Add a period to the end of the text if it doesn't already end with a punctuation character.
function AddPeriod(text)
    if text:find("%p%s*$") then return text else return text.."." end
end

local function CreateVoiceElement(playerId, innerSsml) 
    local voiceIx = playerIdToVoiceIndex[playerId]
    if not voiceIx then
        voiceIx = GetVoiceIndex(playerId)
        playerIdToVoiceIndex[playerId] = voiceIx
    end
    return string.format('<voice name="%s">%s</voice>\n', voices[voiceIx], innerSsml)
end

function widget:AddConsoleMessage(msg)
    -- outfile:write(Spring.Utilities.TableToString(msg))
    -- outfile:write("\n\n")
	if not (msg and spokenMsgTypes[msg.msgtype] and msg.argument) then
		return
	end

    local playerId = msg.player and msg.player.id or nil

    -- if playerId == myPlayerID then return end

	outfile:write(CreateVoiceElement(playerId, EscapeXmlText(AddPeriod(msg.argument))))
	-- outfile:write(CreateVoiceElement(playerId, (msg.playername or "unknown") .. ": " ..(msg.argument or "") .. "."))
	outfile:flush()
end

function widget:MapDrawCmd(playerId, cmdType, px, py, pz, caption)
	--if (select(1, Spring.GetSpectatingState()) or playerId == myPlayerID) then

	--if (playerId == myPlayerID) then return end

	if cmdType == 'point' and caption and caption ~= '' then
        local playerName = Spring.GetPlayerInfo(playerId, false)
        outfile:write(CreateVoiceElement(playerId, EscapeXmlText(AddPeriod(caption))))
        -- outfile:write(CreateVoiceElement(playerId, (playerName or "unknown") .. ": " .. caption .. "."))
        outfile:flush()
	end
end
