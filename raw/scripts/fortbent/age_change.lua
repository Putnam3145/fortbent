local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit',
 'kill'
})

local args = utils.processArgs({...}, validArgs)

local unit = df.unit.find(args.unit)

if args.kill then
    unit.relations.old_year=unit.relations.old_year>0 and df.global.cur_year-1 or unit.relations.old_year
else
    unit.relations.old_year=unit.relations.old_year>0 and unit.relations.old_year+1 or unit.relations.old_year
end