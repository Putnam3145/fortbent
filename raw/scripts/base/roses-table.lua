roses = roses or false

function saveRosesTable()
    local savePath=dfhack.getSavePath()
    if not roses or not savePath then return false end
    local rosesFilePath=savePath..'/prongle.json'
    json.encode_file(roses,rosesFilePath)
end

function loadRosesTable()
    if roses then return roses end
    local savePath=dfhack.getSavePath()
    if not savePath then return false end
    local rosesFilePath=savePath..'/roses.json'
    local rosesFileExists=dfhack.filesystem.isfile(rosesFilePath)
    if not rosesFileExists then
        roses={}
        saveRosesTableToFile()
        return roses
    end
    roses=json.decode_file(rosesFilePath)
    return roses
end

dfhack.onStateChange.rosesFileIO=function(code)
    if code==SC_WORLD_UNLOADED then
        roses=false
    elseif code==SC_VIEWSCREEN_CHANGED then
        if dfhack.gui.getCurViewscreen()._type==df.viewscreen_optionst then
            saveRosesTable()
        end
    end
end

local function saveOnAutosave()
    if df.global.ui.main.autosave_request then
        saveRosesTable()
    end
end

require('repeat-util').scheduleUnlessAlreadyScheduled('rosesQuickAndAutoSave',1,'ticks',saveOnAutosave)