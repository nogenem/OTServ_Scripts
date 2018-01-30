-- Só um exemplo de como iniciar o torneio
function onTimer(cid, interval, lastExecution) 
  if os.date("%w") == 6 then
    TOURNAMENT_SYSTEM.start()
  end
  return true
end
