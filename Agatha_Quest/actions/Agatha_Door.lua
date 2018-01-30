function onUse(cid, item, fromPosition, itemEx, toPosition)
  if getPlayerStorageValue(cid, Agatha.stoIni) < 75 then
    return false
  elseif getPlayerLevel(cid) < 100 then
    return false
  end 
  local dir = getPosByDir(fromPosition, getDirectionTo(getThingPos(cid), fromPosition))
  doTeleportThing(cid, dir, false)
  doTeleportThing(cid, dir, false)
  doSendMagicEffect(getThingPos(cid), 21)
  return true
end  

--<action actionid="3544" event="script" value="Agatha_Door.lua"/>  
