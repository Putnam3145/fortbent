args = {...}
split = require('split')
filename = dfhack.getDFPath().."/raw/objects/civilizations.txt"
local read_file = require('civilizations.read-file')
civs = read_file(filename)

civid = tonumber(args[1])
civ = df.global.world.entities.all[civid]
entity = civ.entity_raw.code
pers, status = dfhack.persistent.get('CIV_'..args[1])
level = pers.ints[1] + 1
pers.ints[1] = level
if civs[entity] then
 if civs[entity]['LEVEL'] then
  if civs[entity]['LEVEL'][tostring(level)] then
   for i,w in pairs(civs[entity]['LEVEL'][tostring(level)]['REMOVE']) do
    for j,x in pairs(w) do
     mtype = j
     for k,y in pairs(x) do
      stype = k
      for l,z in pairs(y) do
       mobj = l
       sobj = z
       dfhack.run_script('civilizations/resource-change',table.unpack({'-civ',args[1],'-type',mtype..':'..stype,'-obj',mobj..':'..sobj,'-remove'}))
      end
     end
    end
   end
   for i,w in pairs(civs[entity]['LEVEL'][tostring(level)]['ADD']) do
    for j,x in pairs(w) do
     mtype = j
     for k,y in pairs(x) do
      stype = k
      for l,z in pairs(y) do
       mobj = l
       sobj = z
       dfhack.run_script('civilizations/resource-change',table.unpack({'-civ',args[1],'-type',mtype..':'..stype,'-obj',mobj..':'..sobj,'-add'}))
      end
     end
    end
   end
   for i,w in pairs(civs[entity]['LEVEL'][tostring(level)]['REMOVE_POSITION']) do
    mobj = i
    sobj = w
    dfhack.run_script('civilizations/noble-change',table.unpack({'-civ',args[1],'-position',mobj..':'..sobj,'-remove'}))
   end
   for i,w in pairs(civs[entity]['LEVEL'][tostring(level)]['ADD_POSITION']) do
    mobj = i
    sobj = w
    dfhack.run_script('civilizations/noble-change',table.unpack({'-civ',args[1],'-position',mobj..':'..sobj,'-add'}))
   end
  end
 end
end
dfhack.persistent.save({key='CIV_'..args[1],value=pers.value,ints=pers.ints})
