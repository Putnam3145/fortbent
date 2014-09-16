-- Assigns claspects based on personality, attributes etc.
claspects = {
	aspects={
	"breath", --1
	"light",
	"time",
	"space",
	"life",
	"hope",
	"void",
	"heart",
	"blood",
	"doom",
	"mind",
	"rage"},
	classes={
	"heir", --1
	"seer",
	"knight",
	"witch",
	"maid",
	"page",
	"rogue",
	"prince",
	"sylph",
	"mage",
	"thief",
	"bard"--[[,
	"muse",
	"lord"]]
	}
}

syndromeUtil=require('syndrome-util')

rng=dfhack.random.new()

local function alreadyHasSyndrome(unit,syn_id)
    for _,syndrome in ipairs(unit.syndromes.active) do
        if syndrome.type == syn_id then return true end
    end
    return false
end

function assignClaspect(unit,creatureClass,creatureAspect)
	local success=false
	for k,v in ipairs(fortbentInorganic.syndrome) do
		if string.find(string.lower(v.syn_name),string.lower(creatureClass)) and string.find(string.lower(v.syn_name),string.lower(creatureAspect)) then
			syndromeUtil.infectWithSyndrome(unit,v,syndromeUtil.ResetPolicy[DoNothing])
			success=true
		end
	end
	return success
end

function unitAlreadyHasClaspect(unit)
    for k,c_syn in ipairs(unit.syndromes.active) do
		for _,ce in ipairs(df.global.world.raws.syndromes.all[c_syn.type].ce) do
			if string.find("display_namest",tostring(ce)) and string.find("Sburb",ce.name) then return true end
		end
	end
    return false
end

local function getRandomAspect()
	local timeOrSpace = rng:random(20)+1 --20% chance of time or space
	if timeOrSpace==20 then
		return rng:random(2)+3
	else
		local aspect=rng:random(10)
		return aspect>2 and aspect+3 or aspect+1
	end
	return aspect
end

local function getSburbClass() 
	return rng:random(12)+1
end

debugScript=false

function creatureIsSburbable(unit)
	for k,class in ipairs(df.creature_raw.find(unit.race).caste[unit.caste].creature_class) do
		if string.find(class.value,"SBURB") then return true end
	end
	return false
end

function unitDoesntNeedClaspect(unit)
	return not creatureIsSburbable(unit) or unitAlreadyHasClaspect(unit)
end

function makeClaspect(unit,unitidx)
	if df.global.gamemode==1 and unitidx==0 then
		local dialog = require('gui.dialogs')
		local godtiers=fortbentInorganic.syndrome
		local tbl={}
		local tunit=df.global.world.units.active[0]
		for k,syn in ipairs(godtiers) do
			table.insert(tbl,{string.sub(syn.syn_name,13,#syn.syn_name-1),nil,syn.id})
		end
		local f=function(name,C)
			syndromeUtil.infectWithSyndrome(tunit,fortbentInorganic.syndrome(C[3]))
		end
		dialog.showListPrompt("Which claspect do you want?","Choose claspect:",COLOR_WHITE,tbl,f)
		return nil
	end
	local creatureAspect  = getRandomAspect()
	local creatureClass   = getSburbClass()
	if assignClaspect(unit,claspects.classes[creatureClass],claspects.aspects[creatureAspect]) then
		return {creatureAspect,creatureClass}
	end
	return false
end

function printAllClaspectsGiven(numberOfAssignedClaspects)
	for i=1,2 do
		for ii=1,12 do
			if i==1 then
				print(claspects.classes[ii],numberOfAssignedClaspects[1][ii])
			else
				print(claspects.aspects[ii],numberOfAssignedClaspects[2][ii])
			end
		end
	end
end


dfhack.onStateChange.claspect = function(code)
	local pauseCounter=0
	if code==SC_WORLD_LOADED then
		fortbentInorganic=dfhack.matinfo.find('INORGANIC:FORTBENT_CLASPECTS').material
		dfhack.timeout(1,'ticks',monthlyClaspectAssign)
	end
	if code==SC_PAUSED then
		pauseCounter=pauseCounter+1
		if pauseCounter>=10 then
			assignAllClaspects()
			pauseCounter=0
		end
	end
end

function assignAllClaspects()
	if df.global.gamemode==1 then makeClaspect(df.global.world.units.active[0],0) end
	for k,unit in ipairs(df.global.world.units.active) do
		if not(unitDoesntNeedClaspect(unit)) then 
			makeClaspect(unit,k) 
		end
	end
end

function monthlyClaspectAssign()
	assignAllClaspects()
	dfhack.timeout(1,'months',monthlyClaspectAssign)
end

if ... == "force" then assignAllClaspects() end