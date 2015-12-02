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

local ExtraUnitScreen=defclass(ExtraUnitScreen,TransparentScreen)

function ExtraUnitScreen:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
    if keys.SELECT then
        self:openExtraInfoScreen()
    end
end

function ExtraUnitScreen:onRender()
    local parent=self._native.parent
    parent:render()
    if parent._type~=df.viewscreen_textviewerst or not pcall(function() parent.unit end) then self:dismiss() return end
    local painter=gui.Painter()
    painter:seek(2,df.global.gps.dimx-1):pen({fg=COLOR_WHITE}):string('Press '):key('SELECT'):string(' for more Fortbent info('):pen({fg=COLOR_RED}):string('DFHACK'):pen({fg=COLOR_WHITE}):string(')')
end

function ExtraUnitScreen:openExtraInfoScreen()
    local moreInfo=ExtraInfoScreen{frame_title=dfhack.TranslateName(self._native.parent.unit.name)}
    moreInfo:show()
end

local ExtraInfoScreen=defclass(ExtraInfoScreen,gui.FramedScreen)

local function determineorientation(unit)
 if unit.sex~=-1 then
  local return_string=''
  local orientation=unit.status.current_soul.orientation_flags
  local male_interested,asexual=false,true
  if orientation.romance_male then
   return_string=return_string..' likes males'
   male_interested=true
   asexual=false
  elseif orientation.marry_male then
   return_string=return_string..' will marry males'
   male_interested=true
   asexual=false
  end
  if orientation.romance_female then
   if male_interested then
 return_string=return_string..' and likes females'
   else
    return_string=return_string..' likes females'
   end
   asexual=false
  elseif orientation.marry_female then
   if male_interested then
 return_string=return_string..' and will marry females'
   else
    return_string=return_string..' will marry females'
   end
   asexual=false
  end
  if asexual then
   return_string=' is asexual'
  end
  return return_string
 else
  return "is not biologically capable of sex"
 end
end

function ExtraInfoScreen:init(args)
    self.unit = self.unit or self._native.parent.parent.unit
    local capitalSubjectPronoun=self.unit.sex==0 and 'She' or self.unit.sex==1 and 'He' or 'It'
    local subjectPronoun=self.unit.sex==0 and 'she' or self.unit.sex==1 and 'he' or 'it'
    local unitClasses = persistTable.GlobalTable.roses.UnitTable[tostring(self.unit.id)]['Classes']
    local currentClass = unitClasses['Current']
    local classes = persistTable.GlobalTable.roses.ClassTable
    local currentClassName = currentClass['Name']
    local currentClassLevel = tonumber(unitClasses[currentClassName]['Level'])+1
    self.addviews{
        widgets.Label{
            frame={t=0},
            text=capitalSubjectPronoun..determineorientation(self.unit)
        },
        widgets.Label{
            frame={t=1},
            text='Stress level: ' .. unit.status.current_soul.personality.stress_level
        },
        widgets.Label{
            frame={t=2}
            text=capitalSubjectPronoun..' is a level '..currentClassLevel..' '..currentClassName
        },
        widgets.Label{
            frame={t=3}
            text='Being the creator of the mod, I have horrible myopia when it comes to conveyance.'
        },
        widgets.Label{
            frame={t=4}
            text='If you have any ideas of what else to add here, let me know!'
        }
    }
end