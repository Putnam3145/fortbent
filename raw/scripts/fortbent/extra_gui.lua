local gui=require('gui')

local widgets=require('gui.widgets')

local persistTable = require 'persist-table'

local TransparentScreen=defclass(TransparentScreen,gui.Screen)

function TransparentScreen:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

function TransparentScreen:onRender()
    self._native.parent:render()
end

local sburbColors={
    BREATH={fg=COLOR_LIGHTCYAN,bg=COLOR_BLACK},
    LIGHT={fg=COLOR_YELLOW,bg=COLOR_BLACK},
    TIME={fg=COLOR_LIGHTRED,bg=COLOR_BLACK},
    SPACE={fg=COLOR_WHITE,bg=COLOR_BLACK},
	LIFE={fg=COLOR_LIGHTGREEN,bg=COLOR_BLACK},
	HOPE={fg=COLOR_YELLOW,bg=COLOR_BLACK},
	VOID={fg=COLOR_BLUE,bg=COLOR_BLACK},
	HEART={fg=COLOR_MAGENTA,bg=COLOR_BLACK},
	BLOOD={fg=COLOR_RED,bg=COLOR_BLACK},
	DOOM={fg=COLOR_GREEN,bg=COLOR_BLACK},
	MIND={fg=COLOR_CYAN,bg=COLOR_BLACK},
	RAGE={fg=COLOR_LIGHTMAGENTA,bg=COLOR_BLACK}
}

local sburbTiles={
	BREATH=0,
	LIGHT=3,
	TIME=1,
	SPACE=2,
	LIFE=7,
	HOPE=8,
	VOID=9, --the arbitrary numbers come from my arbitrary graphics page
	HEART=6,
	BLOOD=5,
	DOOM=11,
	MIND=10,
	RAGE=4}

function getClaspect(unit)
    local unitTable=persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]
    if not unitTable then return {class=nil,color=nil} end
    local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(unit.id)]['Classes']
    local currentClass = unitClasses['Current']
    local classes = persistTable.GlobalTable.roses.ClassTable
    local currentClassName = currentClass['Name']
    if not currentClassLevel[currentClassName] then return {class=nil,color=nil} end
    local currentClassLevel = tonumber(unitClasses[currentClassName]['Level'])+1
    local ofLocations={currentClassName:find('_OF_')}
    local aspectColor=sburbColors[currentClassName:sub(ofLocations[2]+1,-1)]
    local className=currentClassName:sub(1,1)..currentClassName:sub(2,ofLocations[1]-1):lower()
    local aspectName=currentClassName:sub(ofLocations[2]+1,ofLocations[2]+1)..currentClassName:sub(ofLocations[2]+2,-1):lower()
    local tile=dfhack.screen.findGraphicsTile('PUTNAM_GODTIER',sburbTiles[aspectName:upper()],0)
    return {class=className,aspect=aspectName,color=aspectColor,classLength=ofLocations[2],tile=tile}
end

local ExtraUnitListInfo=defclass(ExtraUnitListInfo,TransparentScreen)

function ExtraUnitListInfo:toggleClaspects()
    self.showClaspects=not self.showClaspects
end

function ExtraUnitListInfo:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.CUSTOM_F then
        self:toggleClaspects()
    end
    if keys.LEAVESCREEN or keys.UNITVIEW_RELATIONSHIPS_ZOOM then
        self:dismiss()
    end
end

function ExtraUnitListInfo:onGetSelectedUnit()
    local parent=self._native.parent
    return parent.units[parent.page][parent.cursor_pos[parent.page]]
end

function ExtraUnitListInfo:onResize(w,h)
    self.jobX=math.floor(w/2)
    self.buttonDisplayX=38
    self.recalculateButtonDisplay=true --putting this code into the onResize function results in utterly screwy results, best put it in once the rendering's back to normal
end

function ExtraUnitListInfo:onRender()
    self._native.parent:render()
    if self._native.parent._type~=df.viewscreen_unitlistst then self:dismiss() return end
    if self.recalculateButtonDisplay then
        local h=df.global.gps.dimy
        for i=2,df.global.gps.dimx do
            local tile1,tile2=dfhack.screen.readTile(i,h-2),dfhack.screen.readTile(i+1,h-2)
            if (tile1.ch==0 or tile1.ch==32 or tile1.bg==tile1.fg) then
                if (tile2.ch==0 or tile2.ch==32 or tile2.bg==tile2.fg) then
                    self.buttonDisplayX=i+1
                    self.recalculateButtonDisplay=false
                    break
                end
            end
        end
    end
    if self.showClaspects then
        local parent=self._native.parent
        local stupidWorkaround='                 '
        for k,v in ipairs(self.overrides[parent.page]) do
            if v.class then
                if dfhack.screen.inGraphicsMode() and v.tile then
                    if parent.cursor_pos[parent.page]==k-1 then
                        dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX,k+3,v.class..' of ')
                        dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX+v.classLength+1,k+3,v.aspect..stupidWorkaround)
                        dfhack.screen.paintTile({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX+v.classLength,k+3,'a',v.tile)
                    else
                        dfhack.screen.paintString({fg=COLOR_GREY,bg=COLOR_BLACK},self.jobX,k+3,v.class..' of ')
                        dfhack.screen.paintString(v.color,self.jobX+v.classLength+1,k+3,v.aspect..stupidWorkaround)
                        dfhack.screen.paintTile(v.color,self.jobX+v.classLength,k+3,'a',v.tile)
                    end
                else
                    if parent.cursor_pos[parent.page]==k-1 then
                        dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX,k+3,v.class..' of '..v.aspect..stupidWorkaround)
                    else
                        dfhack.screen.paintString({fg=COLOR_GREY,bg=COLOR_BLACK},self.jobX,k+3,v.class..' of ')
                        dfhack.screen.paintString(v.color,self.jobX+v.classLength,k+3,v.aspect..stupidWorkaround)
                    end
                end
            end
        end
    end
    dfhack.screen.paintString({fg=COLOR_LIGHTRED,bg=COLOR_BLACK},self.buttonDisplayX,df.global.gps.dimy-2,'f')
    dfhack.screen.paintString({fg=COLOR_WHITE,bg=COLOR_BLACK},self.buttonDisplayX+1,df.global.gps.dimy-2,': Display Sburb roles')
end

function ExtraUnitListInfo:init(args)
    self.showClaspects=false
    self.overrides={}
    for k,unitList in ipairs(args.parent.units) do
        self.overrides[k]={}
        for kk,unit in ipairs(unitList) do
            table.insert(self.overrides[k],getClaspect(unit))
        end
    end
end
   
local ExtraUnitScreen=defclass(ExtraUnitScreen,TransparentScreen)

function ExtraUnitScreen:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

function ExtraUnitScreen:onRender()
    local parent=self._native.parent
    parent:render()
    if parent._type~=df.viewscreen_unitst or not parent or not parent.unit then 
        self:dismiss() return 
    end
    if self.claspectInfo.class then
        if dfhack.screen.inGraphicsMode() and self.claspectInfo.tile then
            dfhack.screen.paintString({fg=COLOR_WHITE,bg=COLOR_BLACK},2,3,self.claspectInfo.class..' of ')
            dfhack.screen.paintString(self.claspectInfo.color,2+self.claspectInfo.classLength+1,3,self.claspectInfo.aspect)
            dfhack.screen.paintTile(self.claspectInfo.color,2+self.claspectInfo.classLength,3,'a',self.claspectInfo.tile)
        else
            dfhack.screen.paintString({fg=COLOR_WHITE,bg=COLOR_BLACK},2,3,self.claspectInfo.class..' of ')
            dfhack.screen.paintString(self.claspectInfo.color,2+self.claspectInfo.classLength,3,self.claspectInfo.aspect)
        end
    end
end
   
function ExtraUnitScreen:init(args)
    self.claspectInfo=getClaspect(args.parent.unit)
end
   
viewscreenActions={}

viewscreenActions[df.viewscreen_unitlistst]=function()
    local extraUnitListScreen=ExtraUnitListInfo{parent=dfhack.gui.getCurViewscreen()}
    extraUnitListScreen:show()
end

viewscreenActions[df.viewscreen_unitst]=function()
    local extraUnitScreen=ExtraUnitScreen{parent=dfhack.gui.getCurViewscreen()}
    extraUnitScreen:show()
end

dfhack.onStateChange.fortbent_extra_gui=function(code)
    if code==SC_VIEWSCREEN_CHANGED then
        local viewfunc=viewscreenActions[dfhack.gui.getCurViewscreen()._type]
        if viewfunc then viewfunc() end
    end
end