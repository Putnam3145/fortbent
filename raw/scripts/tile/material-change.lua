--material-change.lua v1.0

validArgs = validArgs or utils.invert({
 'help',
 'plan',
 'location',
 'material',
 'dur',
 'unit',
 'floor',
})
local args = utils.processArgs({...}, validArgs)

if args.help then -- Help declaration
 print([[tile/material-change.lua
  Change a tiles material
  arguments:
   -help
     print this help message
   -unit id
     id of the unit to center on
     required if using -plan
   -plan filename                           \
     filename of plan to use (without .txt) |
   -location [ # # # ]                        | Must have at least one of these
     x,y,z coordinates to use for position  /
   -material INORGANIC_TOKEN
     material to set tile to
     examples:
      STEEL
      GRANITE
      RUBY
   -floor
    targets the z-level below the specified location(s)
   -dur #
     length of time for tile change to last
     0 means the change is natural and will revert back to normal temperature
     DEFAULT 0
  examples:
   tile/material-change -location [ \\LOCATION ] -material RUBY
   tile/material-change -plan 5x5_X -unit \\UNIT_ID -material SLADE -floor -dur 3000
 ]])
 return
end

if not args.material then
 print('No material declaration')
 return
end

dur = tonumber(args.dur) or 0

if args.plan then
 if args.unit and tonumber(args.unit) then
  pos = df.unit.find(tonumber(args.unit)).pos
 elseif args.location then
  pos = args.location
 else
  print('No center decleration, need -unit or -location')
  return
 end
 locations,n = dfhack.script_environment('functions/map').getPositionPlan(file,pos)
 for i,loc in ipairs(locations) do
  if args.floor then
   loc.z = loc.z - 1
  end
  dfhack.script_environment('functions/map').changeInorganic(loc,nil,nil,args.material,dur)
 end
end
if args.location then
 if args.floor then
  args.location[3] = args.location[3] - 1
 end
 dfhack.script_environment('functions/map').changeInorganic(args.location,nil,nil,args.material,dur)
end

