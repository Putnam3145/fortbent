-- Just a data file.

-- You can use lua files as data files!

local utils=require('utils')

lunar_sway={
    "Prospit",
    "Derse"
}

lunar_sway_by_index=utils.invert(lunar_sway)

aspects={
	"Breath", --1
	"Light",
	"Time",
	"Space",
	"Life",
	"Hope",
	"Void",
	"Heart",
	"Blood",
	"Doom",
	"Mind",
	"Rage"}
    
aspects_by_index=utils.invert(aspects)

function getAspectInString(str)
    for k,v in pairs(aspects) do
        if str:find(v) then return v end
    end
    return false
end

local aspect_circle={
    1,
    5,
    2,
    3,
    8,
    12,
    9,
    10,
    7,
    4,
    11,
    6
}

local function get_looped_table_index(tbl,index)
    return tbl[((index-1)%#tbl)+1]
end

function get_opposite_aspect(aspect)
    return aspects[get_looped_table_index(aspect_circle,aspects_by_index[aspect]+6)]
end

function get_adjacent_aspects(aspect)
    return {aspects[get_looped_table_index(aspect_circle,aspects_by_index[aspect]-1)],aspects[get_looped_table_index(aspect_circle,aspects_by_index[aspect]+1)]}
end

local function get_not_adjacent_aspect(num1,num2)
    return math.abs((num1%6)-(num2%6))
end

function get_non_adjacent_aspects(aspect)
    local aspect_list={}
    local aspect_num=aspects_by_index[aspect]
    for k,v in ipairs(aspect_circle) do
        if get_not_adjacent_aspect(aspect_num,k) then
            table.insert(aspect_list,aspects[v])
        end
    end
    return aspect_list
end
    
function make_new_aspect_table()
    return {
        Time=0,
        Space=0,
        Heart=0,
        Mind=0,
        Hope=0,
        Rage=0,
        Light=0,
        Void=0,
        Breath=0,
        Blood=0,
        Life=0,
        Doom=0
    }
end
  
classes={
    "Heir", --1
	"Seer",
	"Knight",
	"Witch",
	"Maid",
	"Page",
	"Prince",
	"Rogue",
	"Thief",
	"Sylph",
	"Bard",
	"Mage"}

function getClassInString(str)
    for k,v in pairs(classes) do
        if str:find(v) then return v end
    end
    return false
end
    

classes_by_index=utils.invert(classes)