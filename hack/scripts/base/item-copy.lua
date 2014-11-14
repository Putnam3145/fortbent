--base/item-copy.lua v1.0
--[[
base_copyitem - used to make an exact copy of the item 
	Requires a reaction

	REACTION OPTIONS:
		All item reagents with [PRESERVE_REAGENT] will be flagged for copying
		Reagents without the [PRESERVE_REAGENT] tag will be consumed
		The reagent with the 'mat' ID will be the material the copied item is made from
		If no reagent with 'mat' is found, it will use the material of the item being copied
		Products will be created as normal
		
	EXAMPLE REACTION:
		[REACTION:LUA_HOOK_COPY_ITEM_EXAMPLE_1] <- LUA_HOOK_COPY_ITEM is required
			[NAME:copy giant's armor]
			[BUILDING:FORGARY_SMITH:NONE]
			[REAGENT:A:1:ARMOR:ITEM_ARMOR_GIANTS_SPECIAL:INORGANIC:NONE][PRESERVE_REAGENT]
			[REAGENT:mat:150:BAR:NONE:INORGANIC:NONE] <- will read the reagent with 'mat' for its definer as the base for the new item
			[REAGENT:C:1500:COIN:NONE:INORGANIC:SILVER]
			[PRODUCT:100:1:BOULDER:NONE:INORGANIC:FORGER_EXPERIANCE] <- for experiance gains, not actually needed
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
			return x
		end
    end
    return false
end

function copyitem(reaction,unit,input_items,input_reagents,output_items,call_native)
	local itemmat = nil
	for i,x in ipairs(input_reagents) do
		if x.flags.PRESERVE_REAGENT then sitems[i] = input_items[i] end
		if x.code == 'mat' then itemmat = input_items[i] end
	end
	
	for i,x in ipairs(sitems) do
		t = itemSubtypes[x]
		if t == 'WEAPON' then v = 'item_weaponst' end
		if t == 'ARMOR' then v = 'item_armorst' end
		if t == 'HELM' then v = 'item_helmst' end
		if t == 'SHOES' then v = 'item_shoesst' end
		if t == 'SHIELD' then v = 'item_shieldst' end
		if t == 'GLOVE' then v = 'item_glovest' end
		if t == 'PANTS' then v = 'item_pantsst' end
		if t == 'AMMO' then v = 'item_ammost' end	
			
		local item=df[v]:new() --incredible
		item.id=df.global.item_next_id
		df.global.world.items.all:insert('#',item)
		df.global.item_next_id=df.global.item_next_id+1
		item:setSubtype(x.subtype.subtype)
		if itemmat == nil then
			item:setMaterial(x.mat_type)
			item:setMaterialIndex(x.mat_index)
		else
			item:setMaterial(itemmat.mat_type)
			item:setMaterialIndex(itemmat.mat_index)
		end
		item:categorize(true)
		item.flags.removed=true
		if t == 'WEAPON' then item:setSharpness(1,0) end
		item:setQuality(input_items[i].quality)
		dfhack.items.moveToGround(item,{x=unit.pos.x,y=unit.pos.y,z=unit.pos.z})
	end
end

-- START Taken from hire-guard.lua
local eventful = require 'plugins.eventful'
local utils = require 'utils'

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

dfhack.onStateChange.loadCopyItem = function(code)
	local registered_reactions
	if code==SC_MAP_LOADED then
		--registered_reactions = {}
		for i,reaction in ipairs(df.global.world.raws.reactions) do
			-- register each applicable reaction (to avoid doing string check
			-- for every lua hook reaction (not just ours), this way uses identity check
			if string.starts(reaction.code,'LUA_HOOK_COPY_ITEM') then
			-- register reaction.code
				eventful.registerReaction(reaction.code,copyitem)
				-- save reaction.code
				--table.insert(registered_reactions,reaction.code)
				registered_reactions = true
			end
		end
		--if #registered_reactions > 0 then print('HireGuard: Loaded') end
		if registered_reactions then print('Copyable Items: Loaded') end
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
if dfhack.isMapLoaded() then dfhack.onStateChange.loadCopyItem(SC_MAP_LOADED) end
-- END Taken from hire-guard.lua
