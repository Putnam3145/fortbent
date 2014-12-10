function getGenderString(gender)
 local genderStr
 if gender==0 then
  genderStr=string.char(12)
 elseif gender==1 then
  genderStr=string.char(11)
 else
  return ""
 end
 return string.char(40)..genderStr..string.char(41)
end
 
function getCreatureList()
 local crList={}
 for k,cr in ipairs(df.global.world.raws.creatures.alphabetic) do
  for kk,ca in ipairs(cr.caste) do
   local str=ca.caste_name[0]
   str=str..' '..getGenderString(ca.gender)
   table.insert(crList,{str,nil,ca})
  end
 end
 return crList
end

function getMatFilter(itemtype)
  local itemTypes={
   SEEDS=function(mat,parent,typ,idx)
    return mat.flags.SEED_MAT
   end,
   PLANT=function(mat,parent,typ,idx)
    return mat.flags.STRUCTURAL_PLANT_MAT
   end,
   LEAVES=function(mat,parent,typ,idx)
    return mat.flags.LEAF_MAT
   end,
   MEAT=function(mat,parent,typ,idx)
    return mat.flags.MEAT
   end,
   CHEESE=function(mat,parent,typ,idx)
    return (mat.flags.CHEESE_PLANT or mat.flags.CHEESE_CREATURE)
   end,
   LIQUID_MISC=function(mat,parent,typ,idx)
    return (mat.flags.LIQUID_MISC_PLANT or mat.flags.LIQUID_MISC_CREATURE or mat.flags.LIQUID_MISC_OTHER)
   end,
   POWDER_MISC=function(mat,parent,typ,idx)
    return (mat.flags.POWDER_MISC_PLANT or mat.flags.POWDER_MISC_CREATURE)
   end,
   DRINK=function(mat,parent,typ,idx)
    return (mat.flags.ALCOHOL_PLANT or mat.flags.ALCOHOL_CREATURE)
   end,
   GLOB=function(mat,parent,typ,idx)
    return (mat.flags.STOCKPILE_GLOB)
   end,
   WOOD=function(mat,parent,typ,idx)
    return (mat.flags.WOOD)
   end,
   THREAD=function(mat,parent,typ,idx)
    return (mat.flags.THREAD_PLANT)
   end,
   LEATHER=function(mat,parent,typ,idx)
    return (mat.flags.LEATHER)
   end
  }
  return itemTypes[df.item_type[itemtype]] or getRestrictiveMatFilter(itemtype)
end

function getRestrictiveMatFilter(itemType)
 local itemTypes={
   WEAPON=function(mat,parent,typ,idx)
    return (mat.flags.ITEMS_WEAPON or mat.flags.ITEMS_WEAPON_RANGED)
   end,
   AMMO=function(mat,parent,typ,idx)
    return (mat.flags.ITEMS_AMMO)
   end,
   ARMOR=function(mat,parent,typ,idx)
    return (mat.flags.ITEMS_ARMOR)
   end,
   INSTRUMENT=function(mat,parent,typ,idx)
    return (mat.flags.ITEMS_HARD)
   end,
   AMULET=function(mat,parent,typ,idx)
    return (mat.flags.ITEMS_SOFT or mat.flags.ITEMS_HARD)
   end,
   ROCK=function(mat,parent,typ,idx)
    return (mat.flags.IS_STONE)
   end,
   BOULDER=ROCK,
   BAR=function(mat,parent,typ,idx)
    return (mat.flags.IS_METAL or mat.flags.SOAP or mat.id==COAL)
   end
   
  }
 for k,v in ipairs({'GOBLET','FLASK','TOY','RING','CROWN','SCEPTER','FIGURINE','TOOL'}) do
  itemTypes[v]=itemTypes.INSTRUMENT
 end
 for k,v in ipairs({'SHOES','SHIELD','HELM','GLOVES'}) do
    itemTypes[v]=itemTypes.ARMOR
 end
 for k,v in ipairs({'EARRING','BRACELET'}) do
    itemTypes[v]=itemTypes.AMULET
 end
 itemTypes.BOULDER=itemTypes.ROCK
 return itemTypes[df.item_type[itemType]]
end
 
function qualityTable()
 return {{'None'},
 {'-Well-crafted-'},
 {'+Finely-crafted+'},
 {'*Superior*'},
 {string.char(240)..'Exceptional'..string.char(240)},
 {string.char(15)..'Masterwork'..string.char(15)}
 }
end
 
local script=require('gui.script')
 
function showItemPrompt(text,item_filter,hide_none)
 require('gui.materials').ItemTypeDialog{
  frame_title='Alchemization',
  prompt=text,
  item_filter=item_filter,
  hide_none=hide_none,
  on_select=script.mkresume(true),
  on_cancel=script.mkresume(false),
  on_close=script.qresume(nil)
 }:show()
 
 return script.wait()
end
 
function showMaterialPrompt(title, prompt, filter, inorganic, creature, plant) --the one included with DFHack doesn't have a filter or the inorganic, creature, plant things available
 require('gui.materials').MaterialDialog{
  frame_title = title,
  prompt = prompt,
  mat_filter = filter,
  use_inorganic = inorganic,
  use_creature = creature,
  use_plant = plant,
  on_select = script.mkresume(true),
  on_cancel = script.mkresume(false),
  on_close = script.qresume(nil)
 }:show()
 
 return script.wait()
end
 
function usesCreature(itemtype)
 local typesThatUseCreatures={REMAINS=true,FISH=true,FISH_RAW=true,VERMIN=true,PET=true,EGG=true,CORPSE=true,CORPSEPIECE=true}
 return typesThatUseCreatures[df.item_type[itemtype]]
end
 
function getCreatureRaceAndCaste(caste)
 return df.global.world.raws.creatures.list_creature[caste.index],df.global.world.raws.creatures.list_caste[caste.index]
end

function alchemization_item_filter(itype,subtype,def) 
    if usesCreature(itype) then return false end
    if itype==df.item_type.SLAB then return false end
    if def then
        if def.source_hfid~=-1 or def.id:find('NO_ALCHEMIZE') or (def.id:find('ZILLY') and grist.ints[2]<1) then return false end
    end
    if dfhack.items.getItemBaseValue(itype,subtype,0,dfhack.matinfo.find('SLATE').index)>grist.ints[1] then return false end
    return true
end

function alchemization_material_filter(mat,parent,typ,idx)
    if not getMatFilter(itemType)(mat,parent,typ,idx) then return false end
    if dfhack.items.getItemBaseValue(itemtype,itemsubtype,typ,idx)<grist.ints[1] or def.id:find('NO_ALCHEMIZE') then
        return false
    end
    return true
end

local grist

function alchemize(adventure,unit)
    if adventure then
        grist=dfhack.persistent.save({key='GRIST_'..df.global.world.units.active[0].civ_id})
    else
        grist=dfhack.persistent.save({key='GRIST_'..df.global.ui.civ_id})
    end
    script.start(function()
    itemok,itemtype,itemsubtype=showItemPrompt('Choose the item',alchemization_item_filter,true) --global variables groooaaaaan but the way the filters work I have to
    local zilly=dfhack.items.getSubtypeDef(itemtype,itemsubtype).id:find('ZILLY')
    if zilly then
        local gristok=script.showYesNoPrompt('Alchemization','This will cost 1 zilly grist out of ' .. grist.ints[2] .. '. Ok?')
        if gristok then
            grist.ints[2]=grist.ints[2]-1
            local zilly_mat
            local subtype=dfhack.items.getSubtypeDef(itemtype,itemsubtype)
            if subtype.id=='ITEM_WEAPON_TROLL_KATANA_ZILLY' then
                zilly_mat=dfhack.matinfo.find('UNBREAKABLE_STUFF_TROLL')
            elseif (df.item_type[itemtype]=='WEAPON' or df.item_type[itemtype]=='TRAPCOMP') and not subtype.flags.HAS_EDGE_ATTACK then
                zilly_mat=dfhack.matinfo.find('SPECIAL_BLUNT_NO_ALCHEMIZE')
            else
                zilly_mat=dfhack.matinfo.find('SPECIAL_SHARP_NO_ALCHEMIZE')
            end
            dfhack.items.createItem(itemtype,itemsubtype,zilly_mat.type,zilly_mat.index,unit)
        end
    else
        local matok,mattype,matindex=showMaterialPrompt('Alchemization','Choose the material',alchemization_material_filter,true,true,true)
        local gristok=script.showYesNoPrompt('Alchemization','This will cost ' .. dfhack.items.getItemBaseValue(itemtype,itemsubtype,mattype,matindex) .. 'grist (you currently have ' .. grist.ints[1] .. '). Ok?')
        if gristok then 
            grist.ints[1]=grist.ints[1]-dfhack.items.getItemBaseValue(itemtype,itemsubtype,mattype,matindex)
            dfhack.items.createItem(itemtype, itemsubtype, mattype, matindex, unit)
        end
    end
    end)
end

utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit',
 'adventure'
})

args = utils.processArgs({...}, validArgs)

alchemize(args.adventure,args.unit)