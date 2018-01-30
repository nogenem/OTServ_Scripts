local posis = {
  {{x = 1529, y = 1113, z = 7}, 1846},  --posicoes q o espelho pode aparecer, id do espelho
  {{x = 1536, y = 1110, z = 7}, 1846},
  --{{x = 111, y = 111, z = 7}, 2222},              
  --{{x = 111, y = 111, z = 7}, 3333},
  --{{x = 111, y = 111, z = 7}, 2222},
}
  
local function randPos(iniPos, posis)
  for i = 1, #posis do
    local newPos = posis[math.random(#posis)]
    if not isPosEqual(newPos[1], iniPos) then
      return newPos
    end
  end
  return posis[math.random(#posis)]
end
  
function onUse(cid, item, fromPosition, itemEx, toPosition)
  if getPlayerLevel(cid) < 100 then
    return false
  elseif getPlayerStorageValue(cid, Agatha.stoIni) ~= -1 then
    return false
  end  
  
  doSendMagicEffect(getThingPos(item.uid), 19)--mudar eff
  doRemoveItem(item.uid, 1)
  doTeleportThing(cid, Agatha.posQuest, false)
  doSendMagicEffect(getThingPos(cid), 21)
  setPlayerStorageValue(cid, Agatha.stoIni, 1)
  local newPos = randPos(fromPosition, posis)
  local mirror = doCreateItem(newPos[2], 1, newPos[1])
  doSetItemAttribute(mirror, "aid", 6658)  --ver isso aki
  doSendMagicEffect(newPos[1], 19)  --mudar eff
  return true
end  

--<action actionid="xxxx" event="script" value="Agatha_Espelho_Out.lua"/>  
