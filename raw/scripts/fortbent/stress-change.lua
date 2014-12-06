local utils = require 'utils'

validArgs = validArgs or utils.invert({
 'unit',
 'amount',
 'adjust'
})

local args = utils.processArgs({...}, validArgs)

local unit = args.unit and df.unit.find(args.unit) or dfhack.gui.getSelectedUnit(true)

if not unit then qerror('No unit was selected or specified.') end

if args.amount then
    if args.adjust then
        unit.status.current_soul.personality.stress_level=unit.status.current_soul.personality.stress_level+args.amount
    else
        unit.status.current_soul.personality.stress_level=args.amount
    end
else
    print(unit.status.current_soul.personality.stress_level)
end