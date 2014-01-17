-- Shortens all surnames regularly
-- Doesn't affect the additional surnames given by heroic deeds
-- Those are stored in .name.words[2] through ...words[6]
-- Made by Akjosch, optimized and made automatic by Putnam

function shorten_name(unit)
    unit.name.words[1] = -1
	unit.status.current_soul.name.words[1]=-1
	if unit.hist_figure_id>-1 then
		df.historical_figure.find(unit.hist_figure_id).name.words[1]=-1
	end
	return true
end

function shorten_all_names()
   for _uid,unit in ipairs(df.global.world.units.active) do
      shorten_name(unit)
   end
end

dfhack.onStateChange.shorten_all_names = function(code) --Many thanks to Warmist for pointing this out to me!
    if code==SC_MAP_LOADED then
        dfhack.timeout(1,'ticks',callback) --disables if map/world is unloaded automatically
    end
end

function callback()
    shorten_all_names()
    dfhack.timeout(500,'ticks',callback)
end

dfhack.onStateChange.shorten_all_names()