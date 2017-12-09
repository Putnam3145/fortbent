function changeAttribute(unit,attribute,amount,duration)
    if df.physical_attribute_type[attribute] then
        unit.body.physical_attrs[attribute].value=unit.body.physical_attrs[attribute].value+amount
        if duration>0 then
            dfhack.script_environment('modtools/persist_timeout').persistTimeout(duration,'fortbent/fraymotifFuncs','changeAttribute',{unit,attribute,-amount,0})
        end
    elseif df.mental_attribute_type[attribute] then
        unit.status.current_soul.mental_attrs[attribute].value=unit.status.current_soul.mental_attrs[attribute].value+amount
        if duration>0 then
            dfhack.script_environment('modtools/persist_timeout').persistTimeout(duration,'fortbent/fraymotifFuncs','changeAttribute',{unit,attribute,-amount,0})
        end
    end
end

--i do not feel particularly insane today, so i'll just copy+paste roses version here.

function makeProjectile(unit,velocityVector)
    if tonumber(unit) then
        unit = df.unit.find(tonumber(unit))
    end
    local vx = velocityVector[1]
    local vy = velocityVector[2]
    local vz = velocityVector[3]
    local count=0
    local l = df.global.world.proj_list
    local lastlist=l
    l=l.next
    while l do
        count=count+1
        if l.next==nil then
            lastlist=l
        end
        l = l.next
    end
    newlist = df.proj_list_link:new()
    lastlist.next=newlist
    newlist.prev=lastlist
    proj = df.proj_unitst:new()
    newlist.item=proj
    proj.link=newlist
    proj.id=df.global.proj_next_id
    df.global.proj_next_id=df.global.proj_next_id+1
    proj.unit=unit
    proj.origin_pos.x=unit.pos.x
    proj.origin_pos.y=unit.pos.y
    proj.origin_pos.z=unit.pos.z
    proj.prev_pos.x=unit.pos.x
    proj.prev_pos.y=unit.pos.y
    proj.prev_pos.z=unit.pos.z
    proj.cur_pos.x=unit.pos.x
    proj.cur_pos.y=unit.pos.y
    proj.cur_pos.z=unit.pos.z
    proj.flags.no_impact_destroy=true
    proj.flags.piercing=true
    proj.flags.parabolic=true
    proj.flags.unk9=true
    proj.speed_x=vx
    proj.speed_y=vy
    proj.speed_z=vz
    unitoccupancy = dfhack.maps.ensureTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
    if not unit.flags1.on_ground then
        unitoccupancy.unit = false
    else
        unitoccupancy.unit_grounded = false
    end
    unit.flags1.projectile=true
    unit.flags1.on_ground=false
end

--Again, these next two are from Roses. I don't feel like reinventing the wheel.

function checkLocation(center,radius)
    if radius then
        rx = tonumber(radius.x) or tonumber(radius[1]) or -1
        ry = tonumber(radius.y) or tonumber(radius[2]) or -1
        rz = tonumber(radius.z) or tonumber(radius[3]) or -1
    else
        rx = -1
        ry = -1
        rz = -1
    end
    local targetList = {}
    local selected = {}
    
    n = 1
    unitList = df.global.world.units.active
    if rx < 0 and ry < 0 and rz < 0 then
        targetList[n] = center
    else
        local xmin = center.pos.x - rx
        local ymin = center.pos.y - ry
        local zmin = center.pos.z - rz
        local xmax = center.pos.x + rx
        local ymax = center.pos.y + ry
        local zmax = center.pos.z + rz
        targetList[n] = center
        for i,unit in ipairs(unitList) do
            if unit.pos.x <= xmax and unit.pos.x >= xmin and unit.pos.y <= ymax and unit.pos.y >= ymin and unit.pos.z <= zmax and unit.pos.z >= zmin and unit ~= center then
                n = n + 1
                targetList[n] = unit
            end
        end
    end
    return targetList,n
end

function checkTarget(source,targetList,target)
    if not target then target = 'all' end
    n = 0
    list = {}
    
    for i,unit in pairs(targetList) do
        if target == 'enemy' then
            if unit.invasion_id > 0 then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'friendly' then
            if unit.invasion_id == -1 and unit.civ_id ~= -1 then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'civ' then
            if source.civ_id == unit.civ_id then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'race' then
            if source.race == unit.race then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'caste' then
            if source.race == unit.race and source.caste == unit.caste then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'gender' then
            if source.sex == unit.sex then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'wild' then
            if unit.training_level == 9 and unit.civ_id == -1 then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'domestic' then
            if unit.training_level == 7 and unit.civ_id == source.civ_id then
                n = n + 1
                list[n] = unit
            end
        elseif target == 'all' then
            n = #targetList
            list = targetList
            break
        end
    end
    return list,n
end