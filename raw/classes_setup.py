import os
import fnmatch
import itertools
import csv

wfile = 'inorganic_dfhack_classes.txt'
wf = open(wfile,'w')
wfile2 = 'dfhack_input.txt'
wf2 = open(wfile2,'w')
wfile3 = 'reaction_classes.txt'
wf3 = open(wfile3,'w')
wfile4 = 'permitted_reactions.txt'
wf4 = open(wfile4,'w')
wf.write('inorganic_dfhack_classes\n')
wf.write('\n[OBJECT:INORGANIC]\n')
wf3.write('reaction_class.txt\n')
wf3.write('\n[OBJECT:REACTION]\n')

files = ['objects/classes.txt']
totdat = [[]]*len(files)
for i in range(len(files)):
	f = open(files[i])
	dat = []
	for row in f:
		dat.append(row)
	totdat[i] = dat
f.close()

ddtot = [[]]*len(totdat)
for j in range(len(totdat)):
	d = []
	for i in range(len(totdat[j])):
		if totdat[j][i].count('[CLASS:') >= 1:
			y = totdat[j][i].partition('[CLASS:')[2].partition(']')[0]
			d.append([y,i])
	dd = []
	if len(d) >= 1:
		for i in range(len(d)-1):
			dd.append([d[i][0], d[i][1], d[i+1][1]])
		dd.append([d[-1][0], d[-1][1], len(totdat[j])])
		ddtot[j] = dd

creature = []
for i in range(len(ddtot)):
	for j in range(len(ddtot[i])):
		creature.append([ddtot[i][j][0]])
		x = ddtot[i][j][1]
		y = ddtot[i][j][2]
		z = len(''.join(totdat[i][x+1:y]).split('['))
		for k in range(z-1):
			val = ''.join(totdat[i][x+1:y]).split('[')[k+1].split(']')[0]
			creature[-1].append(val)

files = ['objects/spells.txt']
totdat = [[]]*len(files)
for i in range(len(files)):
	f = open(files[i])
	dat = []
	for row in f:
		dat.append(row)
	totdat[i] = dat
f.close()

ddtot = [[]]*len(totdat)
for j in range(len(totdat)):
	d = []
	for i in range(len(totdat[j])):
		if totdat[j][i].count('[SPELL:') >= 1:
			y = totdat[j][i].partition('[SPELL:')[2].partition(']')[0]
			d.append([y,i])
	dd = []
	if len(d) >= 1:
		for i in range(len(d)-1):
			dd.append([d[i][0], d[i][1], d[i+1][1]])
		dd.append([d[-1][0], d[-1][1], len(totdat[j])])
		ddtot[j] = dd

spell = []
for i in range(len(ddtot)):
	for j in range(len(ddtot[i])):
		spell.append([ddtot[i][j][0]])
		x = ddtot[i][j][1]
		y = ddtot[i][j][2]
		z = len(''.join(totdat[i][x+1:y]).split('['))
		for k in range(z-1):
			val = ''.join(totdat[i][x+1:y]).split('[')[k+1].split(']')[0]
			spell[-1].append(val)
			
wf.write('\n[INORGANIC:DFHACK_CLASS_SPELLS]\n')
wf.write('\t[USE_MATERIAL_TEMPLATE:STONE_TEMPLATE]\n')
for i in range(len(spell)):
	wf.write('\t[SYNDROME]\n')
	wf.write('\t\t[SYN_NAME:'+spell[i][0]+']\n')
	wf.write('\t\t[CE_CAN_DO_INTERACTION:START:0]\n')
	wf2.write('modtools/reaction-trigger -reaction LEARN_'+spell[i][0]+' -command [ class-learn-spell -unit \\WORKER_ID -spell '+spell[i][0]+' ]\n')
	wf3.write('\n[REACTION:LEARN_'+spell[i][0]+']\n')
	wf3.write('\t[NAME:learn spell - #YOUR_SPELL_NAME_HERE#]\n')
	wf3.write('\t[BUILDING:#YOUR_BUILDING_HERE#:NONE]\n')
	wf4.write('[PERMITTED_REACTION:LEARN_'+spell[i][0]+']\n')
	for j in range(1,len(spell[i])):
		wf.write('\t\t\t['+spell[i][j]+']\n')
			
wf.write('\n##############################################################\n')	
wf3.write('\n##############################################################\n')			
wf.write('\n[INORGANIC:DFHACK_CLASS_NAMES]\n')
wf.write('\t[USE_MATERIAL_TEMPLATE:STONE_TEMPLATE]\n')
for i in range(len(creature)):
	wf.write('\t[SYNDROME]\n')
	wf.write('\t\t[SYN_NAME:'+creature[i][0]+']\n')
	if creature[i][1].count(':') == 1:
		name = creature[i][1].split(':')[1].partition(']')[0]
		wf.write('\t\t[CE_DISPLAY_NAME:NAME:'+name+':'+name+'s:'+name+':START:0]\n')
	if creature[i][1].count(':') == 2:
		name = creature[i][1].split(':')[1]
		plural = creature[i][1].split(':')[2].partition(']')[0]
		wf.write('\t\t[CE_DISPLAY_NAME:NAME:'+name+':'+plural+':'+name+':START:0]\n')
	if creature[i][1].count(':') == 3:
		name = creature[i][1].split(':')[1]
		plural = creature[i][1].split(':')[2]
		adjective = creature[i][1].split(':')[3].partition(']')[0]
		wf.write('\t\t[CE_DISPLAY_NAME:NAME:'+name+':'+plural+':'+adjective+':START:0]\n')
	wf2.write('modtools/reaction-trigger -reaction CHANGE_CLASS_'+creature[i][0]+' -command [ class-change-class -unit \\WORKER_ID -class '+creature[i][0]+' ]\n')
	wf3.write('\n[REACTION:CHANGE_CLASS_'+creature[i][0]+']\n')
	wf3.write('\t[NAME:change class - '+creature[i][1].split(':')[1]+']\n')
	wf3.write('\t[BUILDING:#YOUR_BUILDING_HERE#:NONE]\n')
	wf4.write('[PERMITTED_REACTION:CHANGE_CLASS_'+creature[i][0]+']\n')
wf.close()
wf2.close()
wf3.close()
wf4.close()
