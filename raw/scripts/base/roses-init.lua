--MUST BE LOADED IN DFHACK.INIT

local utils = require 'utils'
local split = utils.split_string

validArgs = validArgs or utils.invert({
 'help',
 'all',
 'classSystem',
 'civilizationSystem',
 'eventSystem',
 'persistentDelay',
 'globalTracking',
 'forceReload'
})
local args = utils.processArgs({...}, validArgs)

roses = dfhack.script_environment('base/roses-table').loadRosesTable()
roses.UnitTable = roses.UnitTable or {}
roses.EntityTable = roses.EntityTable or {}
roses.CommandDelay = roses.CommandDelay or {}
roses.EnvironmentDelay = roses.EnvironmentDelay or {}
roses.CounterTable = roses.CounterTable or {}
roses.SpellTable = roses.SpellTable or {}
if not roses.GlobalTable then dfhack.script_environment('functions/tables').makeGlobalTable() end

local function civilizationNotAlreadyLoaded()
 return (not roses.CivilizationTable) or #roses.CivilizationTable < 1
end
local function classNotAlreadyLoaded()
 return (not roses.ClassTable) or #roses.ClassTable < 1
end
local function eventNotAlreadyLoaded()
 return (not roses.EventTable) or #roses.EventTable < 1
end

if args.all or args.classSystem then
 systemCheck = false
 if classNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeClassTable()
 elseif not classNotAlreadyLoaded() then
  systemCheck = true
 end
 if systemCheck then
  print('Class System successfully loaded')
 end
end

if args.all or args.civilizationSystem then
 systemCheck = false
 if civilizationNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeCivilizationTable()
 elseif not civilizationNotAlreadyLoaded() then
  systemCheck = true
 end
 if systemCheck then
  print('Civilization System successfully loaded')
 end
end

if args.all or args.eventSystem then
 systemCheck = false
 if eventNotAlreadyLoaded() or args.forceReload then
  systemCheck = dfhack.script_environment('functions/tables').makeEventTable()
 elseif not eventNotAlreadyLoaded() then
  systemCheck = true
 end
 if systemCheck then
  print('Event System successfully loaded')
 end
end

if args.all or args.persistentDelay then
 print('')
 print('Creating persistent function calls')
 dfhack.run_command('base/persist-delay')
end

if args.all or args.globalTracking then
 print('')
 print('Loading Global Tracking System')
 dfhack.run_command('base/global-tracking')
end

dfhack.run_command('base/on-death')
dfhack.run_command('base/on-time')