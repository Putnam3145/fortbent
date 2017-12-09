local function killUnit(unit,not_double_kill)
    unit.body.blood_count = 0
    if not not_double_kill then --the things you do for backwards compatibility
        unit.animal.vanish_countdown = 2 --Even if they're undead, the fool can still double-kill.
    end
end

args={...}

killUnit(df.unit.find(args[0]),args[1])
