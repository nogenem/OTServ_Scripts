-- Adicione isso:
TOURNAMENT_SYSTEM.endBattle(cid) 
-- Antes do ultimo 'return TRUE' do 'onLogout'

-- Adicione isso:
addEvent(TOURNAMENT_SYSTEM.onPokeDies, 100, getCreatureMaster(cid)) --na parte do onDeath
-- Embaixo disso no 'onDeath':
checkDuel(owner)
