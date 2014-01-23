-- Assigns claspects based on personality, attributes etc.

if true then --so I can minimize all this; random generator implementation by warmist
	RandomGenerator=defclass(RandomGenerator)
	function RandomGenerator:get(min,max)
		local val=(self:gen())/bit32.bnot(0)
		if min~=nil and max~=nil then
			return min+val*(max-min)
		elseif min~=nil then
			return val*max
		else
			return val
		end
	end
	function RandomGenerator:pick(values)
		local val=self:get(1,#values+1)
		return values[math.floor(val)]
	end
	xorShift=defclass(xorShift,RandomGenerator)
	function xorShift:init(seed)
		self:reseed(seed)
	end
	function xorShift:reseed(seed)
		self.x=seed
		self.y=362436069
		self.z=521288629
		self.w=88675123
	end
	function xorShift:genOnebit()
		local t=bit32.bxor(self.x,bit32.lshift(self.x,11))
		self.x=self.y
		self.y=self.z
		self.z=self.w
		self.w=bit32.bxor(self.w,bit32.rshift(self.w,19))
		self.w=bit32.bxor(self.w,bit32.bxor(t,bit32.rshift(t,8)))
		return self.w
	end
	function xorShift:gen()
		local g=0
		for k=1,32 do
			g=bit32.bor(bit32.lshift(g,1),bit32.band(self:genOnebit(),1))
		end
		return g
	end
	Mersenne=defclass(Mersenne,RandomGenerator) --TODO check if correct...
	function Mersenne:init(seed)
		self.seed={}
		self.seed[0]=seed
		self.index=0
		for i=1,623 do
			self.seed[i]=bit32.band(0x6c078965 * (bit32.bxor(self.seed[i-1],bit32.rshift(self.seed[i-1],30))) + i,bit32.bnot(0)) -- 0x6c078965
		end
	end
	function Mersenne:generate_numbers()
		for i=0,623 do
			local y=bit32.band(self.seed[i],0x80000000)+bit32.band(self.seed[math.fmod(i+1,624)],0x7fffffff)
			self.seed[i]=bit32.bxor(self.seed[math.fmod(i+397,624)],bit32.rshift(y,1))
			if math.fmod(y,2)~=0 then
				self.seed[i]=bit32.bxor(self.seed[i],0x9908b0df)
			end
		end
	end
	function Mersenne:gen()
		if self.index==0 then
			self:generate_numbers()
		end
		local y=self.seed[self.index]
		y=bit32.bxor(y,bit32.rshift(y,11))
		y=bit32.bxor(y,bit32.band(bit32.lshift(y,7),0x9d2c5680))
		y=bit32.bxor(y,bit32.band(bit32.lshift(y,15),0xefc60000))
		y=bit32.bxor(y,bit32.rshift(y,18))
		
		self.index=math.fmod(self.index+1,624)
		return y
	end
end

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

local function alreadyHasSyndrome(unit,syn_id)
    for _,syndrome in ipairs(unit.syndromes.active) do
        if syndrome.type == syn_id then return true end
    end
    return false
end

local function assignSyndrome(target,syn_id) --taken straight from here, but edited so I can understand it better: https://gist.github.com/warmist/4061959/. Also implemented expwnent's changes for compatibility with syndromeTrigger. I have used this so much ;_;
    if df.isnull(target) then
        return nil
    end
    if alreadyHasSyndrome(target,syn_id) then
        return true --I can omit the reset because they aren't going to ever lose their claspect
    end
    local newSyndrome=df.unit_syndrome:new()
    local target_syndrome=df.syndrome.find(syn_id)
    newSyndrome.type=target_syndrome.id
    newSyndrome.year=df.global.cur_year
    newSyndrome.year_time=df.global.cur_year_tick
    newSyndrome.ticks=1
    newSyndrome.unk1=1
    for k,v in ipairs(target_syndrome.ce) do
        local sympt=df.unit_syndrome.T_symptoms:new()
        sympt.ticks=1
        sympt.flags=2
        newSyndrome.symptoms:insert("#",sympt)
    end
    target.syndromes.active:insert("#",newSyndrome)
    return true
end

function assignClaspect(unit,creatureClass,creatureAspect)
	local success=false
	for k,v in ipairs(fortbentInorganic.syndrome) do
		if string.find(string.lower(v.syn_name),string.lower(creatureClass)) and string.find(string.lower(v.syn_name),string.lower(creatureAspect)) then
			assignSyndrome(unit,k)
			success=true
		end
	end
	return success
end

function unitAlreadyHasClaspect(unit)
	if isUnitAssigned[unit.id] then return true end
    for k,c_syn in ipairs(unit.syndromes.active) do
		for _,ce in ipairs(df.global.world.raws.syndromes.all[c_syn.type].ce) do
			if string.find("display_namest",tostring(ce)) and string.find("Sburb",ce.name) then return true end
		end
	end
    return false
end

local function getRandomAspect(seed,unitidx)
	local rand=Mersenne(df.global.cur_year_tick+df.global.ui.site_id+df.global.ui.race_id+df.global.ui.group_id+seed+unitidx)	 --should be sufficient in entropy, eh? :V
	seed=seed+rand:get(1,50)
	local timeOrSpace = rand:get(1,20) --20% chance of time or space
	if timeOrSpace>19 then
		return math.floor(rand:get(3,5))
	else
		local aspect=math.ceil(rand:get(0,10))
		return aspect>2 and aspect+2 or aspect --if you don't know what this does it literally means "if aspect>2 then return aspect+2 else return aspect"
	end
	return aspect
end

local function getSburbClass(seed,unitidx) 
	local rand=Mersenne(df.global.cur_year_tick+df.global.ui.site_id+df.global.ui.race_id+df.global.ui.group_id+seed+unitidx)
	seed=seed+rand:get(1,50)
	return math.ceil(rand:get(0,12))
end

debugScript=false

function creatureIsSburbable(unit)
	for k,class in ipairs(df.global.world.raws.creatures.all[unit.race].caste[unit.caste].creature_class) do
		if string.find(class.value,"SBURB") then return true end
	end
	return false
end

function unitDoesntNeedClaspect(unit)
	if not creatureIsSburbable(unit) or unitAlreadyHasClaspect(unit) then return true end
	return false
end

function makeClaspect(unit,seed,unitidx)
	if df.global.gamemode==1 and unitidx==0 then
		local dialog = require('gui.dialogs')
		local godtiers=fortbentInorganic.syndrome
		local tbl={}
		local tunit=df.global.world.units.active[0]
		for k,syn in ipairs(godtiers) do
			table.insert(tbl,{string.sub(syn.syn_name,13,#syn.syn_name-1),nil,syn.id})
		end
		local f=function(name,C)
			assignSyndrome(tunit,C[3])
		end
		dialog.showListPrompt("Which claspect do you want?","Choose claspect:",COLOR_WHITE,tbl,f)
		return nil
	end
	local creatureAspect  = getRandomAspect(seed,unit.id)
	local creatureClass   = getSburbClass(seed,unit.id)
	if assignClaspect(unit,claspects.classes[creatureClass],claspects.aspects[creatureAspect]) then
		isUnitAssigned[unit.id]=true
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

isUnitAssigned={}

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

seed = 0

function assignAllClaspects()
	if df.global.gamemode==1 then makeClaspect(df.global.world.units.active[0],39853,0) end
	for k,unit in ipairs(df.global.world.units.active) do
		if not unitAlreadyHasClaspect(unit) then makeClaspect(unit,seed,k) end
	end
end

function monthlyClaspectAssign()
	assignAllClaspects()
	dfhack.timeout(1,'months',monthlyClaspectAssign)
end

if ... == "force" then assignAllClaspects() end