--base/item-imbue.lua v1.0
--[[
base_imbueitem - used to change an items material from one to another
	Requires a reaction and an inorganic

	REACTION OPTIONS:
		All item reagents with [PRESERVE_REAGENT] will be flagged for material change
		Reagents without the [PRESERVE_REAGENT] tag will be consumed
		The first product must be the inorganic with the syndrome attached to it
		Subsequent products will be created as normal
		
	EXAMPLE REACTION:
		[REACTION:LUA_HOOK_IMBUE_ITEM_EXAMPLE_1] <- LUA_HOOK_IMBUE_ITEM is required
			[NAME:imbue armor with fire]
			[BUILDING:ANVIL_OF_POWER:NONE]
			[REAGENT:A:1:ARMOR:NONE:INORGANIC:NONE][PRESERVE_REAGENT]
			[REAGENT:C:1500:COIN:NONE:INORGANIC:SILVER]
			[PRODUCT:100:0:BOULDER:NONE:INORGANIC:IMBUE_ITEM_FIRE]
	
	INORGANIC OPTIONS:
		Inorganics must have a syndrome with at least two [SYN_CLASS:] tags
		Valid arguments for the first SYN_CLASS;
			this - this will change the items in the reaction
			all - this will change all items of the same type and subtype as the items in the reaction
			ITEM_TOKEN - this will change a randomly selected item of the given token (e.g. ITEM_ARMOR_TEST_1)
		Valid arguments for the second SYN_CLASS;
			Any INORGANIC_ID
		(OPTIONAL) A third SYN_CLASS can be added to specify duration of the change. Defaults to permanent. Duration is in in-game ticks
			
	EXAMPLE INORGANIC:
		[INORGANIC:UPGRADE_ITEM]
			[USE_MATERIAL_TEMPLATE:STONE_VAPOR_TEMPLATE]
			[SPECIAL]
			[SYNDROME]
				[SYN_CLASS:this]
				[SYN_CLASS:INORGANIC_MAGIC_FIRE]
				[SYN_CLASS:3600]
			[MATERIAL_VALUE:0]
--]]

function createcallback(item,stype,sindex)
	return function (resetweapon)
		item.mat_type = stype
		item.mat_index = sindex
	end
end

function imbueitem(reaction,unit,input_items,input_reagents,output_items,call_native)	
	local ptype = reaction.products[0].mat_type
	local pindx = reaction.products[0].mat_index
	local product = dfhack.matinfo.decode(ptype,pindx)
	local args = {}
	for i,x in ipairs(product.material.syndrome[0].syn_class) do
		args[i] = x.value
	end
	
	local mat = args[1]
	local mat_type = dfhack.matinfo.find(mat).type
	local mat_index = dfhack.matinfo.find(mat).index
	
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

	for i,x in ipairs(sitems) do
		local stype = x.mat_type
		local sindex = x.mat_index
		x.mat_type = mat_type
		x.mat_index = mat_index

		if dur > 0 then
			dfhack.timeout(dur,'ticks',createcallback(x,stype,sindex))
		end
	end
end

-- START Taken from hire-guard.lua
local eventful = require 'plugins.eventful'
local utils = require 'utils'

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

dfhack.onStateChange.loadImbueItem = function(code)
	local registered_reactions
	if code==SC_MAP_LOADED then
		--registered_reactions = {}
		for i,reaction in ipairs(df.global.world.raws.reactions) do
			-- register each applicable reaction (to avoid doing string check
			-- for every lua hook reaction (not just ours), this way uses identity check
			if string.starts(reaction.code,'LUA_HOOK_IMBUE_ITEM') then
			-- register reaction.code
				eventful.registerReaction(reaction.code,imbueitem)
				-- save reaction.code
				--table.insert(registered_reactions,reaction.code)
				registered_reactions = true
			end
		end
		--if #registered_reactions > 0 then print('HireGuard: Loaded') end
		if registered_reactions then print('Imbue Items: Loaded') end
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
if dfhack.isMapLoaded() then dfhack.onStateChange.loadImbueItem(SC_MAP_LOADED) end
-- END Taken from hire-guard.lua