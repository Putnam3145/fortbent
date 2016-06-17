roses = roses or false

local json=require('json')

local json_file_names={
'SpellTable',
'GlobalTable',
'EnvironmentDelay',
'CommandDelay',
'ClassTable',
'CounterTable',
'EntityTable',
}
function saveRosesTable(savePath)
    savePath=savePath or dfhack.getSavePath()
    if not roses or not savePath then return false end
    local rosesFilePath=savePath..'/roses'
    dfhack.filesystem.mkdir(rosesFilePath)
    for k,v in pairs(json_file_names) do
        if roses[v] then
            json.encode_file(roses[v],rosesFilePath..'/'..v..'.json')
        end
    end
    dfhack.filesystem.mkdir(rosesFilePath..'/UnitTable')
    for k,v in pairs(roses.UnitTable) do
        json.encode_file(v,rosesFilePath..'/UnitTable/'..k..'.json')
    end
end

function loadRosesTable()
    if roses then return roses end
    local savePath=dfhack.getSavePath()
    if not savePath then return false end
    local rosesFilePath=savePath..'/roses'
    local rosesFileExists=false
    for k,v in pairs(json_file_names) do
        rosesFileExists=rosesFileExists or dfhack.filesystem.isfile(rosesFilePath..'/'..v..'.json')
    end
    if not rosesFileExists then
        roses={}
        roses.savePath=savePath
        roses.UnitTable={}
        saveRosesTable()
        return roses
    end
    roses={}
    roses.savePath=savePath
    for k,v in pairs(json_file_names) do
        if dfhack.filesystem.isfile(rosesFilePath..'/'..v..'.json') then
            roses[v]=json.decode_file(rosesFilePath..'/'..v..'.json')
        end
    end
    roses.UnitTable={}
    for k,v in ipairs(dfhack.filesystem.listdir(rosesFilePath..'/UnitTable')) do
        if v:sub(-4)=='json' then
            roses.UnitTable[v:sub(0,-6)]=json.decode_file(rosesFilePath..'/UnitTable/'..v)
        end
    end
    return roses
end

dfhack.onStateChange.rosesFileIO=function(code)
    if code==SC_WORLD_UNLOADED then
        saveRosesTable(roses.savePath)
        roses=false
    end
end

local function saveOnAutosave()
    if df.global.ui.main.autosave_request then
        saveRosesTable()
    end
end

require('repeat-util').scheduleUnlessAlreadyScheduled('rosesQuickAndAutoSave',1,'ticks',saveOnAutosave)