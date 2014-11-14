--base/teleport.lua v1.0
--	MUST BE LOADED IN DFHACK.INIT
--	Use with special-teleport.lua
--	Requires two buildings named TELEPORT_1 and TELEPORT_2

events = require "plugins.eventful"
events.enableEvent(events.eventType.BUILDING,100)

events.onBuildingCreatedDestroyed.teleport=function(building_id)
	bldg = df.building.find(building_id)
	if df.building_furnacest:is_instance(bldg) or df.building_workshopst:is_instance(bldg) then
		all_bldgs = df.global.world.raws.buildings.all
		btype = bldg.custom_type
		if btype < 0 then return end
		if ((all_bldgs[btype].code == 'TELEPORT_1') or (all_bldgs[btype].code == 'TELEPORT_2')) then
			pers,status = dfhack.persistent.get('teleport')
			if all_bldgs[btype].code == 'TELEPORT_1' then
				if not pers then
					dfhack.persistent.save({key='teleport',value='teleport',ints={bldg.centerx,bldg.centery,bldg.z,-1,-1,-1,-1}})
				else
					dfhack.persistent.save({key='teleport',ints={bldg.centerx,bldg.centery,bldg.z,pers.ints[4],pers.ints[5],pers.ints[6],-1}})
				end
			else
				if not pers then
					dfhack.persistent.save({key='teleport',value='teleport',ints={-1,-1,-1,bldg.centerx,bldg.centery,bldg.z,-1}})
				else
					dfhack.persistent.save({key='teleport',ints={pers.ints[1],pers.ints[2],pers.ints[3],bldg.centerx,bldg.centery,bldg.z,-1}})
				end
			end
			pers,status = dfhack.persistent.get('teleport')
			if ((pers.ints[1] > 0) and (pers.ints[4] > 0 )) then
				dfhack.persistent.save({key='teleport',ints={pers.ints[1],pers.ints[2],pers.ints[3],pers.ints[4],pers.ints[5],pers.ints[6],1}})
			else
			end
		else
		end
	end
end
