function commandDelay(ticks,script)
 local roses = dfhack.script_environment('base/roses-table').loadRosesTable()
 local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
 local runTick = currentTick + ticks
 local persistDelay = roses.CommandDelay
 local number = #persistDelay._children
 persistDelay[tostring(number+1)] = {}
 persistDelay[tostring(number+1)].Tick = tostring(runTick)
 persistDelay[tostring(number+1)].Command = script
 dfhack.timeout(ticks,'ticks',
                function () 
				 dfhack.run_command(script) 
				end
			   )
end

function environmentDelay(ticks,environment,functions,arguments)
 id = dfhack.timeout(ticks,'ticks',
                     function () 
                      dfhack.script_environment(environment)[functions](table.unpack(arguments))
                     end
                    )
 local roses = dfhack.script_environment('base/roses-table').loadRosesTable()
 local currentTick = 1200*28*3*4*df.global.cur_year + df.global.cur_year_tick
 local runTick = currentTick + ticks
 local persistDelay = roses.EnvironmentDelay
 local number = #persistDelay._children
 persistDelay[tostring(number+1)] = {}
 persistDelay[tostring(number+1)].ID = tostring(id)
 persistDelay[tostring(number+1)].Tick = tostring(runTick)
 persistDelay[tostring(number+1)].Environment = environment
 persistDelay[tostring(number+1)].Function = functions
 persistDelay[tostring(number+1)].Arguments = {}
 for i,x in ipairs(arguments) do
  persistDelay[tostring(number+1)].Arguments[tostring(i)] = tostring(x)
 end
 return id
end