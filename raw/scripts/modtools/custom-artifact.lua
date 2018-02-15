-- Makes it so that the world will always have certain artifacts in certain sites when world loads.
--@ module = true
--Author Putnam

local usage = [===[

modtools/custom-artifact
=====================
This tool, when run, checks if the specific item has an artifact record somewhere in the world
and places the artifact at a valid site (which can be constrained by arguments) if it is not found.

Arguments::

    -itemType type
        the type of item that will have an artifact spawned
        examples:
            WEAPON:ITEM_WEAPON_PICK
            RING
     -itemMat mat
         the material of the newly generated item
         examples:
            INORGANIC:IRON
            CREATURE_MAT:DWARF:BRAIN
            PLANT_MAT:MUSHROOM_HELMET_PLUMP:DRINK
     -name name
        the item's name
        should be set, will just go with no name if not
     -amount num
         the minimum artifacts required
         will continue to create new artifacts until this amount is reached
         this argument is optional and will default to 1
     -ignoreExisting
         will create (num) artifacts named (name) regardless of existing artifacts of that type
         do not use in onload scripts, will overrun world with that artifact type given enough reloads
     -specificEntityType [ entity1 entity2 ... ]
        entity filter, will only spawn in these entity's sites
        examples:
            MOUNTAIN
            EVIL
            FOREST
            PLAINS
     -specificSiteType [ site1 site2 ... ]
        site filter, will only spawn in these site types
        examples:
            CAVE_DETAILED
            DARK_FORTRESS
            TREE_CITY
            CITY
     -help
         displays this message
]===]

local utils=require('utils')

validArgs = utils.invert({
    'itemType',
    'amount',
    'itemMat',
    'specificEntityType',
    'specificSiteType',
    'ignoreExisting',
    'name',
    'help'
})

function getItemType(item) --just kinda grabbed this from item-trigger, like the help dialogue above
    local itemType
    if item:getSubtype() ~= -1 and dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()) then
        itemType = df.item_type[item:getType()]..':'..dfhack.items.getSubtypeDef(item:getType(),item:getSubtype()).id
    else
        itemType = df.item_type[item:getType()]
    end
    return itemType
end

function mysplit(inputstr, sep) --https://stackoverflow.com/questions/1426954/split-string-in-lua
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local function findTranslation(str)
    for k,v in ipairs(df.global.world.raws.language.translations) do
        if v.name==str then return k,v end
    end
    return false
end

function createArtifact(itemType,itemSubtype,name,material,entityFilter,siteFilter)
    local newArtifact = df.artifact_record:new()
    newArtifact.id=df.global.artifact_next_id
    local rng=dfhack.random.new(os.time(),df.global.artifact_next_id)
    local eligibleSites={}
    for _,site in ipairs(df.global.world.world_data.sites) do
        if site.civ_id~=-1 then
            local thisSiteType=df.site_type[site.type]
            if thisSiteType and (not entityFilter or entityFilter[df.historical_entity.find(site.civ_id).entity_raw.code]) and (not siteFilter or siteFilter[thisSiteType]) then
                table.insert(eligibleSites,site.id)
            end
        end
    end
    local pickedSite=eligibleSites[rng:random(#eligibleSites)+1]
    newArtifact.anon_1=-1000000  --TODO: REPLACE REPLACE REPLACE REPLACE REPLACE ALL OF THESE ANON IS BAD
    newArtifact.anon_2=-1000000
    newArtifact.anon_3=-1000000
    newArtifact.anon_4=pickedSite
    newArtifact.anon_5=1
    newArtifact.anon_6=-1
    newArtifact.anon_7=-1
    newArtifact.anon_8=-1
    newArtifact.anon_12=pickedSite
    newArtifact.anon_13=1
    newArtifact.anon_14=-1
    newArtifact.anon_15=-1
    newArtifact.anon_16=-1
    newArtifact.anon_17=250
    newArtifact.anon_18=0
    newArtifact.anon_19=3
    if name then
        newArtifact.name.has_name=true
        newArtifact.name.first_name=name
    end
    local newUnit = df.unit:new() --temp boi
    newUnit.pos.x=df.global.world.units.active[0].pos.x
    newUnit.pos.y=df.global.world.units.active[0].pos.y
    newUnit.pos.z=df.global.world.units.active[0].pos.z
    local newItem = df.item.find(dfhack.items.createItem(itemType,itemSubtype,material.type,material.index,newUnit))
    newUnit:delete()
    newUnit=nil
    newItem.id=df.global.item_next_id
    newItem.pos.x=-30000
    newItem.pos.y=-30000
    newItem.pos.z=-30000
    local artifactRef=df.general_ref_is_artifactst:new()
    artifactRef.artifact_id=newArtifact.id
    newItem.general_refs:insert('#',artifactRef)
    newItem.flags.artifact=true
    newItem.flags.artifact_mood=true
    newItem.maker=-1
    newItem.masterpiece_event=-1
    newItem.quality=df.item_quality.Artifact
    newArtifact.item=newItem
    local newEvent=df.history_event_artifact_storedst:new()
    newEvent.artifact=newArtifact.id
    newEvent.unit=-1
    newEvent.histfig=-1
    newEvent.site=pickedSite
    df.global.world.history.events:insert('#',newEvent)
    df.global.world.artifacts.all:insert('#',newArtifact)
    df.world_site.find(pickedSite).artifacts:insert('#',newArtifact)
    df.global.artifact_next_id=df.global.artifact_next_id+1
end

if moduleMode then 
    return
end

local args = utils.processArgs({...}, validArgs)

if args.help or not args.itemType or not args.itemMat then
    print(usage)
    return
end

local itemType,itemSubtype

local itemTypeSplit=mysplit(args.itemType,':')

local itemTypeStr,itemSubtypeStr=itemTypeSplit[1],itemTypeSplit[2]

itemType=df.item_type[itemTypeStr]

if not itemType then
    qerror('Could not find item type: '..args.itemType)    
end

if #itemTypeSplit>1 then
    local temp
    for _,itemdef in ipairs(df.global.world.raws.itemdefs.all) do
        if itemdef.id == itemSubtypeStr then
            itemSubtype=itemdef.subtype
            break
        end
    end
    if not itemSubtype then
        qerror('Could not find item type: '..args.itemType)
    end
end

args.amount=args.amount and tonumber(args.amount) or 1

local totalArtifactsOfItemType=0

if not args.ignoreExisting then
    for k,v in ipairs(df.global.world.artifacts.all) do
        if getItemType(v.item)==args.itemType then
            totalArtifactsOfItemType=totalArtifactsOfItemType+1
        end
    end
end

local itemMat=args.itemMat and dfhack.matinfo.find(args.itemMat) or false

if totalArtifactsOfItemType<args.amount then
    for i=totalArtifactsOfItemType,args.amount-1,1 do
        createArtifact(itemType,itemSubtype,args.name,itemMat,args.specificEntityType and utils.invert(args.specificEntityType),args.specificSiteType and utils.invert(args.specificSiteType))
    end
end