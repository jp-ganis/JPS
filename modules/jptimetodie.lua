-----------------------
-- TIME TO DIE FRAME
-----------------------

jps.UnitToLiveData = {}
jps.timeToLiveMaxSamples = 30

local JPSEXTInfoFrame = CreateFrame("frame","JPSEXTInfoFrame")
JPSEXTInfoFrame:SetBackdrop({
      bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
      tile=1, tileSize=32, edgeSize=32,
      insets={left=11, right=12, top=12, bottom=11}
})
JPSEXTInfoFrame:SetWidth(150)
JPSEXTInfoFrame:SetHeight(60)
JPSEXTInfoFrame:SetPoint("CENTER",UIParent)
JPSEXTInfoFrame:EnableMouse(true)
JPSEXTInfoFrame:SetMovable(true)
JPSEXTInfoFrame:RegisterForDrag("LeftButton")
JPSEXTInfoFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
JPSEXTInfoFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
JPSEXTInfoFrame:SetFrameStrata("FULLSCREEN_DIALOG")
local infoFrameText = JPSEXTInfoFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- "OVERLAY"
infoFrameText:SetJustifyH("LEFT")
infoFrameText:SetPoint("LEFT", 15, 0)
infoFrameText:SetFont('Fonts\\ARIALN.ttf', 11, 'THINOUTLINE')
local infoTTL = 60
local infoTTD = 60

JPSEXTFrame = CreateFrame("Frame", "JPSEXTFrame")
JPSEXTFrame:SetScript("OnUpdate", function(self, elapsed)
    jps.updateTimeToLive(self, elapsed)
end)
JPSEXTInfoFrame:Hide()

function jps.updateInfoText()
	local infoTexts = ""
	if infoTTL ~= nil and jps.isHealer and infoTTL < 200000 then
		local minutesLive = math.floor(infoTTL / 60)
		local secondsLive = infoTTL - (minutesLive*60)	
		if infoTTL < 200000 then
			infoTexts = infoTexts.."TimeToLive: "..minutesLive.. "min "..secondsLive.. "sec\n"
		else
			infoTexts = "TimeToLive: n/a".."\n"
		end
	end

	if infoTTD ~= nil and infoTTD < 200000 then
		local minutesDie = math.floor(infoTTD / 60)
		local secondsDie = infoTTD - (minutesDie*60)
		infoTexts = infoTexts.."TimeToDie: "..minutesDie.. "min "..secondsDie.. "sec\n"
	else
		infoTexts = infoTexts.."TimeToDie: n/a".."\n"
	end	
	if jps.getConfigVal("show current cast in JPS UI") == 1 then
		local currentCast = "|cff1eff00"..jps.CastBar.currentSpell.."|cffa335ee @ "..jps.CastBar.currentTarget.."\n"
		local message = "|cffffffff"..jps.CastBar.currentMessage
		
		infoTexts = infoTexts..currentCast
		infoTexts = infoTexts..message.."\n"
	end
	if jps.isHealer and jps.getConfigVal("show Lowest Raid Member in UI") == 1  then
		infoTexts = infoTexts.."|cffffffffLowestInRaid: |cffa335ee"..jps.LowestInRaidStatus().."\n"
	end
	if jps.getConfigVal("show Latency in JPS UI") == 1 then
		if jps.CastBar.latency ~= 0 then
			local latency = jps.CastBar.latency
			infoTexts = infoTexts.."|cffffffffLatency: ".."|cFFFF0000"..latency
		end
	end
	infoFrameText:SetText(infoTexts)
end

function jps.updateTimeToLive(self, elapsed)
	if UnitAffectingCombat("player") == nil then return end
	if self.TimeToLiveSinceLastUpdate == nil then self.TimeToLiveSinceLastUpdate = 0 end
    self.TimeToLiveSinceLastUpdate = self.TimeToLiveSinceLastUpdate + elapsed
    if (self.TimeToLiveSinceLastUpdate > jps.UpdateInterval) then
        if jps.Combat and UnitExists("target") then
            self.TimeToLiveSinceLastUpdate = 0
        end
        infoTTL = jps.TimeToLive("target")
		infoTTD = jps.TimeToDie("target")
        jps.updateInfoText()
    end
end

-----------------------
-- TIME TO DIE
-----------------------

function jps.updateUnitTimeToLive(unit)
    local guid = UnitGUID(unit)
    if jps.UnitToLiveData[guid] == nil then jps.UnitToLiveData[guid] = {} end
    local dataset = jps.UnitToLiveData[guid]
    local data = table.getn(dataset)
    if data > jps.timeToLiveMaxSamples then table.remove(dataset, jps.timeToLiveMaxSamples) end
    table.insert(dataset, 1, {GetTime(), UnitHealth(unit)})
    jps.UnitToLiveData[guid] = dataset
end

-- table.getn Returns the size of a table, If the table has an n field with a numeric value, this value is the size of the table.
-- Otherwise, the size is the largest numerical index with a non-nil value in the table
-- we supply 3 arguments to the table.insert(table,position,value) function.
-- We can also use the table.remove(table,position) to remove elements from a table array.
-- jps.UnitToLiveData[guid] = { [1] = {GetTime(), UnitHealth(unit)} , [2] = {GetTime(), UnitHealth(unit)} , [3] = {GetTime(), UnitHealth(unit)} }

function jps.clearTimeToLive()
    jps.UnitToLiveData = {}
    jps.RaidTimeToDie = {}
	jps.RaidTimeToLive = {}
end

function jps.UnitTimeToLive(unit)
	if unit == nil then return 60 end
    local guid = UnitGUID(unit)
	local health_unit = UnitHealth(unit)
	local timetolive = 60 -- e.g. 60 seconds
	local totalDmg = 1 -- to avoid 0/0
	local incomingDps = 1
	
    if jps.UnitToLiveData[guid] ~= nil then
        local dataset = jps.UnitToLiveData[guid]
        local data = table.getn(dataset)
        if #dataset > 1 then
        	local timeDelta = dataset[1][1] - dataset[data][1] -- (lasttime - firsttime)
			local totalTime = math.max(timeDelta, 1)
        	totalDmg = dataset[data][2] - dataset[1][2] -- (UnitHealth_old - UnitHealth_last) = Health Loss
        	incomingDps = math.ceil(totalDmg / totalTime)
			if incomingDps <= 0 then incomingDps = 1 end
        end
		timetolive = math.ceil(health_unit / incomingDps)
    end
    return timetolive
end

function jps.TimeToLive(unit)
	if unit == nil then return 60 end
    local guid = UnitGUID(unit)
	local health_unit = UnitHealth(unit)
	local timetolive = 60 -- e.g. 60 seconds
	local totalDmg = 1 -- to avoid 0/0
	local incomingDps = 1
	
    if jps.RaidTimeToLive[guid] ~= nil then
        local dataset = jps.RaidTimeToLive[guid]
        local data = table.getn(dataset)
        if #dataset > 1 then
        	local timeDelta = dataset[1][1] - dataset[data][1] -- (lasttime - firsttime)
			local totalTime = math.max(timeDelta, 1)
        	totalDmg = dataset[data][2] - dataset[1][2] -- (UnitHealth_old - UnitHealth_last) = Health Loss
        	incomingDps = math.ceil(totalDmg / totalTime)
			if incomingDps <= 0 then incomingDps = 1 end
        end
		timetolive = math.ceil(health_unit / incomingDps)
    end
    return timetolive
end

-- jps.RaidTimeToDie[unitGuid] = { [1] = {GetTime(), eventtable[15] },[2] = {GetTime(), eventtable[15] },[3] = {GetTime(), eventtable[15] } }
function jps.TimeToDie(unit, percent)
	local unitGuid = UnitGUID(unit)
	local health = UnitHealth(unit)
	if health == UnitHealthMax(unit) then
		return 100000
	end
	local time = GetTime()
    local timeToDie = jps.timeToDieFunctions[jps.timeToDieAlgorithm][1](jps.RaidTimeToDie[unitGuid],health,time)
    
	if percent ~= nil and timeToDie ~= nil then
		curPercent = health/UnitHealthMax(unit)
		if curPercent > percent then
			timeToDie = (curPercent-percent)/(curPercent/timeToDie)
		else
			timeToDie = 0
		end
	end
	
	if timeToDie ~= nil then return math.ceil(timeToDie) else return 100000 end
end

-- FRIEND UNIT WITH THE LOWEST TIMETODIE -- USAGE FOR HEALING TO SHIELD INCOMING DAMAGE
function jps.LowestTimetoLive()
	local lowestUnit = jpsName
	local timetolive = 60
	
	for unit, index in pairs(jps.RaidStatus) do
		local timetoliveUnit = jps.TimeToLive(unit)
		if (index["inrange"] == true) and timetoliveUnit < timetolive then
			timetolive = timetoliveUnit
			lowestUnit = unit
		end
	end
	return lowestUnit
end

---------------------------------------------------
-- SLIDER UPDATE INTERVAL
---------------------------------------------------

function jps_round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

local slider = CreateFrame("Slider","UpdateInterval",JPSEXTInfoFrame,"OptionsSliderTemplate") --frameType, frameName, frameParent, frameTemplate  

slider:ClearAllPoints()
slider:SetPoint("TOP",0,20)
--slider:SetWidth(120)
--slider:SetHeight(12)
slider:SetScale(0.8)
slider:SetMinMaxValues(0.05, 0.5)
slider.minValue, slider.maxValue = slider:GetMinMaxValues()
slider:SetValue(0.2)
slider:SetValueStep(0.05)
slider:EnableMouse(true)
local latency = jps_round(jps.CastBar.latency,3)
getglobal(slider:GetName() .. 'Low'):SetText('0.05')
getglobal(slider:GetName() .. 'High'):SetText('0.5')
getglobal(slider:GetName() .. 'Text'):SetText("Update Interval")

local function slider_OnClick(self)
	jps.UpdateInterval = jps_round(slider:GetValue(),2)
	write("jps.UpdateInterval set to: "..jps.UpdateInterval)
end

slider:SetScript("OnValueChanged", function(self,event)
	if jps.UpdateInterval ~= jps_round(slider:GetValue(),2) then
		slider_OnClick(self)
	end
end)
