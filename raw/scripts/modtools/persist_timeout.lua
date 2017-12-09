--Absolutely based on roses' persist-delay.

local persistTable=require('persist-table')

if not persistTable.GlobalTable.persistTimeout then persistTable.GlobalTable.persistTimeout={} end

local persistTimeoutTable=persistTable.GlobalTable.persistTimeout

persistTimeoutTable['nextTimeoutId']=persistTimeoutTable['nextTimeoutId'] or '1' --yeah sorry lua arrays

local df_date=dfhack.script_environment('modtools/df_date')

function persistTimeout(ticks,env,func,args)
    local timeout=dfhack.timeout(ticks,'ticks',function() dfhack.script_environment(env)[func](table.unpack(args)) end)
    local currentTime=df_date.now()
    local runTime=currentTime+ticks
    local currentPersistNumber=tostring(persistTimeoutTable['nextTimeoutId'])
    persistTimeoutTable[currentPersistNumber]={}
    persistTimeoutTable[currentPersistNumber].ID=timeout
    persistTimeoutTable[currentPersistNumber].Tick=tostring(runTime:ticks())
    persistTimeoutTable[currentPersistNumber].Environment=env
    persistTimeoutTable[currentPersistNumber].Function=func
    persistTimeoutTable[currentPersistNumber].Arguments={}
    for k,v in ipairs(args) do
        persistTimeoutTable[currentPersistNumber].Arguments[tostring(k)]=tostring(v)
    end
    persistTimeoutTable['nextTimeoutId']=tostring(math.floor(persistTimeoutTable['nextTimeoutId']+1))
    return timeout
end

function onLoad()
    local listToCull={}
    local listOfTimeouts={}
    for _,v in pairs(persistTimeoutTable._children) do
        local actualTable=persistTimeoutTable[v]
        if actualTable and actualTable.Tick then
            if (df_date.now()<df_date.new(actualTable.Tick)) then
                table.insert(listToCull,v)
            else
                local env=actualTable.Environment
                local func=actualTable.Function
                local args=actualTable.Arguments
                table.insert(listOfTimeouts,dfhack.timeout((df_date.new(persistTimeoutTable.tick)-df_date.now()):ticks(),'ticks',function() dfhack.script_environment(env)[func](table.unpack(args)) end))
            end
        end
    end
    for k,v in ipairs(listToCull) do
        persistTimeoutTable[v]=nil
    end
    return listOfTimeouts
end