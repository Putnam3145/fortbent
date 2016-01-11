--MUST BE LOADED IN DFHACK.INIT

local utils = require 'utils'
local split = utils.split_string
local persistTable = require 'persist-table'

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

persistTable.GlobalTable.roses = persistTable.GlobalTable.roses or {}
persistTable.GlobalTable.roses.UnitTable = persistTable.GlobalTable.roses.UnitTable or {}
persistTable.GlobalTable.roses.EntityTable = persistTable.GlobalTable.roses.EntityTable or {}
persistTable.GlobalTable.roses.CommandDelay = persistTable.GlobalTable.roses.CommandDelay or {}
persistTable.GlobalTable.roses.EnvironmentDelay = persistTable.GlobalTable.roses.EnvironmentDelay or {}
persistTable.GlobalTable.roses.CounterTable = persistTable.GlobalTable.roses.CounterTable or {}
if not persistTable.GlobalTable.roses.GlobalTable then dfhack.script_environment('functions/tables').makeGlobalTable() end

local function civilizationNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.CivilizationTable) or #persistTable.GlobalTable.roses.CivilizationTable._children < 1
end
local function classNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.ClassTable) or #persistTable.GlobalTable.roses.ClassTable._children < 1
end
local function eventNotAlreadyLoaded()
 return (not persistTable.GlobalTable.roses.EventTable) or #persistTable.GlobalTable.roses.EventTable._children < 1
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