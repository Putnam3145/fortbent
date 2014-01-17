# Show syndromes affecting units and the remaining and maximum duration (v3). Call with help on the command line for further options.

def print_help()
	puts "Use one or more of the following options:"
	puts "    showall: Show units even if not affected by any syndrome"
	puts "    showeffects: shows detailed effects of each syndrome"
	puts "    showdisplayeffects: show effects that only change the look of the unit"
	puts "    ignorehiddencurse: Hides syndomes the user should not be able to know about (TODO)"	
	puts "    selected: Show selected unit"
	puts "    dwarves: Show dwarves"
	puts "    livestock: Show livestock"
	puts "    wildanimals: Show wild animals"
	puts "    hostile: Show hostiles (e.g. invaders, thieves, forgeten beasts etc)"
	puts "    world: Show all defined syndromes in the world"
	puts "    export:<filename> Write the output to a file instead of the console."
	puts ""
	puts "Will show all syndromes affecting each units with the maximum and present duration."
end

class Output
	attr_accessor :fileLogger, :indent_level
	  
	def initialize(filename)
		indent_level = ""
		if filename==nil
			@fileLogger = nil
		else
			@fileLogger = File.new(filename + ".html", "w")
			@fileLogger.puts("<html><body>")	
		end
	end	  
	
	RED = "red"
	GREEN = "green"
	DEFAULT = "black"
	HIGHLIGHT = "black\" size=\"+1"
	
	def colorize(text, color_code)
	  "<font color=\"#{color_code}\">#{text}</font>"
	end
	
	def indent()
		if @fileLogger == nil	
			@indent_level = "#{@indent_level} - "
		else
			@fileLogger.puts("<ul>")
		end
	end
	
	def unindent()
		if @fileLogger == nil	
			@indent_level = @indent_level.chomp(" - ")
		else
			@fileLogger.puts("</ul>")
		end
	end	
	
	def break()
		if @fileLogger == nil	
			puts("\n")
		else
			@fileLogger.puts("</br>")
		end
	end
	
	def close()
		if @fileLogger != nil	
			@fileLogger.puts("</body></html>")	
			@fileLogger.flush
			@fileLogger.close
			@fileLogger = nil
		end
	end
	
	def log(text, color=nil)
		if @fileLogger == nil
			puts("#{@indent_level}#{text}")
		elsif color==nil
			@fileLogger.puts(text+"<br/>")		
		elsif @indent_level == ""
			@fileLogger.puts(colorize(text, color))	
		else
			@fileLogger.puts("<li>" + colorize(text, color)+"</li>")	
		end
	end
end

def colorize(text, color_code)
  "<font color=\"#{color_code}\">#{text}</font>"
end

def get_mental_att(att_index)

	# TODO: Surly i can use the names from MentalAttributeType somehow!!!!!
	# case att_index
        # when "ANALYTICAL_ABILITY"
		# return "Analytical Ability"
        # when "FOCUS"
		# return "Focus"
		# when "WILLPOWER"
		# return "Willpower"
		# when "CREATIVITY"
		# return "Creativity"
		# when "INTUITION"
		# return "Intuition"
		# when "PATIENCE"
		# return "Patience"
		# when "MEMORY"
		# return "Memory"
		# when "LINGUISTIC_ABILITY"
		# return "Linguistics"
		# when "SPATIAL_SENSE"
		# return "Spacial Sense"
		# when "MUSICALITY"
		# return "Musicality"
		# when "KINESTHETIC_SENSE"
		# return "Kinestetic Sense"
		# when "EMPATHY"
		# return "Empathy"
		# when "SOCIAL_AWARENESS"
		# return "Social Awareness"
	# end

	case att_index
        when 0
		return "Analytical Ability"
        when 1
		return "Focus"
		when 2
		return "Willpower"
		when 3
		return "Creativity"
		when 4
		return "Intuition"
		when 5
		return "Patience"
		when 6
		return "Memory"
		when 7
		return "Linguistics"
		when 8
		return "Spacial Sense"
		when 9
		return "Musicality"
		when 10
		return "Kinestetic Sense"
		when 11
		return "Empathy"
		when 12
		return "Social Awareness"
		else
		return "Unknown"
	end
end

def get_physical_att(att_index)

	# TODO: Surly i can use the names from PhysicalAttributeType somehow!!!!!
	# case att
        # when "STRENGTH"
		# return "Strength"
		# when "AGILITY"
		# return "Agility"
		# when "TOUGHNESS"
		# return "Toughness"
		# when "ENDURANCE"
		# return "Endurance"
		# when "RECUPERATION"
		# return "Recuperation"
		# when "DISEASE_RESISTANCE"
		# return "Disease Resistance"
	# end
	
	case att_index
        when 0
		return "Strength"
		when 1
		return "Agility"
		when 2
		return "Toughness"
		when 3
		return "Endurance"
		when 4
		return "Recuperation"
		when 5
		return "Disease Resistance"
		else
		return "Unknown"
	end
end 

def get_effect_target(target)

	values = []			
			
	limit = target.key.length - 1
	for i in (0..limit)
	
		if(target.mode[i].to_s() != "")		
		
			case target.mode[i].to_s()
				when "BY_TYPE"
				item = "Type("
				when "BY_TOKEN"
				item = "Token("
				when "BY_CATEGORY"
				item = "Category("
			end
					
			if(target.key[i].to_s()!="")
				item = item + target.key[i].to_s()
			end
				
			if(target.key[i].to_s()!="" and target.tissue[i].to_s()!="")
				item = item + ":"
			end
				
			if(target.tissue[i].to_s()!="")
				item = item + target.tissue[i].to_s()
			end
			
			item = item + ")"
			
			values.push(item)
		end
		
	end	
	
	if values.length == 0 
		return ""
	else
		return " Target=" + values.join(", ")
	end
end

def get_att_pairs(values, percents, physical)

	items = []
	
	color = Output::DEFAULT	
	
	limit = values.length - 1	
	for i in (0..limit)					
		if (values[i]!=0 or percents[i]!=100)
			
			if physical
				item = "#{get_physical_att(i)}("
			else
				item = "#{get_mental_att(i)}("
			end
		
			if(values[i]!=0)
				item = item + "%+d" % values[i]
			end			
			
			if (values[i]!=0 and percents[i]!=100)
				item = item + ", "
			end
			
			if (percents[i]!=100)
				item = item + "%d" % percents[i] + "%"
			end
			
			item = item + ")"
		
			if values[i] >0 && percents[i] >100
				color = Output::GREEN
			elsif values[i] <0 || percents[i] <100
				color = Output::RED		
			end
		
			items.push(item)
		end
	end
	
	return items.join(", "), color 
end

def get_interaction(interaction)

	# name, USAGE_HINT, range, wait period are probally all we really want to show.

	#result = "a=#{interaction.unk_6c} b=#{interaction.unk_7c} c=#{interaction.unk_8c} d=#{interaction.unk_a8} e=#{interaction.unk_c4} f=#{interaction.unk_e4} "
	#result = result + "g=#{interaction.unk_e0} h=#{interaction.unk_e4} i=#{interaction.unk_100} j=#{interaction.unk_11c} k=#{interaction.unk_138} l=#{interaction.unk_154} "
	#result = result + "m=#{interaction.unk_170} n=#{interaction.unk_18c} o=#{interaction.unk_1a8} p=#{interaction.unk_1c4} q=#{interaction.unk_1e8} r=#{interaction.unk_25c} "
	#result = result + "s=#{interaction.unk_278}"
		
	return "Ability=#{interaction.unk_25c}, Delay=#{interaction.unk_278}"
end

def get_effect_flags(flags)

	values = []
	
	if(flags.SIZE_DELAYS) then values.push("Size Delays") end
	if(flags.SIZE_DILUTES) then values.push("Size Dilutes") end
	if(flags.VASCULAR_ONLY) then values.push("Vascular Only") end
	if(flags.MUSCULAR_ONLY) then values.push("Musles Only") end
	if(flags.RESISTABLE) then values.push("Resistable") end
	if(flags.LOCALIZED) then values.push("Localized") end	

	return values.join(",")
end

def get_tag1_flags(flags, add)
    
	values = []
	
	good = false
	bad = false
	
	if add
		good_color = Output::GREEN
		bad_color = Output::RED
	else
		good_color = Output::RED
		bad_color = Output::GREEN	
	end
	
	if(flags.EXTRAVISION) 
		values.push(colorize("Extravision", good_color)) 
		good = true 
	end
	
	if(flags.OPPOSED_TO_LIFE) 
		values.push(colorize("Attack the living", bad_color)) 
		bad = true 
	end
	
	if(flags.NOT_LIVING) 
		values.push(colorize("Undead", Output::DEFAULT)) 
	end  
	
	if(flags.NOEXERT) 
		values.push(colorize("Does not tire", good_color))
		good = true 
	end
	
	if(flags.NOPAIN) 
		values.push(colorize("Does not feel pain", good_color)) 
		good = true 
	end
	
	if(flags.NOBREATHE) 
		values.push(colorize("Does not breathe", good_color)) 
		good = true 
	end
	
	if(flags.HAS_BLOOD) 
		values.push(colorize("Has blood", Output::DEFAULT)) 
	end
	
	if(flags.NOSTUN) 
		values.push(colorize("Can't be stunned", good_color))
		good = true  
	end
	
	if(flags.NONAUSEA) 
		values.push(colorize("Does not get nausea", good_color)) 
		good = true 
	end
	
	if(flags.NO_DIZZINESS) 
		values.push(colorize("Does not get dizzy", good_color)) 
		good = true 
	end
	
	if(flags.NO_FEVERS) 
		values.push(colorize("Does not get fever", good_color)) 
		good = true 
	end
	
	if(flags.TRANCES) 
		values.push(colorize("Can enter trance", good_color)) 
		good = true 
	end
	
	if(flags.NOEMOTION) 
		values.push(colorize("Feels no emotion", good_color)) 
		good = true 
	end
	
	if(flags.LIKES_FIGHTING) 
		values.push(colorize("Like fighting", Output::DEFAULT)) 
	end
	
	if(flags.PARALYZEIMMUNE) 
		values.push(colorize("Can't be paralazed", good_color)) 
		good = true 
	end
	if(flags.NOFEAR) 
		values.push(colorize("Does not feel fear", good_color)) 
		good = true 
	end
	
	if(flags.NO_EAT) 
		values.push(colorize("Does not eat", good_color)) 
		good = true 
	end
	
	if(flags.NO_DRINK) 
		values.push(colorize("Does not drink", good_color))
		good = true  
	end
	
	if(flags.NO_SLEEP) 
		values.push(colorize("Does not sleep", good_color)) 
		good = true 
	end
	if(flags.MISCHIEVOUS) 
		values.push(colorize("Mischievous", Output::DEFAULT)) 
	end
	
	if(flags.NO_PHYS_ATT_GAIN) 
		values.push(colorize("Physical stats cant improve", good_color)) 
		good = true 
	end
	
	if(flags.NO_PHYS_ATT_RUST) 
		values.push(colorize("Physical stats do not rust", good_color)) 
		good = true 
	end
	
	if(flags.NOTHOUGHT) 
		values.push(colorize("Stupid", bad_color)) 
		bad = true 
	end
	
	if(flags.NO_THOUGHT_CENTER_FOR_MOVEMENT) 
		values.push(colorize("No brain needed to move", good_color)) 
		good = true 
	end
	
	if(flags.CAN_SPEAK) 
		values.push(colorize("Can speak", good_color)) 
		good = true 
	end
	
	if(flags.CAN_LEARN) 
		values.push(colorize("Can learn", good_color)) 
		good = true 
	end
	
	if(flags.UTTERANCES)
		values.push(colorize("Utterances", Output::DEFAULT)) 
	end
	
	if(flags.CRAZED) 
		values.push(colorize("Crazed", bad_color)) 
		bad = true 
	end
	
	if(flags.BLOODSUCKER) 
		values.push(colorize("Drinks Blood", bad_color)) 
		bad = true 
	end
	
	if(flags.NO_CONNECTIONS_FOR_MOVEMENT) 
		values.push(colorize("Can move without nerves", good_color)) 
		good = true 
	end
	
	if(flags.SUPERNATURAL) 
		values.push(colorize("Supernatural", good_color)) 
		good = true 
	end
	
	if add
		if bad
			color = Output::RED
		elsif good
			color = Output::GREEN
		else
			color = Output::DEFAULT
		end
	else
		if good
			color = Output::RED
		elsif bad
			color = Output::GREEN
		else
			color = Output::DEFAULT
		end
	end
	
	return values.join(","), color
end

def get_tag2_flags(flags, add)
	values = []
	
	good = false
	bad = false
	
	if add
		good_color = Output::GREEN
		bad_color = Output::RED
	else
		good_color = Output::RED
		bad_color = Output::GREEN	
	end
	
	if(flags.NO_AGING) 
		good = true
		values.push(colorize("Does not age", good_color))  
	end
	
	if(flags.MORTAL) 
		bad = true
		values.push(colorize("Mortal", bad_color)) 
	end
	
	if(flags.STERILE) 		
		values.push(colorize("Can't have children", Output::DEFAULT))  
	end
	
	if(flags.FIT_FOR_ANIMATION) 
		values.push(colorize("Can be animated", Output::DEFAULT)) 
	end
	
	if(flags.FIT_FOR_RESURRECTION) 
		good = true
		values.push(colorize("Can be resurected", Output::DEFAULT)) 
	end		
		
	if add
		if bad
			color = Output::RED
		elsif good
			color = Output::GREEN
		else
			color = Output::DEFAULT
		end
	else
		if good
			color = Output::RED
		elsif bad
			color = Output::GREEN
		else
			color = Output::DEFAULT
		end
	end
		
	return values.join(","), color
end

def get_effect(ce, duration, showdisplayeffects)
				
	flags = get_effect_flags(ce.flags)
	if flags != ""
		flags = " (#{flags})"	
	end

	if ce.end == -1 
		duration = " [Permanent]"
	elsif ce.start >= ce.peak or ce.peak <= 1
		duration = " [#{ce.start}-#{ce.end}]"
	else
		duration = " [#{ce.start}-#{ce.peak}-#{ce.end}]"	
	end		
	
	case ce.getType().to_s()
	when "PAIN"
		name = "Pain"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "SWELLING"
		name = "Swelling"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "OOZING"
		name = "Oozing"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "BRUISING"
		name = "Bruising"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "BLISTERS"	
		name = "Blisters"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "NUMBNESS"
		name = "Numbness"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::GREEN
	when "PARALYSIS"
		name = "Paralysis"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "FEVER"
		name = "Fever"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "BLEEDING"
		name = "Bleeding"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "COUGH_BLOOD"
		name = "Cough Blood"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "VOMIT_BLOOD"
		name = "Vomit Blood"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "NAUSEA"
		name = "Nausea"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "UNCONSCIOUSNESS"
		name = "Unconsciousness"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "NECROSIS"	
		name = "Necrosis"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "IMPAIR_FUNCTION"
		name = "Impairs"
		desc = "Power=#{ce.sev}#{get_effect_target(ce.target)}"
		color = Output::RED
	when "DROWSINESS"
		name = "Drowsiness"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "DIZZINESS"
		name = "Dizziness"
		desc = "Power=#{ce.sev}"
		color = Output::RED
	when "ADD_TAG"
		name = "Add"
		tags1 = get_tag1_flags(ce.tags1, true)
		tags2 = get_tag2_flags(ce.tags2, true)		
		desc = "#{tags1[0]},#{tags2[0]}"
		
		if tags1[1] == Output::RED || tags2[1] == Output::RED
			color = Output::RED
		elsif tags1[1] == Output::GREEN || tags2[1] == Output::GREEN
			color = Output::GREEN	
		else		
			color = Output::DEFAULT	
		end
	when "REMOVE_TAG"
		name = "Remove"
		tags1 = get_tag1_flags(ce.tags1, true)
		tags2 = get_tag2_flags(ce.tags2, true)		
		desc = "#{tags1[0]},#{tags2[0]}"
		
		if tags1[1] == Output::RED || tags2[1] == Output::RED
			color = Output::RED
		elsif tags1[1] == Output::GREEN || tags2[1] == Output::GREEN
			color = Output::GREEN	
		else		
			color = Output::DEFAULT	
		end	
	when "DISPLAY_TILE"
		if !showdisplayeffects then return "", Output::DEFAULT end	
		name = "Tile"
		desc = "Tile=#{ce.unk_6c}, Colour=#{ce.unk_70}"	
		color = Output::DEFAULT		
	when "FLASH_TILE"
		if !showdisplayeffects then return "", Output::DEFAULT end	
		name = "Flash"		
		color = ce.sym_color >> 8		
		tile = ce.sym_color - (color * 256)
		desc = "Tile = #{tile} Colour=#{color} Time=#{ce.period} Period=#{ce.time}"	
		color = Output::DEFAULT		
	when "SPEED_CHANGE"	
		name = "Physical"
		desc = "Speed("

		if(ce.unk_6c!=0)
			desc = desc + "%+d" % ce.unk_6c
		end			
		
		if (ce.unk_6c!=0 and ce.unk_70!=100)
			desc = desc + ", "
		end
		
		if (ce.unk_70!=100)
			desc = desc + "%d" % ce.unk_70 + "%"
		end
		
		desc = desc + ")"	

		if ce.unk_6c >=0 && ce.unk_70 >=100
			color = Output::GREEN
		else
			color = Output::RED		
		end
		
	when "CAN_DO_INTERACTION"
		name = "Add Interaction"
		desc = "#{get_interaction(ce)}"	
		color = Output::GREEN		
	when "SKILL_ROLL_ADJUST"
		name = "Skill Check"
		desc = "Percent=#{ce.unk_6c}, Chance=#{ce.unk_70}%"	
		
		if ce.unk_6c >=100
			color = Output::GREEN
		else
			color = Output::RED		
		end
		
	when "BODY_TRANSFORMATION"
		name = "Transformation"
		if ce.caste_str != "DEFAULT"
			caste = ", Caste=#{ce.caste_str}"
		else
			caste = ""
		end
		
		if ce.unk_6c > 0
			chance = "Chance=#{ce.unk_6c} "
		else
			chance = ""
		end
		
		desc = "#{chance}Race=#{ce.race_str}#{caste}"	
		color = Output::DEFAULT		
	when "PHYS_ATT_CHANGE"
		name = "Physical"
		data = get_att_pairs(ce.phys_att_unk, ce.phys_att_perc, true)
		desc = data[0]
		color = data[1]
	when "MENT_ATT_CHANGE"
		name = "Mental"
		data = get_att_pairs(ce.ment_att_unk, ce.ment_att_perc, false)
		desc = data[0]
		color = data[1]	
	when "MATERIAL_FORCE_MULTIPLIER"
		# Material reference + top/bottom number of a fraction
		name = "Material Force Multiplier"
		desc = "a=#{ce.unk_6c}, b=#{ce.unk_88}, c=#{ce.unk_a4}, d=#{ce.unk_c0}, e=#{ce.unk_c4}, f=#{ce.unk_c8}, g=#{ce.unk_cc}"
		color = Output::DEFAULT				
	when "BODY_MAT_INTERACTION"
		# interactionId, SundromeTriggerType
		name = "Body Material Interaction"
		desc = "a=#{ce.unk_6c}, b=#{ce.unk_88}, c=#{ce.unk_8c}, d=#{ce.unk_90}, e=#{ce.unk_94}"	
		color = Output::DEFAULT		
	when "BODY_APPEARANCE_MODIFIER"
		if !showdisplayeffects then return "", Output::DEFAULT end	
		# !!! seems to be missing info class !!!
		# should be enum and value
		name = "Body Appearence"
		desc = "<TODO>"
		color = Output::DEFAULT		
	when "BP_APPEARANCE_MODIFIER"	
		if !showdisplayeffects then return "", Output::DEFAULT end	
		name = "Body Part Appearence"
		desc = "Value=#{ce.value} change_type_enum?=#{ce.unk_6c}#{get_effect_target(ce.target)}"
		color = Output::DEFAULT		
	when "DISPLAY_NAME"
		if !showdisplayeffects then return "", Output::DEFAULT end	
		name = "Set Display Name"
		desc = "#{ce.name}"
		color = Output::DEFAULT		
	else
		name = "Unknown effect type"
		color = Output::HIGHLIGHT		
	end
	
	return "#{name}#{duration}#{flags} #{desc}", color
end

print_syndrome = lambda { |logger, syndrome, showeffects, showdisplayeffects|  
	rawsyndrome = df.world.raws.syndromes.all[syndrome.type]					
	duration = rawsyndrome.ce.minmax_by{ |ce| ce.end }
							
	if duration[0].end == -1
		durationStr = "Permanent"
	else
		if duration[0].end == duration[1].end
			durationStr = "#{syndrome.ticks} of #{duration[0].end}"
		else
			durationStr = "#{syndrome.ticks} of #{duration[0].end}-#{duration[1].end}"				
		end
	end
		
	effects = rawsyndrome.ce.collect { |effect| get_effect(effect, syndrome.ticks, showdisplayeffects) }
	
	if effects.any?{ |text, color| color==Output::RED }
		color = Output::RED
	elsif effects.any?{|text, color| color==Output::GREEN }
		color = Output::GREEN
	else
		color = Output::DEFAULT
	end		
	
	name = rawsyndrome.syn_name == "" ? "mystery" : rawsyndrome.syn_name
	
	logger.indent()
	logger.log "#{name} [#{durationStr}]", color
	
	if showeffects
		logger.indent()
		effects.each{ |text, color| if text!="" then logger.log text, color end }
		logger.unindent()
	end	
	logger.unindent()
}

print_syndromes = lambda { |logger, unit, showrace, showall, showeffects, showhiddencurse, showdisplayeffects|

	if showhiddencurse
		syndromes = unit.syndromes.active
	else 
		syndromes = unit.syndromes.active
		# TODO: syndromes = unit.syndromes.active.select{ |s| visible_syndrome?(unit, s) }
	end

	if !syndromes.empty? or showall 
		if showrace	
			logger.log "#{df.world.raws.creatures.all[unit.race].name[0]}#{unit.name == '' ? "" : ": "}#{unit.name}", Output::HIGHLIGHT
		else
			logger.log "#{unit.name}", Output::HIGHLIGHT
		end
	end
	
	syndromes.each { |syndrome| print_syndrome[logger, syndrome, showeffects, showdisplayeffects] }
}



print_raw_syndrome = lambda { |logger, rawsyndrome, showeffects, showdisplayeffects|  				
		
	effects = rawsyndrome.ce.collect { |effect| get_effect(effect, 0, showdisplayeffects) }
	
	if effects.any?{ |item| item[1]==Output::RED }
		color = Output::RED
	elsif effects.any?{|item| item[1]==Output::GREEN }
		color = Output::GREEN
	else
		color = Output::DEFAULT
	end		
	
	name = rawsyndrome.syn_name == "" ? "mystery" : rawsyndrome.syn_name
	
	logger.indent()
	logger.log name, color
	
	if showeffects		
		logger.indent()
		effects.each{ |text, color| if text!="" then logger.log text, color end }
		logger.unindent()
	end	
	logger.unindent()
}

def starts_with?(str, prefix)
  prefix = prefix.to_s
  str[0, prefix.length] == prefix
end

showall = false
showeffects = false
selected = false
dwarves = false
livestock = false
wildanimals = false
hostile = false
world = false
showhiddencurse = false
showdisplayeffects = false
	
if $script_args.any?{ |arg| arg == "help" or arg == "?" or arg == "-?" }
	print_help()
elsif $script_args.empty?
	dwarves = true
	showeffects = true
else	
	if $script_args.any?{ |arg| arg == "showall" } then showall=true end
	if $script_args.any?{ |arg| arg == "showeffects" } then showeffects=true end
	if $script_args.any?{ |arg| arg == "ignorehiddencurse" } then showhiddencurse=true end
	if $script_args.any?{ |arg| arg == "showdisplayeffects" } then showdisplayeffects=true end
	if $script_args.any?{ |arg| arg == "selected" } then selected=true end
	if $script_args.any?{ |arg| arg == "dwarves" } then dwarves=true end
	if $script_args.any?{ |arg| arg == "livestock" } then livestock=true end
	if $script_args.any?{ |arg| arg == "wildanimals" } then wildanimals=true end
	if $script_args.any?{ |arg| arg == "hostile" } then hostile=true end
	if $script_args.any?{ |arg| arg == "world" } then world=true end
	if $script_args.any?{ |arg| starts_with?(arg, "export:") }  
		exportfile = $script_args.find{ |arg| starts_with?(arg, "export:") }.gsub("export:", "")
		export=true 
	end	
end

if export
	logger = Output.new(exportfile)
else
	logger = Output.new(nil)
end
	
if selected 
	print_syndromes[logger, df.unit_find(), true, showall, showeffects, showhiddencurse, showdisplayeffects]
	logger.break()
end
	
if dwarves 
	logger.log "Dwarves", Output::HIGHLIGHT
	df.unit_citizens.each { |unit|
		print_syndromes[logger, unit, false, showall, showeffects, showhiddencurse, showdisplayeffects]
	}
	logger.break()
end

if livestock
	logger.log "LiveStock", Output::HIGHLIGHT
	df.world.units.active.find_all { |u| df.unit_category(u) == :Livestock }.each { |unit|
		print_syndromes[logger, unit, true, showall, showeffects, showhiddencurse, showdisplayeffects]
	}
	logger.break()
end

if wildanimals
	logger.log "Wild Animals", Output::HIGHLIGHT
	df.world.units.active.find_all { |u| df.unit_category(u) == :Other and  df.unit_other_category(u) == :Wild }.each { |unit|
		print_syndromes[logger, unit, true, showall, showeffects, showhiddencurse, showdisplayeffects]
	}
	logger.break()
end

if hostile 
	logger.log "Hostile Units", Output::HIGHLIGHT
	df.unit_hostiles.each { |unit|
		print_syndromes[logger, unit, true, showall, showeffects, showhiddencurse, showdisplayeffects]
	}
	logger.break()
end

if world
	logger.log "All Syndromes", Output::HIGHLIGHT
	df.world.raws.syndromes.all.each { |syndrome| print_raw_syndrome[logger, syndrome, showeffects, showdisplayeffects]	}
end

logger.close()