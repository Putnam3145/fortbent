
local split = require('split')
local utils = require 'utils'

function read_file(path)
 local iofile = io.open(path,"r")
 local totdat = {}
 local count = 1
 while true do
  local line = iofile:read("*line")
  if line == nil then break end
  totdat[count] = line
  count = count + 1
 end
 iofile:close()
 
 d = {}
 classes = {}
 count = 1
 for i,x in ipairs(totdat) do
  if split(x,':')[1] == '[CLASS' then
   d[count] = {split(split(x,':')[2],']')[1],i,0}
   count = count + 1
  end
 end
 for i,x in ipairs(d) do
  if i == #d then
   x[3] = #totdat
  else
   x[3] = d[i+1][2]-1
  end
  classes[x[1]]={}
 end
 for i,x in ipairs(d) do
  classes[x[1]]['R_CLASS'] = {}
  classes[x[1]]['R_PHYS'] = {}
  classes[x[1]]['R_COUNTER'] = {}
  classes[x[1]]['R_MENT'] = {}
  classes[x[1]]['B_PHYS'] = {}
  classes[x[1]]['B_MENT'] = {}
  classes[x[1]]['R_SKILL'] = {}
  classes[x[1]]['R_TRAIT'] = {}
  classes[x[1]]['F_CLASS'] = {}
  classes[x[1]]['B_SKILL'] = {}
  classes[x[1]]['B_TRAIT'] = {}
  classes[x[1]]['SPELL'] = {}
  for j = x[2],x[3],1 do
   totdat[j] = totdat[j]:gsub("%s+","")
   if split(totdat[j],':')[1] == '[NAME' then 
    classes[x[1]]['NAME'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[LEVELS' then 
    classes[x[1]]['LEVELS'] = tonumber(split(split(totdat[j],':')[2],']')[1])
   elseif split(totdat[j],':')[1] == '[AUTO_UPGRADE' then 
    classes[x[1]]['A_UPGRADE'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[EXP' then 
    classes[x[1]]['EXP'] = {select(2,table.unpack(split(totdat[j],':')))}
   elseif split(totdat[j],':')[1] == '[REQUIREMENT_CLASS' then 
    classes[x[1]]['R_CLASS'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[FORBIDDEN_CLASS' then 
    classes[x[1]]['F_CLASS'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIREMENT_SKILL' then 
    classes[x[1]]['R_SKILL'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIREMENT_TRAIT' then 
    classes[x[1]]['R_TRAIT'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIREMENT_COUNTER' then 
    classes[x[1]]['R_COUNTER'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIREMENT_PHYS' then 
    classes[x[1]]['R_PHYS'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[REQUIREMENT_MENT' then 
    classes[x[1]]['R_MENT'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[BONUS_PHYS' then 
    classes[x[1]]['B_PHYS'][split(totdat[j],':')[2]] = {select(3,table.unpack(split(totdat[j],':')))}
   elseif split(totdat[j],':')[1] == '[BONUS_TRAIT' then 
    classes[x[1]]['B_TRAIT'][split(totdat[j],':')[2]] = {select(3,table.unpack(split(totdat[j],':')))}
   elseif split(totdat[j],':')[1] == '[BONUS_SKILL' then 
    classes[x[1]]['B_SKILL'][split(totdat[j],':')[2]] = {select(3,table.unpack(split(totdat[j],':')))}
   elseif split(totdat[j],':')[1] == '[BONUS_MENT' then 
    classes[x[1]]['B_MENT'][split(totdat[j],':')[2]] = {select(3,table.unpack(split(totdat[j],':')))}
   elseif split(totdat[j],':')[1] == '[SPELL' then 
    classes[x[1]]['SPELL'][split(totdat[j],':')[2]] = {}
	classes[x[1]]['SPELL'][split(totdat[j],':')[2]]['REQUIRED_LEVEL'] = split(split(totdat[j],':')[3],']')[1]
	spell = split(totdat[j],':')[2]
   elseif split(totdat[j],':')[1] == '[SPELL_REQUIRE_PHYS' then
    classes[x[1]]['SPELL'][spell]['R_PHYS'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[SPELL_REQUIRE_MENT' then
    classes[x[1]]['SPELL'][spell]['R_MENT'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[SPELL_FORBIDDEN_SPELL' then
    classes[x[1]]['SPELL'][spell]['F_SPELL'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[SPELL_FORBIDDEN_CLASS' then
    classes[x[1]]['SPELL'][spell]['F_CLASS'][split(totdat[j],':')[2]] = split(split(totdat[j],':')[3],']')[1]
   elseif split(totdat[j],':')[1] == '[SPELL_UPGRADE' then
    classes[x[1]]['SPELL'][spell]['UPGRADE'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[SPELL_COST' then
    classes[x[1]]['SPELL'][spell]['COST'] = split(split(totdat[j],':')[2],']')[1]
   elseif split(totdat[j],':')[1] == '[SPELL_EXP_GAIN' then
    classes[x[1]]['SPELL'][spell]['EXP'] = split(split(totdat[j],':')[2],']')[1]
--   else
--    print('Unrecognized token in classes.txt '..totdat[j]..' line '..tostring(j))
   end
  end
 end
 return classes
end

return read_file