--base/item-upgrade.lua v1.0
--[[
upgradeitem - used to upgrade item from one to another, or to change them from one to another
	Requires a reaction an inorganic and corresponding items

	REACTION OPTIONS:
		All item reagents with [PRESERVE_REAGENT] will be flagged for upgrading
		Reagents without the [PRESERVE_REAGENT] tag will be consumed
		The first product must be the inorganic with the syndrome attached to it
		Subsequent products will be created as normal
		
	EXAMPLE REACTION:
		[REACTION:LUA_HOOK_UPGRADE_ITEM_EXAMPLE_1] <- LUA_HOOK_UPGRADE_ITEM is required
			[NAME:upgrade armor]
			[BUILDING:UPGRADE_SMITH:NONE]
			[REAGENT:A:1:ARMOR:NONE:INORGANIC:NONE][PRESERVE_REAGENT]
			[REAGENT:C:1500:COIN:NONE:INORGANIC:SILVER]
			[PRODUCT:100:0:BOULDER:NONE:INORGANIC:UPGRADE_ITEM]
	
	INORGANIC OPTIONS:
		Inorganics must have a syndrome with at least two [SYN_CLASS:] tags
		Valid arguments for the first SYN_CLASS;
			this - this will change the items in the reaction
			all - this will change all items of the same type and subtype as the items in the reaction
			ITEM_TOKEN - this will change a randomly selected item of the given token (e.g. ITEM_ARMOR_TEST_1)
		Valid arguments for the second SYN_CLASS;
			upgrade - this will upgrade the item to one higher (i.e. ITEM_ARMOR_TEST_1 -> ITEM_ARMOR_TEST_2)
			downgrade - this will downgrade the item to one lower (i.e. ITEM_ARMOR_TEST_2 -> ITEM_ARMOR_TEST_1)
			ITEM_TOKEN - this will change the item to a completely new token (i.e. ITEM_ARMOR_TEST_1 -> ITEM_ARMOR_ELF_ARMOR)
		(OPTIONAL) A third SYN_CLASS can be added to specify duration of the change. Defaults to permanent. Duration is in in-game ticks
			
	EXAMPLE INORGANIC:
		[INORGANIC:UPGRADE_ITEM]
			[USE_MATERIAL_TEMPLATE:STONE_VAPOR_TEMPLATE]
			[SPECIAL]
			[SYNDROME]
				[SYN_CLASS:this]
				[SYN_CLASS:upgrade]
			[MATERIAL_VALUE:0]
	
	ITEM OPTIONS:
		Nothing special is required from items except when using the upgrade/downgrade option
		then the item you wish to change need to be named in the convention BLAH_BLAH_BLAH_1, BLAH_BLAH_BLAH_2, etc...
	
	EXAMPLE ITEMS:
		[ITEM_ARMOR:ITEM_ARMOR_TEST_1]
			[NAME:armor:armor]
			[PREPLURAL:suits of]
			[MATERIAL_PLACEHOLDER:leather]
			[ARMORLEVEL:1]
			[UBSTEP:1]
			[LBSTEP:1]
			[SHAPED]
			[LAYER:ARMOR]
			[COVERAGE:100]
			[LAYER_SIZE:20]
			[LAYER_PERMIT:49]
			[MATERIAL_SIZE:6]
			[LEATHER]
			[HARD]
			[BARRED]
			[SCALED]
	
		[ITEM_ARMOR:ITEM_ARMOR_TEST_2]
			[NAME:plated hide:plated hides]
			[ARMORLEVEL:3]
			[SHAPED]
			[LAYER:ARMOR]
			[COVERAGE:100]
			[LAYER_SIZE:25]
			[LEATHER]
			[LAYER_PERMIT:49]
			[MATERIAL_SIZE:9]
			[BARRED]
			[HARD]
			[METAL]
			
	RESTRICTIONS!
		Only upgrade between the same types (i.e. ARMOR -> ARMOR), never upgrade to different types
		Can upgrade anything with a subtype (including toys, instruments, siegeammo, etc...)
		Will not downgrade if item is at _1 and will not upgrade if there is no higher _#
--]]

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function createcallback(x,sid)
	return function(resetitem)
		x:setSubtype(sid)
	end
end

function itemSubtypes(item) -- Taken from Putnam's itemSyndrome
   local subtypedItemTypes =
    {
    ARMOR = df.item_armorst,
    WEAPON = df.item_weaponst,
    HELM = df.item_helmst,
    SHOES = df.item_shoesst,
    SHIELD = df.item_shieldst,
    GLOVES = df.item_glovest,
    PANTS = df.item_pantsst,
    TOOL = df.item_toolst,
    SIEGEAMMO = df.item_siegeammost,
    AMMO = df.item_ammost,
    TRAPCOMP = df.item_trapcompst,
    INSTRUMENT = df.item_instrumentst,
    TOY = df.item_toyst}
    for x,v in pairs(subtypedItemTypes) do
        if v:is_instance(item) then 
			return df.item_type[x]
		end
    end
    return false
end

function upgradeitem(reaction,unit,input_items,input_reagents,output_items,call_native)	
	local ptype = reaction.products[0].mat_type
	local pindx = reaction.products[0].mat_index
	local product = dfhack.matinfo.decode(ptype,pindx)
	local args = {}
	for i,x in ipairs(product.material.syndrome[0].syn_class) do
		args[i] = x.value
	end
	
	local dur = 0
	if #args == 2 then dur = tonumber(args[2]) end
	
	local sitems = {}
	if args[0] == 'this' then
-- Upgrade only the input items with preserve reagent
		for i,x in ipairs(input_reagents) do
			if x.flags.PRESERVE_REAGENT then sitems[i] = input_items[i] end
		end
	elseif args[0] == 'all' then
-- Upgrade all items of the same type as input
		local itemList = df.global.world.items.all
		local k = 1
		for j,y in ipairs(input_reagents) do
			if y.flags.PRESERVE_REAGENT then
				for i,x in ipairs(itemList) do
					if itemSubtypes(x) then
						if x.subtype.id == y.subtype.id then 
							sitems[k] = itemList[i] 
							k = k + 1
						end
					end
				end
			end	
		end
	else
-- Randomly upgrade one specific item
		local itemList = df.global.world.items.all
		local k = 1
		for j,y in ipairs(input_reagents) do
			if y.flags.PRESERVE_REAGENT then
				for i,x in ipairs(itemList) do
					if itemSubtypes(x) then
						if x.subtype.id == y.subtype.id then 
							sitems[k] = itemList[i] 
							k = k + 1
						end
					end
				end
			end	
		end
		local rando = dfhack.random.new()
		sitems = {sitems[rando:random(#sitems)]}
	end

	if args[1] == 'upgrade' then
-- Increase items number by one
		for _,x in ipairs(sitems) do
			local name = x.subtype.id
			if dur > 0 then sid = x.subtype.subtype end
			local namea = split(name,'_')
			local num = tonumber(namea[#namea])
			num = num + 1
			namea[#namea] = tostring(num)
			name = table.concat(namea,'_')
			item_index = itemSubtypes(x)
			for i=0,dfhack.items.getSubtypeCount(item_index)-1,1 do
				item_sub = dfhack.items.getSubtypeDef(item_index,i)
				if item_sub.id == name then x:setSubtype(item_sub.subtype) end
			end
			if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(x,sid)) end
		end
	elseif args[1] == 'downgrade' then
-- Decrease items number by one
		for _,x in ipairs(sitems) do
			local name = x.subtype.id
			if dur > 0 then sid = x.subtype.subtype end
			local namea = split(name,'_')
			local num = tonumber(namea[#namea])
			num = num - 1
			if num > 0 then namea[#namea] = tostring(num) end
			name = table.concat(namea,'_')
			item_index = itemSubtypes(x)
			for i=0,dfhack.items.getSubtypeCount(item_index)-1,1 do
				item_sub = dfhack.items.getSubtypeDef(item_index,i)
				if item_sub.id == name then x:setSubtype(item_sub.subtype) end
			end
			if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(x,sid)) end
		end
	else
-- Change item to new item
		for _,x in ipairs(sitems) do
			if dur > 0 then sid = x.subtype.subtype end
			item_index = itemSubtypes(x)
			for i=0,dfhack.items.getSubtypeCount(item_index)-1,1 do
				item_sub = dfhack.items.getSubtypeDef(item_index,i)
				if item_sub.id == args[1] then x:setSubtype(item_sub.subtype) end
			end
			if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(x,sid)) end
		end
	end
end

-- START Taken from hire-guard.lua
local eventful = require 'plugins.eventful'
local utils = require 'utils'

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

dfhack.onStateChange.loadUpgradeItem = function(code)
	local registered_reactions
	if code==SC_MAP_LOADED then
		--registered_reactions = {}
		for i,reaction in ipairs(df.global.world.raws.reactions) do
			-- register each applicable reaction (to avoid doing string check
			-- for every lua hook reaction (not just ours), this way uses identity check
			if string.starts(reaction.code,'LUA_HOOK_UPGRADE_ITEM') then
			-- register reaction.code
				eventful.registerReaction(reaction.code,upgradeitem)
				-- save reaction.code
				--table.insert(registered_reactions,reaction.code)
				registered_reactions = true
			end
		end
		--if #registered_reactions > 0 then print('HireGuard: Loaded') end
		if registered_reactions then print('Upgradable Items: Loaded') end
	elseif code==SC_MAP_UNLOADED then
		--[[ doesn't seem to be working, and probably not needed
		registered_reactions = registered_reactions or {}
		if #registered_reactions > 0 then print('HireGuard: Unloaded') end
		for i,reaction in ipairs(registered_reactions) do
			-- un register each registered reaction (to prevent persistance between
			-- differing worlds (probably irrelavant, but doesn't hurt)
			-- un register reaction.code
			eventful.registerReaction(reaction.code,nil)
		end
		registered_reactions = nil -- clear registered_reactions
		--]]
	end
end

-- if dfhack.init has already been run, force it to think SC_WORLD_LOADED to that reactions get refreshed
if dfhack.isMapLoaded() then dfhack.onStateChange.loadUpgradeItem(SC_MAP_LOADED) end
-- END Taken from hire-guard.lua
