local eventful=require('plugins.eventful')

eventful.enableEvent(eventful.eventType.SYNDROME,5)

eventful.onSyndrome.fortbentGodTierAutoTrueTransform=function(unit_id,syndrome_index)
    local unit=df.unit.find(unit_id)
    if unit.enemy.were_race~=unit.enemy.normal_race and df.creature_raw.find(unit.enemy.were_race).creature_id:find('HERO_OF') then
        unit.enemy.normal_race=unit.enemy.were_race
        unit.enemy.normal_caste=unit.enemy.were_caste
        local syndromeUtil=require('syndrome-util')
        syndromeUtil.eraseSyndrome(unit,syndrome_index)
    end
end