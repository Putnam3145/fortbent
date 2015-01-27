local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

df.unit.find(args.unit).job.mood_timeout=1