function onUse(cid, item, fromPosition, itemEx, toPosition)
  if getPlayerItemCount(cid, Agatha.colar) <= 0 then
    return false
  elseif getPlayerStorageValue(cid, Agatha.stoIni) ~= 1 then
    return false
  elseif getPlayerStorageValue(cid, Agatha.stoPergs[1]) ~= -1 then
    local t = {}
    for i = 1, #Agatha.stoPergs do
      table.insert(t, getPlayerStorageValue(cid, Agatha.stoPergs[i]))
    end
    return doShowTextDialog(cid, item.itemid, table.concat(t, "\n")) and true
  end
  
  local tmp = Agatha.charadas 
  local choises = {}
  for i = 1, 15 do
    local rand = math.random(#tmp)
    table.insert(choises, tmp[rand])
    setPlayerStorageValue(cid, Agatha.stoPergs[i], (" "..i.."º - "..tmp[rand].c))
    table.remove(tmp, rand)
  end
  
  local setSto = " "
  local txt = {}
  for i = 1, #choises do
    table.insert(txt, i.."º - "..choises[i].c)
    setSto = setSto.."".. choises[i].r ..";"
  end
  
  local Perg = getItemsInContainerById(getPlayerSlotItem(cid, 3).uid, 10308)
  if #Perg >= 1 then
    doRemoveItem(Perg[1], 1)
  end
  
  local perg = doPlayerAddItem(cid, 10308, 1)
  doSetItemAttribute(perg, "aid", 6659)
  
  setPlayerStorageValue(cid, Agatha.stoRec, setSto) 
  doShowTextDialog(cid, item.itemid, table.concat(txt, "\n"))
  return true
end  

--<action actionid="6654" event="script" value="Agatha_Receita.lua"/>
  