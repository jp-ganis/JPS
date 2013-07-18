-- Time To Die Update Function-----------------------
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
local infoTTD = 60

JPSEXTFrame = CreateFrame("Frame", "JPSEXTFrame")
JPSEXTFrame:SetScript("OnUpdate", function(self, elapsed)
    jps.updateTimeToLive(self, elapsed)
end)
JPSEXTInfoFrame:Hide()

function jps.updateInfoText()
	local infoTexts = ""

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
			local latency = jps_round(jps.CastBar.latency,2)
			infoTexts = infoTexts.."|cffffffffLatency: ".."|cFFFF0000"..latency
		end
	end
	infoFrameText:SetText(infoTexts)
end

function jps.updateTimeToLive(self, elapsed)
	if self.TimeToLiveSinceLastUpdate == nil then self.TimeToLiveSinceLastUpdate = 0 end
    self.TimeToLiveSinceLastUpdate = self.TimeToLiveSinceLastUpdate + elapsed
    if (self.TimeToLiveSinceLastUpdate > jps.UpdateInterval) then
        if jps.Combat and UnitExists("target") then
            self.TimeToLiveSinceLastUpdate = 0
        end
		infoTTD = jps.TimeToDie("target")
        jps.updateInfoText()
    end
end

-----------------------
-- TIME TO DIE
-----------------------

function updateTimeToDie(elapsed, unit)
	if not unit then
			updateTimeToDie(elapsed, "target")
			updateTimeToDie(elapsed, "focus")
			updateTimeToDie(elapsed, "mouseover")
			for id = 1, 4 do
				updateTimeToDie(elapsed, "boss" .. id)
			end
			if jps.isHealer then
				for id = 1, 4 do
					updateTimeToDie(elapsed, "party" .. id)
					updateTimeToDie(elapsed, "partypet" .. id)
				end
				for id = 1, 5 do
					updateTimeToDie(elapsed, "arena" .. id)
					updateTimeToDie(elapsed, "arenapet" .. id)
				end
				for id = 1, 40 do
					updateTimeToDie(elapsed, "raid" .. id)
					updateTimeToDie(elapsed, "raidpet" .. id)
				end
			end
		return
	end
	if not UnitExists(unit) then return end

	local unitGuid = UnitGUID(unit)
	local health = UnitHealth(unit)

	if health == UnitHealthMax(unit) or health == 0 then
		jps.RaidTimeToDie[unitGuid] = nil
		return
	end

	local time = GetTime()

	jps.RaidTimeToDie[unitGuid] = jps.timeToDieFunctions[jps.timeToDieAlgorithm][0](jps.RaidTimeToDie[unitGuid],health,time)
	if jps.RaidTimeToDie[unitGuid] then
		if jps.RaidTimeToDie[unitGuid]["timeSinceNoChange"] >= jps.maxTDDLifetime then
			jps.RaidTimeToDie[unitGuid] = nil
		end
	end
end

-- Time To Die Algorithms
jps.timeToDieFunctions = {}
jps.timeToDieFunctions["InitialMidpoints"] = { 
	[0] = function(dataset, health, time)
		if not dataset or not dataset.health0 then
			dataset = {}
			dataset.time0, dataset.health0 = time, health
			dataset.mhealth, dataset.mtime = time, health
			dataset.health = health
			dataset.timeSinceChange = 0
			dataset.timeSinceNoChange = 0
			dataset.timestamp = time
		else
			dataset.timeSinceLastChange = time - dataset.timestamp
			dataset.timestamp = time
			dataset.healthChange = dataset.health - health 
			dataset.health = health
			if dataset.healthChange <= 1 then
				dataset.timeSinceNoChange = dataset.timeSinceNoChange + dataset.timeSinceLastChange
			else
				dataset.timeSinceNoChange = 0 
			end
			dataset.mhealth = (dataset.mhealth + health) * .5
			dataset.mtime = (dataset.mtime + time) * .5
			if dataset.mhealth > dataset.health0 then
				return nil
			end
		end
		return dataset
	end,
	[1] = function(dataset, health, time)
		if not dataset or not dataset.health0 then
			return nil
		else
			return health * (dataset.time0 - dataset.mtime) / (dataset.mhealth - dataset.health0)
		end
	end 
}
jps.timeToDieFunctions["LeastSquared"] = { 
	[0] = function(dataset, health, time)	
		if not dataset or not dataset.n then
			dataset = {}
			dataset.n = 1
			dataset.time0, dataset.health0 = time, health
			dataset.mhealth = time * health
			dataset.mtime = time * time
			dataset.health = health
			dataset.timeSinceChange = 0
			dataset.timeSinceNoChange = 0
			dataset.timestamp = time
		else
			dataset.n = dataset.n + 1
			dataset.timeSinceLastChange = time - dataset.timestamp
			dataset.timestamp = time
			dataset.healthChange = dataset.health - health 
			dataset.health = health
			if dataset.healthChange <= 1 then
				dataset.timeSinceNoChange = dataset.timeSinceNoChange + dataset.timeSinceLastChange
			else
				dataset.timeSinceNoChange = 0 
			end
			dataset.time0 = dataset.time0 + time
			dataset.health0 = dataset.health0 + health
			dataset.mhealth = dataset.mhealth + time * health
			dataset.mtime = dataset.mtime + time * time
			local timeToDie = jps.timeToDieFunctions["LeastSquared"][1](dataset,health,time)
			if not timeToDie then
				return nil
			end
		end
		return dataset
	end,
	[1] = function(dataset, health, time)
		if not dataset or not dataset.n then
			return nil
		else
			local timeToDie = (dataset.health0 * dataset.mtime - dataset.mhealth * dataset.time0) / (dataset.health0 * dataset.time0 - dataset.mhealth * dataset.n) - time
			if timeToDie < 0 then
				return nil
			else
				return timeToDie
			end
		end
	end 
}
jps.timeToDieFunctions["WeightedLeastSquares"] = { 
	[0] = function(dataset, health, time)	
		if not dataset or not dataset.health0 then
			dataset = {}
			dataset.time0, dataset.health0 = time, health
			dataset.mhealth = time * health
			dataset.mtime = time * time
			dataset.health = health
			dataset.timeSinceChange = 0
			dataset.timeSinceNoChange = 0
			dataset.timestamp = time
		else
			dataset.timeSinceLastChange = time - dataset.timestamp
			dataset.timestamp = time
			dataset.healthChange = dataset.health - health 
			dataset.health = health
			if dataset.healthChange <= 1 then
				dataset.timeSinceNoChange = dataset.timeSinceNoChange + dataset.timeSinceLastChange
			else
				dataset.timeSinceNoChange = 0 
			end
			dataset.time0 = (dataset.time0 + time) * .5
			dataset.health0 = (dataset.health0 + health) * .5
			dataset.mhealth = (dataset.mhealth + time * health) * .5
			dataset.mtime = (dataset.mtime + time * time) * .5
			local timeToDie = jps.timeToDieFunctions["WeightedLeastSquares"][1](dataset,health,time)
			if not timeToDie then
				return nil
			end
		end
		return dataset
	end,
	[1] = function(dataset, health, time)
		if not dataset or not dataset.health0 then
			return nil
		else
		
			local timeToDie = (dataset.mtime * dataset.health0 - dataset.time0 * dataset.mhealth) / (dataset.time0 * dataset.health0 - dataset.mhealth) - time
			if timeToDie < 0 then
				return nil
			else
				return timeToDie
			end
		end
	end 
}

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
	
	jps.CastBar.latency = 0
	jps.CastBar.latencySpell = nil
	jps.CastBar.nextSpell = ""
	jps.CastBar.nextTarget = ""
	jps.CastBar.currentSpell = ""
	jps.CastBar.currentTarget = ""
	jps.CastBar.currentMessage = ""
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
function jps.LowestTimetoDie()
	local lowestUnit = jpsName
	local timetodie = 60
	
	for unit,index in pairs(jps.RaidStatus) do
		local timetodieUnit = jps.TimeToDie(unit)
		if (index["inrange"] == true) and timetodieUnit < timetodie then
			timetodie = timetodieUnit
			lowestUnit = unit
		end
	end
	return lowestUnit
end

---------------------------------------------------
-- SLIDER UPDATE INTERVAL
---------------------------------------------------

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
local latency = jps_round(jps.CastBar.latency,2)
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
