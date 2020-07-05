
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

local function getRollText(index)
  for k, v in pairs(ROLL) do
    if (v == index) then
      return k
    end
  end
  return "Missing Roll in getRollText(index)"
end

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

local rollDefault = ROLL.GREED
local debug = false

--------------------------------------------------------------
---- helper functions
--------------------------------------------------------------

local addonName = "ZGBijouRoller"

local bijouFrame = CreateFrame("Frame", addonName)
local panel = CreateFrame("Frame", addonName .. "Panel")
local saveSettingsButton = CreateFrame("CheckButton", "saveSettingsButton", panel, "ChatConfigCheckButtonTemplate")
saveSettingsButton:SetScript("OnClick",
  function()
    ZGBijouRollerSettings["saveSettings"] = not ZGBijouRollerSettings["saveSettings"]
  end
)
local bijouDropDown = CreateFrame("FRAME", "bijouDropDown", panel, "UIDropDownMenuTemplate")
local coinDropDown = CreateFrame("FRAME", "coinDropDown", panel, "UIDropDownMenuTemplate")
local seperateRollsButton = CreateFrame("CheckButton", "seperateRollsButton", panel, "ChatConfigCheckButtonTemplate")
seperateRollsButton:SetScript("OnClick",
  function()
    ZGBijouRollerSettings["seperateRolls"] = not ZGBijouRollerSettings["seperateRolls"]
    if (ZGBijouRollerSettings["seperateRolls"]) then
      coinDropDown:Show()
    else
      coinDropDown:Hide()
    end
  end
)

-- print the current roll behaviour
local function printRollBehavior()
  for k, v in pairs(ROLL) do
    if (v == ZGBijouRollerSettings["rollBijou"]) then
      print(format("current roll behaviour for BIJOUs: %s", k))
    end
    if (ZGBijouRollerSettings["seperateRolls"] and v == ZGBijouRollerSettings["rollCoin"]) then
      print(format("current roll behaviour for COINs:  %s", k))
    end
  end
  if (not ZGBijouRollerSettings["seperateRolls"]) then
    print("coin roll behaviour is locked to bijou behaviour")
  end
end

-- function for clicking on the bijou dropdown in the options panel
local function bijouDropDown_OnClick(_, arg1)
  ZGBijouRollerSettings["rollBijou"] = arg1
  UIDropDownMenu_SetText(bijouDropDown, getRollText(arg1))
end

-- initialization of the bojou dropdown panel
local function initBijouDropDown(dropDown, level, menuList)
  local info = UIDropDownMenu_CreateInfo()
  info.func = bijouDropDown_OnClick
  for k, v in pairs(ROLL) do
    info.text = k
    info.arg1 = v
    info.checked = v == ZGBijouRollerSettings["rollBijou"]
    UIDropDownMenu_AddButton(info)
  end
end

-- function for clicking on the coin dropdown in the options panel
local function coinDropDown_OnClick(_, arg1)
  ZGBijouRollerSettings["rollCoin"] = arg1
  UIDropDownMenu_SetText(coinDropDown, getRollText(arg1))
end

-- initialization of the coin dropdown panel
local function initCoinDropDown(dropDown, level, menuList)
  local info = UIDropDownMenu_CreateInfo()
  info.func = coinDropDown_OnClick
  for k, v in pairs(ROLL) do
    info.text = k
    info.arg1 = v
    info.checked = v == ZGBijouRollerSettings["rollCoin"]
    UIDropDownMenu_AddButton(info)
  end
end

-- setter for ZGBijouRollerSettings["seperateRolls"]
local function setSeperateRolls(value)
  ZGBijouRollerSettings["seperateRolls"] = value
  seperateRollsButton:SetChecked(ZGBijouRollerSettings["seperateRolls"])
  if (ZGBijouRollerSettings["seperateRolls"]) then
    coinDropDown:Show()
  else
    coinDropDown:Hide()
  end
end

-- initialization of the addon panel
local function InitializePanel()
  panel.name = "ZG Bijou Roller"

  InterfaceOptions_AddCategory(panel)

  local title = panel:CreateFontString(addonName .. "Title", "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -12)
  title:SetText(panel.name)

  -- save settings
  local saveSettingsText = panel:CreateFontString(addonName .. "saveSettingsText", "OVERLAY", "GameFontNormalSmall")
  saveSettingsText:SetPoint("TOPLEFT", 35, -45)
  saveSettingsText:SetText("Load all these settings after a relog / reloadui ?")

  local saveSettingsText2 = panel:CreateFontString(addonName .. "saveSettingsText2", "OVERLAY", "GameFontNormalSmall")
  saveSettingsText2:SetPoint("TOPLEFT", 35, -65)
  saveSettingsText2:SetText(format("If not, the default roll behaviour (%s) will ge selected again.", getRollText(rollDefault)))

  saveSettingsButton:SetPoint("TOPLEFT", 10, -48)
  saveSettingsButton:SetChecked(ZGBijouRollerSettings["saveSettings"])

  -- bijou behaviour
  local bijouRollText = panel:CreateFontString(addonName .. "bijouRollText", "OVERLAY", "GameFontNormalSmall")
  bijouRollText:SetPoint("TOPLEFT", 10, -135)
  bijouRollText:SetText("Bijou rolls:")

  bijouDropDown:SetPoint("TOPLEFT", 0, -150)
  UIDropDownMenu_SetText(bijouDropDown, getRollText(ZGBijouRollerSettings["rollBijou"]))
  UIDropDownMenu_Initialize(bijouDropDown, initBijouDropDown, 1)

  local seperateRollsText = panel:CreateFontString(addonName .. "seperateRollsText", "OVERLAY", "GameFontNormalSmall")
  seperateRollsText:SetPoint("TOPLEFT", 220, -135)
  seperateRollsText:SetText("Roll Coins separably?")

  seperateRollsButton:SetPoint("TOPLEFT", 260, -150)
  seperateRollsButton:SetChecked(ZGBijouRollerSettings["seperateRolls"])

  -- coin behaviour
  local coinRollText = panel:CreateFontString(addonName .. "coinRollText", "OVERLAY", "GameFontNormalSmall")
  coinRollText:SetPoint("TOPLEFT", 360, -135)
  coinRollText:SetText("Coin rolls:")

  coinDropDown:SetPoint("TOPLEFT", 350, -150)
  UIDropDownMenu_SetText(coinDropDown, getRollText(ZGBijouRollerSettings["rollCoin"]))
  UIDropDownMenu_Initialize(coinDropDown, initCoinDropDown, 1)

  if (not ZGBijouRollerSettings["seperateRolls"]) then
    coinDropDown:Hide()
  end

  -- info footer
  local info1 = panel:CreateFontString(addonName .. "info1", "OVERLAY", "GameFontNormalSmall")
  info1:SetPoint("TOPLEFT", 70, -335)
  info1:SetText("All options will be saved immediatly without using the Okay or Cancel Button below.")

  local helpText = panel:CreateFontString(addonName .. "Help", "OVERLAY", "GameFontNormalSmall")
  helpText:SetPoint("TOPLEFT", 10, -400)
  helpText:SetText("For more information, type /zgroll")
end

-- ADDON_LOADED
function bijouFrame:ADDON_LOADED(eventName)
  if (debug) then
    print(format("event found in bijouFrame:ADDON_LOADED: %s", eventName))
  end
  if (eventName == addonName) then
    if (ZGBijouRollerSettings == nil or not ZGBijouRollerSettings["saveSettings"]) then
      ZGBijouRollerSettings = {}
      ZGBijouRollerSettings["rollBijou"] = rollDefault
      ZGBijouRollerSettings["rollCoin"] = rollDefault
    else
      if (ZGBijouRollerSettings["rollBijou"] == nil) then
        ZGBijouRollerSettings["rollBijou"] = rollDefault
      end
      if (ZGBijouRollerSettings["rollCoin"] == nil) then
        ZGBijouRollerSettings["rollCoin"] = rollDefault
      end
    end
    InitializePanel()
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
    if (ZGBijouRollerSettings["seperateRolls"] and rollOnCoin[name]
      and (ZGBijouRollerSettings["rollCoin"] == ROLL.NEED and canNeed
        or ZGBijouRollerSettings["rollCoin"] == ROLL.GREED and canGreed
        or ZGBijouRollerSettings["rollCoin"] == ROLL.PASS)) then
      if (debug) then
        print(format("item match. rolling for coin: %s", ZGBijouRollerSettings["rollCoin"]))
      end
      RollOnLoot(rollID, ZGBijouRollerSettings["rollCoin"])
    elseif (ZGBijouRollerSettings["rollBijou"] == ROLL.NEED and canNeed
      or ZGBijouRollerSettings["rollBijou"] == ROLL.GREED and canGreed
      or ZGBijouRollerSettings["rollBijou"] == ROLL.PASS) then
      if (debug) then
        print(format("item match. rolling for bijou: %s", ZGBijouRollerSettings["rollBijou"]))
      end
      RollOnLoot(rollID, ZGBijouRollerSettings["rollBijou"])
    else
      print("You found a bug, please report it with the following informations!")
      print("Buginfo:")
      print(string.format("name: %s", name))
      print(string.format("canNeed: %s", canNeed))
      print(string.format("canGreed: %s", canGreed))
      print(string.format("rollCoin: %s", ZGBijouRollerSettings["rollCoin"]))
      print(string.format("rollBijou: %s", ZGBijouRollerSettings["rollBijou"]))
      print(string.format("seperateRolls: %s", ZGBijouRollerSettings["seperateRolls"]))
    end
  end
end

function bijouFrame:RAID_INSTANCE_WELCOME(name)
  local zg = C_Map.GetAreaInfo(1977)
  if (debug) then
    print(format("zone name: %s", name))
    print(format("localized Zul'Gurub: %s", zg))
  end
  if (name == zg) then
    print("ZG Bijou Roller active")
    printRollBehavior()
    print("For more information type /zgroll help")
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
    bijouDropDown_OnClick(nil, ROLL.NEED)
    printRollBehavior()
  elseif (msg == "greed") then
    bijouDropDown_OnClick(nil, ROLL.GREED)
    printRollBehavior()
  elseif (msg == "pass") then
    bijouDropDown_OnClick(nil, ROLL.PASS)
    printRollBehavior()
  elseif (msg == "help") then
    printHelp()
  else
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel) -- one call will only open the normal interface options. blizzard bug?
  end
end

-- handler for coin commands
local function handlerCoin(msg)
  if (msg == "need") then
    coinDropDown_OnClick(nil, ROLL.NEED)
    setSeperateRolls(true)
    printRollBehavior()
  elseif (msg == "greed") then
    coinDropDown_OnClick(nil, ROLL.GREED)
    setSeperateRolls(true)
    printRollBehavior()
  elseif (msg == "pass") then
    coinDropDown_OnClick(nil, ROLL.PASS)
    setSeperateRolls(true)
    printRollBehavior()
  elseif (msg == "lock") then
    setSeperateRolls(false)
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
bijouFrame:RegisterEvent("RAID_INSTANCE_WELCOME")
bijouFrame:SetScript(
  "OnEvent",
  function(self, event, ...)
    if (bijouFrame[event]) then
      bijouFrame[event](self, ...)
    end
  end
)
