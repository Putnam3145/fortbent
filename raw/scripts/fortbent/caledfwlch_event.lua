local utils=require('utils')

validArgs = utils.invert({
 'void',
 'doom',
})

local args = utils.processArgs({...}, validArgs)

local function capitalizeFirstLetterOfString(str)
    return str:sub(1,1):upper()..str:sub(2,-1)
end

local function getPronoun(unit)
    if unit.status.current_soul then
        if unit.status.current_soul.sex==0 then
            return {'she','her','her','hers'}
        elseif unit.status.current_soul.sex==1 then
            return {'he','him','his','his'}
        else
            return {'they','them','their','theirs'}
        end
    else
        return {'it','it','its','its'}
    end
end

local doomHero=df.unit.find(args.doom)
local voidHero=df.unit.find(args.void)
local doomName=capitalizeFirstLetterOfString(doomHero.name.first_name)
local voidName=capitalizeFirstLetterOfString(voidHero.name.first_name)
local doomPronoun=getPronoun(doomHero)
local voidPronoun=getPronoun(voidHero)
dfhack.makeAnnouncement(df.announcement_type.ENDGAME_EVENT_1,{RECENTER=true,A_DISPLAY=true,D_DISPLAY=true,PAUSE=true,DO_MEGA=true},doomHero.pos,doomName..' has seen a vision of Lord English and how to defeat him. To deal with this, ' .. doomPronoun[1] .. ' asks ' ..voidName..' for help. Being a highly skilled void hero, '..voidPronoun..' accepts the challenge, and a legendary sword is created, Caledfwlch.',COLOR_CYAN,true)
local caledfwlchDef='WEAPON:ITEM_WEAPON_TROLL_CALEDFWLCH_CUE'
local cueball=dfhack.matinfo.find('INORGANIC:CUEBALL_LE_POISON_NO_ALCHEMIZE')
local caledfwlchId=dfhack.items.createItem(dfhack.items.findType(caledfwlchDef),dfhack.items.findSubtype(caledfwlchDef),cueball.type,cueball.index,voidHero)
local caledfwlch=df.item.find(caledfwlchId)
caledfwlch:setQuality(5)