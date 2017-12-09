local utils=require('utils')

validArgs = validArgs or utils.invert({
 'unit',
 'amount'
})

local args = utils.processArgs({...}, validArgs)

df.unit.find(args.unit).body.blood_count=math.ceil(df.unit.find(args.unit).body.blood_count/tonumber(args.amount))
