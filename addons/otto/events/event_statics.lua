local event_statics = { }

--=====================================================================
-- MARK: Buffs
--=====================================================================

-- buffs considered ' enfeeble buffs'
event_statics.enfeebling = S{ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,28,29,30,31,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,144,145,146,147,148,149,155,156,157,158,159,167,168,174,175,177,186,189,192,193,194,223,259,260,261,262,263,264,298,378,379,380,386,387,388,389,390,391,392,393,394,395,396,397,398,399,400,404,448,449,450,451,452,473,540,557,558,559,560,561,562,563,564,565,566,567,597}

--=====================================================================
-- MARK: Messages 
--=====================================================================


event_statics.message_death = S{6,20,113,406,605,646}
event_statics.immune = S {655, 656, 228} -- ${actor} casts ${spell}.${lb}${target} completely resists the spell.
event_statics.resisted = S{85,284,653,654} 
event_statics.aspir = S{228}
event_statics.lose_effect = S{64,74,83,123,159,168,204,206,322,341,342,343,344,350,378,453,531,647}
event_statics.monster_buff_gained = S{ 186, 194, 205, 230, 266, 280, 319 }
--=====================================================================
-- MARK: No idea / Copied over / maybe not used? 
--=====================================================================

event_statics.cant_cast_states = T{ 0, 2, 6, 7, 10, 14, 28, 29, 193, 262 } -- KO, Sleep, Silence, Petrification, Stun, Charm, Terrorize, Mute, Lullaby, Omerta

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


return event_statics