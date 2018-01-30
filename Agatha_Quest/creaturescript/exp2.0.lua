function onStatsChange(cid, attacker, type, combat, value)
  if value >= getCreatureHealth(cid) then
    if getPlayerStorageValue(cid, Agatha.stoIni) >= 1 and getPlayerStorageValue(cid, Agatha.stoIni) <= 10 then
      setPlayerStorageValue(cid, Agatha.stoIni, -1)
      setPlayerStorageValue(cid, Agatha.stoRec, -1)
      setPlayerStorageValue(cid, Agatha.stoPer, -1)
      setPlayerStorageValue(cid, Agatha.stoEni, -1)
      setPlayerStorageValue(cid, Agatha.stoRes, -1)
    end
  end
  return false
end