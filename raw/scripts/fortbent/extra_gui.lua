local gui=require('gui')

local widgets=require('gui.widgets')

local putnamSkills=dfhack.script_environment('modtools/putnam_skills')

local claspectAssign=dfhack.script_environment('fortbent/claspect_assign')

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
    Breath={fg=COLOR_LIGHTCYAN,bg=COLOR_BLACK},
    Light={fg=COLOR_YELLOW,bg=COLOR_BLACK},
    Time={fg=COLOR_LIGHTRED,bg=COLOR_BLACK},
    Space={fg=COLOR_WHITE,bg=COLOR_BLACK},
	Life={fg=COLOR_LIGHTGREEN,bg=COLOR_BLACK},
	Hope={fg=COLOR_YELLOW,bg=COLOR_BLACK},
	Void={fg=COLOR_BLUE,bg=COLOR_BLACK},
	Heart={fg=COLOR_MAGENTA,bg=COLOR_BLACK},
	Blood={fg=COLOR_RED,bg=COLOR_BLACK},
	Doom={fg=COLOR_GREEN,bg=COLOR_BLACK},
	Mind={fg=COLOR_CYAN,bg=COLOR_BLACK},
	Rage={fg=COLOR_LIGHTMAGENTA,bg=COLOR_BLACK}
}

local sburbTiles={
	Breath=0,
	Light=3,
	Time=1,
	Space=2,
	Life=7,
	Hope=8,
	Void=9, --the arbitrary numbers come from my arbitrary graphics page
	Heart=6,
	Blood=5,
	Doom=11,
	Mind=10,
    Rage=4
}
    
local extendedZodiacSburbAspects={
	Breath={tile=11,suffix={'us','un'}}, --ONE INDEXED TABLES GOTTA ADD ONE TO THE LUNAR SWAY BEFORE THIS WORKS
	Light={tile=5,suffix={'pio','pia'}},
	Time={tile=0,suffix={'rist','ries'}},
	Space={tile=7,suffix={'go','ga'}},
	Life={tile=1,suffix={'sci','sces'}},
	Hope={tile=2,suffix={'nius','rius'}},
	Void={tile=4,suffix={'ittanius','ittarius'}}, --the arbitrary numbers come whatpumpkin's arbitrary extended zodiac page
	Heart={tile=8,suffix={'lo','o'}},
	Blood={tile=9,suffix={'cer','cen'}},
	Doom={tile=10,suffix={'mino','mini'}},
	Mind={tile=6,suffix={'ra','za'}},
    Rage={tile=3,suffix={'icorn','iborn'}},
}

function getClaspect(unit)
    local currentClass
    local currentClasses = putnamSkills.getSkillsFromUnit(unit)
    if currentClasses then currentClass=currentClasses[1] else return {class=false} end 
    local currentClassName = df.musical_form.find(currentClass.id).name.first_name
    local currentClassLevel = currentClass.rating
    local ofLocations={currentClassName:find(' of ')}
    local aspectColor=sburbColors[currentClassName:sub(ofLocations[2]+1,-1)]
    local className=currentClassName:sub(1,1)..currentClassName:sub(2,ofLocations[1]-1):lower()
    local aspectName=currentClassName:sub(ofLocations[2]+1,ofLocations[2]+1)..currentClassName:sub(ofLocations[2]+2,-1):lower()
    local tile=dfhack.screen.findGraphicsTile('PUTNAM_GODTIER',sburbTiles[aspectName],0)
    return {class=className,aspect=aspectName,color=aspectColor,classLength=ofLocations[2],tile=tile}
end

trollCastes={
    TROLL_BURGUNDY={idx=0,prefix='Ar',color=COLOR_RED},
    TROLL_BRONZE={idx=2,prefix='Taur',color=COLOR_BROWN},
    TROLL_GOLD={idx=4,prefix='Gem',color=COLOR_YELLOW},
    TROLL_LIME={idx=6,prefix='Ca',optional={letter='n',criterion=function(suffix) return suffix:find('[aeiousnczgpl]')==1 end},color=COLOR_LIGHTGREEN},
    TROLL_OLIVE={idx=8,prefix='Le',color=COLOR_GREEN},
    TROLL_JADE={idx=10,prefix='Vir',color=COLOR_LIGHTGREEN}, --16 colors and only two are green, oof
    TROLL_TEAL={idx=12,prefix='Li',optional={letter='b',criterion=function(suffix) return suffix:find('[aeiouscnz]')==1 end},color=COLOR_CYAN},
    TROLL_CERULEAN={idx=14,prefix='Scor',color=COLOR_LIGHTBLUE},
    TROLL_INDIGO={idx=16,prefix='Sagi',color=COLOR_BLUE},
    TROLL_PURPLE={idx=18,prefix='Capri',color=COLOR_MAGENTA},
    TROLL_VIOLET={idx=20,prefix='Aqu',optional={letter='a',criterion=function(suffix) return not suffix:find('[aeiou]')==1 end},color=COLOR_MAGENTA}, --see above comment about green
    TROLL_FUSCHIA={idx=22,prefix='Pi',color=COLOR_LIGHTMAGENTA},
}

trollCastes.TROLL_MUTANT=trollCastes.TROLL_LIME

function makeZodiacSign(prefix,suffix,optional)
    if optional then
        if optional.criterion(suffix) then
            prefix=prefix..optional.letter
        end
    end
    if prefix:sub(-1)==suffix:sub(1,1) and prefix..suffix~='Cannius' then --if last letter of prefix is the same as first letter of suffix
        suffix=suffix:sub(2) --remove first letter of suffix
    end
    return prefix..suffix
end

function getCaste(unit)
    for k,v in ipairs(df.creature_raw.find(unit.race).caste[unit.caste].creature_class) do
        local casteInfo=trollCastes[v.value]
        if casteInfo then return casteInfo end
    end
    return {idx=-30000,prefix='bepis',color=COLOR_WHITE}
end

function getZodiac(unit)
    local aspect,caste,sway=extendedZodiacSburbAspects[getClaspect(unit).aspect],getCaste(unit),claspectAssign.getLunarSway(unit)
    if caste.idx==-30000 then return {tile=dfhack.screen.findGraphicsTile('HUSSIE_EMOTES',8,1),name='ERROR',color=COLOR_WHITE} end
    return {
        tile=dfhack.screen.findGraphicsTile('EXTENDED_ZODIAC',aspect.tile,caste.idx+sway),
        name=makeZodiacSign(caste.prefix,aspect.suffix[sway+1],caste.optional),
        color=caste.color
    }
end

local ExtraUnitListInfo=defclass(ExtraUnitListInfo,TransparentScreen)

function ExtraUnitListInfo:changeMode()
    self.displayMode=(self.displayMode+1)%3
end

function ExtraUnitListInfo:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.CUSTOM_F then
        self:changeMode()
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
    self.pageY=h-9
    self.buttonDisplayX=12
    self.recalculateButtonDisplay=true --putting this code into the onResize function results in utterly screwy results, best put it in once the rendering's back to normal
end

function ExtraUnitListInfo:onRender()
    self._native.parent:render()
    self.buttonDisplayTimeout=self.buttonDisplayTimeout and self.buttonDisplayTimeout-1 or 10
    if self.buttonDisplayTimeout<=0 then
        self.recalculateButtonDisplay=true
    end
    if self._native.parent._type~=df.viewscreen_unitlistst then self:dismiss() return end
    if self.recalculateButtonDisplay then
        local old_x=self.buttonDisplayX
        local old_y=self.buttonDisplayY
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
        self.buttonDisplayTimeout=math.ceil(df.global.enabler.gfps/30)
    end
    if self.displayMode~=0 then
        local parent=self._native.parent
        local stupidWorkaround='                             '
        local curPage=math.floor(parent.cursor_pos[parent.page]/self.pageY)
        if self.displayMode==1 then
            for k,v in ipairs(self.sburbOverrides[parent.page]) do
                if math.floor((k-1)/self.pageY)==curPage and v.class then
                    local yPos=((k-1)%self.pageY)+4
                    if dfhack.screen.inGraphicsMode() and v.tile then
                        if parent.cursor_pos[parent.page]==k-1 then
                            dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX,yPos,v.class..' of ')
                            dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX+v.classLength+1,yPos,v.aspect..stupidWorkaround)
                            dfhack.screen.paintTile({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX+v.classLength,yPos,'a',v.tile)
                        else
                            dfhack.screen.paintString({fg=COLOR_GREY,bg=COLOR_BLACK},self.jobX,yPos,v.class..' of ')
                            dfhack.screen.paintString(v.color,self.jobX+v.classLength+1,yPos,v.aspect..stupidWorkaround)
                            dfhack.screen.paintTile(v.color,self.jobX+v.classLength,yPos,'a',v.tile)
                        end
                    else
                        if parent.cursor_pos[parent.page]==k-1 then
                            dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX,yPos,v.class..' of '..v.aspect..stupidWorkaround)
                        else
                            dfhack.screen.paintString({fg=COLOR_GREY,bg=COLOR_BLACK},self.jobX,yPos,v.class..' of ')
                            dfhack.screen.paintString(v.color,self.jobX+v.classLength,yPos,v.aspect..stupidWorkaround)
                        end
                    end
                end
            end
        else
            for k,v in ipairs(self.zodiacOverrides[parent.page]) do
                if math.floor((k-1)/self.pageY)==curPage and v.color~=COLOR_WHITE then
                    local yPos=((k-1)%self.pageY)+4
                    if dfhack.screen.inGraphicsMode() and v.tile then
                        if parent.cursor_pos[parent.page]==k-1 then
                            dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX+1,yPos,v.name..stupidWorkaround)
                            dfhack.screen.paintTile({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX,yPos,'a',v.tile)
                        else
                            dfhack.screen.paintString({fg=v.color,bg=COLOR_BLACK},self.jobX+1,yPos,v.name..stupidWorkaround)
                            dfhack.screen.paintTile({fg=v.color,bg=COLOR_BLACK},self.jobX,yPos,'a',v.tile)
                        end
                    else
                        if parent.cursor_pos[parent.page]==k-1 then
                            dfhack.screen.paintString({fg=COLOR_BLACK,bg=COLOR_GREY},self.jobX,yPos,v.name..stupidWorkaround)
                        else
                            dfhack.screen.paintString({fg=v.color,bg=COLOR_BLACK},self.jobX,yPos,v.name..stupidWorkaround)
                        end
                    end
                end
            end
        end
    end
    dfhack.screen.paintString({fg=COLOR_LIGHTRED,bg=COLOR_BLACK},self.buttonDisplayX,df.global.gps.dimy-2,'f')
    dfhack.screen.paintString({fg=COLOR_WHITE,bg=COLOR_BLACK},self.buttonDisplayX+1,df.global.gps.dimy-2,': Fortbent info')
    
end

function ExtraUnitListInfo:init(args)
    self.displayMode=0
    self.sburbOverrides={}
    self.zodiacOverrides={}
    for k,unitList in ipairs(args.parent.units) do
        self.sburbOverrides[k]={}
        self.zodiacOverrides[k]={}
        for kk,unit in ipairs(unitList) do
            if unit.status and unit.status.current_soul then
                table.insert(self.sburbOverrides[k],getClaspect(unit))
                table.insert(self.zodiacOverrides[k],getZodiac(unit))
            end
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
