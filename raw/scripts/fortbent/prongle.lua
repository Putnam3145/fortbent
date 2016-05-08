-- Nothing for now. Ignore.

--[[
    Prongle is basically troll twitter, as shows in Hiveswap.
    These are some functions I wrote for dialogue in the Caledfwlch event script that I ended up scrapping because it's much easier to abstract than do writing in-character.
    However, in-character writing is a damn good idea for something that will actually show up to people on the regular. I might implement Prongle proper at some point with this in mind.
]]

local prongleData=prongleData or false

local json=require('json')

local df_date={} --lol I really should put this in its own file

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
    local newDate={year=date1.year-date2.year,year_tick=date1.year_tick-date2.year_tick}
    if newDate.year_tick<0 then
        newDate.year=newDate.year-1
        newDate.year_tick=newDate.year_tick%403200
    end
    return newDate
end

df_date.__add=function(date1,date2)
    local newDate={year=date1.year+date2.year,year_tick=date1.year_tick+date2.year_tick}
    if newDate.year_tick>=403200 then
        newDate.year=newDate.year+1
        newDate.year_tick=newDate.year_tick%403200
    end
    return newDate
end

function leading_zero(str,size)
    str=tostring(str)
    while str:len()<size do
        str='0'..str
    end
    return str
end

df_date.__tostring=function(date)
    local month=math.floor(date.year_tick/33600)+1
    local day=math.floor((date.year_tick%33600)/1200)+1
    return date.year..'-'..leading_zero(month,2)..'-'..leading_zero(day,2)
end

df_date.tostring_comparison=function(date)
    local month=math.floor(date.year_tick/33600)
    local day=math.floor((date.year_tick%33600)/1200)
    local year_string=date.year==1 and ' year, ' or ' years, '
    local month_string=month==1 and ' month, ' or ' months, and '
    local day_string=day==1 and ' day' or ' days'
    return date.year..year_string..month..month_string..day..day_string
end

local function getCurDate()
    local cur_date={year=df.global.cur_year,year_tick=df.global.cur_year_tick}
    setmetatable(cur_date,df_date)
    return cur_date
end

local function saveProngleDataToFile()
    local savePath=dfhack.getSavePath()
    if not prongleData or not savePath then return false end
    local prongleDataFilePath=savePath..'/prongle.json'
    json.encode_file(prongleData,prongleDataFilePath)
end

local function loadProngleDataFromFile()
    local savePath=dfhack.getSavePath()
    if prongleData or not savePath then return false end
    local prongleDataFilePath=savePath..'/prongle.json'
    local prongleDataFileExists=dfhack.filesystem.isfile(prongleDataFilePath)
    if not prongleDataFileExists then
        prongleData={}
        saveProngleDataToFile()
        return true
    end
    prongleData=json.decode_file(prongleDataFilePath)
    local cur_date=getCurDate()
    for k,timeline in pairs(prongleData) do
        for kk=#timeline.events,1,-1 do
            local event=timeline.events[kk]
            local eventDate=event.date
            setmetatable(eventDate,df_date)
            if eventDate>cur_date then
                table.remove(timeline.events,kk)
            end
        end
    end
end

local function getProngleTimeline(unit)
    if not prongleData then loadProngleDataFromFile() end
    local unit_str='unit_'..unit.id
    prongleData[unit_str]=prongleData[unit_str] or {unit=unit.id,events={}}
    return prongleData[unit_str]
end

local function getValue(unit,value)
    for k,v in ipairs(unit.status.current_soul.personality.values) do
        if df.value_type[v.type]==value then return v.strength end
    end
    if unit.civ_id>-1 then
        local entity=df.historical_entity.find(unit.civ_id)
        return entity.resources.values[value]+entity.resources.values_2[value]
    else
        return nil
    end
end

local function getPronoun(unit)
    if unit.status.current_soul then
        if unit.status.current_soul.sex==0 then
            return {'she','her','her','hers'}
        elseif unit.status.current_soul.sex==1 then
            return {'he','him','his','his'}
        else
            return {'they','them','their','theirs'}
        end
    else
        return {'it','it','its','its'}
    end
end

local function capitalizeFirstLetterOfString(str)
    return str:sub(1,1):upper()..str:sub(2,-1)
end

local function getSwearinessLevel(unit,personalityTrait,invertTrait,accountForThoughtlessness,accountForStress)
    local decorum=50-getValue(unit,'DECORUM')
    local swearyTrait=unit.status.current_soul.personality.traits[personalityTrait]
    if invertTrait then swearyTrait=100-swearyTrait end
    if accountForThoughtlessness then
        local thoughtlessness=unit.status.current_soul.personality.traits.THOUGHTLESSNESS
        if thoughtlessness>75 then
            return swearyTrait
        elseif accountForThoughtlessness then
            thoughtlessness=math.floor(((100-thoughtlessness)/25)+0.5)
        end
        local stressLevel=accountForStress and math.log(unit.status.current_soul.personality.stress_level) or 1
        if not stressLevel>0 then stressLevel=1 end --"not n>0" instead of "n<=0" because math.log of a number less than 0 is indeterminate, which always returns false to comparisons.
        stressLevel=math.max(1,math.floor(stressLevel+0.5))
        return ((swearyTrait*stressLevel)+(decorum*thoughtlessnessLevel)/(stressLevel+thoughtlessnessLevel))
    else
        local stressLevel=accountForStress and math.log(unit.status.current_soul.personality.stress_level) or 1
        if not stressLevel>0 then stressLevel=1 end --"not n>0" instead of "n<=0" because math.log of a number less than 0 is indeterminate, which always returns false to comparisons.
        stressLevel=math.max(1,math.floor(stressLevel+0.5))
        return ((swearyTrait*stressLevel)+(decorum)/(1+stressLevel))
    end
end

local gui=require('gui')

local widgets=require('gui.widgets')

local GraphicalButton=defclass(GraphicalButton,widgets.Widget)

GraphicalButton.ATTRS={
    on_click = DEFAULT_NIL,
    on_rclick = DEFAULT_NIL,
    graphic = DEFAULT_NIL, --refers to the name of a tilepage
    label = DEFAULT_NIL
}

function GraphicalButton:preUpdateLayout()
    self.frame=self.frame or {}
    if not self.page then self.frame.w=0 self.frame.h=0 return end
    self.frame.w=self.page.page_dim_x
    self.frame.h=self.page.page_dim_y
end

function GraphicalButton:onRenderBody(dc)
    if not self.page then return end
    for k,v in ipairs(self.page.texpos) do
        dc:seek(k%self.frame.w,math.floor(k/self.frame.w)):tile(32,v)
    end
end

function GraphicalButton:onInput(keys)
    if keys._MOUSE_L_DOWN and self:getMousePos() and self.on_click then
        self.on_click()
    end
    if keys._MOUSE_R_DOWN and self:getMousePos() and self.on_rclick then
        self.on_rclick()
    end
end

function GraphicalButton:init(args)
    if not self.graphic then return end
    for k,v in ipairs(df.global.texture.page) do
        if v.token==self.graphic then self.page=v return end
    end
    error('No tilepage found: '..self.graphic)
end

local ClickableLabel=defclass(ClickableLabel,widgets.Label)

ClickableLabel.ATTRS.on_click=DEFAULT_NIL

ClickableLabel.ATTRS.on_rclick=DEFAULT_NIL

ClickableLabel.ATTRS.default_pen=COLOR_CYAN

ClickableLabel.ATTRS.highlight_pen=DEFAULT_NIL

ClickableLabel.ATTRS.args={}

function ClickableLabel:onInput(keys)
    if keys._MOUSE_L_DOWN and self:getMousePos() and self.on_click then
        self:on_click()
    end
    if keys._MOUSE_R_DOWN and self:getMousePos() and self.on_rclick then
        self:on_rclick()
    end
end

function ClickableLabel:onRenderBody(dc)
    if self:getMousePos() then
        self.text_pen=self.highlight_pen
    else
        self.text_pen=self.default_pen
    end
    self.super.onRenderBody(self,dc)
end

function ClickableLabel:init(args)
    if not self.highlight_pen then self.highlight_pen=(self.default_pen+8)%16 end
    self.super.init(self,args)
end

local function lineBreakTableString(str)
    local prevBreak=1
    local str_list={}
    for i=1,str:len() do
        if str:sub(i,i)=='\n' then
            table.insert(str_list,str:sub(prevBreak,i-1))
            prevBreak=i+1
        end
    end
    table.insert(str_list,str:sub(prevBreak,str:len()))
    return str_list
end

local function wordWrapString(str,limit)
    local words=str:gmatch("%g+")
    local cur_string=""
    local prev_string=""
    local str_list={}
    for word in words do
        prev_string=cur_string
        cur_string=cur_string..word..' '
        if cur_string:len()>limit then
            table.insert(str_list,prev_string)
            cur_string=word..' '
        end
    end
    table.insert(str_list,cur_string)
    return str_list
end

local function separateString(str,limit)
    local str_list={}
    local lineBrokenStrs=lineBreakTableString(str)
    for k,v in ipairs(lineBrokenStrs) do
        for kk,vv in ipairs(wordWrapString(v,limit)) do
            table.insert(str_list,vv)
        end
    end
    return str_list
end

ProngleTimeline=defclass(ProngleTimeline, gui.FramedScreen)

ProngleTimeline.ATTRS.unit=DEFAULT_NIL

function ProngleTimeline:scrollUp()
    self.scroll=math.max(1,self.scroll-1)
end

function ProngleTimeline:scrollDown()
    self.scroll=math.min(self.bottom-2,self.scroll+1)
end

function ProngleTimeline:pageUp()
    self.scroll=math.max(1,self.scroll-df.global.gps.dimy-1)
end

function ProngleTimeline:pageDown()
    self.scroll=math.min(self.bottom-2,self.scroll+df.global.gps.dimy-1)
end



function ProngleTimeline:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    else
        self:inputToSubviews(keys)
        if keys.STANDARDSCROLL_UP or keys.SECONDSCROLL_UP then
            self:scrollUp()
        end
        if keys.STANDARDSCROLL_DOWN or keys.SECONDSCROLL_DOWN then
            self:scrollDown()
        end
        if keys.STANDARDSCROLL_PAGEUP or keys.SECONDSCROLL_PAGEUP then
            self:pageUp()
        end
        if keys.STANDARDSCROLL_PAGEDOWN or keys.SECONDSCROLL_PAGEDOWN then
            self:pageDown()
        end
    end
end

function ProngleTimeline:onResize(w,h)
    self:updateLayout(gui.ViewRect{ rect = gui.mkdims_wh(0,0,w,h) })
    self.prongs_on_screen=math.floor(h/6)
    self.width=math.min(46,w)
    self.scroll=self.scroll or 1
end

function ProngleTimeline:onRenderBody(dc)
    if not self.events then self:init() end
    for i=self.scroll,self.scroll+self.prongs_on_screen do
        local actualPosition=(i-self.scroll)*6
        if self.events[i] then
            local eventDate=self.events[i].date
            setmetatable(df_date,eventDate)
            dc:seek(6,actualPosition):string(tostring(eventDate))
            local textTbl=separateString(self.events[i].text,self.width)
            for k,str in ipairs(textTbl) do
                dc:seek(5,actualPosition+(k)):string(str)
            end
        end
    end
end

function ProngleTimeline:init()
    if not prongleData then loadProngleDataFromFile() end
    self.scroll=1
    self.events={}
    local prongleTimeline=getProngleTimeline(df.unit.find(self.unit))
    self.bottom=0
    for k=#prongleTimeline.events,1,-1 do
        table.insert(self.events,prongleTimeline.events[k])
        self.bottom=self.bottom+1
    end
end



ProngleScreen=defclass(ProngleScreen, gui.FramedScreen)

function ProngleScreen:onInput(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    else
        self:inputToSubviews(keys)
        
    end
end

local caste_colors={
    mutant=COLOR_LIGHTRED,
    red=COLOR_RED,
    brown=COLOR_BROWN,
    yellow=COLOR_YELLOW,
    olive=COLOR_GREEN,
    jade=COLOR_LIGHTGREEN,
    lime=COLOR_LIGHTGREEN,
    teal=COLOR_CYAN,
    cerulean=COLOR_LIGHTBLUE,
    cobalt=COLOR_BLUE,
    purple=COLOR_MAGENTA,
    violet=COLOR_MAGENTA,
    fuschia=COLOR_LIGHTMAGENTA
}

function ProngleScreen:init()
    for k,v in ipairs(df.global.world.units.active) do
        if dfhack.units.isCitizen(v) then
            local default_pen=COLOR_CYAN
            local unitRaw=df.creature_raw.find(v.race)
            if unitRaw.creature_id=='TROLL_ALTERNIA' then
                local casteName=unitRaw.caste[v.caste].caste_name[0]
                local _,findTroll=casteName:find('troll ')
                local realCasteName=casteName:sub(findTroll+2,-2)
                default_pen=caste_colors[realCasteName] or default_pen
            end
            self:addviews{ClickableLabel{
                view_id='Label #'..v.id,
                frame={t=k-1},
                text=dfhack.TranslateName(dfhack.units.getVisibleName(v)),
                args={unit=v.id},
                default_pen=default_pen,
                on_click=function(self) 
                    local prongleTimeline=ProngleTimeline{unit=self.args.unit}
                    prongleTimeline:show()
                end
                }
            }
        end
    end
end

local viewscreenActions={}

viewscreenActions[df.viewscreen_optionst]=function()
    saveProngleDataToFile()
end

local ProngleOpenScreen=defclass(ProngleOpenScreen,gui.Screen)

function ProngleOpenScreen:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

function ProngleOpenScreen:onRender()
    local parent=self._native.parent
    if parent._type~=df.viewscreen_overallstatusst then self:dismiss() return false end
    self._native.parent:render()
    self:renderSubviews()
end

function ProngleOpenScreen:init()
    self:addviews{ClickableLabel{
        view_id='The Label',
        frame={t=2,l=36},
        text='Open Prongle',
        default_pen=COLOR_GRAY,
        on_click=function(self) 
            local prongleScreen=ProngleScreen()
            prongleScreen:show()
        end
        },
        ClickableLabel{
        view_id='tutorial',
        frame={t=3,l=36},
        text='^Click me!',
        default_pen=COLOR_RED,
        on_click=function(self)
            self:setText('')
        end
        }
    }
end

viewscreenActions[df.viewscreen_overallstatusst]=function()
    local prongleOpenScreen=ProngleOpenScreen{}
    prongleOpenScreen:show()
end

local stateChangeActions={}

stateChangeActions[SC_VIEWSCREEN_CHANGED]=function()
    local viewfunc=viewscreenActions[dfhack.gui.getCurViewscreen()._type]
    if viewfunc then viewfunc() end
end

stateChangeActions[SC_WORLD_UNLOADED]=function()
    prongleData=false
end

stateChangeActions[SC_WORLD_LOADED]=function()
    loadProngleDataFromFile()
end

dfhack.onStateChange.prongle=function(op)
    local opFunc=stateChangeActions[op]
    if opFunc then opFunc() end
end

local putnamEvents=dfhack.script_environment('modtools/putnam_events')

putnamEvents.onEmotion.prongle=function(unit,emotion)
    if dfhack.units.isCitizen(unit) then
        local prongleTimeline=getProngleTimeline(unit)
        local str='I felt ' .. df.emotion_type[emotion.type] .. ' at ' .. df.unit_thought_type[emotion.thought] .. ' today.'
        local cur_date={year=emotion.year,year_tick=emotion.year_tick}
        table.insert(prongleTimeline.events,{text=str,date=cur_date})
    end
end

putnamEvents.enableEvent(putnamEvents.eventTypes.ON_EMOTION,2)

loadProngleDataFromFile()