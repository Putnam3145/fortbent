local df_date={}

df_date.new=function(number)
    local newDate={year=1,year_tick=number}
    setmetatable(newDate,df_date)
    return newDate:fix()
end

df_date.fix=function(dfDate)
    while dfDate.year_tick>=403200 do
        dfDate.year=dfDate.year+1
        dfDate.year_tick=dfDate.year_tick-403200
    end
    while dfDate.year_tick<0 do
        dfDate.year=newDate.year-1
        dfDate.year_tick=dfDate.year_tick+403200
    end
    return dfDate
end

df_date.__eq=function(date1,date2)
    return date1.year==date2.year and date1.year_tick==date2.year_tick
end

df_date.__lt=function(date1,date2)
    if date1.year<date2.year then return true end
    if date1.year>date2.year then return false end
    if date1.year==date2.year then
        return date1.year_tick<date2.year_tick
    end
end

df_date.__le=function(date1,date2)
    if date1.year<date2.year then return true end
    if date1.year>date2.year then return false end
    if date1.year==date2.year then
        return date1.year_tick<=date2.year_tick
    end
end

df_date.__sub=function(date1,date2)
    if type(date1)=='number' then
        date1=df_date.new(date1)
    end
    if type(date2)=='number' then
        date2=df_date.new(date2)
    end
    local newDate={year=date1.year-date2.year,year_tick=date1.year_tick-date2.year_tick}
    setmetatable(newDate,df_date)
    return newDate:fix()
end

df_date.__add=function(date1,date2)
    if type(date1)=='number' then
        date1=df_date.new(date1)
    end
    if type(date2)=='number' then
        date2=df_date.new(date2)
    end
    local newDate={year=date1.year+date2.year,year_tick=date1.year_tick+date2.year_tick}
    setmetatable(newDate,df_date)
    return newDate:fix()
end

df_date.ticks=function(dfDate)
    return (dfDate.year*403200)+dfDate.year_tick
end

df_date.dayOfWeek=function(dfDate)
    return (math.floor(dfDate.year_tick/1200)%7)+1
end

df_date.monthOfYear=function(dfDate)
    return math.floor(dfDate.year_tick/33600)+1
end

df_date.dayOfYear=function(dfDate)
    return math.floor(dfDate.year_tick/1200)
end

df_date.dayOfMonth=function(dfDate)
    return (math.floor(dfDate.year_tick/1200)%28)+1
end

df_date.__index=df_date

df_date.now=function()
    local newDate={year=df.global.cur_year,year_tick=df.global.cur_year_tick}
    setmetatable(newDate,df_date)
    return newDate
end

new=df_date.new

now=df_date.now