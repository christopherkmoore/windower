local event_statics = { }

--=====================================================================
-- MARK: Buffs
--=====================================================================

-- buffs considered ' enfeeble buffs'
event_statics.enfeebling = S{ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,28,29,30,31,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,144,145,146,147,148,149,155,156,157,158,159,167,168,174,175,177,186,189,192,193,194,223,259,260,261,262,263,264,298,378,379,380,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,404,448,449,450,451,452,473,540,557,558,559,560,561,562,563,564,565,566,567,597}
event_statics.dot_debuffs = S{ 3,128,129,130,131,132,133,134,135,192,540 }
--=====================================================================
-- MARK: Messages 
--=====================================================================


event_statics.message_death = S{6,20,113,406,605,646}
event_statics.immune = S {655, 656, 228} -- ${actor} casts ${spell}.${lb}${target} completely resists the spell.
event_statics.resisted = S{85,284,653,654} 
event_statics.aspir = S{228}
event_statics.lose_effect = S{64,74,83,123,159,168,204,206,322,341,342,343,344,350,378,453,531,647}

--=====================================================================
-- MARK: Player
--=====================================================================

event_statics.mage_disabled_states = T{ 0, 2, 6, 7, 10, 14, 28, 29, 193, 262 } -- KO, Sleep, Silence, Petrification, Stun, Charm, Terrorize, Mute, Lullaby, Omerta
event_statics.melee_disabled_states = T{ 0, 2,  7, 10, 14, 16, 28, 193, 262 }  -- KO, Sleep, Petrification, Stun, Charm, Amnesia, Terrorize, Lullaby, Omerta
event_statics.disabled_states = T{ 0, 2,  7, 10, 14, 28, 193, 262 }  -- KO, Sleep, Petrification, Stun, Charm, Terrorize, Lullaby, Omerta


--=====================================================================
-- MARK: White Mage 
--=====================================================================

event_statics.debuff_to_dispel_map = {['Accuracy Down']='Erase',['addle']='Erase',['AGI Down']='Erase',['Attack Down']='Erase',['bind']='Erase',['Bio']='Erase',['blindness']='Blindna',['Burn']='Erase',['Choke']='Erase',['CHR Down']='Erase',['curse']='Cursna',['Defense Down']='Erase',['DEX Down']='Erase',['Dia']='Erase',['disease']='Viruna',['doom']='Cursna',['Drown']='Erase',['Elegy']='Erase',['Evasion Down']='Erase',['Frost']='Erase',['Inhibit TP']='Erase',['INT Down']='Erase',['Lullaby']='Cure',['Magic Acc. Down']='Erase',['Magic Atk. Down']='Erase',['Magic Def. Down']='Erase',['Magic Evasion Down']='Erase',['Max HP Down']='Erase',['Max MP Down']='Erase',['Max TP Down']='Erase',['MND Down']='Erase',['Nocturne']='Erase',['paralysis']='Paralyna',['petrification']='Stona',['plague']='Viruna',['poison']='Poisona',['Rasp']='Erase',['Requiem']='Erase',['Shock']='Erase',['silence']='Silena',['slow']='Erase',['STR Down']='Erase',['VIT Down']='Erase',['weight']='Erase'}
event_statics.dispel_to_debuff_map = {['Blindna']={'blindness'},['Cursna']={'curse','doom'},['Paralyna']={'paralysis'},['Poisona']={'poison'},['Silena']={'silence'},['Stona']={'petrification'},['Viruna']={'disease','plague'},['Erase']={'weight','Accuracy Down','addle','AGI Down','Attack Down','bind','Bio','Burn','Choke','CHR Down','Defense Down','DEX Down','Dia','Drown','Elegy','Evasion Down','Frost','Inhibit TP','INT Down','Magic Acc. Down','Magic Atk. Down','Magic Def. Down','Magic Evasion Down','Max HP Down','Max MP Down','Max TP Down','MND Down','Nocturne','Rasp','Requiem','Shock','slow','STR Down','VIT Down'}}
event_statics.raise_spells = S{12,13,140,494} 
event_statics.na_spells = S{143, 14, 15, 16, 17, 18, 19, 20, 95} 
--=====================================================================
-- MARK: Bard 
--=====================================================================
event_statics.song_buff_ids = S{195,196,197,198,199,200,201,206} -- 215 etude and 216 carol?

event_statics.songs = {
    paeon = {'Army\'s Paeon VI','Army\'s Paeon V','Army\'s Paeon IV','Army\'s Paeon III','Army\'s Paeon II','Army\'s Paeon'},
    ballad = {'Mage\'s Ballad III','Mage\'s Ballad II','Mage\'s Ballad'},
    minne = {'Knight\'s Minne V','Knight\'s Minne IV','Knight\'s Minne III','Knight\'s Minne II','Knight\'s Minne'},
    march = {'Victory March','Advancing March'},
    minuet = {'Valor Minuet V','Valor Minuet IV','Valor Minuet III','Valor Minuet II','Valor Minuet'}, 
    madrigal = {'Blade Madrigal','Sword Madrigal'},
    prelude = {'Archer\'s Prelude','Hunter\'s Prelude'},
    mambo = {'Dragonfoe Mambo','Sheepfoe Mambo'},
    aubade = {'Fowl Aubade'},
    pastoral = {'Herb Pastoral'},
    fantasia = {'Shining Fantasia'},
    operetta = {'Puppet\'s Operetta','Scop\'s Operetta'},
    capriccio = {'Gold Capriccio'},
    round = {'Warding Round'},
    gavotte = {'Shining Fantasia'},
    hymnus = {'Goddess\'s Hymnus'},
    mazurka = {'Chocobo Mazurka'},
    sirvente = {'Foe Sirvente'},
    dirge = {'Adventurer\'s Dirge'},
    scherzo = {'Sentinel\'s Scherzo'},
    carol = {},
    etude = {},
    setude = {'Herculean Etude','Sinewy Etude'},
    detude = {'Uncanny Etude','Dextrous Etude'},
    vetude = {'Vital Etude','Vivacious Etude'},
    aetude = {'Swift Etude','Quick Etude'},
    ietude = {'Sage Etude','Learned Etude'},
    metude = {'Logical Etude','Spirited Etude'},
    cetude = {'Bewitching Etude','Enchanting Etude'},
    fcarol = {'Fire Carol','Fire Carol II'},
    icarol = {'Ice Carol','Ice Carol II'},
    wcarol = {'Wind Carol','Wind Carol II'},
    ecarol = {'Earth Carol','Earth Carol II'},
    tcarol = {'Lightning Carol','Lightning Carol II'},
    acarol = {'Water Carol','Water Carol II'},
    lcarol = {'Light Carol','Light Carol II'},
    dcarol = {'Dark Carol','Dark Carol II'},
}

event_statics.debuffs = {
    lullaby = {'Horde Lullaby II','Horde Lullaby','Foe Lullaby II','Foe Lullaby'},
    requiem = {'Foe Requiem VII', 'Foe Requiem VI', 'Foe Requiem V','Foe Requiem IV','Foe Requiem III','Foe Requiem II', 'Foe Requiem I'},
    elegy = {'Carnage Elegy'},
    nocturne = {'Pining Nocturne'},
    threnody = {
         fire = 'Fire Threnody', fire2 = 'Fire Threnody II',
         ice = 'Ice Threnody', ice2 = 'Ice Threnody II',
         wind = 'Wind Threnody', wind2 = 'Wind Threnody II',
         earth = 'Earth Threnody', earth2 = 'Earth Threnody II',
         lightning = 'Ltng. Threnody', lightning2 = 'Ltng. Threnody II',
         water = 'Water Threnody', water2 = 'Water Threnody II',
         light = 'Light Threnody', light2 = 'Light Threnody II',
         dark = 'Dark Threnody', dark2 = 'Dark Threnody II',
    }
}

event_statics.extra_song_harp = {
    [18571] = 4, -- Daurdabla 99
    [18575] = 3, -- Daurdabla 90
    [18576] = 3, -- Daurdabla 95
    [18839] = 4, -- Daurdabla 99-2
    [21400] = 3, -- Blurred Harp
    [21401] = 3, -- Blurred Harp +1
    [21407] = 3, -- Terpander
}

event_statics.honor_march_horn = {
    [21398] = true -- Marsyas
}



--=====================================================================
-- MARK: Dispel
--=====================================================================

event_statics.dispels = {
    dispel = {id=260,en="Dispel",ja="ディスペル",cast_time=3,element=7,icon_id=316,icon_id_nq=15,levels={[5]=32,[20]=32},mp_cost=25,prefix="/magic",range=12,recast=10,recast_id=260,requirements=6,skill=35,targets=32,type="BlackMagic"},
    dispelga = {id=360,en="Dispelga",ja="ディスペガ",cast_time=3,element=7,icon_id=316,icon_id_nq=15,levels={[3]=99,[4]=99,[5]=99,[10]=99,[15]=99,[20]=99,[21]=99},mp_cost=200,prefix="/magic",range=12,recast=10,recast_id=360,requirements=0,skill=35,targets=32,type="BlackMagic",unlearnable=true},
    finale = {id=462,en="Magic Finale",ja="魔法のフィナーレ",cast_time=2,element=6,icon_id=-1,icon_id_nq=38,levels={[10]=33},mp_cost=0,prefix="/song",range=12,recast=24,recast_id=462,requirements=0,skill=40,targets=32,type="BardSong"},
    blank_gaze = {id=592,en="Blank Gaze",ja="ブランクゲイズ",blu_points=2,cast_time=3,element=6,icon_id=-1,icon_id_nq=62,levels={[16]=38},mp_cost=25,prefix="/magic",range=9,recast=10,recast_id=592,requirements=0,skill=43,targets=32,type="BlueMagic"},
    geist_wall = {id=605,en="Geist Wall",ja="ガイストウォール",blu_points=3,cast_time=3,element=7,icon_id=-1,icon_id_nq=63,levels={[16]=46},mp_cost=35,prefix="/magic",range=4,recast=30,recast_id=605,requirements=0,skill=43,targets=32,type="BlueMagic"},
    dark_shot = {id=132,en="Dark Shot",ja="ダークショット",element=7,icon_id=495,mp_cost=1,prefix="/jobability",range=12,recast_id=195,targets=32,tp_cost=0,type="CorsairShot"},
}

event_statics.dispel_jobs = S{ 'BRD', 'RDM', 'BLU', 'COR'}

event_statics.dispel_spell_ids = S{ 260, 360, 462, 592, 605, 132 }
event_statics.dispel_message_successful = S { 341, 342}
event_statics.monster_buff_gained = S{ 186, 194, 205, 230, 266, 280, 319 }


--=====================================================================
-- MARK: Skillchains
--=====================================================================

event_statics.skillchain_ids = S{288,289,290,291,292,293,294,295,296,297,298,299,300,301,385,386,387,388,389,390,391,392,393,394,395,396,397,767,768,769,770}

event_statics.skillchains = {
	[288] = {id=288,english='Light',elements={'Light','Thunder','Wind','Fire'}},
	[289] = {id=289,english='Darkness',elements={'Dark','Ice','Water','Earth'}},
	[290] = {id=290,english='Gravitation',elements={'Dark','Earth'}},
	[291] = {id=291,english='Fragmentation',elements={'Thunder','Wind'}},
	[292] = {id=292,english='Distortion',elements={'Ice','Water'}},
	[293] = {id=293,english='Fusion',elements={'Light','Fire'}},
	[294] = {id=294,english='Compression',elements={'Dark'}},
	[295] = {id=295,english='Liquefaction',elements={'Fire'}},
	[296] = {id=296,english='Induration',elements={'Ice'}},
	[297] = {id=297,english='Reverberation',elements={'Water'}},
	[298] = {id=298,english='Transfixion', elements={'Light'}},
	[299] = {id=299,english='Scission',elements={'Earth'}},
	[300] = {id=300,english='Detonation',elements={'Wind'}},
	[301] = {id=301,english='Impaction',elements={'Thunder'}},
	[385] = {id=385, english='Light',elements={'Light','Thunder','Wind','Fire'}} -- CKM added because this is the absorbs message.
}

event_statics.magic_tiers = {
	[1] = {suffix=''},
	[2] = {suffix='II'},
	[3] = {suffix='III'},
	[4] = {suffix='IV'},
	[5] = {suffix='V'},
	[6] = {suffix='VI'}
}

event_statics.jutsu_tiers = {
    [1] = {suffix='Ichi'},
    [2] = {suffix='Ni'},
    [3] = {suffix='San'}
}

event_statics.spell_priorities = {
	[1] = {element='Thunder'},
	[2] = {element='Ice'},
	[3] = {element='Wind'},
	[4] = {element='Fire'},
	[5] = {element='Water'},
	[6] = {element='Earth'},
	[7] = {element='Dark'},
	[8] = {element='Light'}
}

event_statics.storms = {
	[178] = {id=178,name='Firestorm',weather=4},
	[179] = {id=179,name='Hailstorm',weather=12},
	[180] = {id=180,name='Windstorm',weather=10},
	[181] = {id=181,name='Sandstorm',weather=8},
	[182] = {id=182,name='Thunderstorm',weather=14},
	[183] = {id=183,name='Rainstorm',weather=6},
	[184] = {id=184,name='Aurorastorm',weather=16},
	[185] = {id=185,name='Voidstorm',weather=18},
	[589] = {id=589,name='Firestorm',weather=5},
	[590] = {id=590,name='Hailstorm',weather=13},
	[591] = {id=591,name='Windstorm',weather=11},
	[592] = {id=592,name='Sandstorm',weather=9},
	[593] = {id=593,name='Thunderstorm',weather=15},
	[594] = {id=594,name='Rainstorm',weather=7},
	[595] = {id=595,name='Aurorastorm',weather=17},
	[596] = {id=596,name='Voidstorm',weather=19}
}

event_statics.elements = {
	['Light'] = {spell=nil,helix='Luminohelix',ga=nil,ja=nil,ra=nil,jutsu=nil,white='Banish',holy="Holy"},
	['Dark'] = {spell=nil,helix='Noctohelix',ga=nil,ja=nil,ra=nil,jutsu=nil,white=nil,holy=nil},
	['Thunder'] = {spell='Thunder',helix='Ionohelix',ga='Thundaga',ja='Thundaja',ra='Thundara',jutsu='Raiton',white=nil,holy=nil},
	['Ice'] = {spell='Blizzard',helix='Cryohelix',ga='Blizzaga',ja='Blizzaja',ra='Blizzara',jutsu='Hyoton',white=nil,holy=nil},
	['Fire'] = {spell='Fire',helix='Pyrohelix',ga='Firaga',ja='Firaja',ra='Fira',jutsu='Katon',white=nil,holy=nil},
	['Wind'] = {spell='Aero',helix='Anemohelix',ga='Aeroga',ja='Aeroja',ra='Aerora',jutsu='Huton',white=nil,holy=nil},
	['Water'] = {spell='Water',helix='Hydrohelix',ga='Waterga',ja='Waterja',ra='Watera',jutsu='Suiton',white=nil,holy=nil},
	['Earth'] = {spell='Stone',helix='Geohelix',ga='Stonega',ja='Stoneja',ra='Stonera',jutsu='Doton',white=nil,holy=nil},
}


--=====================================================================
-- MARK: General 
--=====================================================================
event_statics.buff_map = {['Barfira']='Barfire',['Barblizzara']='Barblizzard',['Baraera']='Baraero',['Barstonra']='Barstone',['Barthundra']='Barthunder',['Barwatera']='Barwater',['Baramnesra']='Baramnesia',['Barsleepra']='Barsleep',['Barpoisonra']='Barpoison',['Barparalyzra']='Barparalyze',['Barblindra']='Barblind',['Barsilencera']='Barsilence',['Barpetra']='Barpetrify',['Barvira']='Barvirus',['Blaze Spikes']='Blaze Spikes',['Ice Spikes']='Ice Spikes',['Shock Spikes']='Shock Spikes',['Dread Spikes']='Dread Spikes',['Boost-STR']='STR Boost',['Boost-DEX']='DEX Boost',['Boost-VIT']='VIT Boost',['Boost-AGI']='AGI Boost',['Boost-INT']='INT Boost',['Boost-MND']='MND Boost',['Boost-CHR']='CHR Boost',['Gain-STR']='STR Boost',['Gain-DEX']='DEX Boost',['Gain-VIT']='VIT Boost',['Gain-AGI']='AGI Boost',['Gain-INT']='INT Boost',['Gain-MND']='MND Boost',['Gain-CHR']='CHR Boost',['Temper']='Multi Strikes',['Enfire II']='Enfire II',['Enblizzard II']='Enblizzard II',['Enaero II']='Enaero II',['Enstone II']='Enstone II',['Enthunder II']='Enthunder II',['Enwater II']='Enwater II',["Army's Paeon"]='Paeon',["Army's Paeon II"]='Paeon',["Army's Paeon III"]='Paeon',["Army's Paeon IV"]='Paeon',["Army's Paeon V"]='Paeon',["Army's Paeon VI"]='Paeon',["Army's Paeon VII"]='Paeon',["Army's Paeon VIII"]='Paeon',["Mage's Ballad"]='Ballad',["Mage's Ballad II"]='Ballad',["Mage's Ballad III"]='Ballad',["Knight's Minne"]='Minne',["Knight's Minne II"]='Minne',["Knight's Minne III"]='Minne',["Knight's Minne IV"]='Minne',["Knight's Minne V"]='Minne',["Valor Minuet"]='Minuet',["Valor Minuet II"]='Minuet',["Valor Minuet III"]='Minuet',["Valor Minuet IV"]='Minuet',["Valor Minuet V"]='Minuet',["Sword Madrigal"]='Madrigal',["Blade Madrigal"]='Madrigal',["Hunter's Prelude"]='Prelude',["Archer's Prelude"]='Prelude',["Sheepfoe Mambo"]='Mambo',["Dragonfoe Mambo"]='Mambo',["Fowl Aubade"]='Aubade',["Herb Pastoral"]='Pastoral',["Shining Fantasia"]='Fantasia',["Scop's Operetta"]='Operetta',["Puppet's Operetta"]='Operetta',["Jester's Operetta"]='Operetta',["Gold Capriccio"]='Capriccio',["Devotee Serenade"]='Serenade',["Warding Round"]='Round',["Goblin Gavotte"]='Gavotte',["Cactuar Fugue"]='Fugue',["Protected Aria"]='Aria',["Advancing March"]='March',["Victory March"]='March',["Sinewy Etude"]='Etude',["Dextrous Etude"]='Etude',["Vivacious Etude"]='Etude',["Quick Etude"]='Etude',["Learned Etude"]='Etude',["Spirited Etude"]='Etude',["Enchanting Etude"]='Etude',["Herculean Etude"]='Etude',["Uncanny Etude"]='Etude',["Vital Etude"]='Etude',["Swift Etude"]='Etude',["Sage Etude"]='Etude',["Logical Etude"]='Etude',["Bewitching Etude"]='Etude',["Fire Carol"]='Carol',["Ice Carol"]='Carol',["Wind Carol"]='Carol',["Earth Carol"]='Carol',["Lightning Carol"]='Carol',["Water Carol"]='Carol',["Light Carol"]='Carol',["Dark Carol"]='Carol',["Fire Carol II"]='Carol',["Ice Carol II"]='Carol',["Wind Carol II"]='Carol',["Earth Carol II"]='Carol',["Lightning Carol II"]='Carol',["Water Carol II"]='Carol',["Light Carol II"]='Carol',["Dark Carol II"]='Carol',["Goddess's Hymnus"]='Hymnus',["Chocobo Mazurka"]='Mazurka',["Raptor Mazurka"]='Mazurka',["Foe Sirvente"]='Sirvente',["Adventurer's Dirge"]='Dirge',["Sentinel's Scherzo"]='Scherzo',["Sandstorm II"]=592,["Rainstorm II"]=594,["Windstorm II"]=591,["Firestorm II"]=589,["Hailstorm II"]=590,["Thunderstorm II"]=593,["Voidstorm II"]=596,["Aurorastorm II"]=595}

event_statics.equippable_bags = {
    'Inventory',
    'Wardrobe',
    'Wardrobe2',
    'Wardrobe3',
    'Wardrobe4'
}

event_statics.messages_blacklist = S{1,6,8,9,10,11,12,13,14,15,19,20,21,22,23,30,31,32,33,36,37,38,39,44,45,50,53,54,57,58,59,60,61,63,65,67,69,70,76,77,79,80,81,95,96,97,98,105,107,124,132,149,151,152,157,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,195,196,201,207,208,209,211,212,213,214,222,223,229,232,234,235,239,248,249,250,253,254,255,256,257,258,259,260,261,262,263,264,265,273,276,281,281,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,310,314,336,339,340,352,353,354,355,357,358,361,363,366,367,368,371,372,373,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,415,419,434,436,438,440,442,443,444,447,448,449,450,455,456,457,458,459,460,461,462,463,464,465,466,467,468,469,470,471,472,473,474,475,476,478,512,513,535,536,537,538,540,541,542,543,544,545,548,549,550,551,552,553,554,555,556,557,558,559,568,573,576,577,578,582,583,584,587,588,590,592,601,603,606,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,652,669,673,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,704,705,706,707,708,709,710,711,712,713,714,715,718,719,720,721,722,723,724,725,726,727,728,729,731,735}

rarr = string.char(129,168)
sparr = ' '..rarr..' '

msg_gain_other = S{374,375,412}


messages_loseEffect = S{64,74,83,123,159,168,204,206,322,341,342,343,344,350,378,453,531,647}
messages_wearOff = S{204,206}
messages_paralyzed = S{29,84}

messages_noEffect = S{75}
messages_specific_debuff_gain = {
    [142]={'Accuracy Down','Evasion Down'},
    [144]={'Accuracy Down','Evasion Down'},
    [145]={'Accuracy Down','Evasion Down'},
    [329]={'STR Down'},
    [330]={'DEX Down'},
    [331]={'VIT Down'},
    [332]={'AGI Down'},
    [333]={'INT Down'},
    [334]={'MND Down'},
    [335]={'CHR Down'},
    --[519]={'Lethargic Daze'},
    --[520]={'Sluggish Daze'},
    --[521]={'Weakened Daze'},
    [533]={'Accuracy Down'},
    [534]={'Attack Down'},
    [591]={'Bewildered Daze'}
}
messages_specific_debuff_lose = {
    [351]={'blindness','paralysis','poison','silence'},
    [359]={'doom'},
}


spells_buffs = S{43,44,45,46,47,48,49,50,51,52,53,54,55,57,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,84,85,86,87,88,89,90,91,92,96,97,99,100,101,102,103,104,105,106,107,108,109,110,111,113,114,115,116,117,118,119,125,126,127,128,129,130,131,132,133,134,135,136,137,138,141,142,249,250,251,277,287,308,309,310,311,312,313,314,315,316,317,318,338,339,340,353,354,355,358,473,476,477,478,479,480,481,482,483,484,485,486,487,488,489,490,491,492,493,495,504,505,506,507,509,510,511,768,769,770,771,772,773,774,775,776,777,778,779,780,781,782,783,784,785,786,787,788,789,790,791,792,793,794,795,796,797,798,800,801,802,803,804,805,806,807,808,809,810,811,812,813,814,815,816,840,845,846}
spells_damage = S{21,22,28,29,30,31,32,38,39,40,41,42,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,244,245,246,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,496,497,498,499,500,501,502,828,829,830,831,832,833,834,835,836,837,838,839}
spells_debuffs = S{23,24,25,26,27,33,34,35,36,37,56,58,59,79,80,98,112,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,242,243,252,253,254,255,256,257,258,259,260,266,267,268,269,270,271,272,273,274,275,276,278,279,280,281,282,283,284,285,286,319,341,342,343,344,345,346,347,348,349,350,351,352,356,357,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,421,422,423,454,455,456,457,458,459,460,461,462,463,466,471,472,503,508,799,817,818,819,820,821,822,823,824,825,826,827,841,842,843,844,871,872,873,874,875,876,877,878}
spells_healing = S{1,2,3,4,5,6,7,8,9,10,11,12,13,93,140,474,475,494}
spells_misc = S{81,82,83,120,121,122,123,124,139,241,261,262,263,264,265}
spells_songBuffs = S{378,379,380,381,382,383,384,385,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,401,402,403,404,405,406,407,408,409,410,411,412,413,414,415,416,417,418,419,420,424,425,426,427,428,429,430,431,432,433,434,435,436,437,438,439,440,441,442,443,444,445,446,447,448,449,450,451,452,453,464,465,467,468,469,470}
spells_summoning = S{288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,847}
spells_trust = S{896,897,898,899,900,901,902,903,904,905,906,907,908,909,910,911,912,913,914,916,917,918,919,920,921,922,923,924,925,926,927,928,929,930,931,932,933,934,935,936,937,938,939,941,942,943,944,945,946,947,948,949,950,951,952,958,959,960,961,962,964}

spell_debuff_idmap = {
    [23]=134,[24]=134,[25]=134,[26]=134,[27]=134,[33]=134,[34]=134,[35]=134,[36]=134,
    [37]=134,[56]=13,[58]=4,[59]=6,[79]=13,[80]=4,[98]=2,[112]=156,[216]=12,[217]=12,[220]=3,[221]=3,[222]=3,
    [223]=3,[224]=3,[225]=3,[226]=3,[227]=3,[228]=3,[229]=3,[230]=135,[231]=135,[232]=135,[233]=135,[234]=135,
    [235]=128,[236]=129,[237]=130,[238]=131,[239]=132,[240]=133,[242]=146,[252]=10,[253]=2,[254]=5,[255]=7,[256]=8,
    [257]=9,[258]=11,[259]=2,[266]=136,[267]=137,[268]=138,[269]=139,[270]=140,[271]=141,[272]=142,[273]=2,[274]=2,
    [276]=5,[278]=186,[279]=186,[280]=186,[281]=186,[282]=186,[283]=186,[284]=186,[285]=186,[286]=21,[356]=4,[357]=13,
    [359]=6,[361]=5,[362]=11,[363]=2,[364]=2,[365]=7,[366]=12,[368]=192,[369]=192,[370]=192,[371]=192,[372]=192,[373]=192,
    [374]=192,[375]=192,[376]=193,[377]=193,[421]=194,[422]=194,[423]=194,[454]=217,[455]=217,[456]=217,[457]=217,[458]=217,
    [459]=217,[460]=217,[461]=217,[463]=193,[471]=193,[472]=223,[841]=148,[842]=148,[843]=404,[844]=404,[871]=217,[872]=217,
    [873]=217,[874]=217,[875]=217,[876]=217,[877]=217,[878]=217,[879]=597,[882]=148,[883]=404,[884]=21,[885]=186,[886]=186,[887]=186,
    [888]=186,[889]=186,[890]=186,[891]=186,[892]=186
}

buff_map = {['Barfira']='Barfire',['Barblizzara']='Barblizzard',['Baraera']='Baraero',['Barstonra']='Barstone',['Barthundra']='Barthunder',['Barwatera']='Barwater',['Baramnesra']='Baramnesia',['Barsleepra']='Barsleep',['Barpoisonra']='Barpoison',['Barparalyzra']='Barparalyze',['Barblindra']='Barblind',['Barsilencera']='Barsilence',['Barpetra']='Barpetrify',['Barvira']='Barvirus',['Blaze Spikes']='Blaze Spikes',['Ice Spikes']='Ice Spikes',['Shock Spikes']='Shock Spikes',['Dread Spikes']='Dread Spikes',['Boost-STR']='STR Boost',['Boost-DEX']='DEX Boost',['Boost-VIT']='VIT Boost',['Boost-AGI']='AGI Boost',['Boost-INT']='INT Boost',['Boost-MND']='MND Boost',['Boost-CHR']='CHR Boost',['Gain-STR']='STR Boost',['Gain-DEX']='DEX Boost',['Gain-VIT']='VIT Boost',['Gain-AGI']='AGI Boost',['Gain-INT']='INT Boost',['Gain-MND']='MND Boost',['Gain-CHR']='CHR Boost',['Temper']='Multi Strikes',['Enfire II']='Enfire II',['Enblizzard II']='Enblizzard II',['Enaero II']='Enaero II',['Enstone II']='Enstone II',['Enthunder II']='Enthunder II',['Enwater II']='Enwater II',["Army's Paeon"]='Paeon',["Army's Paeon II"]='Paeon',["Army's Paeon III"]='Paeon',["Army's Paeon IV"]='Paeon',["Army's Paeon V"]='Paeon',["Army's Paeon VI"]='Paeon',["Army's Paeon VII"]='Paeon',["Army's Paeon VIII"]='Paeon',["Mage's Ballad"]='Ballad',["Mage's Ballad II"]='Ballad',["Mage's Ballad III"]='Ballad',["Knight's Minne"]='Minne',["Knight's Minne II"]='Minne',["Knight's Minne III"]='Minne',["Knight's Minne IV"]='Minne',["Knight's Minne V"]='Minne',["Valor Minuet"]='Minuet',["Valor Minuet II"]='Minuet',["Valor Minuet III"]='Minuet',["Valor Minuet IV"]='Minuet',["Valor Minuet V"]='Minuet',["Sword Madrigal"]='Madrigal',["Blade Madrigal"]='Madrigal',["Hunter's Prelude"]='Prelude',["Archer's Prelude"]='Prelude',["Sheepfoe Mambo"]='Mambo',["Dragonfoe Mambo"]='Mambo',["Fowl Aubade"]='Aubade',["Herb Pastoral"]='Pastoral',["Shining Fantasia"]='Fantasia',["Scop's Operetta"]='Operetta',["Puppet's Operetta"]='Operetta',["Jester's Operetta"]='Operetta',["Gold Capriccio"]='Capriccio',["Devotee Serenade"]='Serenade',["Warding Round"]='Round',["Goblin Gavotte"]='Gavotte',["Cactuar Fugue"]='Fugue',["Protected Aria"]='Aria',["Advancing March"]='March',["Victory March"]='March',["Sinewy Etude"]='Etude',["Dextrous Etude"]='Etude',["Vivacious Etude"]='Etude',["Quick Etude"]='Etude',["Learned Etude"]='Etude',["Spirited Etude"]='Etude',["Enchanting Etude"]='Etude',["Herculean Etude"]='Etude',["Uncanny Etude"]='Etude',["Vital Etude"]='Etude',["Swift Etude"]='Etude',["Sage Etude"]='Etude',["Logical Etude"]='Etude',["Bewitching Etude"]='Etude',["Fire Carol"]='Carol',["Ice Carol"]='Carol',["Wind Carol"]='Carol',["Earth Carol"]='Carol',["Lightning Carol"]='Carol',["Water Carol"]='Carol',["Light Carol"]='Carol',["Dark Carol"]='Carol',["Fire Carol II"]='Carol',["Ice Carol II"]='Carol',["Wind Carol II"]='Carol',["Earth Carol II"]='Carol',["Lightning Carol II"]='Carol',["Water Carol II"]='Carol',["Light Carol II"]='Carol',["Dark Carol II"]='Carol',["Goddess's Hymnus"]='Hymnus',["Chocobo Mazurka"]='Mazurka',["Raptor Mazurka"]='Mazurka',["Foe Sirvente"]='Sirvente',["Adventurer's Dirge"]='Dirge',["Sentinel's Scherzo"]='Scherzo',["Sandstorm II"]=592,["Rainstorm II"]=594,["Windstorm II"]=591,["Firestorm II"]=589,["Hailstorm II"]=590,["Thunderstorm II"]=593,["Voidstorm II"]=596,["Aurorastorm II"]=595}
debuff_map = {['Accuracy Down']='Erase',['addle']='Erase',['AGI Down']='Erase',['Attack Down']='Erase',['bind']='Erase',['Bio']='Erase',['blindness']='Blindna',['Burn']='Erase',['Choke']='Erase',['CHR Down']='Erase',['curse']='Cursna',['Defense Down']='Erase',['DEX Down']='Erase',['Dia']='Erase',['disease']='Viruna',['doom']='Cursna',['Drown']='Erase',['Elegy']='Erase',['Evasion Down']='Erase',['Frost']='Erase',['Inhibit TP']='Erase',['INT Down']='Erase',['Lullaby']='Cure',['Magic Acc. Down']='Erase',['Magic Atk. Down']='Erase',['Magic Def. Down']='Erase',['Magic Evasion Down']='Erase',['Max HP Down']='Erase',['Max MP Down']='Erase',['Max TP Down']='Erase',['MND Down']='Erase',['Nocturne']='Erase',['paralysis']='Paralyna',['petrification']='Stona',['plague']='Viruna',['poison']='Poisona',['Rasp']='Erase',['Requiem']='Erase',['Shock']='Erase',['silence']='Silena',['slow']='Erase',['STR Down']='Erase',['VIT Down']='Erase',['weight']='Erase'}
removal_map = {['Blindna']={'blindness'},['Cursna']={'curse','doom'},['Paralyna']={'paralysis'},['Poisona']={'poison'},['Silena']={'silence'},['Stona']={'petrification'},['Viruna']={'disease','plague'},['Erase']={'weight','Accuracy Down','addle','AGI Down','Attack Down','bind','Bio','Burn','Choke','CHR Down','Defense Down','DEX Down','Dia','Drown','Elegy','Evasion Down','Frost','Inhibit TP','INT Down','Magic Acc. Down','Magic Atk. Down','Magic Def. Down','Magic Evasion Down','Max HP Down','Max MP Down','Max TP Down','MND Down','Nocturne','Rasp','Requiem','Shock','slow','STR Down','VIT Down'}}
sleep_spells = S{'horde_lullaby_ii', 'horde_lullaby_i', 'foe_lullaby', 'foe_lullaby_ii', 'sleep', 'sleepga', 'sleepga_ii'}

debuff_casemap = {['nocturne']='Nocturne',['accuracy down']='Accuracy Down',['magic def. down']='Magic Def. Down',['inhibit tp']='Inhibit TP',['weight']='weight',['str down']='STR Down',['slow']='slow',['defense down']='Defense Down',['elegy']='Elegy',['choke']='Choke',['max hp down']='Max HP Down',['lullaby']='Lullaby',['paralysis']='paralysis',['int down']='INT Down',['petrification']='petrification',['vit down']='VIT Down',['requiem']='Requiem',['curse']='curse',['bio']='Bio',['chr down']='CHR Down',['disease']='disease',['frost']='Frost',['bind']='bind',['doom']='doom',['silence']='silence',['rasp']='Rasp',['addle']='addle',['poison']='poison',['evasion down']='Evasion Down',['dia']='Dia',['mnd down']='MND Down',['max mp down']='Max MP Down',['max tp down']='Max TP Down',['burn']='Burn',['magic atk. down']='Magic Atk. Down',['magic evasion down']='Magic Evasion Down',['attack down']='Attack Down',['plague']='plague',['drown']='Drown',['shock']='Shock',['blindness']='blindness',['dex down']='DEX Down',['agi down']='AGI Down',['magic acc. down']='Magic Acc. Down', ['gravity']= 'Gravity'}

ignoreDebuffs = {
	['Accuracy Down'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['AGI Down'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['Attack Down'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['DEX Down'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['Inhibit TP'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['Max TP Down'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['STR Down'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['addle'] = S{'WAR','MNK','THF','BST','RNG','DRG','SAM','COR','PUP','DNC'},
	['blind'] = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'},
	['silence'] = S{'WAR','MNK','THF','BST','RNG','DRG','SAM','COR','PUP','DNC'}

}

dec2roman = {'I','II','III','IV','V','VI','VII','VIII','IX','X','XI'}
roman2dec = {['I']=1,['II']=2,['III']=3,['IV']=4,['V']=5,['VI']=6,['VII']=7,['VIII']=8,['IX']=9,['X']=10,['XI']=11}

cure_potencies = {[1]=87, [2]=199, [3]=438, [4]=816, [5]=1056, [6]=1311}
tier_of_cure = {['Cure']=1,['Cure II']=2,['Cure III']=3,['Cure IV']=4,['Cure V']=5,['Cure VI']=6}
tier_of_curaga = {['Curaga']=1,['Curaga II']=2,['Curaga III']=3,['Curaga IV']=4,['Curaga V']=5}
cure_of_tier = {'Cure','Cure II','Cure III','Cure IV','Cure V','Cure VI'}
curaga_of_tier = {'Curaga','Curaga II','Curaga III','Curaga IV','Curaga V'}

indoor_zones = S{0,26,53,223,224,225,226,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,252,256,257,280,284}

roll_info = {
    ["Allies' Roll"] =      {lucky=3,unlucky=10,effect='Skillchain Accuracy & Damage + %'},
    ["Avenger's Roll"] =    {lucky=4,unlucky=8,effect='Counter Rate + %'},
    ["Beast Roll"] =        {lucky=4,unlucky=8,effect='Pet: Attack & Ranged Attack + %'},
    ["Blitzer's Roll"] =    {lucky=4,unlucky=9,effect='Melee Attack Delay - %'},
    ["Bolter's Roll"] =     {lucky=3,unlucky=9,effect='Movement Speed + %'},
    ["Caster's Roll"] =     {lucky=2,unlucky=7,effect='Fast Cast + %'},
    ["Chaos Roll"] =        {lucky=4,unlucky=8,effect='Attack & Ranged Attack + %'},
    ["Choral Roll"] =       {lucky=2,unlucky=6,effect='Spell Interruption Rate - %'},
    ["Companion's Roll"] =  {lucky=2,unlucky=10,effect='Pet: Regain & Regen'},
    ["Corsair's Roll"] =    {lucky=5,unlucky=9,effect='Exp. & Cap. Points + %'},
    ["Courser's Roll"] =    {lucky=3,unlucky=9,effect='Snapshot + %'},
    ["Dancer's Roll"] =     {lucky=3,unlucky=7,effect='Regen'},
    ["Drachen Roll"] =      {lucky=4,unlucky=8,effect='Pet: Accuracy & Ranged Accuracy ++'},
    ["Evoker's Roll"] =     {lucky=5,unlucky=9,effect='Refresh'},
    ["Fighter's Roll"] =    {lucky=5,unlucky=9,effect='Double Attack Rate + %'},
    ["Gallant's Roll"] =    {lucky=3,unlucky=7,effect='Defense + %'},
    ["Healer's Roll"] =     {lucky=3,unlucky=7,effect='Cure Potency + %'},
    ["Hunter's Roll"] =     {lucky=4,unlucky=8,effect='Accuracy & Ranged Accuracy ++'},
    ["Magus's Roll"] =      {lucky=2,unlucky=6,effect='Magic Defense Bonus ++'},
    ["Miser's Roll"] =      {lucky=5,unlucky=7,effect='Save TP ++'},
    ["Monk's Roll"] =       {lucky=3,unlucky=7,effect='Subtle Blow ++'},
    ["Ninja's Roll"] =      {lucky=4,unlucky=8,effect='Evasion ++'},
    ["Puppet Roll"] =       {lucky=3,unlucky=7,effect='Pet: Magic Accuracy & MAB ++'},
    ["Rogue's Roll"] =      {lucky=5,unlucky=9,effect='Critical Hit Rate + %'},
    ["Samurai Roll"] =      {lucky=2,unlucky=6,effect='Store TP ++'},
    ["Scholar's Roll"] =    {lucky=2,unlucky=6,effect='Conserve MP ++'},
    ["Tactician's Roll"] =  {lucky=5,unlucky=8,effect='Regain'},
    ["Warlock's Roll"] =    {lucky=4,unlucky=8,effect='Magic Accuracy ++'},
    ["Wizard's Roll"] =     {lucky=5,unlucky=9,effect='MAB ++'}
}

local function prep_geo_spells()
    local geo_spells = {indi=S{},geo=S{}}
    for sid, spell in pairs(res.spells) do
        if spell.en:startswith('Indi-') then
            geo_spells.indi:add(sid)
        elseif spell.en:startswith('Geo-') then
            geo_spells.geo:add(sid)
        end
    end
    return geo_spells.indi, geo_spells.geo
end
indi_spell_ids, geo_spell_ids = prep_geo_spells()


return event_statics