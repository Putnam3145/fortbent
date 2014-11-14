filename = dfhack.getDFPath().."/raw/objects/civilizations.txt"
local read_file = require('civilizations.read-file')
civs = read_file(filename)
local split = require('split')
local utils = require 'utils'
validArgs = validArgs or utils.invert({
 'help',
 'civ',
 'position',
 'remove',
 'add'
})
local args = utils.processArgs({...}, validArgs)

civid = tonumber(args.civ)
civ = df.global.world.entities.all[civid]
positions = civ.positions
mobj = split(args.position,':')[1]
sobj = split(args.position,':')[2]
removes = false
add = false
if args.remove then removes = true end
if args.add then add = true end
if add and removes then return end
if not add and not removes then
 print('No valid command, use -remove or -add')
 return
end

if removes then
 for i,x in pairs(positions.own) do
  if mobj == x.code then
   positions.own:erase(i)
  end
 end
 for i,x in pairs(positions.site) do
  if mobj == x.code then
   positions.site:erase(i)
  end
 end
 for i,x in pairs(positions.conquered_site) do
  if mobj == x.code then
   positions.conquered_site:erase(i)
  end
 end
end

if add then
 civ = df.global.world.entities.all[civid]
 entity = civ.entity_raw.code
 if civs[entity] then
  if civs[entity]['LEVEL'] then
   for i,x in pairs(civs[entity]['LEVEL']) do
    for j,y in pairs(x['ADD_POSITION']) do
     if mobj == j then
      pos = positions.own[0]:new()
      pos.code = mobj
      pos.id = positions.next_position_id
      positions.next_position_id = positions.next_position_id + 1
      for k,z in pairs(y['ALLOWED_CREATURE']) do
       for _,w in pairs(df.global.world.raws.creatures.all) do
        if k == w.creature_id then
         for _,v in pairs(w.caste) do
          if z == v.caste_id then
           pos.allowed_creature:insert('#',v.index)
          end
         end
        end
       end
      end
      for k,z in pairs(y['REJECTED_CREATURE']) do
       for _,w in pairs(df.global.world.raws.creatures.all) do
        if k == w.creature_id then
         for _,v in pairs(w.caste) do
          if z == v.caste_id then
           pos.rejected_creature:insert('#',v.index)
          end
         end
        end
       end
      end
      for k,z in pairs(y['ALLOWED_CLASS']) do
       pos.allowed_class:insert('#',z)
      end
      for k,z in pairs(y['REJECTED_CLASS']) do
       pos.rejected_class:insert('#',z)
      end
      if y['NAME'] then 
       pos.name[0] = split(y['NAME'],':')[1]
       pos.name[1] = split(y['NAME'],':')[2]
       pos.name_female[0] = ''
       pos.name_female[1] = ''
       pos.name_male[0] = ''
       pos.name_male[1] = ''
      else
       pos.name[0] = ''
       pos.name[1] = ''
       pos.name_female[0] = ''
       pos.name_female[1] = ''
       pos.name_male[0] = ''
       pos.name_male[1] = ''
      end
      if y['NAME_FEMALE'] then
       pos.name_female[0] = split(y['NAME_FEMALE'],':')[1]
       pos.name_female[1] = split(y['NAME_FEMALE'],':')[2]
      end
      if y['NAME_MALE'] then 
       pos.name_male[0] = split(y['NAME_MALE'],':')[1]
       pos.name_male[1] = split(y['NAME_MALE'],':')[2]
      end
      if y['SPOUSE'] then 
       pos.spouse[0] = split(y['SPOUSE'],':')[1]
       pos.spouse[1] = split(y['SPOUSE'],':')[2]
       pos.spouse_female[0] = ''
       pos.spouse_female[1] = ''
       pos.spouse_male[0] = ''
       pos.spouse_male[1] = ''
      else
       pos.spouse[0] = ''
       pos.spouse[1] = ''
       pos.spouse_female[0] = ''
       pos.spouse_female[1] = ''
       pos.spouse_male[0] = ''
       pos.spouse_male[1] = ''
      end
      if y['SPOUSE_FEMALE'] then
       pos.spouse_female[0] = split(y['SPOUSE_FEMALE'],':')[1]
       pos.spouse_female[1] = split(y['SPOUSE_FEMALE'],':')[2]
      end
      if y['SPOUSE_MALE'] then 
       pos.spouse_male[0] = split(y['SPOUSE_MALE'],':')[1]
       pos.spouse_male[1] = split(y['SPOUSE_MALE'],':')[2]
      end
      if y['SQUAD'] then
       pos.squad_size = tonumber(split(y['SQUAD'],':')[1])
       pos.squad[0] = split(y['SQUAD'],':')[2]
       pos.squad[1] = split(y['SQUAD'],':')[3]
      else
       pos.squad[0] = ''
       pos.squad[1] = ''
       pos.squad_size = 0
      end
      if y['LAND_NAME'] then
       pos.land_name = y['LAND_NAME']
      else
       pos.land_name = ''
      end
      if y['LAND_HOLDER'] then
       pos.land_holder = tonumber(y['LAND_HOLDER'])
      else
       pos.land_holder = 0
      end
      if y['REQUIRED_BOXES'] then
       pos.required_boxes = tonumber(y['REQUIRED_BOXES'])
      else
       pos.required_boxes = 0
      end
      if y['REQUIRED_CABINETS'] then
       pos.required_cabinets = tonumber(y['REQUIRED_CABINETS'])
      else
       pos.required_cabinets = 0
      end
      if y['REQUIRED_RACKS'] then
       pos.required_racks = tonumber(y['REQUIRED_RACKS'])
      else
       pos.required_racks = 0
      end
      if y['REQUIRED_STANDS'] then
       pos.required_stands = tonumber(y['REQUIRED_STANDS'])
      else
       pos.required_stands = 0
      end
      if y['REQUIRED_OFFICE'] then
       pos.required_office = tonumber(y['REQUIRED_OFFICE'])
      else
       pos.required_office = 0
      end
      if y['REQUIRED_BEDROOM'] then
       pos.required_bedroom = tonumber(y['REQUIRED_BEDROOM'])
      else
       pos.required_bedroom = 0
      end
      if y['REQUIRED_DINING'] then
       pos.required_dining = tonumber(y['REQUIRED_DINING'])
      else
       pos.required_dining = 0
      end
      if y['REQUIRED_TOMB'] then
       pos.required_tomb = tonumber(y['REQUIRED_TOMB'])
      else
       pos.required_tomb = 0
      end
      if y['MANDATE_MAX'] then
       pos.mandate_max = tonumber(y['MANDATE_MAX'])
      else
       pos.mandate_max = 0
      end
      if y['DEMAND_MAX'] then
       pos.demand_max = tonumber(y['DEMAND_MAX'])
      else
       pos.demand_max = 0
      end
      if y['COLOR'] then
       pos.color[0] = split(y['COLOR'],':')[1]
       pos.color[1] = split(y['COLOR'],':')[2]
       pos.color[2] = split(y['COLOR'],':')[3]
      else
       pos.color[0] = 5
       pos.color[1] = 0
       pos.color[2] = 0
      end
      if y['PRECEDENCE'] then
       pos.precedence = tonumber(y['PRECEDENCE'])
      else
       pos.precedence = -1
      end
      for v,w in pairs(pos.responsibilities) do
       if y['RESPONSIBILITY'][v] then
        pos.responsibilities[v] = true
       else
        pos.responsibilities[v] = false
       end
      end
      for v,w in pairs(pos.flags) do
       if y[v] then
        pos.flags[v] = true
       else
        pos.flags[v] = false
       end
      end
      if y['FLAGS'] then
       for v,w in pairs(y['FLAGS']) do
        if pos.flags[v] then pos.flags[v] = true end
       end
      end
      if y['NUMBER'] then
       pos.number = tonumber(y['NUMBER'])
      else
       pos.number = -1
      end
      for v,w in pairs(y['APPOINTED_BY']) do
       p = -1
       own = false
       site = false
       for s,t in pairs(positions.own) do
        if v == t.code then
         p = t.id
         own = true
         break
        end
       end
       if p == -1 then
        for s,t in pairs(positions.site) do
         if v == t.code then 
          p = t.id
          site = true
          break
         end
        end
       end
       if p == -1 then
        for s,t in pairs(positions.conquered_site) do
         if v == t.code then 
          p = t.id
          break
         end
        end
       end
       if p == -1 then
        print('No valid APPOINTED_BY position found')
       else
        pos.appointed_by:insert('#',p)
        if own then pos.appointed_by_civ:insert('#',civid) end
        if site then pos.appointed_by_civ:insert('#',-1) end
       end
      end
      if y['COMMANDER'] then
       v = split(y['COMMANDER'],':')[1]
       p = -1
       own = false
       site = false
       for s,t in pairs(positions.own) do
        if v == t.code then
         p = t.id
         own = true
         break
        end
       end
       if p == -1 then
        for s,t in pairs(positions.site) do
         if v == t.code then 
          p = t.id
          site = true
          break
         end
        end
       end
       if p == -1 then
        for s,t in pairs(positions.conquered_site) do
         if v == t.code then 
          p = t.id
          break
         end
        end
       end
       if p == -1 then
        print('No valid COMMANDER position found')
       else
        pos.commander_id:insert('#',p)
        pos.commander_types:insert('#',0)
        if own then pos.commander_civ:insert('#',civid) end
        if site then pos.commander_civ:insert('#',-1) end
       end
      end
      if y['REPLACED_BY'] then
       v = y['REPLACED_BY']
       p = -1
       own = false
       site = false
       for s,t in pairs(positions.own) do
        if v == t.code then
         p = t.id
         own = true
         break
        end
       end
       if p == -1 then
        for s,t in pairs(positions.site) do
         if v == t.code then 
          p = t.id
          site = true
          break
         end
        end
       end
       if p == -1 then
        for s,t in pairs(positions.conquered_site) do
         if v == t.code then 
          p = t.id
          break
         end
        end
       end
       if p == -1 then
        print('No valid REPLACED_BY position found')
       else
        pos.replaced_by = p
       end
      else
       pos.replaced_by = -1
      end
      positions.own:insert('#',pos)
     else
      print('No valid position found in civilization.txt')
      return
     end
    end
   end
  end
 end
end