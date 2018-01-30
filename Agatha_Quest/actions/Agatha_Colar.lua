function onUse(cid, item, fromPosition, itemEx, toPosition)
  if getPlayerStorageValue(cid, Agatha.stoIni) ~= 1 then
    return false
  elseif getPlayerItemCount(cid, Agatha.colar) >= 1 then
    return false
  end
  local item = doPlayerAddItem(cid, Agatha.colar, 1)
  doSetItemAttribute(item, "name", "Agatha's Necklace")
  doSetItemAttribute(item, "description", "This is the Agatha's old necklace, be careful with this item!")
  return true
end

--<action actionid="6616" event="script" value="Agatha_Colar.lua"/>
  