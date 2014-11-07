utils = require('utils')

validArgs = validArgs or utils.invert({
 'unit'
})

local args = utils.processArgs({...}, validArgs)

local function teleport(unit,pos)
 local unitoccupancy = dfhack.maps.getTileBlock(unit.pos).occupancy[unit.pos.x%16][unit.pos.y%16]
 local newoccupancy = dfhack.maps.getTileBlock(pos).occupancy[pos.x%16][pos.y%16]
 if newoccupancy.unit then
  unit.flags1.on_ground=true
 end
 unit.pos.x = pos.x
 unit.pos.y = pos.y
 unit.pos.z = pos.z
 if not unit.flags1.on_ground then unitoccupancy.unit = false else unitoccupancy.unit_grounded = false end
end

local function teleport_to_dest(unit)
 if not (unit.relations.draggee_id~=-1 or unit.relations.dragger_id~=-1 or unit.relations.following~=0 or unit.counters.unconscious>0) then
  if (dfhack.maps.isValidTilePos(unit.pos) and dfhack.maps.isValidTilePos(unit.path.dest)) then
   teleport(unit,unit.path.dest)
  end
 end
end

teleport_to_dest(args.unit)