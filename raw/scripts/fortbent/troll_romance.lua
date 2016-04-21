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

custom_relation_types['MOIRAIL']=413

custom_relation_types['KISMESIS']=612

custom_relation_types['AUSPISTICE']=1025

function RelationsOverlay:onShow()
    if self._native.parent._type~=df.viewscreen_layer_unit_relationshipst then self:dismiss() return end
    self.relationships=df.historical_figure.find(self._native.parent.unit.hist_figure_id).info.relationships.list
    if not self.relationships then self:dismiss() return end
    local overrideIds={}
    for k,relationship in ipairs(self.relationships) do
        for kk,relationship_type in ipairs(relationship.anon_3) do --anon_3 is a vector of relationship types. The existing enum is not related to anon_3's version.
            if custom_relation_types[relationship_type] then table.insert(overrideIds,{id=relationship.histfig_id,str=custom_relation_types[relationship_type]}) end
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

local putnamEvents=dfhack.script_environment('modtools/putnam_events')

local function hasCustomRelationship(histfig,relationship_type)
    local typeToLookFor=custom_relation_types[relationship_type]
    for k,v in ipairs(histfig.info.relationships.list) do
        for kk,vv in ipairs(v.anon_3) do
            if vv==typeToLookFor then return v.histfig_id,v.anon_4[kk] end
        end
    end
    return false
end

local function addNewRelationship(histfig1,histfig2,relationship_type,value)
    for k,v in ipairs(histfig1.info.relationships.list) do
        if v.histfig_id==histfig2.id then
            v.anon_3:insert('#',custom_relation_types[relationship_type])
            v.anon_4:insert('#',value)
            return true
        end
    end
    return false
end

local function adjustRelationship(histfig1,histfig2,relationship_type,value)
    local typeToLookFor=type(relationship_type)=='string' and custom_relation_types[relationship_type] or relationship_type
    for k,v in ipairs(histfig1.info.relationships.list) do
        if v.histfig_id==histfig2.id then
            for kk,vv in ipairs(v.anon_3) do
                if vv==typeToLookFor then v.anon_4[kk]=v.anon_4[kk]+value return v.anon_4[kk] end
            end
        end
    end
    return false
end

local function getMutualRelation(histfig1,histfig2,relationship_type)
    local typeToLookFor=type(relationship_type)=='string' and custom_relation_types[relationship_type] or relationship_type
    local greatest_mutual_relationship={fig=0,value=-1000}
    for k,v in ipairs(histfig1.info.relationships.list) do
        for kk,vv in ipairs(histfig2.info.relationships.list) do
            if vv.histfig_id==v.histfig_id then
                local total_relation_value=0
                for kkk,vvv in ipairs(v.anon_3) do
                    if vvv==relationship_type then
                        total_relation_value=total_relation_value+v.anon_4[kkk]
                    end
                end
                for kkk,vvv in ipairs(vv.anon_3) do
                    if vvv==relationship_type then
                        total_relation_value=total_relation_value+vv.anon_4[kkk]
                    end                    
                end
                if greatest_mutual_relationship.value<total_relation_value then
                    greatest_mutual_relationship.value=total_relation_value
                    greatest_mutual_relationship.fig=v.histfig_id
                end
            end
        end
    end
    return greatest_mutual_relationship.fig,greatest_mutual_relationship.value
end

putnamEvents.onRelationshipUpdate.troll_romance=function(histfig1_id,histfig2_id,relationship_type,old_value,new_value)
    local histfig1=df.historical_figure.find(histfig1_id)
    local hasMoirailAlready=hasCustomRelationship(histfig1,'MOIRAIL')
    if not hasMoirailAlready and relationship_type==1 and new_value>=80 and then
        local histfig2=df.historical_figure.find(histfig2_id)
        local unit1=df.unit.find(histfig1.unit_id)
        local hasLoverAlready=unit1.relations.lover_id~=-1 or unit1.relations.spouse_id~=-1
        if hasLoverAlready and unit1.relations.lover_id~=histfig2.unit_id and unit1.relations.spouse_id~=histfig2.unit_id and adjustRelationship(histfig2,histfig1,1,0)>=80 then
            addNewRelationship(histfig1,histfig2,'MOIRAIL',1)
        end
    elseif hasMoirailAlready and relationship_type==1 and adjustRelationship(histfig1,histfig2,'MOIRAIL',0) then --adjustRelationship returns false if not found, so basically a search function when used this way
        adjustRelationship(histfig1,df.historical_figure.find(histfig2_id),'MOIRAIL',math.ceil((new_value-old_value)/2))
    elseif relationship_type==2 and new_value>=100 then
        local histfig2=df.historical_figure.find(histfig2_id)
        local hasKismesisAlready=hasCustomRelationship(histfig1,'KISMESIS')
        local otherHasKismesisAlready=hasCustomRelationship(histfig2,'KISMESIS')
        if hasKismesisAlready or otherHasKismesisAlready then 
            if not hasCustomRelationship(histfig1,'AUSPISTICE') then
                local auspistice=getMutualRelation(histfig1,histfig2,1)
                addNewRelationship(histfig1,auspistice,'AUSPISTICE',1)
                addNewRelationship(histfig2,auspistice,'AUSPISTICE',1)
            end
        else
            if adjustRelationship(histfig2,histfig1,2,0)>=100 then
                addNewRelationship(histfig1,histfig2,'KISMESIS',1)
            end
        end
    end
end

putnamEvents.enableEvent(putnamEvents.eventTypes.ON_RELATIONSHIP_UPDATE,20)

local function getDistance(pos1,pos2)
    return math.sqrt(((pos1.x*2)-(pos2.x*2))^2+((pos1.y*2)-(pos2.y*2))^2+((pos1.z*3)-(pos2.z*3))^2)
end

putnamEvents.onEmotion.troll_romance=function(unit,emotion)
    local thought=df.unit_thought_type[emotion.thought]
    if thought=='Argument' then
        local hist_fig=df.historical_figure.find(unit.hist_figure_id)
        local hist_fig2=df.historical_figure.find(df.unit.find(emotion.subthought).hist_figure_id)
        local isKismesisArgument,kismesisStrength=adjustRelationship(hist_fig,hist_fig2,'KISMESIS',1)
        if isKismesisArgument then
            dfhack.run_script('fortbent/add-thought','-thought','arguing with a kismesis','-emotion','AROUSAL','-severity',kismesisStrength*4,'-unit',unit.id) --http://goo.gl/8WOPP 
        end
        local auspistice=hasCustomRelationship(hist_fig,'AUSPISTICE')
        local auspistice2=hasCustomRelationship(hist_fig2,'AUSPISTICE')
        if auspistice==auspistice2 then
            if getDistance(df.unit.find(df.historical_figure.find(auspistice).unit_id).pos,unit.pos)<30 then
                dfhack.run_script('fortbent/add-thought','-thought','the soothing of an auspistice','-emotion','FONDNESS','-severity',50,'-unit',unit.id)
                dfhack.run_script('fortbent/add-thought','-thought','auspiticizing','-emotion','FONDNESS','-severity',20,'-unit',auspistice.unit_id)
            end
        end
    end
    if df.emotion_type.attrs[emotion.type].divider>0 and unit.status.current_soul.stress_level>1000 then
        local hist_fig=df.historical_figure.find(unit.hist_figure_id)
        local moirail=hasCustomRelationship(hist_fig,'MOIRAIL')
        if moirail then
            if getDistance(df.unit.find(df.historical_figure.find(moirail).unit_id).pos,unit.pos)<30 then
                dfhack.run_script('fortbent/add-thought','-thought','a feelings jam with the moirail','-emotion',getMoirailFeelingsJamEmotion(unit),'-severity',500,'-unit',unit.id)
            end
        end
    end
end

putnamEvents.enableEvent(putnamEvents.eventTypes.ON_EMOTION,10)