fraymotifEffects={}

fraymotifAffects={}

fraymotifModifiers={}

fraymotifNames={}

fraymotifAdjectives={}

local claspects=dfhack.script_environment('fortbent/claspects')

for k,v in ipairs(claspects.aspects) do
    fraymotifEffects[v]={}
    fraymotifAffects[v]={}
    fraymotifModifiers[v]={}
    fraymotifNames[v]={}
    fraymotifAdjectives[v]={}
end

fraymotifEffects.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if affectType=='unit' then
        local duration=100 --how long, in ticks, it ought to last
        local damage=10 --how much damage it ought to do; also applies to emotion severity and projectile speed.
        local tickRate=50 --how often the effect should tick within the duration.
        for k,v in ipairs(modifiers) do
            if v.duration then duration=duration*v.duration end --more motifers=exponentially more powerful fraymotifs.
            if v.strength then damage=damage*v.strength end
            if v.speed then tickRate=math.ceil(tickRate/v.speed) end
        end
        if duration>0 then
            for i=tickRate,duration,tickRate do --in the default, this'll increment 50, 100
                dfhack.timeout(i,'ticks',function() defender.body.blood_count=defender.body.blood_count-damage end)
            end
        else
            defender.body.blood_count=defender.body.blood_count-damage
        end
    end
    if affectType=='soul' then
        local duration=100 --how long, in ticks, it ought to last
        local damage=10 --how much damage it ought to do; also applies to emotion severity and projectile speed.
        local tickRate=50 --how often the effect should tick within the duration.
        for k,v in ipairs(modifiers) do
            if v.duration then duration=duration*v.duration end --more motifers=exponentially more powerful fraymotifs.
            if v.strength then damage=damage*v.strength end
            if v.speed then tickRate=math.ceil(tickRate/v.speed) end
        end
        if duration>0 then
            for i=tickRate,duration,tickRate do --in the default, this'll increment 50, 100
                dfhack.timeout(i,'ticks',function() defender.status.current_soul.personality.stress_level=defender.status.current_soul.personality.stress_level+damage end) --do you ever wish for some GODDAMN +=
            end
        else
            defender.status.current_soul.personality.stress_level=defender.status.current_soul.personality.stress_level+damage
        end
    end
end

fraymotifEffects.BREATH.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if affectType=='unit' then
        local speed=100 --how long it'll take to fully change the temperature
        local reduction=30 --degrees in Fahrenheit/urists of change in temperature
        for k,v in ipairs(modifiers) do
            if v.speed then speed=math.ceil(speed/v.speed) end
            if v.strength then reduction=math.ceil(reduction*v.strength) end
        end
        local unitFuncs=dfhack.script_environment('functions/unit') --hey i'm using more of roses stuff now
        if speed>0 then
            for i=math.floor(speed/reduction),speed,speed/reduction do
                dfhack.timeout(math.floor(i),'ticks',function() 
                    for k,v in ipairs(defender.status2.body_part_temperature) do
                        unitFuncs.changeBody(defender,k,'temperature',-1,0)
                    end
                end)
            end
        else
            for k,v in ipairs(defender.status2.body_part_temperature) do
                unitFuncs.changeBody(defender,k,'temperature',-reduction,0)
            end
        end
    elseif affectType=='soul' then
        local unitFuncs=dfhack.script_environment('functions/unit')
        local duration=1000
        local reduction=500
        for k,v in ipairs(modifiers) do
            if v.duration then duration=math.ceil(duration*v.duration) end
            if v.strength then reduction=math.ceil(reduction*v.strength) end
        end
        unitFuncs.changeAttribute(defender,'WILLPOWER',-reduction,duration)
    end
    return true
end

fraymotifEffects.LIGHT.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if affectType=='unit' then
        local speed=100 --how long it'll take to fully change the temperature
        local addition=30 --degrees in Fahrenheit/urists of change in temperature
        for k,v in ipairs(modifiers) do
            if v.speed then speed=math.ceil(speed/v.speed) end
            if v.strength then addition=math.ceil(addition*v.strength) end
        end
        local unitFuncs=dfhack.script_environment('functions/unit') --hey i'm using more of roses stuff now
        if speed>0 then
            for i=math.floor(speed/addition),speed,speed/addition do
                dfhack.timeout(math.floor(i),'ticks',function() 
                    for k,v in ipairs(defender.status2.body_part_temperature) do
                        unitFuncs.changeBody(defender,k,'temperature',1,0)
                    end
                end)
            end
        else
            for k,v in ipairs(defender.status2.body_part_temperature) do
                unitFuncs.changeBody(defender,k,'temperature',addition,0)
            end
        end
    elseif affectType=='soul' then
        local unitFuncs=dfhack.script_environment('functions/unit')
        local duration=1000
        local reduction=500
        for k,v in ipairs(modifiers) do
            if v.duration then duration=math.ceil(duration*v.duration) end
            if v.strength then reduction=math.ceil(reduction*v.strength) end
        end
        unitFuncs.changeAttribute(defender,'ANALYTICAL_ABILITY',-reduction,duration)
    end
    return true
end

fraymotifEffects.TIME.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if (specialAffect.seer or specialAffect.mage) and specialAffect.mind then
        local radius = {3,3,3}
        for k,v in ipairs(modifiers) do
            if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
        end
        local wrapper=dfhack.script_environment('functions/wrapper')
        local targetList,numFound=wrapper.checkLocation(attacker,radius)
        local allies,num_civ=wrapper.checkTarget(attacker,targetList,'civ')
        for k,v in ipairs(allies) do
            dfhack.run_script('full-heal','-r','-unit',v.id)
        end
    else
        if affectType=='unit' then
            local duration=50
            for k,v in ipairs(modifiers) do
                if v.strength then duration=math.ceil(duration*v.strength) end
                if v.duration then duration=math.ceil(duration*v.duration) end
            end
            local action_actions={ --i literally copied this all from sparking
                Move=function(data)
                    data.move.timer=duration
                end,
                Attack=function(data)
                    if data.attack.timer1>0 then
                        data.attack.timer1=duration
                    else
                        data.attack.timer2=duration
                    end
                end,
                HoldTerrain=function(data)
                    data.holdterrain.timer=duration
                end,
                Climb=function(data)
                    data.climb.timer=duration
                end,
                Unsteady=function(data)
                    data.unsteady.timer=duration
                end,
                Recover=function(data)
                    data.recover.timer=duration
                end,
                StandUp=function(data)
                    data.standup.timer=duration
                end,
                LieDown=function(data)
                    data.liedown.timer=duration
                end,
                Job2=function(data)
                    data.job2.timer=duration
                end,
                PushObject=function(data)
                    data.pushobject.timer=duration
                end,
                SuckBlood=function(data)
                    data.suckblood.timer=duration        
                end
            }
            for _,action in ipairs(defender.actions) do
                local func=action_actions[df.unit_action_type[action.type]]
                if func then func(action.data) end
            end
        end
    end
end

fraymotifEffects.SPACE.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    local unitFuncs=dfhack.script_environment('functions/unit')
    local velocity=1
    for k,v in ipairs(modifiers) do
        if v.strength then velocity=v.strength*velocity end
    end
    unitFuncs.makeProjectile(defender,{0,0,velocity})
end

--life is generic

--i actually sorta made the generic one to be like life anyway lol

--i should probably come up with different fraymotifs for more specific life ones though

local function hopeSplode(hopePerson,victim,power,range)
    local deltaCoords={x=hopePerson.pos.x-victim.pos.x,y=hopePerson.pos.y-victim.pos.y,z=hopePerson.pos.z-victim.pos.z}
    local biggestCoord=math.max(deltaCoords.x,deltaCoords.y,deltaCoords.z)
    if biggestCoord==0 then biggestCoord=1 deltaCoords.z=1 end
    local direction={x=deltaCoords.x/biggestCoord,y=deltaCoords.y/biggestCoord,z=deltaCoords.z/biggestCoord} --i do not particularly feel like quaternions at the moment
    local distance=math.sqrt((deltaCoords.x)^2+(deltaCoords.y)^2+(deltaCoords.z)^2)
    local newPower=power/(distance/math.max(0.5,range))^3
    local unitFuncs=dfhack.script_environment('functions/unit')
    unitFuncs.makeProjectile(victim,{direction.x*newPower,direction.y*newPower,direction.z*newPower}) --basically an expanding concussive wave with realistic dropoff
end

fraymotifEffects.HOPE.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    local power=1
    local range=1
    for k,v in ipairs(modifiers) do
        if v.strength then power=v.strength*power end
        if v.radius then range=v.radius+range end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(attacker,{50,50,50}) --!!!!!
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    for k,v in ipairs(enemies) do
        hopeSplode(attacker,defender,power,range)
    end
    for k,v in ipairs(animals) do
        hopeSplode(attacker,defender,power,range)
    end
end

fraymotifEffects.VOID.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    local chance=0.002
    for k,v in ipairs(modifiers) do
        if v.strength then chance=v.strength*chance end
    end
    local rng=dfhack.random.new()
    if rng:drandom0()<chance then
        unit.animal.vanish_countdown=1 --you just GONE
    end
end

fraymotifEffects.HEART.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if specialAffect.mind then
        local new_soul=df.unit_soul:new()
        new_soul:assign(defender.status.current_soul) --I'll consider souls[0] immutable; any permanent changes go into a new one. 
        for k,v in pairs(new_soul.mental_attrs) do
            v.value=0 --Basically: the heart and mind heroes get together, make a new soul which has a copy of the old mind, completely wreck it, then replace the old soul with it.
        end
        for k,v in ipairs(new_soul.skills) do
            v.rating=0
            v.experience=0
        end
        new_soul.name.first_name='mud'
        defender.status.souls:insert('#',new_soul)
        defender.status.current_soul=new_soul
    else
        fraymotifEffects.GENERIC(attacker,defender,modifiers,'soul')
    end
    return true
end

fraymotifEffects.BLOOD.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if affectType=='unit' then
        local damage=150
        local velocity=20
        for k,v in ipairs(modifiers) do
            if v.strength then damage=math.ceil(damage*v.strength) end
            if v.speed then tickRate=math.ceil(velocity*v.speed) end
        end
        defender.body.blood_count=defender.body.blood_count-damage
        local wrapper=dfhack.script_environment('functions/wrapper')
        local enemyToTarget=false
        do
            local targetList=wrapper.checkLocation(defender,{5,5,0})
            local enemies,num_enemies_found=wrapper.checkTarget(defender,targetList,'civ')
            enemyToTarget=enemies[1]
        end
        local itemFuncs=dfhack.script_environment('functions/item')
        local itemtype,itemsubtype=dfhack.items.findType('LIQUID_MISC:NONE'),-1 --NONE's gonna be -1 anyway
        local extracts=df.creature_raw.find(defender.race).caste[defender.caste].extracts
        if extracts.blood_mat and extracts.blood_matidx then
            local bloodShot=dfhack.items.createItem(itemType,itemSubtype,extracts.blood_mat,extracts.blood_matidx,defender)
            bloodShot.dimension=damage
            itemFuncs.makeProjectileShot(bloodShot,defender.pos,enemyToTarget.pos,{velocity=velocity,accuracy=100,max_range=8,min_range=0}) --max_range is ceil(sqrt(5^2+5^2), so basically the max distance there)
            return true
        end
    elseif affectType=='soul' then
        fraymotifEffects.GENERIC(attacker,defender,modifiers,affectType,specialAffect)
    end
end

fraymotifEffects.DOOM.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    local chance=0.002
    local doomTimer=1000
    for k,v in ipairs(modifiers) do
        if v.strength then chance=v.strength*chance end
        if v.speed then doomTimer=doomTimer/v.speed end
    end
    if dfhack.random.new():drandom0()<chance then
        dfhack.timeout(doomTimer,'ticks',function() defender.body.blood_count=0 defender.animal.vanish_countdown=2 end)
    end
end

fraymotifEffects.MIND.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    if specialAffect.heart then
        local new_soul=df.unit_soul:new()
        new_soul:assign(defender.status.souls[0])
        for k,v in pairs(new_soul) do
            v.value=0
        end
        new_soul.name.first_name='mud'
        defender.status.souls:insert('#',new_soul)
        defender.status.current_soul=new_soul
    else
        fraymotifEffects.GENERIC(attacker,defender,modifiers,'soul',specialAffect)
    end
end

fraymotifEffects.MIND.SEER=function(attacker,defender,modifiers,affectType,specialAffect)
    if specialAffect.time then
        local radius = {3,3,3}
        for k,v in ipairs(modifiers) do
            if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
        end
        local wrapper=require('functions/wrapper')
        local targetList,numFound=wrapper.checkLocation(attacker,radius)
        local allies,num_civ=wrapper.checkTarget(attacker,targetList,'civ')
        for k,v in ipairs(allies) do
            dfhack.run_script('full-heal','-r','-unit',v.id)
        end
    else
        fraymotifEffects.MIND.GENERIC(attacker,defender,modifiers,affectType,specialAffect)
    end
end

local function getBpToAttack(unit,specialAffect,attackInfo)
    if specialAffect.space then
        return attackInfo.body_part_idx[0]
    else
        for k,bp in ipairs(unit.body.body_plan.body_parts) do
            if bp.flags.UPPERBODY then return k end
        end
    end
end

local function getAttackToUse(unit,specialAffect)
    local attacks=df.creature_raw.find(unit.race).caste[unit.caste].body_info.attacks
    for k,attack in ipairs(attacks) do
        if attack.flags.main then return k,attack end
    end
end

fraymotifEffects.RAGE.GENERIC=function(attacker,defender,modifiers,affectType,specialAffect)
    local strength=500
    for k,v in ipairs(modifiers) do
        if v.strength then strength=math.ceil(v.strength*strength) end
    end
    local action=df.unit_action:new()
    action.id=defender.next_action_id
    action.type=df.unit_action_type.Attack
    local action_data=action.data.attack
    action_data.target_unit_id=defender.id
    local attackToUse,attackInfo=getAttackToUse(defender,specialAffect)
    action_data.flags=0
    action_data.attack_item_id=-1
    action_data.target_body_part_id=getBpToAttack(defender,specialAffect,attackInfo)
    action_data.attack_body_part_id=attackInfo.body_part_idx[0]
    action_data.attack_id=attackToUse
    action_data.attack_velocity=strength*(attackInfo.velocity_modifier/1000)
    action_data.attack_accuracy=10000
    action_data.unk_38=attackInfo.skill --TODO: check if unk_38's been changed to skill yet
    action_data.timer1=1
    action_data.timer2=1
    defender.actions:insert('#',action)
    defender.next_action_id=defender.next_action_id+1
    return true
end

--[[At this point, "affect types" should be explained.

Basically, this allows a single effect to take multiple affects into account. The perfectly generic effect up there will remove blood from a unit, increase their stress or whatever.]]

--[[specialAffect allows certain Fraymotif combinations to result in unique combinations; for example, a Seer of Mind and a Time hero may join together to fully heal all nearby allies.

]]

fraymotifAffects.GENERIC=function(attacker,defender,effect,modifiers)
    local radius={-1,-1,-1} --the most basic doesn't have any range by default, but can be improved to have one.
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found}) --strength is divided between all of the enemies found.
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    --modifiers should be taken into account; to be exact, there should be a "range", "radius" modifiers for affects that use projectiles or flows.
    return true --if it returns false, it'll show a failure message
end

fraymotifModifiers.GENERIC={strength=1,speed=1,radius=0,duration=1} --LITERALLY NOTHING

fraymotifModifiers.BREATH.GENERIC={strength=1.2,speed=1.3,radius=1}

fraymotifModifiers.LIGHT.GENERIC={strength=1.3,radius=1}

fraymotifModifiers.TIME.GENERIC={speed=1.5,duration=1.5}

fraymotifModifiers.SPACE.GENERIC={radius=3,strength=2}

fraymotifModifiers.LIFE.GENERIC={strength=2,speed=2,duration=0.4}

fraymotifModifiers.HOPE.GENERIC={strength=1.6,radius=1}

fraymotifModifiers.VOID.GENERIC=fraymotifModifiers.GENERIC --get it haha it's NOTHING you fat nasty trash

fraymotifModifiers.HEART.GENERIC={strength=1.1,speed=1.6,radius=-1}

fraymotifModifiers.BLOOD.GENERIC={strength=2,radius=-2,duration=0.5}

fraymotifModifiers.DOOM.GENERIC={strength=2,speed=.6}

fraymotifModifiers.MIND.GENERIC={strength=1.1,speed=1.6,radius=-1}

fraymotifModifiers.RAGE.GENERIC={strength=2,duration=0.8}

fraymotifNames.GENERIC={'fray','motif'}

fraymotifAdjectives.GENERIC={'very ordinary','still ordinary','generic','unchanged','ordinary','perfectly generic'}

fraymotifNames.BREATH.GENERIC={'diffuse','chill'}

fraymotifAdjectives.BREATH.GENERIC={'zephyrean','fluid','pressurized','boyling','boiling','windy'}

fraymotifNames.LIGHT.GENERIC={'targeted','heat'}

fraymotifAdjectives.LIGHT.GENERIC={'prismatic','spectral','bright','energetic','luminous','electromagnetic'}

fraymotifNames.TIME.GENERIC={'quick','stopper'}

fraymotifAdjectives.TIME.GENERIC={'allegro','presto','accelerated','paced','high-tempo','quicker'} --listen okay they'll all do the same thing anyway

fraymotifNames.SPACE.GENERIC={'geometric','accelerator'}

fraymotifAdjectives.SPACE.GENERIC={'3-D','volumetric','widened','increased','enlargened','bigger'}

fraymotifNames.LIFE.GENERIC={'targeted','lifedrain'}

fraymotifAdjectives.LIFE.GENERIC={'vigorous','pulchritudinous','vimful','squirming','writhing','lifelike'}

fraymotifNames.HOPE.GENERIC={'optimistic','hopesplosion'}

fraymotifAdjectives.HOPE.GENERIC={'hopeful','forward-thinking','gung-ho','enthusiastic','tally-ho','rip-snorting'}

fraymotifNames.VOID.GENERIC={'targeted','zap'}

fraymotifAdjectives.VOID.GENERIC={'very ordinary','still ordinary','generic','unchanged','ordinary','perfectly generic'}

fraymotifNames.HEART.GENERIC={'soul','trauma'}

fraymotifNames.HEART.GENERIC.MIND={}

  fraymotifNames.HEART.GENERIC.MIND.GENERIC="Soulfray" --this is stupid

fraymotifAdjectives.HEART.GENERIC={'beating','splintered','self-actualized','personal','pink','hearty'}

fraymotifNames.BLOOD.GENERIC={'bloody','bloodshot'} --"bloody bloodshot" is hilarious okay

fraymotifAdjectives.BLOOD.GENERIC={'bloody','bloody','bloody','bloody','bloody','bloody'} --:^Y

fraymotifNames.DOOM.GENERIC={'slow-burn','doom'}

fraymotifAdjectives.DOOM.GENERIC={'defeatist','inevitable','wyrd','destined','finishing','depressed'}

fraymotifNames.MIND.GENERIC={'brainy','trauma'}

fraymotifAdjectives.MIND.GENERIC={'mindful','freudian','compulsive','cognitive','punishing','synaptic'}

fraymotifAdjectives.MIND.GENERIC.HEART={}

  fraymotifAdjectives.MIND.GENERIC.HEART.GENERIC='Mindflay'
  
  fraymotifAdjectives.MIND.SEER=fraymotifAdjectives.MIND.GENERIC
  fraymotifAdjectives.MIND.SEER.TIME="Switch to someone who isn't a failure"

fraymotifNames.RAGE.GENERIC={'indiscriminatory','self-loathing'}

fraymotifAdjectives.RAGE.GENERIC={'hateful','spiteful','incoherent','incandescent','indignant','potent'}

fraymotifAffects.BREATH.GENERIC=function(attacker,defender,effect,modifiers)
    local radius={2,2,2}
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'unit',{time=true})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'unit',{time=true})
    end
    return true
end

--light is generic

fraymotifAffects.TIME.GENERIC=function(attacker,defender,effect,modifiers)
    table.insert(modifiers,{speed=1.2})
    local radius={-1,-1,-1}
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    return true
end

fraymotifAffects.SPACE.GENERIC=function(attacker,defender,effect,modifiers)
    local radius={3,3,3} --seriously bigger's fine
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found,duration=0.8})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    return true
end

--life is generic

fraymotifAffects.HOPE.GENERIC=function(attacker,defender,effect,modifiers)
    local rng=dfhack.random.new()
    if rng:drandom0()<0.5 then
        table.insert(modifiers,{strength=2})
        local radius={-1,-1,-1}
        for k,v in ipairs(modifiers) do
            if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
        end
        local wrapper=dfhack.script_environment('functions/wrapper')
        local targetList=wrapper.checkLocation(defender,radius)
        local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
        local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
        local num_found=num_animals_found+num_enemies_found
        table.insert(modifiers,{strength=1/num_found})
        for k,v in ipairs(enemies) do
            effect(attacker,defender,modifiers,'unit',{})
        end
        for k,v in ipairs(animals) do
            effect(attacker,defender,modifiers,'unit',{})
        end
        return true
    end
    return false
end

--void is generic

fraymotifAffects.HEART.GENERIC=function(attacker,defender,effect,modifiers)
    local radius={-1,-1,-1}
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'soul',{heart=true})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'soul',{heart=true})
    end
    return true
end

fraymotifAffects.BLOOD.GENERIC=function(attacker,defender,effect,modifiers)
    table.insert(modifiers,{vascular_only=true,strength=1.2})
    local radius={-1,-1,-1}
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    return true
end

fraymotifAffects.DOOM.GENERIC=function(attacker,defender,effect,modifiers)
    table.insert(modifiers,{speed=0.1,duration=10})
    local radius={-1,-1,-1}
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'unit',{})
    end
    return true
end

fraymotifAffects.MIND.GENERIC=function(attacker,defender,effect,modifiers)
    local radius={-1,-1,-1}
    for k,v in ipairs(modifiers) do
        if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
    end
    local wrapper=dfhack.script_environment('functions/wrapper')
    local targetList=wrapper.checkLocation(defender,radius)
    local enemies,num_enemies_found=wrapper.checkTarget(attacker,targetList,'enemy')
    local animals,num_animals_found=wrapper.checkTarget(attacker,targetList,'wild')
    local num_found=num_animals_found+num_enemies_found
    table.insert(modifiers,{strength=1/num_found})
    for k,v in ipairs(enemies) do
        effect(attacker,defender,modifiers,'soul',{mind=true})
    end
    for k,v in ipairs(animals) do
        effect(attacker,defender,modifiers,'soul',{mind=true})
    end
    return true
end

fraymotifAffects.MIND.SEER=function(attacker,defender,effect,modifiers)
    --will ALWAYS target precisely one enemy
    effect(attacker,defender,modifiers,'soul',{seer=true,mind=true})
    return true
end

fraymotifAffects.MIND.MAGE=function(attacker,defender,effect,modifiers)
    --will ALWAYS target precisely one enemy
    effect(attacker,defender,modifiers,'soul',{mage=true,mind=true})
    return true
end

fraymotifAffects.RAGE.GENERIC=function(attacker,defender,effect,modifiers)
    local script=require('gui.script')
    script.start(function() 
        table.insert(modifiers,{strength=2})
        local radius={5,5,5}
        for k,v in ipairs(modifiers) do
            if v.radius then for kk,vv in ipairs(radius) do vv=vv+v.radius end end
        end
        local wrapper=dfhack.script_environment('functions/wrapper')
        local targetList,numFound=wrapper.checkLocation(defender,radius) --completely indiscriminate!
        local _,num_civ=wrapper.checkTarget(attacker,targetList,'civ')
        table.insert(modifiers,{strength=1/numFound}) 
        local yes_or_no=script.showYesNoPrompt('Fraymotifs','Rage fraymotif will catch '..tostring(num_civ)..' citizens in AOE. Use?')
        if yes_or_no then
            for k,v in ipairs(targetList) do
                effect(attacker,defender,modifiers,'unit',{})
            end
        end
        return yes_or_no
    end)
end

for k,v in ipairs(claspects.aspects) do
    for kk,vv in ipairs(claspects.classes) do
        fraymotifEffects[v][vv]=fraymotifEffects[v][vv] or fraymotifEffects[v]['GENERIC'] or fraymotifEffects['GENERIC']
        fraymotifAffects[v][vv]=fraymotifAffects[v][vv] or fraymotifAffects[v]['GENERIC'] or fraymotifAffects['GENERIC']
        fraymotifModifiers[v][vv]=fraymotifModifiers[v][vv] or fraymotifModifiers[v]['GENERIC'] or fraymotifModifiers['GENERIC']
        fraymotifNames[v][vv]=fraymotifNames[v][vv] or fraymotifNames[v]['GENERIC'] or fraymotifNames['GENERIC']
        fraymotifNames[v][vv]['GENERIC']=fraymotifNames[v][vv]['GENERIC'] or fraymotifNames[v]['GENERIC'] or fraymotifNames['GENERIC']
        for kkk,vvv in ipairs(claspects.aspects) do
            fraymotifNames[v][vv][vvv]=fraymotifNames[v][vv][vvv] or {}
            fraymotifNames[v][vv][vvv]['GENERIC']=fraymotifNames[v][vv][vvv]['GENERIC'] or fraymotifNames[v]['GENERIC'] or fraymotifNames['GENERIC']
            for kkkk,vvvv in ipairs(claspects.classes) do --what the fuck
                fraymotifNames[v][vv][vvv][vvvv]=fraymotifNames[v][vv][vvv][vvvv] or fraymotifNames[v][vv][vvv]['GENERIC'] --is this even readable to anyone, i can barely read it and i'm writing it
                --since this'll NEED documentation down the road due to all the goddamn "v"s: v is aspect names, vv is classes, vvv is nested aspect names, vvvv is nested class names, so I can name special fraymotifs.
                --also i can't believe I actually need this monstrous 4D for loop here
            end
        end
        fraymotifAdjectives[v][vv]=fraymotifAdjectives[v][vv] or fraymotifAdjectives[v]['GENERIC'] or fraymotifAdjectives['GENERIC']
    end
end