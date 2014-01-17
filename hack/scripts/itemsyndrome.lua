-- Checks regularly if creature has an item equipped with a special syndrome and applies item's syndrome if it is.

local function getMaterial(item)
	return dfhack.matinfo.decode(item).material
end

local function findItemSyndromeInorganic()
	for matID,material in ipairs(df.global.world.raws.inorganics) do
		if string.find(material.id,"DFHACK_ITEMSYNDROME_MATERIAL_") then return matID end --the last underscore is needed to prevent duped raws; I want good modder courtesy if it kills me, dammit!
	end
	return nil
end

itemSyndromeMatID = findItemSyndromeInorganic()

if itemSyndromeMatID then itemSyndromeMat = df.global.world.raws.inorganics[itemSyndromeMatID].material end

local function getSyndrome(material)
	if material==nil then return nil end
	if #material.syndrome>0 then return material.syndrome[0]
	else return nil end
end

local function syndromeIsDfHackSyndrome(syndrome)
	for k,v in ipairs(syndrome.syn_class) do
		if v.value=="DFHACK_ITEM_SYNDROME" then return true end
	end
	return false
end

local function itemHasNoSubtype(item)
	local itemtype = tostring(item)
	local subtypedItemTypes =
	{
	"armor",
	"weapon",
	"helm",
	"shoes",
	"shield",
	"glove",
	"pants",
	"tool",
	"siegeammo",
	"ammo",
	"trapcomp",
	"instrument",
	"toy"}
	for _,v in ipairs(subtypedItemTypes) do
		if string.find(itemtype,v) then return false end
	end
	return true
end

local function itemHasSyndrome(item)
	if itemHasNoSubtype(item) or not itemSyndromeMat then return nil end
	for _,syndrome in ipairs(itemSyndromeMat.syndrome) do
		if syndrome.syn_name == item.subtype.name then return syndrome end
	end
	return nil
end

local function alreadyHasSyndrome(unit,syn_id)
	for _,syndrome in ipairs(unit.syndromes.active) do
		if syndrome.type == syn_id then return true end
	end
	return false
end

local function assignSyndrome(target,syn_id) --taken straight from here, but edited so I can understand it better: https://gist.github.com/warmist/4061959/
    if target==nil then
        return nil
    end
	if alreadyHasSyndrome(target,syn_id) then
		local syndrome
		for k,v in ipairs(target.syndromes.active) do
			if v.type == syn_id then syndrome = v end
		end
		if not syndrome then return nil end
		syndrome.ticks=1
		return true
	end
    local newSyndrome=df.unit_syndrome:new()
    local target_syndrome=df.syndrome.find(syn_id)
    newSyndrome.type=target_syndrome.id
    --newSyndrome.year=
    --newSyndrome.year_time=
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

local function syndromeIsIndiscriminate(syndrome)
	if #syndrome.syn_affected_class==0 and #syndrome.syn_affected_creature==0 and #syndrome.syn_affected_caste==0 and #syndrome.syn_immune_class==0 and #syndrome.syn_immune_creature==0 and #syndrome.syn_immune_caste==0 then return true end
	return false
end

local function creatureIsAffected(unit,syndrome)
	if syndromeIsIndiscriminate(syndrome) then return true end
	local affected = false
	local unitraws = df.creature_raw.find(unit.race)
	local casteraws = unitraws.caste[unit.caste]
	local unitracename = unitraws.creature_id
	local castename = casteraws.caste_id
	local unitclasses = casteraws.creature_class
	for _,unitclass in ipairs(unitclasses) do
		for _,syndromeclass in ipairs(syndrome.syn_affected_class) do
			if unitclass.value==syndromeclass.value then affected = true end
		end
	end
	for caste,creature in ipairs(syndrome.syn_affected_creature) do
		local affected_creature = creature.value
		local affected_caste = syndrome.syn_affected_caste[caste].value --slightly evil, but oh well, hehe.
		if affected_creature == unitracename and affected_caste == castename then affected = true end
	end
	for _,unitclass in ipairs(unitclasses) do
		for _,syndromeclass in ipairs(syndrome.syn_immune_class) do
			if unitclass.value==syndromeclass.value then affected = false end
		end
	end
	for caste,creature in ipairs(syndrome.syn_immune_creature) do
		local immune_creature = creature.value
		local immune_caste = syndrome.syn_immune_caste[caste].value
		if immune_creature == unitracename and immune_caste == castename then affected = false end
	end
	return affected
end

local function itemAffectsHauler(item_inv)
	local item = item_inv.item
	local syndrome = getSyndrome(getMaterial(item))
	if not syndrome then syndrome = itemHasSyndrome(item) end
	for k,v in ipairs(syndrome.syn_class) do
		if v.value=="DFHACK_AFFECTS_HAULER" then return true end
	end
	return false
end

local function itemAffectsStuckins(item_inv)
	local item = item_inv.item
	local syndrome = getSyndrome(getMaterial(item))
	if not syndrome then syndrome = itemHasSyndrome(item) end
	for k,v in ipairs(syndrome.syn_class) do
		if v.value=="DFHACK_AFFECTS_STUCKIN" then return true end
	end
	return false
end

local function itemIsArmorOnly(item_inv)
	local item = item_inv.item
	local syndrome = getSyndrome(getMaterial(item))
	if not syndrome then syndrome = itemHasSyndrome(item) end
	for k,v in ipairs(syndrome.syn_class) do
		if v.value=="DFHACK_ARMOR_ONLY" then return true end
	end
	return false
end
	
local function itemIsWieldedOnly(item_inv)
	local item = item_inv.item
	local syndrome = getSyndrome(getMaterial(item))
	if not syndrome then syndrome = itemHasSyndrome(item) end
	for k,v in ipairs(syndrome.syn_class) do
		if v.value=="DFHACK_WIELDED_ONLY" then return true end
	end
	return false
end
	
local function itemOnlyAffectsStuckins(item_inv)
	local item = item_inv.item
	local syndrome = getSyndrome(getMaterial(item))
	if not syndrome then syndrome = itemHasSyndrome(item) end
	for k,v in ipairs(syndrome.syn_class) do
		if v.value=="DFHACK_STUCKINS_ONLY" then return true end
	end
	return false
end
		
local function itemIsInValidPosition(item_inv)
	if (item_inv.mode == 0 and not itemAffectsHauler(item_inv)) or (item_inv.mode == 7 and not itemAffectsStuckins(item_inv)) or (item_inv.mode ~= 2 and itemIsArmorOnly(item_inv)) or (item_inv.mode ~=1 and itemIsWieldedOnly(item_inv)) or (item_inv.mode ~=7 and itemOnlyAffectsStuckins(item_inv)) then return false end
	return true
end

local function syndromeIsTransformation(syndrome)
	for _,effect in ipairs(syndrome.ce) do
		local effectType = tostring(effect)
		if string.find(effectType,"body_transformation") then return true end
	end
	return false
end

local function rememberInventory(unit)
	local invCopy = {}
	for inv_id,item_inv in ipairs(unit.inventory) do
		invCopy[inv_id+1] = {}
		local itemToWorkOn = invCopy[inv_id+1]
		itemToWorkOn.item = item_inv.item
		itemToWorkOn.mode = item_inv.mode
		itemToWorkOn.body_part_id = item_inv.body_part_id
	end
	return invCopy
end

local function moveAllToInventory(unit,invTable)
	for _,item_inv in ipairs(invTable) do
		dfhack.items.moveToInventory(item_inv.item,unit,item_inv.mode,item_inv.body_part_id)
	end
end

local function findItems()
	for _uid,unit in ipairs(df.global.world.units.all) do
		local transformation
		for itemid,item_inv in ipairs(unit.inventory) do
			local item = item_inv.item
			if getMaterial(item)~=nil and getSyndrome(getMaterial(item))~=nil then
				local syndrome = getSyndrome(getMaterial(item))
				local syndromeApplied
				if syndromeIsTransformation(syndrome) then
					unitInventory = rememberInventory(unit)
					transformation = true
				end
				if syndromeIsDfHackSyndrome(syndrome) and creatureIsAffected(unit,syndrome) and itemIsInValidPosition(item_inv) then
					assignSyndrome(unit,syndrome.id)
					syndromeApplied = true
				end
			end
			if itemHasSyndrome(item) then
				local syndrome = itemHasSyndrome(item)
				if syndromeIsTransformation(syndrome) then
					unitInventory = rememberInventory(unit)
					transformation = true
				end
				if creatureIsAffected(unit,syndrome) then assignSyndrome(unit,syndrome.id) end
			end
			if item.contaminants then
				for _,contaminant in ipairs(item.contaminants) do
					if getMaterial(contaminant)~=nil and getSyndrome(getMaterial(contaminant))~=nil then
						local syndrome = getSyndrome(getMaterial(contaminant))
						if syndromeIsTransformation(syndrome) then
							unitInventory = rememberInventory(unit)
							transformation =true
						end
						if syndromeIsDfHackSyndrome(syndrome) and creatureIsAffected(unit,syndrome) and itemIsInValidPosition(item_inv) then assignSyndrome(unit,syndrome.id) end
					end
				end
			end
		end
		if transformation then dfhack.timeout(2,"ticks",function() moveAllToInventory(unit,unitInventory) end) end
	end
end


dfhack.onStateChange.itemsyndrome = function(code) --Many thanks to Warmist for pointing this out to me!
	if code==SC_WORLD_LOADED then
		dfhack.timeout(1,'ticks',callback) --disables if map/world is unloaded automatically
	end
end

function callback()
	findItems()
	dfhack.timeout(150,'ticks',callback)
end

if ... ~= "force" then dfhack.onStateChange.itemsyndrome() end

if ... == "force" then findItems() end