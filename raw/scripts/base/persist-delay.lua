local persistTable = require 'persist-table'

local delayTable = persistTable.GlobalTable.roses.CommandDelay
for _,i in pairs(delayTable._children) do
 local delay = delayTable[i]
 local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
 if currentTick >= tonumber(delay.Tick) then
  delay = nil
 else
  local ticks = delay.Tick-currentTick
  dfhack.timeout(ticks,'ticks',
                 function ()
                  dfhack.run_command(delay.Script)
                 end
                )
 end
end

local delayTable = persistTable.GlobalTable.roses.EnvironmentDelay
for _,i in pairs(delayTable._children) do
 local delay = delayTable[i]
 local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
 if currentTick >= tonumber(delay.Tick) then
  delay = nil
 else
  local ticks = delay.Tick-currentTick
  local environment = delay.Environment
  local functions = delay.Function
  local arguments = delay.Arguments._children
  dfhack.timeout(ticks,'ticks',
                 function ()
                  dfhack.script_environment(environment)[functions](table.unpack(arguments))
                 end
                )
 end
end