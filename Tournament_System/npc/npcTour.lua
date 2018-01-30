local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)
local talkState = {}

function onCreatureAppear(cid) npcHandler:onCreatureAppear(cid) end
function onCreatureDisappear(cid) npcHandler:onCreatureDisappear(cid) end
function onCreatureSay(cid, type, msg) npcHandler:onCreatureSay(cid, type, msg) end
function onThink() npcHandler:onThink() end


function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end
	
	local talkUser = NPCHANDLER_CONVbehavior == CONVERSATION_DEFAULT and 0 or cid
	
	if msgcontains(string.lower(msg), "help") or msgcontains(string.lower(msg), "subscribe") then
		
		if TOURNAMENT_SYSTEM.getStatus() == 'CLOSED' then
			selfSay("The tournament is closed!")
			talkState[talkUser] = 0
			return true
		end
		
		if TOURNAMENT_SYSTEM.getStatus() == 'STARTED' then
			selfSay("The tournament has already began.")
			talkState[talkUser] = 0
			return true
		end
		
		selfSay("Nice, you need 100 dollars to subscribe!")
		talkState[talkUser] = 1
		
	elseif talkState[talkUser] == 1 and msgcontains(string.lower(msg), "yes") then
		
		if(doPlayerRemoveMoney(cid, 100)) then
			selfSay("Nice, now you are subscribed!")
			TOURNAMENT_SYSTEM.subscribe(getCreatureName(cid))
			talkState[talkUser] = 0
			npcHandler:releaseFocus(cid)
		else
			return selfSay("Sorry you dont have money, need 100 dollars.")
		end
	elseif msg == "no" and talkState[talkUser] >= 1 then
		selfSay("Then not", cid)
		talkState[talkUser] = 0
		npcHandler:releaseFocus(cid)
	end
	
	return true
end

npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
