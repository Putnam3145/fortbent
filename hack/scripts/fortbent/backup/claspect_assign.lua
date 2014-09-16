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

personality_weights = {
	{ --breath
		ANXIETY                 =     0,
		ANGER                   =     0, 
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     1, 
		IMMODERATION            =     3, 
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0, 
		EXCITEMENT_SEEKING      =    10,
		CHEERFULNESS            =    10,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =    10,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =   -10, --BALANCE
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =     0,
		COOPERATION             =   -10,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =   -10,
		CAUTIOUSNESS            =     0},

	{ --light
		ANXIETY                 =     2,
		ANGER                   =     0,
		DEPRESSION              =     1,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =     1,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =    10,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =    10,
		ALTRUISM                =     0,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =    10,
		ORDERLINESS             =     1,
		DUTIFULNESS             =   -10,
		ACHIEVEMENT_STRIVING    =   -10,
		SELF_DISCIPLINE         =     1,
		CAUTIOUSNESS            =   -10},

	{ --time and space each follow a different set of rules. Simply this: there is a 1/20 chance for a hero to be a time or space hero. That's it.
		ANXIETY                 =     0,
		ANGER                   =     0,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =     0,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =     0},

	{ --space
		ANXIETY                 =     0,
		ANGER                   =     0,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =     0,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =     0},

	{ --life
		ANXIETY                 =   -10,
		ANGER                   =     0,
		DEPRESSION              =   -10,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     1,
		GREGARIOUSNESS          =     1,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     1,
		CHEERFULNESS            =    10,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =    10,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =    10,
		COOPERATION             =     0,
		MODESTY                 =   -10,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =   -10},

	{ --hope
		ANXIETY                 =     0,
		ANGER                   =   -10,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =   -10,
		IMMODERATION            =   -10,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =    10,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =    10,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     1,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =    10,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     1,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     1,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =     1},

	{ --void
		ANXIETY                 =     0,
		ANGER                   =     0,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ACTIVITY_LEVEL          =     0,
		ASSERTIVENESS           =     0,
		EXCITEMENT_SEEKING      =     1,
		CHEERFULNESS            =     0,
		IMAGINATION             =     1,
		ARTISTIC_INTEREST       =     1,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =   -10,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =   -10,
		ALTRUISM                =     0,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =   -10,
		ORDERLINESS             =     0,
		DUTIFULNESS             =    10,
		ACHIEVEMENT_STRIVING    =    10,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =    10},

	{ --heart
		ANXIETY                 =   -10,
		ANGER                   =     0,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =   -10,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ACTIVITY_LEVEL          =     0,
		ASSERTIVENESS           =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =    10,
		EMOTIONALITY            =    10,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =     0,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =    10,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =   -10,
		CAUTIOUSNESS            =     0},

	{ --blood
		ANXIETY                 =     0,
		ANGER                   =     0,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =     0,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =   -10,
		CHEERFULNESS            =   -10,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =   -10,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =    10,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =     0,
		COOPERATION             =    10,
		MODESTY                 =     0,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =    10,
		CAUTIOUSNESS            =     0},

	{ --doom
		ANXIETY                 =    10,
		ANGER                   =     0,
		DEPRESSION              =    10,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =     0,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ACTIVITY_LEVEL          =     0,
		ASSERTIVENESS           =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =   -10,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =   -10,
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =   -10,
		COOPERATION             =     0,
		MODESTY                 =    10,
		SYMPATHY                =     0,
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =     0},

	{ --mind
		ANXIETY                 =    10,
		ANGER                   =    -1,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     0,
		IMMODERATION            =    -1,
		VULNERABILITY           =    10,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =    -1,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =     0,
		ARTISTIC_INTEREST       =   -10, --oh damn that's not right... oh well, fuck it, balance trumps all right now
		EMOTIONALITY            =   -10, --that's not quite right either... let me just say "fuck it" again
		ADVENTUROUSNESS         =     0,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =     0,
		COOPERATION             =     0,
		MODESTY                 =     0,
		SYMPATHY                =   -10, --oh god dang it
		SELF_EFFICACY           =     0,
		ORDERLINESS             =     0,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =    10,
		CAUTIOUSNESS            =    -1},

	{ --rage
		ANXIETY                 =     0,
		ANGER                   =     5,
		DEPRESSION              =     0,
		SELF_CONSCIOUSNESS      =     5,
		IMMODERATION            =     5,
		VULNERABILITY           =     0,
		FRIENDLINESS            =     0,
		GREGARIOUSNESS          =     0,
		ASSERTIVENESS           =    -1,
		ACTIVITY_LEVEL          =     0,
		EXCITEMENT_SEEKING      =     0,
		CHEERFULNESS            =     0,
		IMAGINATION             =   -10,
		ARTISTIC_INTEREST       =     0,
		EMOTIONALITY            =     0,
		ADVENTUROUSNESS         =   -10,
		INTELLECTUAL_CURIOSITY  =     0,
		LIBERALISM              =     0,
		TRUST                   =     0,
		STRAIGHTFORWARDNESS     =     0,
		ALTRUISM                =   -10,
		COOPERATION             =     1,
		MODESTY                 =     1,
		SYMPATHY                =    -1,
		SELF_EFFICACY           =    -1,
		ORDERLINESS             =    -1,
		DUTIFULNESS             =     0,
		ACHIEVEMENT_STRIVING    =     0,
		SELF_DISCIPLINE         =     0,
		CAUTIOUSNESS            =     0}
}

local function getTotal(tbl)
	local total = {0,0}
	for k,v in pairs(tbl) do
		if v>0 
			then 
				total[1]=v+total[1]
			else
				total[2]=v+total[2]
		end
	end
	return total
end

function getSignlessTotal(tbl)
	if not tbl then return 0 end
	local total= 0
	for k,v in ipairs(tbl) do
		total=v+total
	end
	return total
end

local function getWeightAverages()
	local weightAverages={0,0}
		for k,claspect in ipairs(personality_weights) do
			local total = getTotal(claspect)
			for i=1,2 do
				weightAverages[i]=weightAverages[i]+total[i]
			end
		end
		for i=1,2 do
			weightAverages[i]=weightAverages[i]/12
		end
	return weightAverages
end

function fixWeights() --this is here so I don't have to think about my weights meaning anything :D What's important is that they stay similar relative to one another, which this preserves.
	local weightAverages=getWeightAverages()
	for k,aspect in ipairs(personality_weights) do
		local total=getTotal(aspect)
		for kk,trait in pairs(aspect) do
			if trait>0
			then
				trait=(weightAverages[1]/total[1])*trait
			elseif trait<0 then
				trait=(weightAverages[2]/total[2])*trait 
			else
				trait= 0 --:V
			end
		end
	end
	print("claspect assignment enabled.")
end

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

function assignClaspect(unit,creatureClass,creatureAspect) --Putting all of the claspect combos into a single table would be... problematic.
	for k,v in ipairs(df.global.world.raws.syndromes.all) do
		if string.find(string.lower(v.syn_name),string.lower(creatureClass)) and string.find(string.lower(v.syn_name),string.lower(creatureAspect)) then
			assignSyndrome(unit,k)
		end
	end
end

function unitAlreadyHasClaspect(unit)
    for k,c_syn in ipairs(unit.syndromes.active) do
		for _,ce in ipairs(df.global.world.raws.syndromes.all[c_syn.type].ce) do
			if string.find(tostring(ce),"display_namest") and string.find(ce.name,"Sburb") then return true end
		end
	end
    return false
end

local function getHighestAspect(aspects,seed)
	local highest=1
	local rand=Mersenne(df.global.cur_year_tick+df.global.ui.site_id+df.global.ui.race_id+df.global.ui.group_id+(seed or 0)) --should be sufficient in entropy, eh? :V
	local timeOrSpace = rand:get(1,20)
	print(timeOrSpace)
	if timeOrSpace>19 then
		return math.floor(rand:get(3,5))
	end
	local topValue=-1000000000 --meaning top value after weight calculations; "highest" refers to the highest claspect, which can be referred to by the table at the top
	for k,aspect in ipairs(aspects) do
		if k<3 or k>4 then
			if getSignlessTotal(aspects[k])>topValue then
				topValue=getSignlessTotal(aspects[aspect]) 
				highest=k
			end
		end
	end
	return highest
end

local function getSburbClass(unit) 
	local al=(unit.status.current_soul.traits.ACTIVITY_LEVEL)
	local class="waste"
	--classes are not necessarily counterparts if they're in similar positions in respect to the middle
	--if al==0 then class=13 [[later, for when I add muses back]]
		--[[else]]if al<32 then class=2
		elseif al<41 then class=12
		elseif al<45 then class=7
		elseif al<47 then class=9
		elseif al<49 then class=6
		elseif al<50 then class=1
		elseif al==50 then class=(math.floor(unit.id/2)==unit.id/2) and 1 or 10
		elseif al<52 then class=10
		elseif al<53 then class=5
		elseif al<55 then class=3
		elseif al<58 then class=11
		elseif al<61 then class=4
		else--[[if al>65 and al~=100 then]] class=8
		--else class=14
	end
	return class
end

debugScript=true

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

function makeClaspect(unit,seed)
	if unitDoesntNeedClaspect(unit) then return nil end
	local personality     =  unit.status.current_soul.traits
	local creatureWeights =  {}
	for k,aspect in ipairs(personality_weights) do
		creatureWeights[k]={}
		for trait_name,trait in pairs(aspect) do
			table.insert(creatureWeights[k],(personality[trait_name]-50)*trait)
		end
	end
	local creatureAspect  = getHighestAspect(creatureWeights,seed)
	local creatureClass   = getSburbClass(unit)
	assignClaspect(unit,claspects.classes[creatureClass],claspects.aspects[creatureAspect])
	return {creatureAspect,creatureClass}
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
	local numberOfAssignedClaspects={{0,0,0,0,0,0,0,0,0,0,0,0},{0,0,0,0,0,0,0,0,0,0,0,0}}
	for k,unit in ipairs(df.global.world.units.active) do
		local claspect=makeClaspect(unit,k)
		if debugScript and claspect then
			numberOfAssignedClaspects[2][claspect[1]]=numberOfAssignedClaspects[2][claspect[1]]+1
			numberOfAssignedClaspects[1][claspect[2]]=numberOfAssignedClaspects[1][claspect[2]]+1
		end
	end
	if debugScript then
		printAllClaspectsGiven(numberOfAssignedClaspects)
	end
end

function monthlyClaspectAssign()
	assignAllClaspects()
	dfhack.timeout(1,'months',monthlyClaspectAssign)
end

dfhack.onStateChange.claspect()

fixWeights()