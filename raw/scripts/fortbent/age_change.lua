local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit',
 'kill'
})

local args = utils.processArgs({...}, validArgs)

local unit = df.unit.find(args.unit)

if args.kill then
    unit.old_year=unit.old_year>0 and df.global.cur_year-1 or unit.old_year
else
    unit.old_year=unit.old_year>0 and unit.old_year+1 or unit.old_year
end