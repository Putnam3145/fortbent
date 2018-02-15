for k,v in ipairs(df.global.world.units.all) do
    v.name.words[1]=-1
    if v.status and v.status.current_soul then
        v.status.current_soul.name.words[1]=-1
    end
    if v.hist_figure_id>-1 then
        df.historical_figure.find(v.hist_figure_id).name.words[1]=-1
    end
end

if ...=='-universal' then
    for k,v in ipairs(df.global.world.history.figures) do
        v.name.words[1]=-1
    end
end