Agatha = {
  stoIni = 854880, --sto inicial da quest
  stoRec = 854881, --sto dos actionsIDs receita
  stoEni = 854882, --sto do enigma
  stoRes = 854883, --sto da resposta do enigma
  
  stoPergs = {854884, 854885, 854886, 854887, 854888, 854889, 854890, 854891, 854892, 854893, 854894, 854895, 854896, 854897, 854898}, --sto charadas
  
  allStos = {854880, 854881, 854882, 854883}, 
  
  colar = 2173, --id do colar da agatha
  hammer = 4846, --id do hammer
  pilar = 3900, --id do pilar q tem q usar o hammer
  pocao = 2007, --id da pocao pra ser usada nas estantes
  
  posLab = {x = 1557, y = 1119, z = 10}, --pos do labirinto
  posQuest = {x = 1563, y = 1103, z = 9}, --pos da quest
  
  fromPos = {x = 1525, y = 1084, z = 8}, --pos superior da area dos dark abras
  toPos = {x = 1566, y = 1128, z = 8}, --pos inferior da area dos dark abras
       
  charadas = {
    --{c = charada, r = actionid do item resposta}
    {c = "Take a kitasatos.", r = 6631}, --tube, emcima da mesa
    {c = "Plasmother remains.", r = 6633}, --gosma verde
    {c = "Maurizio pollini.", r = 6639}, --piano
    {c = "Human eye.", r = 6642}, --beholder eye
    {c = "Hard tail.", r = 6623}, --onix tail
    
    {c = "Squirtle's house.", r = 6637}, --turtle hull
    {c = "Bug venom.", r = 6624}, --bug venom
    {c = "Found in the desert.", r = 6625}, --sandbag
    {c = "Voodoo doll.", r = 6635}, --voodoo doll
    {c = "Future piece of a raticate.", r = 6634}, --rat tail
    {c = "Bloodsucker wings.", r = 6628}, --bat wing
    {c = "Dragon claw.", r = 6622}, --dragon clawn
    {c = "Small pieces of spring.", r = 6632}, --leaves, mesa  
    
    {c = "Take a tube.", r = 6630}, --tube[1]
    {c = "Bat wing.", r = 6628}, --bat wing
    {c = "Take a pot.", r = 6647}, --panela
    {c = "Take a pipe.", r = 6626}, --water-pipe
    {c = "I can't move...frozen...", r = 6652}, --frazen human
    {c = "Insect can step but a giant can die.", r = 6649}, --trap
    {c = "Our guide.", r = 6642}, --beholder eye
    {c = "The most common colors are brown, blue, green and black.", r = 6642}, --beholder eye
    {c = "Dark bloodsucker wings.", r = 6646}, --black bat wing
    {c = "Plank.", r = 6640}, --madeira
    
    {c = "Bear paw.", r = 6648}, --bear paw
    {c = "Concentration of human energy.", r = 6620}, --soul orb
    {c = "Onix tail.", r = 6623}, --onix tail
    {c = "Darkness eye.", r = 6617}, --dracola eye
    {c = "Played by keys.", r = 6639}, --piano
    {c = "If you lose a hand you can use instead.", r = 6621}, --gancho
    {c = "You can see the shape of the earth.", r = 6618}, --mapa
    {c = "Wood.", r = 6640}, --madeira
    {c = "Pirates like it.", r = 6621}, --gancho
    
    {c = "Trap.", r = 6649}, --trap
    {c = "Weapons and legs of a giant.", r = 6648}, --bear paw
    {c = "Take a bowl.", r = 6650}, --bowl
    {c = "Small leaves.", r = 6632}, --small leaves
    {c = "The most powerful weapon of a insect.", r = 6636}, --pinsir horn
    {c = "The most popular is used in bears.", r = 6649}, --trap
    {c = "Piano.", r = 6639}, --piano
    {c = "House of a insect.", r = 6638}, --mel
    {c = "Leaves.", r = 6653}, --leaves, estantes
    {c = "Brown claws.", r = 6648}, --bear paw
    {c = "Dragon claw.", r = 6622}, --dragon claw
    {c = "Insect's weapon.", r = 6624}, --bug venom
    {c = "Soul orb.", r = 6620}, --soul orb
    
    {c = "Monster's plasma.", r = 6633}, --gosma verde
    {c = "You can find wine inside.", r = 6627}, --big cask
    {c = "People dream using this in a journey.", r = 6619}, --pokeball
    {c = "Shadow eye.", r = 6617}, --dracula eye
    {c = "Granular material.", r = 6625}, --sandbag
    {c = "Pokeball.", r = 6619}, --pokeball
    {c = "You can store oil inside.", r = 6627}, --big cask
    {c = "It can distinguish about 10 million colors.", r = 6642}, --behonder eye
    {c = "Dracola's eye.", r = 6617}, --dracula eye
    {c = "Green and disgusting.", r = 6633}, --gosma verde
    {c = "Hands.", r = 6648}, --bear paw
    
    {c = "Its cold here, im freezing...", r = 6652}, --frozen human
    {c = "Flowers.", r = 6651}, --flowers
    {c = "Honeycomb.", r = 6638}, --mel
    {c = "Plant armor.", r = 6640}, --madeira
    {c = "Termite food.", r = 6640}, --madeira
    {c = "The trainers weapon.", r = 6619}, --pokeball
    {c = "Traveler best friend.", r = 6618}, --mapa
    {c = "Essence incorporeal.", r = 6620}, --soul orb
    {c = "Green remains.", r = 6633}, --gosma verde
    {c = "Big cask.", r = 6627}, --big cask
    {c = "It has a powerful poison.", r = 6624}, --bug venom
    {c = "Used in dark magic.", r = 6635}, --voodoo
    
    {c = "A tail of a furious.", r = 6629}, --gya furious
    {c = "It does not have teeth problems.", r = 6643}, --fang
    {c = "Green sharps.", r = 6653}, --leaves estantes
    {c = "Piece of spring.", r = 6651}, --flowers
    {c = "Sweet taste.", r = 6638}, --mel
    {c = "Rocks.", r = 6623}, --onix tail
    {c = "Elder fang.", r = 6643}, --fang
    {c = "Used to eat leaves.", r = 6624}, --bug venom
  }, 
}

--[[
  boost stone = 12415
  bilhete = 10308

  actions usados 6600-6661 
    Estantes = 6600-6615
    Bau Colar = 6616
    Receita = 6654
    Enigma = 6655
    Black Book = 6656
    Espelho Labirinto = 6657
    Espelho Out = 6658
    receita[2] = 6659
    poçao final = 6660
    martelo final = 6661
]]--
