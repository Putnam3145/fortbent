--base/building-upgrade.lua v1.0
--MUST BE LOADED IN DFHACK.INIT
--[[
upgradebuilding - used to upgrade buildings from one to another, or to change them from one to another
	Requires a reaction an inorganic and corresponding buildings

	REACTION OPTIONS:
		All reagents with [PRESERVE_REAGENT] will be added to the building materials of the upgraded building and can be reclaimed by destroying the upgraded building
		Reagents without the [PRESERVE_REAGENT] tag will be consumed and will not be able to be reclaimed
		The first product must be the inorganic with the syndrome attached to it
		Subsequent products will be created as normal
		
	EXAMPLE REACTION:
		[REACTION:LUA_HOOK_UPGRADE_BUILDING_EXAMPLE_1] <- LUA_HOOK_UPGRADE_BUILDING is required
			[NAME:upgrade building]
			[BUILDING:TEST_BUILDING_1:NONE]
			[REAGENT:A:1:BOULDER:NONE:INORGANIC:NONE][PRESERVE_REAGENT]
			[REAGENT:B:1:BOULDER:NONE:INORGANIC:NONE][PRESERVE_REAGENT]
			[REAGENT:C:1500:COIN:NONE:INORGANIC:SILVER]
			[PRODUCT:100:0:BOULDER:NONE:INORGANIC:UPGRADE_BUILDING]
	
	INORGANIC OPTIONS:
		Inorganics must have a syndrome with at least two [SYN_CLASS:] tags
		Valid arguments for the first SYN_CLASS;
			here - this will change this particular building
			BUILDING_TOKEN - this will change a randomly selected building of the given token (e.g. TEST_BUILDING_1)
		Valid arguments for the second SYN_CLASS;
			upgrade - this will upgrade the building from the name to one higher (i.e. TEST_BUILDING_1 -> TEST_BUILDING_2)
			downgrade - this will downgrade the building from the name to one lower (i.e. TEST_BUILDING_2 -> TEST_BUILDING_1)
			BUILDING_TOKEN - this will change the building to a completely new token (i.e. TEST_BUILDING_1 -> RESEARCH_BUILDING)
		(OPTIONAL) A third SYN_CLASS can be added to specify duration of the change. Defaults to permanent. Duration is in in-game ticks
		
	EXAMPLE INORGANIC:
		[INORGANIC:UPGRADE_BUILDING]
			[USE_MATERIAL_TEMPLATE:STONE_VAPOR_TEMPLATE]
			[SPECIAL]
			[SYNDROME]
				[SYN_CLASS:here]
				[SYN_CLASS:upgrade]
			[MATERIAL_VALUE:0]
	
	BUILDING OPTIONS:
		Nothing special is required from buildings except when using the upgrade/downgrade option
		then the buildings you wish to change need to be named in the convention BLAH_BLAH_BLAH_1, BLAH_BLAH_BLAH_2, etc...
	
	EXAMPLE BUILDINGS:
		[BUILDING_WORKSHOP:TEST_BUILDING_1]
			[NAME:Soul Forge]
			[NAME_COLOR:7:0:1]
			[DIM:3:3]
			[WORK_LOCATION:1:1]
			[BLOCK:1:0]
			[TILE:0:1:207]
			[COLOR:0:1:0:7:0]
			[TILE:1:1:207]
			[COLOR:1:1:MAT]
			[BUILD_ITEM:1:NONE:NONE:NONE:NONE]
			[BUILDMAT]
			[WORTHLESS_STONE_ONLY]
	
		[BUILDING_WORKSHOP:TEST_BUILDING_2]
			[NAME:Upgraded Soul Forge]
			[NAME_COLOR:7:0:1]
			[DIM:3:3]
			[WORK_LOCATION:1:1]
			[BLOCK:1:0]
			[TILE:0:1:207]
			[COLOR:0:1:0:7:0]
			[TILE:1:1:207]
			[COLOR:1:1:MAT]
			
	RESTRICTIONS!
		Only upgrade between buildings of the same type (i.e. WORKSHOP->WORKSHOP)
		Only upgrade to buildings of the same size (i.e. 3x3 -> 3x3)
		Only upgrade to buildings with the same center and work spot (I don't know if this is strictly necessary, haven't done much testing)
		Be careful about forbiden tiles in a building, the effect of changing these tiles without redefining the building is unknown
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
	return function(resetbuilding)
		x.custom_type = sid
	end
end

function upgradebuilding(reaction,unit,input_items,input_reagents,output_items,call_native)
	local sitems = {}
	for i,x in ipairs(input_reagents) do
		if x.flags.PRESERVE_REAGENT then sitems[i] = input_items[i] end
	end
	local pos = unit.pos

	local ptype = reaction.products[0].mat_type
	local pindx = reaction.products[0].mat_index
	local product = dfhack.matinfo.decode(ptype,pindx)
	local args = {}
	for i,x in ipairs(product.material.syndrome[0].syn_class) do
		args[i] = x.value
	end
	
	local dur = 0
	if #args == 2 then dur = tonumber(args[2]) end
	printall(args)
	print(#args)
	print(dur)
	print(args[2])
	local bldg
	if args[0] == 'here' then 
-- Upgrade only the building that runs the reaction
		bldg = dfhack.buildings.findAtTile(pos)
	elseif args[0] == 'all' then
-- Upgrade all buildings of this type (doesn't currently work)
	else
-- Upgrade random building of specific type
		local bldga = {}
		local i = 0
		for _,x in ipairs(df.global.world.buildings.all) do
			if df.building_furnacest:is_instance(x) or df.building_workshopst:is_instance(x) then
				local ctype = x.custom_type
				if ctype >= 0 then
					if df.global.world.raws.buildings.all[ctype].code == args[0] then 
						bldga[i] = x
						i = i+1
					end
				end
			end
		end
		local rando = dfhack.random.new()
		bldg = bldga[rando:random(#bldga)]
	end
	
	if args[1] == 'upgrade' then
-- Increase buildings number by one
		local name = df.global.world.raws.buildings.all[bldg.custom_type].code
		if dur > 0 then sid = bldg.custom_type end
		local namea = split(name,'_')
		local num = tonumber(namea[#namea])
		num = num + 1
		namea[#namea] = tostring(num)
		name = table.concat(namea,'_')
		local ctype = nil
		for _,x in ipairs(df.global.world.raws.buildings.all) do
			if x.code == name then ctype = x.id end
		end
		if ctype == nil then 
			print('Cant find upgrade building, possibly upgraded to max') 
			return
		end
		
		bldg.custom_type=ctype

		for _,x in pairs(bldg.contained_items) do
			for _,y in pairs(sitems) do
				if x.item == y then 
					x.use_mode = 2 
					x.item.flags.in_building = true 
				end
			end
		end
		if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(bldg,sid)) end
	elseif args[1] == 'downgrade' then
-- Decrease buildings number by one
		local name = df.global.world.raws.buildings.all[bldg.custom_type].code
		if dur > 0 then sid = bldg.custom_type end
		local namea = split(name,'_')
		local num = tonumber(namea[#namea])
		num = num - 1
		if num > 0 then namea[#namea] = tostring(num) end 
		name = table.concat(namea,'_')
		local ctype = nil
		for _,x in ipairs(df.global.world.raws.buildings.all) do
			if x.code == name then ctype = x.id end
		end
		if ctype == nil then 
			print('Cant find upgrade building, possibly upgraded to max') 
			return
		end
		
		bldg.custom_type=ctype
		
		for _,x in pairs(bldg.contained_items) do
			for _,y in pairs(sitems) do
				if x.item == y then 
					x.use_mode = 2 
					x.item.flags.in_building = true 
				end
			end
		end
		if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(bldg,sid)) end
	else
-- Change building to new building
		if dur > 0 then sid = bldg.custom_type end
		local name = args[1]
		local ctype = nil
		for _,x in ipairs(df.global.world.raws.buildings.all) do
			if x.code == name then ctype = x.id end
		end
		if ctype == nil then 
			print('Cant find upgrade building, possibly upgraded to max') 
			return
		end
		
		bldg.custom_type=ctype
		
		for _,x in pairs(bldg.contained_items) do
			for _,y in pairs(sitems) do
				if x.item == y then 
					x.use_mode = 2 
					x.item.flags.in_building = true 
				end
			end
		end
		if dur > 0 then dfhack.timeout(dur,'ticks',createcallback(bldg,sid)) end
	end
end

-- START Taken from hire-guard.lua
local eventful = require 'plugins.eventful'
local utils = require 'utils'

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

dfhack.onStateChange.loadUpgradeBuilding = function(code)
	local registered_reactions
	if code==SC_MAP_LOADED then
		--registered_reactions = {}
		for i,reaction in ipairs(df.global.world.raws.reactions) do
			-- register each applicable reaction (to avoid doing string check
			-- for every lua hook reaction (not just ours), this way uses identity check
			if string.starts(reaction.code,'LUA_HOOK_UPGRADE_BUILDING') then
			-- register reaction.code
				eventful.registerReaction(reaction.code,upgradebuilding)
				-- save reaction.code
				--table.insert(registered_reactions,reaction.code)
				registered_reactions = true
			end
		end
		--if #registered_reactions > 0 then print('HireGuard: Loaded') end
		if registered_reactions then print('Upgradable Buildings: Loaded') end
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
if dfhack.isMapLoaded() then dfhack.onStateChange.loadUpgradeBuilding(SC_MAP_LOADED) end
-- END Taken from hire-guard.lua
