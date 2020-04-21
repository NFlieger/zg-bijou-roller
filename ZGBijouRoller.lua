
--------------------------------------------------------------
---- Data
--------------------------------------------------------------

local ITEM_IDS = {
  19698, -- Zulian Coin
  19699, -- Razzashi Coin
  19700, -- Hakkari Coin
  19701, -- Gurubashi Coin
  19702, -- Vilebranch Coin
  19703, -- Witherbark Coin
  19704, -- Sandfury Coin
  19705, -- Skullsplitter Coin
  19706, -- Bloodscalp Coin
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

local rollOn = {}

function rollOn:addItem(itemId)
  local item = Item:CreateFromItemID(itemId)
	item:ContinueOnItemLoad(
		function()
      if (debug) then
        print(format("item added to auto loot: %d - %s", itemId, item:GetItemName()))
      end
			rollOn[item:GetItemName()] = true
		end
	)
end

---- options

local debug = false
local rollBehaviour = ROLL.GREED

--------------------------------------------------------------
---- helper functions
--------------------------------------------------------------

local EVENT_NAME = "ZGBijouRoller"

local bijouFrame = CreateFrame("Frame", EVENT_NAME)

-- ADDON_LOADED
function bijouFrame:ADDON_LOADED(eventName)
  if (debug) then
    print(format("event found in bijouFrame:ADDON_LOADED: %s", eventName))
  end
  if (eventName == EVENT_NAME) then
    for k, _ in pairs(ITEM_IDS) do
      rollOn:addItem(ITEM_IDS[k])
      if (debug) then
        print(format("item added: %d",ITEM_IDS[k]))
      end
    end
    
    if (debug) then
      print(format("ZGBijouRoller loaded with: %s", rollBehaviour))
    end
  end
end

-- START_LOOT_ROLL
function bijouFrame:START_LOOT_ROLL(rollID)
  local _, name, _, _, _, canNeed, canGreed, _ = GetLootRollItemInfo(rollID)
  if (rollOn[name]) then
    if (debug) then
      print(format("item match. rolling: %s", rollBehaviour))
      print(format("canNeed: %s", tostring(canNeed)))
      print(format("canGreed: %s", tostring(canGreed)))
    end
    if (rollBehaviour == ROLL.NEED and canNeed
      or rollBehaviour == ROLL.GREED and canGreed
      or rollBehaviour == ROLL.PASS) then
      RollOnLoot(rollID, rollBehaviour)
    end
  end
end

-- print help on how to use the command line
local function printHelp()
  print("ZG Bijou Roller usage:")
  print("/zgbijouroller debug : toggle debug modus")
  print("/bijouroll need  : roll need on all bijous and coins in zg")
  print("/bijouroll greed : roll greed on all bijous and coins in zg")
  print("/bijouroll pass  : pass on all bijous and coins in zg")
  print("/bijouroll current : prints the current roll behavior")
end

-- print the current roll behaviour
local function printRollBehavior()
  for k, v in pairs(ROLL) do
    if (v == rollBehaviour) then
      print(format("bijou roll behaviour changed to %s", k))
      return
    end
  end
end

--------------------------------------------------------------
---- CLI
--------------------------------------------------------------

-- command line handler
local function handler(msg)
  if (msg == "debug") then    
    debug = not debug
    if (debug) then 
      print("debug is now on")
    else 
      print("debug is now off")
    end
  elseif (msg == "current") then
    printRollBehavior()
  elseif (msg == "need") then
    rollBehaviour = ROLL.NEED
    printRollBehavior()
  elseif (msg == "greed") then
    rollBehaviour = ROLL.GREED
    printRollBehavior()
  elseif (msg == "pass") then
    rollBehaviour = ROLL.PASS
    printRollBehavior()
  else
    printHelp()
  end
end

--------------------------------------------------------------
---- handles
--------------------------------------------------------------

-- CLI
SLASH_ZGBIJOUROLLER1 = '/zgbijouroller'
SLASH_ZGBIJOUROLLER2 = '/bijouroll'
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
