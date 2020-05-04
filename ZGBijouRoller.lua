
--------------------------------------------------------------
---- Data
--------------------------------------------------------------

local COIN_IDS = {
  19698, -- Zulian Coin
  19699, -- Razzashi Coin
  19700, -- Hakkari Coin
  19701, -- Gurubashi Coin
  19702, -- Vilebranch Coin
  19703, -- Witherbark Coin
  19704, -- Sandfury Coin
  19705, -- Skullsplitter Coin
  19706, -- Bloodscalp Coin
}

local BIJOU_IDS = {
  19707, -- Red Hakkari Bijou
  19708, -- Blue Hakkari Bijou
  19709, -- Yellow Hakkari Bijou
  19710, -- Orange Hakkari Bijou
  19711, -- Green Hakkari Bijou
  19712, -- Purple Hakkari Bijou
  19713, -- Bronze Hakkari Bijou
  19714, -- Silver Hakkari Bijou
  19715, -- Gold Hakkari Bijou
}

local ROLL = {
  PASS  = 0,
  NEED  = 1,
  GREED = 2
}

local rollOnCoin = {}
local rollOnBijou = {}

function rollOnCoin:addItem(itemId)
  local item = Item:CreateFromItemID(itemId)
  item:ContinueOnItemLoad(
    function()
      if (debug) then
        print(format("item added to auto loot: %d - %s", itemId, item:GetItemName()))
      end
      rollOnCoin[item:GetItemName()] = true
    end
  )
end

function rollOnBijou:addItem(itemId)
  local item = Item:CreateFromItemID(itemId)
  item:ContinueOnItemLoad(
    function()
      if (debug) then
        print(format("item added to auto loot: %d - %s", itemId, item:GetItemName()))
      end
      rollOnBijou[item:GetItemName()] = true
    end
  )
end

---- options

local debug = false
local rollBijou = ROLL.GREED
local seperateRolls = false
local rollCoin = rollBijou

--------------------------------------------------------------
---- helper functions
--------------------------------------------------------------

local EVENT_NAME = "ZGBijouRoller"

local bijouFrame = CreateFrame("Frame", EVENT_NAME)

-- print the current roll behaviour
local function printRollBehavior()
  for k, v in pairs(ROLL) do
    if (v == rollBijou) then
      print(format("current roll behaviour for bijous: %s", k))
    end
    if (seperateRolls and v == rollCoin) then
      print(format("current roll behaviour for coins:  %s", k))
    end
  end
  if (not seperateRolls) then
    print("coin roll behaviour is locked to bijou behaviour")
  end
end

-- ADDON_LOADED
function bijouFrame:ADDON_LOADED(eventName)
  if (debug) then
    print(format("event found in bijouFrame:ADDON_LOADED: %s", eventName))
  end
  if (eventName == EVENT_NAME) then
    for k, _ in pairs(COIN_IDS) do
      rollOnCoin:addItem(COIN_IDS[k])
      if (debug) then
        print(format("item added: %d",COIN_IDS[k]))
      end
    end
    for k, _ in pairs(BIJOU_IDS) do
      rollOnBijou:addItem(BIJOU_IDS[k])
      if (debug) then
        print(format("item added: %d",BIJOU_IDS[k]))
      end
    end

    if (debug) then
      print("ZGBijouRoller loaded.")
      printRollBehavior()
    end
  end
end

-- START_LOOT_ROLL
function bijouFrame:START_LOOT_ROLL(rollID)
  local _, name, _, _, _, canNeed, canGreed, _ = GetLootRollItemInfo(rollID)
  if (rollOnBijou[name] or rollOnCoin[name]) then
    if (debug) then
      print(format("canNeed: %s", tostring(canNeed)))
      print(format("canGreed: %s", tostring(canGreed)))
    end
    if (seperateRolls and rollOnCoin[name]
      and (rollCoin == ROLL.NEED and canNeed
        or rollCoin == ROLL.GREED and canGreed
        or rollCoin == ROLL.PASS)) then
      if (debug) then
        print(format("item match. rolling for coin: %s", rollCoin))
      end
      RollOnLoot(rollID, rollCoin)
    elseif (rollBijou == ROLL.NEED and canNeed
      or rollBijou == ROLL.GREED and canGreed
      or rollBijou == ROLL.PASS) then
      if (debug) then
        print(format("item match. rolling for bijou: %s", rollBijou))
      end
      RollOnLoot(rollID, rollBijou)
    else
      print("You found a bug, please report it with the following informations!")
      print("Buginfo:")
      print(string.format("name: %s", name))
      print(string.format("canNeed: %s", canNeed))
      print(string.format("canGreed: %s", canGreed))
      print(string.format("rollCoin: %s", rollCoin))
      print(string.format("rollBijou: %s", rollBijou))
      print(string.format("seperateRolls: %s", seperateRolls))
    end
  end
end

-- print help on how to use the command line
local function printHelp()
  print("ZG Bijou Roller usage:")
  print("By default the rolls by coins are the same as for bijous.")
  print("If you omit the itemtype in the command, bijou will be taken as default.")
  print("/zgroll [bj|bijou|c|coin]? need  : roll need on all bijous or coins in zg")
  print("/zgroll [bj|bijou|c|coin]? greed : roll greed on all bijous or coins in zg")
  print("/zgroll [bj|bijou|c|coin]? pass  : pass on all bijous or coins in zg")
  print("/zgroll [c|coin]? lock : locks the roll behaviour for coins to be the same as for bijous")
  print("/zgroll current : prints the current roll behavior")
  print("/zgbijouroller debug : toggle debug modus")
end

--------------------------------------------------------------
---- CLI
--------------------------------------------------------------

-- handler for bijou commands
local function handlerBijou(msg)
  if (msg == "need") then
    rollBijou = ROLL.NEED
    printRollBehavior()
  elseif (msg == "greed") then
    rollBijou = ROLL.GREED
    printRollBehavior()
  elseif (msg == "pass") then
    rollBijou = ROLL.PASS
    printRollBehavior()
  else
    printHelp()
  end
end

-- handler for coin commands
local function handlerCoin(msg)
  if (msg == "need") then
    rollCoin = ROLL.NEED
    seperateRolls = true
    printRollBehavior()
  elseif (msg == "greed") then
    rollCoin = ROLL.GREED
    seperateRolls = true
    printRollBehavior()
  elseif (msg == "pass") then
    rollCoin = ROLL.PASS
    seperateRolls = true
    printRollBehavior()
  elseif (msg == "lock") then
    seperateRolls = false
    printRollBehavior()
  else
    printHelp()
  end
end

-- command line handler
local function handler(msg)
  local bijouPattern = "^bijous?%s+(.*)"
  local bjPattern = "^bjs?%s+(.*)"
  local coinPattern = "^coins?%s+(.*)"
  local cPattern = "^cs?%s+(.*)"
  if (msg == "debug") then    
    debug = not debug
    if (debug) then 
      print("debug is now on")
    else 
      print("debug is now off")
    end
  elseif (msg == "current") then
    printRollBehavior()
  elseif (string.match(msg, bijouPattern)) then
    local command = string.match(msg, bijouPattern)
    handlerBijou(string.lower(command))
  elseif (string.match(msg, bjPattern)) then
    local command = string.match(msg, bjPattern)
    handlerBijou(string.lower(command))
  elseif (string.match(msg, coinPattern)) then
    local command = string.match(msg, coinPattern)
    handlerCoin(string.lower(command))
  elseif (string.match(msg, cPattern)) then
    local command = string.match(msg, cPattern)
    handlerCoin(string.lower(command))
  else
    handlerBijou(string.lower(msg))
  end
end


--------------------------------------------------------------
---- handles
--------------------------------------------------------------

-- CLI
SLASH_ZGBIJOUROLLER1 = '/zgbijouroller'
SLASH_ZGBIJOUROLLER2 = '/bijouroll'
SLASH_ZGBIJOUROLLER3 = '/bijouroller'
SLASH_ZGBIJOUROLLER4 = '/zgroll'
SlashCmdList["ZGBIJOUROLLER"] = handler

bijouFrame:RegisterEvent("ADDON_LOADED")
bijouFrame:RegisterEvent("START_LOOT_ROLL")
bijouFrame:SetScript(
  "OnEvent",
  function(self, event, ...)
    if (bijouFrame[event]) then
      bijouFrame[event](self, ...)
    end
  end
)
