
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
  --print(itemTypes[df.item_type[itemtype]])
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
    return (mat.flags.IS_METAL or mat.flags.SOAP or mat.id=='COAL')
   end
   
  }
 for k,v in ipairs({'SHOES','SHIELD','HELM','GLOVES'}) do
    itemTypes[v]=itemTypes.ARMOR
 end
 for k,v in ipairs({'EARRING','BRACELET','CHAIN'}) do
    itemTypes[v]=itemTypes.AMULET
 end
 itemTypes.BOULDER=itemTypes.ROCK
 --print(itemType)
 --print(itemTypes[df.item_type[itemType]])
 return itemTypes[df.item_type[itemType]] or itemTypes.INSTRUMENT
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

function alchemization_item_filter(itype,subtype,def) 
    if def then
        if (def.id:find('ZILLY') and grist.ints[2]>0) then return true end
        if def.id:find('ARTIFACT_GRIST') then return true end
    end
    if dfhack.items.getItemBaseValue(itype,subtype,0,dfhack.matinfo.find('SLATE').index)>grist.ints[1] then return false end
    if itype==df.item_type.BOULDER or itype==df.item_type.WOOD or itype==df.item_type.PLANT or itype==df.item_type.ROUGH then return true end
    return false
end

function adventure_item_filter(itype,subtype,def)
    if usesCreature(itype) then return false end
    if itype==df.item_type.SLAB or itype==df.item_type.BOOK then return false end
    if def then
        if def.source_hfid~=-1 or def.id:find('NO_ALCHEMIZE') or (def.id:find('ZILLY') and grist.ints[2]<1) then return false end
    end
    if dfhack.items.getItemBaseValue(itype,subtype,0,dfhack.matinfo.find('SLATE').index)>grist.ints[1] then return false end
    return true
end

function alchemization_material_filter(mat,parent,typ,idx)
    if not getMatFilter(itemtype)(mat,parent,typ,idx) then return false end
    if dfhack.items.getItemBaseValue(itemtype,itemsubtype,typ,idx)>grist.ints[1] or mat.id:find('NO_ALCHEMIZE') then
        return false
    end
    return true
end

function alchemize(adventure,unit)
    script.start(function()
    if adventure then
        grist=dfhack.persistent.save({key='GRIST_'..df.global.world.units.active[0].civ_id})
        unit=df.global.world.units.active[0]
        itemok,itemtype,itemsubtype=showItemPrompt('Choose item ('..grist.ints[1]..' grist remaining)',adventure_item_filter,true) --global variables groooaaaaan but the way the filters work I have to
    else
        grist=dfhack.persistent.save({key='GRIST_'..df.global.ui.civ_id})
        itemok,itemtype,itemsubtype=showItemPrompt('Choose item ('..grist.ints[1]..' grist remaining)',alchemization_item_filter,true) --global variables groooaaaaan but the way the filters work I have to    end
    --print(grist)
    itemok,itemtype,itemsubtype=showItemPrompt('Choose item ('..grist.ints[1]..' grist remaining)',alchemization_item_filter,true) --global variables groooaaaaan but the way the filters work I have to
    if not itemok then return end
    local zilly=dfhack.items.getSubtypeCount(itemtype)>-1 and dfhack.items.getSubtypeDef(itemtype,itemsubtype).id:find('ZILLY')
    local artifact=dfhack.items.getSubtypeCount(itemtype)>-1 and dfhack.items.getSubtypeDef(itemtype,itemsubtype).id:find('ARTIFACT_GRIST')
    if zilly then
        local gristok=script.showYesNoPrompt('Alchemization','This will cost 1 zilly grist out of ' .. grist.ints[2] .. '. Ok?')
        if gristok then
            grist.ints[2]=grist.ints[2]-1
            grist:save()
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
            grist:save()
        end
    elseif artifact then
        local artifact_mat=dfhack.matinfo.find('JPEG_ARTIFACT_NO_ALCHEMIZE')
        repeat amountok,amount=script.showInputPrompt('Alchemization','How many do you want?',COLOR_LIGHTGREEN) until (tonumber(amount)>0 or not amountok)
        local grist_cost=dfhack.items.getItemBaseValue(itemtype,itemsubtype,artifact_mat.type,artifact_mat.index)*tonumber(amount)
        local gristok=script.showYesNoPrompt('Alchemization','This will cost ' .. grist_cost .. ' grist (you currently have ' .. grist.ints[1] .. '). Ok?')
        if gristok then
            grist.ints[1]=grist.ints[1]-grist_cost
            grist:save()
            dfhack.items.createItem(itemtype,itemsubtype,artifact_mat.type,artifact_mat.index,unit)
        end
    else
        local matok,mattype,matindex=showMaterialPrompt('Alchemization','Choose the material',alchemization_material_filter,true,true,true)
        local amountok,amount
        local grist_cost=dfhack.items.getItemBaseValue(itemtype,itemsubtype,mattype,matindex)
        local maximum=math.floor(grist.ints[1]/grist_cost)
        repeat amountok,amount=script.showInputPrompt('Alchemization','How many do you want? (up to '..maximum..')',COLOR_LIGHTGREEN) until (tonumber(amount)<maximum+1 or not amountok)
        local gristok=script.showYesNoPrompt('Alchemization','This will cost ' .. grist_cost*tonumber(amount) .. ' grist (you currently have ' .. grist.ints[1] .. '). Ok?')
        if gristok and amountok then 
            grist.ints[1]=grist.ints[1]-(grist_cost*tonumber(amount))
            grist:save() --redundancy redundancy redundancy
            if df.item_type.attrs[itemtype].is_stackable then
                local proper_item=df.item.find(dfhack.items.createItem(itemtype, itemsubtype, mattype, matindex, unit))
                proper_item:setStackSize(amount)
            else
                for i=1,amount do
                    dfhack.items.createItem(itemtype, itemsubtype, mattype, matindex, unit)
                end
            end
            grist:save()
        end
    end
    end)
    grist:save()
end

utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit',
 'adventure'
})

args = utils.processArgs({...}, validArgs)

alchemize(args.adventure,df.unit.find(args.unit))