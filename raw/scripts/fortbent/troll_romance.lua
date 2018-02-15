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
        local list=self._native.parent.layer_objects[0]
        local page=math.floor(list.cursor/list.page_size)
        if math.floor(v.line/list.page_size)==page then 
            local bg=self._native.parent.layer_objects[0].cursor==v.line and COLOR_GREEN or v.str.color_bg
            dfhack.screen.paintString({fg=v.str.color_fg,bg=bg},52,(v.line%list.page_size)+3,v.str.name)
        end
    end
end

local custom_relation_types={}

custom_relation_types[413]={name='Moirail',color_fg=COLOR_LIGHTRED,color_bg=COLOR_BLACK}

custom_relation_types[612]={name='Kismesis',color_fg=COLOR_BLACK,color_bg=COLOR_GREY}

custom_relation_types[1025]={name='Auspistice',color_fg=COLOR_BLACK,color_bg=COLOR_WHITE} --actually screw that one but whatever.

custom_relation_types['MOIRAIL']=413

custom_relation_types['KISMESIS']=612

custom_relation_types['AUSPISTICE']=1025

function RelationsOverlay:onShow()
    if self._native.parent._type~=df.viewscreen_layer_unit_relationshipst then self:dismiss() return end
    local histfig=df.historical_figure.find(self._native.parent.unit.hist_figure_id)
    if not histfig.info or not histfig.info.relationships then self:dismiss() return end
    self.relationships=df.historical_figure.find(self._native.parent.unit.hist_figure_id).info.relationships.list
    if not self.relationships then self:dismiss() return end
    local overrideIds={}
    for k,relationship in ipairs(self.relationships) do
        for kk,relationship_type in ipairs(relationship.attitude) do --attitude is a vector of relationship types. The existing enum is not related to attitude's version.
            if custom_relation_types[relationship_type] then table.insert(overrideIds,{id=relationship.histfig_id,str=custom_relation_types[relationship_type]}) end
        end
    end
    self.overrides={}
    for k,relation_hf in ipairs(self._native.parent.relation_hf) do
        if relation_hf then
            for kk,histfig_link in ipairs(histfig.histfig_links) do
                if (df.histfig_hf_link_loverst:is_instance(histfig_link) or df.histfig_hf_link_spousest:is_instance(histfig_link)) and relation_hf.id==histfig_link.target_hf then
                    table.insert(self.overrides,{line=k,str={name='Matesprit',color_fg=COLOR_RED,color_bg=COLOR_BLACK}})
                end
            end
            for kk,overrideId in ipairs(overrideIds) do
                if relation_hf.id==overrideId.id then table.insert(self.overrides,{line=k,str=overrideId.str}) end
            end
        end
    end
end

viewscreenActions={}

viewscreenActions[df.viewscreen_layer_unit_relationshipst]=function()
    local relations=RelationsOverlay()
    relations:show()
end

dfhack.onStateChange.fortbent_troll_romance=function(code)
    if code==SC_VIEWSCREEN_CHANGED then
        local viewfunc=viewscreenActions[dfhack.gui.getCurViewscreen()._type]
        if viewfunc then viewfunc() end
    end
end

local putnamEvents=dfhack.script_environment('modtools/putnam_events')

local function hasCustomRelationship(histfig,relationship_type)
    local typeToLookFor=custom_relation_types[relationship_type]
    for k,v in ipairs(histfig.info.relationships.list) do
        for kk,vv in ipairs(v.attitude) do
            if vv==typeToLookFor then return v.histfig_id,v.rank[kk] end
        end
    end
    return false
end

local function addNewRelationship(histfig1,histfig2,relationship_type,value)
    for k,v in ipairs(histfig1.info.relationships.list) do
        if v.histfig_id==histfig2.id then
            v.attitude:insert('#',custom_relation_types[relationship_type])
            v.rank:insert('#',value)
            return true
        end
    end
    return false
end

local function removeRelationship(histfig1,histfig2,relationship_type)
    for k,v in ipairs(histfig1.info.relationships.list) do
        if v.histfig_id==histfig2.id then
            for kk,vv in ipairs(v.attitude) do
                if vv==relationship_type then 
                    vv=-relationship_type 
                    v.rank[kk]=-v.rank[kk] 
                    return true
                end
            end
        end
    end
    return false
end

local function adjustRelationship(histfig1,histfig2,relationship_type,value)
    local typeToLookFor=type(relationship_type)=='string' and custom_relation_types[relationship_type] or relationship_type
    for k,v in ipairs(histfig1.info.relationships.list) do
        if v.histfig_id==histfig2.id then
            for kk,vv in ipairs(v.attitude) do
                if vv==typeToLookFor then v.rank[kk]=v.rank[kk]+value return v.rank[kk] end
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
                for kkk,vvv in ipairs(v.attitude) do
                    if vvv==relationship_type then
                        total_relation_value=total_relation_value+v.rank[kkk]
                    end
                end
                for kkk,vvv in ipairs(vv.attitude) do
                    if vvv==relationship_type then
                        total_relation_value=total_relation_value+vv.rank[kkk]
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

local function getAllRelations(histfig,relationship_type)
    local relations={}
    for k,v in ipairs(histfig.info.relationships.list) do
        for kk,vv in ipairs(v.attitude) do
            if vv==relationship_type then table.insert(relations,df.historical_figure.find(v.histfig_id)) end
        end
    end
    return relations
end

local df_date={}

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

putnamEvents.onRelationshipUpdate.troll_romance=function(histfig1_id,histfig2_id,relationship_type,old_value,new_value)
    local histfig1=df.historical_figure.find(histfig1_id)
    local hasMoirailAlready=hasCustomRelationship(histfig1,'MOIRAIL')
    if not hasMoirailAlready and relationship_type==1 and new_value>=80 then
        local histfig2=df.historical_figure.find(histfig2_id)
        local unit1=df.unit.find(histfig1.unit_id)
        local hasLoverAlready=unit1.relationship_ids.Lover~=-1 or unit1.relationship_ids.Spouse~=-1
        if hasLoverAlready and unit1.relationship_ids.Lover~=histfig2.unit_id and unit1.relationship_ids.Spouse~=histfig2.unit_id and adjustRelationship(histfig2,histfig1,1,0)>=80 then
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

local function getDistance(pos1,pos2)
    return math.sqrt(((pos1.x*2)-(pos2.x*2))^2+((pos1.y*2)-(pos2.y*2))^2+((pos1.z*3)-(pos2.z*3))^2)
end

local function getMoirailFeelingsJamEmotion(unit)
    local traits=unit.status.current_soul.personality.traits
    local approved_traits={
        LOVE_PROPENSITY='LOVE',
        STRESS_VULNERABILITY='RELIEF',
        HOPEFUL='OPTIMISM',
        CHEER_PROPENSITY='GAIETY',
        GENERIC='EMPATHY',
        DUTIFULNESS='SATISFACTION',
        FRIENDLINESS='TENDERNESS',
        PRIDE='PRIDE' --wowee we're getting into uncharted territory
    }
    local approved_inverse_traits={
        CHEER_PROPENSITY='GRATITUDE',
        STRESS_VULNERABILITY='EXCITEMENT'
    }
    local maxSoFar=0
    local bestTrait='GENERIC'
    local inverse=false
    for k,v in pairs(traits) do
        if (v>maxSoFar and approved_traits[k]) or (100-v>maxSoFar and approved_inverse_traits[k]) then
            if (100-v)>maxSoFar then
                maxSoFar=100-v
                bestTrait=k
                inverse=true
            else
                maxSoFar=v
                bestTrait=k
                inverse=false
            end
        end
    end
    return inverse and approved_inverse_traits[bestTrait] or approved_traits[bestTrait] or 'EMPATHY'
end

function getMoirailCompatibility(unit1,unit2)
    local personality1=unit1.status.current_soul.personality.traits
    local personality2=unit2.status.current_soul.personality.traits
    local compatibility=0
    compatibility=compatibility+(math.abs(personality1.CHEER_PROPENSITY-personality2.CHEER_PROPENSITY))
    compatibility=compatibility+(math.abs(personality1.DEPRESSION_PROPENSITY-personality2.DEPRESSION_PROPENSITY))
    compatibility=compatibility+(math.abs(personality1.ANGER_PROPENSITY-personality2.ANGER_PROPENSITY))
    compatibility=compatibility+(math.abs(personality1.ANXIETY_PROPENSITY-personality2.ANXIETY_PROPENSITY))
    compatibility=compatibility+(math.abs(personality1.STRESS_VULNERABILITY-personality2.STRESS_VULNERABILITY))
    compatibility=compatibility+(math.abs(personality1.VIOLENT-personality2.VIOLENT))
    compatibility=compatibility+(math.abs(personality1.CONFIDENCE-personality2.CONFIDENCE))
    compatibility=compatibility+(100-math.abs(personality1.HOPEFUL-personality2.HOPEFUL))
    compatibility=compatibility+(math.abs(personality1.BASHFUL-personality2.BASHFUL))
    compatibility=compatibility+(math.abs(personality1.IMAGINATION-personality2.IMAGINATION))
    return compatibility/1000
end

function getKismesisCompatibility(unit1,unit2)
    local personality1=unit1.status.current_soul.personality.traits
    local personality2=unit2.status.current_soul.personality.traits
    local compatibility=0
    compatibility=compatibility+(math.abs(personality1.CHEER_PROPENSITY-personality2.CHEER_PROPENSITY))
    compatibility=compatibility+(math.abs(personality1.ANGER_PROPENSITY-personality2.ANGER_PROPENSITY))
    compatibility=compatibility+(math.abs(personality1.HOPEFUL-personality2.HOPEFUL))
    compatibility=compatibility+(math.abs(personality1.BASHFUL-personality2.BASHFUL))
    compatibility=compatibility+(math.abs(personality1.EXCITEMENT_SEEKING-personality2.EXCITEMENT_SEEKING))
    compatibility=compatibility+(math.abs(personality1.ASSERTIVENESS-personality2.ASSERTIVENESS))
    compatibility=compatibility+(math.abs(personality1.FRIENDLINESS-personality2.FRIENDLINESS))
    compatibility=compatibility+(math.abs(personality1.GREGARIOUSNESS-personality2.GREGARIOUSNESS))
    compatibility=compatibility+(math.abs(personality1.GRATITUDE-personality2.GRATITUDE))
    compatibility=compatibility+(math.abs(personality1.TRUST-personality2.TRUST))
    compatibility=compatibility+(math.abs(personality1.THOUGHTLESSNESS-personality2.THOUGHTLESSNESS))
    compatibility=compatibility+(math.abs(personality1.DUTIFULNESS-personality2.DUTIFULNESS))
    compatibility=compatibility+(math.abs(personality1.ALTRUISM-personality2.ALTRUISM))
    return compatibility/1300
end

function hasHadThoughtRecently(unit,thought,howRecently)
    local cur_date={year=df.global.cur_year,year_tick=df.global.cur_year_tick}
    setmetatable(cur_date,df_date)
    for k,unit_thought in ipairs(unit.status.current_soul.personality.emotions) do
        local thought_date={year=unit_thought.year,year_tick=unit_thought.year_tick}
        setmetatable(thought_date,df_date)
        local date_difference=cur_date-thought_date
        if (date_difference.year*403200+date_difference.year_tick)<howRecently then
            if df.unit_thought_type[unit_thought.thought]==thought then
                return true
            elseif df.unit_thought_type[unit_thought.thought]=='Syndrome' then
                if df.syndrome.find(unit_thought.subthought).syn_name==thought then return true end
            end
        end
    end
end

putnamEvents.onEmotion.troll_romance=function(unit,emotion)
    local thought=df.unit_thought_type[emotion.thought]
    if unit.hist_figure_id<0 then return end
    local histfig=df.historical_figure.find(unit.hist_figure_id)
    if not histfig or not histfig.info or not histfig.info.relationships then return end
    if thought=='Argument' then
        if emotion.subthought~=-1 and df.historical_figure.find(emotion.subthought) then
            local histfig2=df.historical_figure.find(emotion.subthought)
            local isKismesisArgument,kismesisStrength=adjustRelationship(histfig,histfig2,'KISMESIS',1)
            if isKismesisArgument then
                dfhack.run_script('add-thought','-thought','arguing with a kismesis','-emotion','AROUSAL','-severity',kismesisStrength*4,'-unit',unit.id) --http://goo.gl/8WOPP 
            end
        end
    end
    if thought=='Talked' and df.emotion_type.attrs[emotion.type].divider<0 then
        local hasMoirailAlready=hasCustomRelationship(histfig,'MOIRAIL')
        local rng=dfhack.random.new()
        local loverId=unit.relationship_ids.Lover~=-1 and (df.unit.find(unit.relationship_ids.Lover) and df.unit.find(unit.relationship_ids.Lover).hist_figure_id or false) or (unit.relationship_ids.Spouse~=-1 and df.unit.find(unit.relationship_ids.Spouse) and df.unit.find(unit.relationship_ids.Spouse).hist_figure_id) or nil
        if loverId==hasMoirailAlready then
            hasMoirailAlready=false 
            local loverFig=df.historical_figure.find(loverId)
            removeRelationship(histfig,loverFig,'MOIRAIL') 
            removeRelationship(loverFig,histfig,'MOIRAIL') 
        end
        if not hasMoirailAlready and rng:drandom0()<0.1 then
            local moirailPropensity=(unit.status.current_soul.personality.traits.GREGARIOUSNESS+unit.status.current_soul.personality.traits.LOVE_PROPENSITY+unit.status.current_soul.personality.traits.FRIENDLINESS+(100-unit.status.current_soul.personality.traits.DISDAIN_ADVICE)+(100-unit.status.current_soul.personality.traits.DISCORD))/500 --what a line
            local friends=getAllRelations(histfig,1)
            for k,friend_hf in ipairs(friends) do
                local friend=df.unit.find(friend_hf.unit_id)
                local friendHasMoirailAlready=hasCustomRelationship(friend_hf,'MOIRAIL')
                if friend and not hasMoirailAlready and not friendHasMoirailAlready and not (friend_hf.id==loverId) and getDistance(unit.pos,friend.pos)<30 then
                    local moirailCompatibility=getMoirailCompatibility(unit,friend)
                    local friendMoirailPropensity=(friend.status.current_soul.personality.traits.GREGARIOUSNESS+friend.status.current_soul.personality.traits.LOVE_PROPENSITY+friend.status.current_soul.personality.traits.FRIENDLINESS+(100-friend.status.current_soul.personality.traits.DISDAIN_ADVICE)+(100-friend.status.current_soul.personality.traits.DISCORD))/500
                    if rng:drandom0()<moirailCompatibility*((moirailPropensity+friendMoirailPropensity)/2) then
                        addNewRelationship(histfig,df.historical_figure.find(friend.hist_figure_id),'MOIRAIL',1)
                        addNewRelationship(df.historical_figure.find(friend.hist_figure_id),histfig,'MOIRAIL',1)
                        hasMoirailAlready=true
                    end
                end
            end
        end
    elseif df.emotion_type.attrs[emotion.type].divider>0 then
        if unit.status.current_soul.personality.stress_level>1000 then
            local moirail=hasCustomRelationship(histfig,'MOIRAIL')
            if moirail then
                local moirailUnit=df.unit.find(df.historical_figure.find(moirail).unit_id)
                if getDistance(moirailUnit.pos,unit.pos)<30 and not hasHadThoughtRecently(unit,'a feelings jam with the moirail',4800) and not hasHadThoughtRecently(moirailUnit,'a feelings jam with the moirail',4800) then
                    dfhack.run_script('add-thought','-thought','a feelings jam with the moirail','-emotion',getMoirailFeelingsJamEmotion(unit),'-severity',500,'-unit',unit.id)
                    dfhack.run_script('add-thought','-thought','a feelings jam with the moirail','-emotion',getMoirailFeelingsJamEmotion(moirailUnit),'-severity',500,'-unit',moirailUnit.id)
                end
            end
        end
        if thought=='Talked' then
            local hasKismesisAlready=hasCustomRelationship(histfig,'KISMESIS')
            local rng=dfhack.random.new()
            if rng:drandom0()<0.1 then
                local grudges=getAllRelations(histfig,2)
                for k,grudge_hf in ipairs(grudges) do
                    local grudge=df.unit.find(grudge_hf.unit_id)
                    local grudgeHasKismesisAlready=hasCustomRelationship(grudge_hf,'KISMESIS')
                    if getDistance(unit.pos,grudge.pos)<30 then
                        if not (hasKismesisAlready or grudgeHasKismesisAlready) then
                            local kismesisCompatibility=getKismesisCompatibility(unit,grudge)
                            if rng:drandom0()<kismesisCompatibility*((unit.status.current_soul.personality.traits.HATE_PROPENSITY+grudge.status.current_soul.personality.traits.HATE_PROPENSITY)/2) then
                                --isn't the fact that HATE_PROPENSITY is already a thing just wonderful
                                addNewRelationship(histfig,df.historical_figure.find(grudge.hist_figure_id),'KISMESIS',1)
                                addNewRelationship(df.historical_figure.find(grudge.hist_figure_id),histfig,'KISMESIS',1)
                                hasKismesisAlready=true
                            end
                        else
                            local auspistice=hasCustomRelationship(histfig,'AUSPISTICE')
                            if not auspistice and not auspistice2 and (hasCustomRelationship(histfig,'KISMESIS') or hasCustomRelationship(grudge_hf,'KISMESIS')) then
                                local auspisticeID=getMutualRelation(histfig,grudge_hf,1)
                                local auspistice=df.historical_figure.find(auspisticeID)
                                addNewRelationship(histfig,auspistice,'AUSPISTICE',1)
                                addNewRelationship(grudge_hf,auspistice,'AUSPISTICE',1)
                            else
                                local auspistice2=hasCustomRelationship(grudge_hf,'AUSPISTICE')
                                if auspistice and auspistice==auspistice2 then
                                    if getDistance(df.unit.find(df.historical_figure.find(auspistice).unit_id).pos,unit.pos)<30 then
                                        dfhack.run_script('add-thought','-thought','the soothing of an auspistice','-emotion','FONDNESS','-severity',50,'-unit',unit.id)
                                        dfhack.run_script('add-thought','-thought','auspiticizing','-emotion','FONDNESS','-severity',20,'-unit',df.historical_figure.find(auspistice).unit_id)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

putnamEvents.enableEvent(putnamEvents.eventTypes.ON_EMOTION,2)