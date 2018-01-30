--[[
  -INFO:
    -Versão feita usando globalStorages para burlar o
      problema de carregamento multiplo da pasta lib/
    -Versão utilizando o meu sistema de duel
    -Versão usando o nome dos players em vez do UID
  -TODO:
    -Precisa fazer proteções para funções do Order [principalmente de DUEL]
    -Precisa forçar o player a por um poke pra fora antes do fim do coutdown
    -Precisa limpar todos os addEvents caso o torneio seja cancelado/fechado
]]--
local function _printTimeDiff(diff)
  local dateFormat = {
    {'hour', diff / 60 / 60}, 
    {'min', diff / 60 % 60},
    {'sec', diff % 60},
  }
  local out = {}  
  local prefix = ''                                
  for k, t in ipairs(dateFormat) do
    local v = math.floor(t[2])
    if v > 0 then
      prefix = #out == 0 and '' or k < #dateFormat and ' ' or ' and '
      table.insert(out, prefix .. v .. '' .. (v <= 1 and t[1] or t[1].."s"))
    end
  end
  return table.concat(out)
end 

function table.copy(t)
  if type(t) ~= 'table' then return {} end
  local r = {}
  for i, v in pairs(t) do
    if type(i) == 'table' then
      i = table.copy(i)
    end
    if type(v) == 'table' then
      v = table.copy(v)
    end
    r[i] = v
  end
  return r
end

function table.shuffle(t)
  if type(t) ~= 'table' or #t == 0 then return {} end
  local result = {}
  for i = 1, #t do
    local value = table.remove(t, math.random(1,#t))
    table.insert(result, value)
  end
  return result
end

function table.tostring(t)
	if type(t) ~= 'table' then return '' end
  local str = "{"

	local function getValidFormat(v)
		if type(v) == "table" then
			return table.tostring(v)
		elseif type(v) == "string" then
			return "'" .. v .. "'"
		else
			return v
		end
	end

	for i, v in pairs(t) do
		str = str .. "["..getValidFormat(i).."] = " .. getValidFormat(v) .. ", "
	end

  str = #str > 1 and str:sub(1, #str-2) or str --tira o ultimo ', '
	str = str .. "}"
	return str
end

function string.totable(str)
	return loadstring("return " .. str)()
end

local TOURNAMENT_CONFIGS = {
  arenas = {
    [1] = {pos = {x = 1030, y = 1064, z = 7}, nome = "Psychic"},
    [2] = {pos = {x = 1030, y = 1068, z = 7}, nome = "Venom"},
  },
  player2_xplus = 6, --quanto sera somado a pos.x do player1
  player2_yplus = 0, --quanto sera somado a pos.y do player1
  coliseum = { --area do coliseum
    from = {x = 1048, y = 1056, z = 7}, --top left
    to = {x = 1059, y = 1061, z = 7}    --bottom right
  },
  min_players = 4, --Quantidade minima de players para iniciar o torneio
  times = {  --tempos em segundos!
    start_tournament = 60 * 60,       --tempo para iniciar o torneio
    msg_before_tournament = 5 * 60,   --tempo antes do inicio do torneio para mandar a
                                        --msg que ele esta iniciando (Vai ser descontado do start_tournament)
    tp_to_duel = 60,                  --tempo para teleportar o player para a arena
    start_duel = 30,                  --tempo para iniciar o duel DEPOIS do tp para a arena
    cd_to_duel = 5,                   --countdown para iniciar o duel (Vai ser descontado do start_duel)
  },
  effects = {
    won_lost_eff = true,              --mandar animatedEffect de win/lost ?
    start_duel_eff = false,           --mandar animatedEffect de START ao comecar o duel ?
    cd_duel_eff = true                --mandar animatedEffect do countdown para iniciar o duel ?
  },
  pstos = { --player storages
    status = 223020,
    battle = 223021,
    fightpos = 223022,    --pos pela qual tao batalhando no torneio, usado soh pra descidir 1*-3* lugar
    oldpos = 170663,      --pos que o player tava antes de comecar o duel do torneio
    duel = {
      ballsleft = 52481,  --quantos pokes os jogadores ainda tem       [OBRIGATORIO POR A STORAGE CERTA AKI!][EDITE AKI PARA MUDAR DUEL SYSTEM]
      enemy = 52483,      --time/jogador inimigo                       [OBRIGATORIO POR A STORAGE CERTA AKI!][EDITE AKI PARA MUDAR DUEL SYSTEM]
      
      --Apenas para o meu sistema de duel! Pode ignorar/remover se for usar outro!
      duel_mode = 52480,  --modo de duel, 1x1 e afins
      my_team = 52482,    --time do player, possui valor: 'meu nome,'
      dueling = 52484,    --igual a 10 => duelando
      inviter = 52485,    --nome do invitador
    }
  },
  gstos = { --global storages
    current_players = 223023,
    all_players = 223024,
    round = 223025,
    status = 223026,
    winners = 223027,
    dueling = 223028,
  },
  rewards = {
    [1] = {
      {id = 2160, n = 100},             --money
      {id = 7746, n = 1, descr = true}  --trofeu, descr = true pra ele receber a descrição do vencedor
    },
    [2] = {
      {id = 2160, n = 50},              --money
      {id = 7745, n = 1, descr = true}  --trofeu, descr = true pra ele receber a descrição do vencedor
    },
    [3] = {
      {id = 2160, n = 20},              --money
      {id = 7744, n = 1, descr = true}  --trofeu, descr = true pra ele receber a descrição do vencedor
    },
  }
}

local function NEW_TOURNAMENT_CLASS()
  local self = {}
  local _ = {}

  -- Private funcs
  function _.serialize(currentValue, newValue)
    if type(newValue) == "number" then
      return newValue
    end
    if type(currentValue) == "number" then
      currentValue = ""
    end
    if type(newValue) == "table" then
      for i, s in pairs(newValue) do
        currentValue = currentValue .. tostring(s) .. ","
      end
    else
      currentValue = currentValue .. tostring(newValue) .. ","
    end
    return currentValue
  end
  
  function _.deserializeToTable(currentValue)
    if type(currentValue) == "number" then
      return {}
    else
      return string.explode(currentValue, ",")
    end
  end
  
  function _.setStatus(value)
    setGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.status, value)
  end

  function _.setRound(value)
    setGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.round, value)
  end

  function _.setDueling(value)
    setGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.dueling, value)
  end

  function _.setCurrentPlayers(value)
    local newValue = _.serialize(getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.current_players), value) 
    setGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.current_players, newValue)
  end

  function _.setAllPlayers(value)
    local newValue = _.serialize(getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.all_players), value) 
    setGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.all_players, newValue)
  end

  function _.setWinners(value)
    local newValue = _.serialize(getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.winners), value) 
    setGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.winners, newValue)
  end

  function _.reset()
    _.setCurrentPlayers(-1)
    _.setAllPlayers(-1)
    _.setRound(0)
    _.setStatus('CLOSED')
    _.setWinners(-1)
    _.setDueling(0)
  end

  function _.openSubscribe()
    local status = self.getStatus()
    if status ~= 'CLOSED' then
      print('TOURNAMENT_SYSTEM:_.openSubscribe()> Status ('.. status ..') ~= CLOSED.')
      return false
    end
    _.setStatus('OPENED')
    return true
  end

  function _.endSubscribe()
    local status = self.getStatus()
    if status ~= 'OPENED' then
      print('TOURNAMENT_SYSTEM:_.endSubscribe()> Status ('.. status ..') ~= OPENED.')
      return false
    end
    _.setStatus('CLOSED')
    return true
  end

  function _.addRewards()
    local winners = self.getWinners()
    for i, name in pairs(winners) do
      local player = getPlayerByName(name)
      if isCreature(player) then
        for _, item in ipairs(TOURNAMENT_CONFIGS.rewards[i]) do
          local tmp = doPlayerAddItem(player, item.id, item.n)
          if item.descr then
            doItemSetAttribute(tmp, 'description', 'Reward for the '..i..'# place in the tournament ('..name..').')
          end
        end
      end
      doPlayerSendTextMessage(player, 20, "You finished the tournament in "..i.."# place!")
    end
  end

  function _.endDuel(player)
    if isCreature(player) then
      local oldposSto = getPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.oldpos)
      
      if oldposSto == -1 then return false end
      
      if #getCreatureSummons(player) >= 1 then
         doCreatureExecuteTalkAction(player, "/backaction")
      end
      
      oldposSto = string.totable(oldposSto)
      doTeleportThing(player, oldposSto)
      
      --[EDITE AKI SE PRECISAR LIMPAR ALGUMA STORAGE DO SISTEMA DE DUEL]
    end
  end

  function _.cleanPlayerStos(player)
    if isCreature(player) then
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status, -1)
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.battle, -1)
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.fightpos, -1)
      _.endDuel(player)
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.oldpos, -1)
    end
  end

  function _.finish(error)
    if self.getStatus() == 'CLOSED' then
      print('TOURNAMENT_SYSTEM:_.finish(error)> Attempt to end a closed tournament.')
      return false
    end

    local currentPlayers = self.getCurrentPlayers()
    for i, name in ipairs(currentPlayers) do
      local player = getPlayerByName(name)
      _.cleanPlayerStos(player)
    end

    if not error then
      _.addRewards()
      doBroadcastMessage('The tournament has ended!')
    else
      doBroadcastMessage('Tournament canceled due to internal error.')
    end
    _.reset()
  end

  function _.nextRound()
    local won, lost, remove, skip = {}, {}, {}, {}

    local currentPlayers = self.getCurrentPlayers()
    local n = #currentPlayers
    for i = 1, n do
      local player = getPlayerByName(currentPlayers[i])

      if isCreature(player) then
        local status = getPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status)
        if not isInRange(getThingPos(player), TOURNAMENT_CONFIGS.coliseum.from, TOURNAMENT_CONFIGS.coliseum.to) then
          doPlayerSendTextMessage(player, 22, "You aren't in the coliseum area, so you are disqualified of the tournament!")
          table.insert(remove, player)
        elseif status == 'LOST' then
          table.insert(lost, player)
          table.insert(remove, player)
        elseif status == 'DUELING' then
          doPlayerSendTextMessage(player, 22, "System error, you are disqualified of the tournament!") --rever isso
          table.insert(remove, player)
        elseif status == 'WON' or status == 'WAITING' then
          table.insert(won, player)
        end
      end
    end

    if #won == 0 then
      _.finish()
      return false
    end

    if #lost == 1 and #won == 2 then
      local winners = self.getWinners()
      winners[3] = lost[1]
      _.setWinners(winners)
    elseif #lost == 1 and #won == 1 then
      local winners = self.getWinners()
      winners[1] = won[1]
      winners[2] = lost[1]
      _.setWinners(winners)
      _.finish()
      return false
    elseif #won == 1 and #lost == 0 then
      local winners = self.getWinners()
      winners[1] = won[1]
      _.setWinners(winners)

      _.finish()
      return false
    end

    if #lost == 2 and #won == 2 then
      if getPlayerStorageValue(won[1], TOURNAMENT_CONFIGS.pstos.fightpos) ~= -1 then --luta pelo 1*-3* lugar
        local p1 = getPlayerStorageValue(won[1], TOURNAMENT_CONFIGS.pstos.fightpos)
        local p2 = getPlayerStorageValue(lost[1], TOURNAMENT_CONFIGS.pstos.fightpos)
        local winners = self.getWinners()

        winners[1] = p1 == 1 and won[1] or won[2]
        winners[2] = p2 == 1 and lost[1] or lost[2]
        winners[3] = p1 == 3 and won[1] or won[2]

        _.setWinners(winners)
        _.finish()
        return
      else
        setPlayerStorageValue(won[1], TOURNAMENT_CONFIGS.pstos.fightpos, 1)
        setPlayerStorageValue(won[2], TOURNAMENT_CONFIGS.pstos.fightpos, 1)
        setPlayerStorageValue(lost[1], TOURNAMENT_CONFIGS.pstos.fightpos, 3)
        setPlayerStorageValue(lost[2], TOURNAMENT_CONFIGS.pstos.fightpos, 3)
        setPlayerStorageValue(lost[1], TOURNAMENT_CONFIGS.pstos.status, 'WAITING')
        setPlayerStorageValue(lost[2], TOURNAMENT_CONFIGS.pstos.status, 'WAITING')
        currentPlayers = {won[1], won[2], lost[1], lost[2]}
      end
    else
      currentPlayers = table.shuffle(won)
    end
    n = #currentPlayers
    
    for i, v in ipairs(remove) do  
      _.cleanPlayerStos(v)
    end

    local n2 = #TOURNAMENT_CONFIGS.arenas 
    for i = 1, n, 2 do
      local player1, player2 = currentPlayers[i], currentPlayers[i+1]
      if player2 == nil then
        table.insert(skip, player1)
      elseif n2 == 0 then  
        table.insert(skip, player1)
        table.insert(skip, player2)
      else
        _.prepareBattle(player1, player2, TOURNAMENT_CONFIGS.arenas[n2]) 
        n2 = n2 - 1  
      end
    end

    for i, player in ipairs(skip) do
      doBroadcastMessage("Player: " ..getCreatureName(player).. " skipped this round!")
      doPlayerSendTextMessage(player, 22, 'You skipped this round!')
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status, 'WAITING')
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.battle, -1)
    end

    local round = self.getRound() + 1
    _.setRound(round)
    _.setCurrentPlayers(currentPlayers)
    doBroadcastMessage('The '.. round ..'# round of the tournament will start soon!')
  end

  function _.init()
    if not _.endSubscribe() then
      _.finish(true)
      return false
    end

    local allPlayers = self.getAllPlayers()
    local currentPlayers = self.getCurrentPlayers()
    for i = 1, #allPlayers do
      local player = getPlayerByName(allPlayers[i])
      if player then
        setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status, 'WAITING')
      end
      table.insert(currentPlayers, player)
    end

    if #currentPlayers < TOURNAMENT_CONFIGS.min_players then
      doBroadcastMessage('Tournament canceled | Not enough subcribers ('.. #currentPlayers.. '/'..TOURNAMENT_CONFIGS.min_players..'+)')
      _.reset()
      return false
    end

    _.setCurrentPlayers(currentPlayers)
    _.setStatus('STARTED')

    doBroadcastMessage('The tournament has started!')

    _.nextRound()
  end

  function _.prepareBattle(player1, player2, arena)
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.battle, player2)
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.battle, player1)

    --[EDITE AKI PARA MUDAR DUEL SYSTEM]
    if getPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.enemy) ~= -1 then
      doEndDuel(player1, true) --termina os duels antes de começar o torneio
    end
    if getPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.enemy) ~= -1 then
      doEndDuel(player2, true) --termina os duels antes de começar o torneio
    end

    doPlayerSendTextMessage(player1, 20, "You will be teleported to the arena in " ..
                                     _printTimeDiff(TOURNAMENT_CONFIGS.times.tp_to_duel).. ".")
    doPlayerSendTextMessage(player2, 20, "You will be teleported to the arena in " ..
                                     _printTimeDiff(TOURNAMENT_CONFIGS.times.tp_to_duel).. ".")
    
    doBroadcastMessage("Player: " ..getCreatureName(player1).. " will battle against player: " ..
                                getCreatureName(player2).. " at the arena " ..arena.nome.. "!")
    
    _.setDueling(self.getDueling()+1)
    
    local function countdown(n)
      if not isCreature(player1) or not isCreature(player2) then return end
      if self.getStatus() ~= 'STARTED' then return end
      if n == 0 then
        _.startBattle(player1, player2)
        if TOURNAMENT_CONFIGS.effects.start_duel_eff then
          doSendAnimatedText(getCreaturePosition(player1), 'START', 26000)
          doSendAnimatedText(getCreaturePosition(player2), 'START', 26000)
        end
        return
      end
      if TOURNAMENT_CONFIGS.effects.cd_duel_eff then
        doSendAnimatedText(getCreaturePosition(player1), n, 26000)
        doSendAnimatedText(getCreaturePosition(player2), n, 26000)
      end
      addEvent(countdown, 1000, n-1)
    end
    
    addEvent(function()
      if not isCreature(player1) or not isCreature(player2) then
        return false
      end
      if self.getStatus() ~= 'STARTED' then return false end

      local pos1 = table.copy(arena.pos)
      local pos2 = table.copy(arena.pos)
            pos2.x = pos2.x+TOURNAMENT_CONFIGS.player2_xplus
            pos2.y = pos2.y+TOURNAMENT_CONFIGS.player2_yplus

      setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.oldpos, table.tostring(getThingPos(player1)))
      setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.oldpos, table.tostring(getThingPos(player2)))

      doTeleportThing(player1, pos1)
      doTeleportThing(player2, pos2)

      local sums1 = getCreatureSummons(player1)
      if #sums1 >= 1 then
        doTeleportThing(sums1[1], getClosestFreeTile(sums1[1], pos1))
      end
      local sums2 = getCreatureSummons(player2)
      if #sums2 >= 1 then
        doTeleportThing(sums2[1], getClosestFreeTile(sums2[1], pos2))
      end

      doPlayerSendTextMessage(player1, 20, "Your duel will start in " ..
                                       _printTimeDiff(TOURNAMENT_CONFIGS.times.start_duel).. ".")
      doPlayerSendTextMessage(player2, 20, "Your duel will start in " ..
                                       _printTimeDiff(TOURNAMENT_CONFIGS.times.start_duel).. ".")
      
      local cd_time = TOURNAMENT_CONFIGS.times.start_duel - TOURNAMENT_CONFIGS.times.cd_to_duel
      addEvent(function()
        countdown(TOURNAMENT_CONFIGS.times.cd_to_duel)
      end, cd_time * 1000)
    end, TOURNAMENT_CONFIGS.times.tp_to_duel * 1000)
  end

  function _.startBattle(player1, player2)
    --[EDITE AKI PARA MUDAR DUEL SYSTEM]
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.duel_mode, 1) --1x1
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.ballsleft, 6) --6 pokes no duel
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.my_team, 
        getCreatureName(player1)..",") --seu time
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.enemy, 
        getCreatureName(player2)..",") --time adversario
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.dueling, 0) --todo mundo ja aceito 
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.duel.inviter, getCreatureName(player1))

    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.duel_mode, 1) --1x1
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.ballsleft, 6) --6 pokes no duel
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.my_team, 
        getCreatureName(player2)..",") --seu time
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.enemy, 
        getCreatureName(player1)..",") --time adversario
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.dueling, 0) --todo mundo ja aceito 
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.duel.inviter, getCreatureName(player1))

    --[NAO EDITE ISSO!]
    setPlayerStorageValue(player1, TOURNAMENT_CONFIGS.pstos.status, 'DUELING')
    setPlayerStorageValue(player2, TOURNAMENT_CONFIGS.pstos.status, 'DUELING')

    --[EDITE AKI PARA MUDAR DUEL SYSTEM]
    beginDuel(player1, 0)
  end

  -- Public funcs
  function self.getStatus()
    return getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.status)
  end

  function self.getCurrentPlayers()
    return string.explode(getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.current_players), ",")
  end

  function self.getAllPlayers()
    return string.explode(getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.all_players), ",")
  end

  function self.getRound()
    return getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.round)
  end

  function self.getDueling()
    return getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.dueling)
  end

  function self.getWinners()
    return string.explode(getGlobalStorageValue(TOURNAMENT_CONFIGS.gstos.winners), ",")
  end

  function self.isSubscribeOpen()
    return self.getStatus() == 'OPENED'
  end

  function self.subscribe(name)
    local status = self.getStatus()
    if status ~= 'OPENED' then
      print('TOURNAMENT_SYSTEM:subscribe()> Status ('.. status ..') ~= OPENED.')
      return false
    end
    if not self.isPlayerSubscribed(name) then
      _.addSubscribe(name)
      return true
    end
    return false
  end

  function self.isPlayerSubscribed(name)
    return isInArray(self.getAllPlayers(), name)
  end

  function self.removeSubscribe(name)
    local status = self.getStatus()
    if status ~= 'OPENED' then
      print('TOURNAMENT_SYSTEM:removeSubscribe()> Status ('.. status ..') ~= OPENED.')
      return false
    end
    local allPlayers = self.getAllPlayers()
    if not isInArray(allPlayers, name) then
      print('TOURNAMENT_SYSTEM:removeSubscribe()> Player ('.. name ..') not subscribed.')
      return false
    end
    local i = table.find(allPlayers, name)
    table.remove(allPlayers, i)
    _.setAllPlayers(allPlayers)
    return true
  end

  function self.start()
    if not _.openSubscribe() then
      _.finish(true)
      return false
    end
    doBroadcastMessage('The subscribe time for the tournament has started! The tournament will begin in ' ..
                            _printTimeDiff(TOURNAMENT_CONFIGS.times.start_tournament).. '!')

    local time_before = TOURNAMENT_CONFIGS.times.start_tournament - TOURNAMENT_CONFIGS.times.msg_before_tournament 
    addEvent(function()
      if self.getStatus() == 'CLOSED' then return false end
      doBroadcastMessage('The tournament will start in '.. 
                              _printTimeDiff(TOURNAMENT_CONFIGS.times.msg_before_tournament) ..
                              ', hurry up and subscribe!'..
                              ' Remember that you MUST be in the coliseum to participate!')
    end, time_before * 1000)

    addEvent(function()
      if self.getStatus() == 'CLOSED' then return false end
      _.init()
    end, TOURNAMENT_CONFIGS.times.start_tournament * 1000)
    return true
  end

  function self.endBattle(loser)
    if self.getStatus() ~= 'STARTED' or
      getPlayerStorageValue(loser, TOURNAMENT_CONFIGS.pstos.status) == -1 then
      return false
    end
    local winner = getPlayerStorageValue(loser, TOURNAMENT_CONFIGS.pstos.battle) 
    if winner == -1 then --esperando antes do prepareBattle
      if getPlayerStorageValue(loser, TOURNAMENT_CONFIGS.pstos.duel.enemy) ~= -1 then  --duelando enquanto espera
        return false
      else                 --deslogo enquanto esperava
        _.cleanPlayerStos(loser)
        return false
      end
    elseif not isCreature(winner) then
      _.cleanPlayerStos(loser)
      return false   
    end

    for i, player in ipairs({winner, loser}) do
      _.endDuel(player)
      doPlayerAddSkillTry(player, i-1, 30)
      if i == 1 then --winner
        setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status, 'WON') --[NAO EDITE ISSO!]
        if TOURNAMENT_CONFIGS.effects.won_lost_eff then
          doSendAnimatedText(getThingPos(player), "Win", 144)
          doPlayerSendTextMessage(player, 20, "You won!")
        end
      else
        setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status, 'LOST') --[NAO EDITE ISSO!]
        if TOURNAMENT_CONFIGS.effects.won_lost_eff then
          doSendAnimatedText(getThingPos(player), "Lose", 144)
          doPlayerSendTextMessage(player, 20, "You lost!")
        end
      end
      setPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.battle, -1)
    end

    local dueling = self.getDueling()
    if dueling > 0 then
      _.setDueling(dueling - 1)
      if dueling-1 == 0 then
        addEvent(_.nextRound, 100)
      end
    end
  end

  function self.onPokeDies(player)
    if self.getStatus() ~= 'STARTED' then return false end
    if getPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.status) == 'DUELING' and
      getPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.battle) ~= -1 then
      local ballsleft = getPlayerStorageValue(player, TOURNAMENT_CONFIGS.pstos.duel.ballsleft)
      if ballsleft <= 0 then
        self.endBattle(player)
      end
    end
  end

  function self.endTournament(cid)
    if isCreature(cid) and getPlayerAccess(cid) < 5 then
      print('TOURNAMENT_SYSTEM:endTournament()> Player ('.. getCreatureName(cid) ..') tried to end tournament!')
      return false
    end
    _.finish(true)
  end

  if self.getStatus() == -1 then
    _.reset()
  end

  return self
end

-- Global tournament var
TOURNAMENT_SYSTEM = NEW_TOURNAMENT_CLASS()