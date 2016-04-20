local gui=require('gui')

local TransparentViewscreen=defclass(TransparentViewscreen,gui.Screen)

function TransparentViewscreen:onInput(keys)
    self:inputToSubviews(keys)
    self:sendInputToParent(keys)
    if keys.LEAVESCREEN then
        self:dismiss()
    end
end

function TransparentViewscreen:onRender()
    self._native.parent:render()
end

local RelationsOverlay=defclass(RelationsOverlay,TransparentViewscreen)

function RelationsOverlay:onRender()
    self._native.parent:render()
    if self._native.parent._type~=df.viewscreen_layer_unit_relationshipst then self:dismiss() return end
    for k,v in ipairs(self.overrides) do
        local bg=self._native.parent.layer_objects[0].cursor==v.line and COLOR_GREEN or v.str.color_bg
        dfhack.screen.paintString({fg=v.str.color_fg,bg=bg},52,v.line+3,v.str.name)
    end
end

local custom_relation_types={}

custom_relation_types[413]={name='Moirail',color_fg=COLOR_RED,color_bg=COLOR_BLACK}

custom_relation_types[612]={name='Kismesis',color_fg=COLOR_BLACK,color_bg=COLOR_GREY}

custom_relation_types[1025]={name='Auspistice',color_fg=COLOR_BLACK,color_bg=COLOR_WHITE} --actually screw that one but whatever.

function RelationsOverlay:onShow()
    if self._native.parent._type~=df.viewscreen_layer_unit_relationshipst then self:dismiss() return end
    self.relationships=df.historical_figure.find(self._native.parent.unit.hist_figure_id).info.relationships.list
    if not self.relationships then self:dismiss() return end
    local overrideIds={}
    for k,relationship in ipairs(self.relationships) do
        for kk,relation_type in ipairs(relationship.anon_3) do --anon_3 is a vector of relationship types. The existing enum is not related to anon_3's version.
            if custom_relation_types[relation_type] then table.insert(overrideIds,{id=relationship.histfig_id,str=custom_relation_types[relation_type]}) end
        end
    end
    self.overrides={}
    for k,relation_hf in ipairs(self._native.parent.relation_hf) do
        for kk,overrideId in ipairs(overrideIds) do
            if relation_hf.id==overrideId.id then print(kk) table.insert(self.overrides,{line=k,str=overrideId.str}) end
        end
    end
end

viewscreenActions={}

viewscreenActions[df.viewscreen_layer_unit_relationshipst]=function()
    local relations=RelationsOverlay()
    relations:show()
end

dfhack.onStateChange.fortbent_screenstuff=function(code)
    if code==SC_VIEWSCREEN_CHANGED then
        local viewfunc=viewscreenActions[dfhack.gui.getCurViewscreen()._type]
        if viewfunc then viewfunc() end
    end
end
