
local split = require('split')
local utils = require 'utils'

function establishciv(civ,civs)
 key = tostring(civ.id)
 entity = civ.entity_raw.code
-- Check if the persistent variabls are present
 curpers,status = dfhack.persistent.get('CIV_'..key)
 if not curpers then
  dfhack.persistent.save({key='CIV_'..key,value=entity,ints={0,0,0,0,0,0,0}})
  if civs[entity] then
   if civs[entity]['LEVEL'] then
    if civs[entity]['LEVEL']['0'] then
     print('The '..civs[entity]['NAME']..' have '..civs[entity]['LEVEL'][0]['NAME']..'.')
     for i,w in pairs(civs[entity]['LEVEL']['0']['REMOVE']) do
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
     for i,w in pairs(civs[entity]['LEVEL']['0']['ADD']) do
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
    end
   end
  end
 end
end

return establishciv