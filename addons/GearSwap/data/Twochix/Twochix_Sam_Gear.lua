-- Setup vars that are user-dependent.
function user_job_setup()
    state.OffenseMode:options('Normal','SomeAcc','Acc','FullAcc','Fodder')
    state.HybridMode:options('Normal','DTLite','PDT','Reraise')
    state.WeaponskillMode:options('Match','Normal','SomeAcc','Acc','FullAcc','Fodder','Proc')
    state.RangedMode:options('Normal', 'Acc')
    state.PhysicalDefenseMode:options('PDT','PDTReraise')
	state.MagicalDefenseMode:options('MDT','MDTReraise')
	state.ResistDefenseMode:options('MEVA')
    state.IdleMode:options('Normal', 'Reraise')
	state.Weapons:options('Dojikiri','ProcWeapon','Bow')

	gear.ws_jse_back = { name="Smertrios's Mantle", augments={'STR+20','Accuracy+20 Attack+20','STR+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}}
    gear.stp_jse_back ={ name="Smertrios's Mantle", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Phys. dmg. taken-10%',}}
    
    -- Additional local binds
    send_command('bind ^` input /ja "Hasso" <me>')
    send_command('bind !` input /ja "Seigan" <me>')
	send_command('bind !backspace input /ja "Third Eye" <me>')
	send_command('bind @` gs c cycle SkillchainMode')
	send_command('bind !@^` gs c cycle Stance')
	send_command('bind !r gs c set skipprocweapons false;gs c weapons ProcWeapon;gs c set WeaponskillMode Proc;gs c update')
	send_command('bind ^q gs c weapons Bow;gs c update')

    select_default_macro_book()
end

-- Define sets and vars used by this job file.
function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    
    -- Precast Sets
    -- Precast sets to enhance JAs
    sets.precast.JA.Meditate = {head="Wakido Kabuto +2",hands="Sakonji Kote +1",back=gear.ws_jse_back}
    sets.precast.JA['Warding Circle'] = {head="Wakido Kabuto +2"}
    sets.precast.JA['Blade Bash'] = {hands="Sakonji Kote +1"}
	sets.precast.JA['Sekkanoki'] = {hands="Kasuga Kote +1"}
	sets.precast.JA['Sengikori'] = {feet="Kas. Sune-Ate +1"}

    -- Fast cast sets for spells
    sets.precast.FC = {neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",hands="Leyline Gloves",ring1="Lebeche Ring",ring2="Prolix Ring"}
	   
    -- Ranged snapshot gear
    sets.precast.RA = {}
	   
    -- Weaponskill sets
    -- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {ammo="Knobkierrie",
        head=gear.valorous_wsd_head,neck="Fotia Gorget",ear1="Thrud Earring",ear2="Moonshade Earring",
        body="Sakonji Domaru +3",hands="Wakido Kote +3",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
        back=gear.ws_jse_back,waist="Sailfi Belt +1",legs="Wakido Haidate +3",feet=gear.valorous_wsd_feet}
    
    sets.precast.WS.SomeAcc = set_combine(sets.precast.WS, {feet="Wakido Sune. +2"})
	sets.precast.WS.Acc = set_combine(sets.precast.WS, {head="Wakido Kabuto +2",body="Sakonji Domaru +3",feet="Wakido Sune. +2"})
    sets.precast.WS.FullAcc = set_combine(sets.precast.WS, 
    {head="Wakido Kabuto +2",neck="Samurai's Nodowa +2",ear1="Mache Earring +1",
    ear2="Telos Earring",body="Sakonji Domaru +3",hands="Wakido Kote +3",ring2="Karieyh Ring",feet="Wakido Sune. +2"})
    sets.precast.WS.Fodder = set_combine(sets.precast.WS, {})
	
	sets.precast.WS.Proc = {ammo="Hasty Pinion +1",
        head="Flam. Zucchetto +2",neck="Samurai's Nodowa +2",ear1="Mache Earring +1",ear2="Telos Earring",
        body="Tartarus Platemail",hands="Flam. Manopolas +2",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
        back=gear.stp_jse_back,waist="Olseni Belt",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}
	
    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Tachi: Fudo'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Fudo'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Tachi: Fudo'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Fudo'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Tachi: Fudo'].Fodder = set_combine(sets.precast.WS.Fodder, {})
	
    sets.precast.WS['Tachi: Shoha'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Shoha'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Tachi: Shoha'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Shoha'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Tachi: Shoha'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Tachi: Rana'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Rana'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Tachi: Rana'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Rana'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Tachi: Rana'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Tachi: Kasha'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Kasha'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Tachi: Kasha'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Kasha'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Tachi: Kasha'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Tachi: Gekko'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Gekko'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Tachi: Gekko'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Gekko'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Tachi: Gekko'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Tachi: Yukikaze'] = set_combine(sets.precast.WS, {})
    sets.precast.WS['Tachi: Yukikaze'].SomeAcc = set_combine(sets.precast.WS.SomeAcc, {})
    sets.precast.WS['Tachi: Yukikaze'].Acc = set_combine(sets.precast.WS.Acc, {})
    sets.precast.WS['Tachi: Yukikaze'].FullAcc = set_combine(sets.precast.WS.FullAcc, {})
    sets.precast.WS['Tachi: Yukikaze'].Fodder = set_combine(sets.precast.WS.Fodder, {})

    sets.precast.WS['Tachi: Ageha'] = {ammo="Pemphredo Tathlum",
        head="Flam. Zucchetto +2",neck="Samurai's Nodowa +2",ear1="Digni. Earring",ear2="Moonshade Earring",
        body="Flamma Korazin +2",hands="Flam. Manopolas +2",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
        back=gear.ws_jse_back,waist="Eschan Stone",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}
		
    sets.precast.WS['Tachi: Hobaku'] = {ammo="Pemphredo Tathlum",
        head="Flam. Zucchetto +2",neck="Samurai's Nodowa +2",ear1="Digni. Earring",ear2="Moonshade Earring",
        body="Flamma Korazin +2",hands="Flam. Manopolas +2",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
        back=gear.ws_jse_back,waist="Eschan Stone",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}
		
    sets.precast.WS['Tachi: Jinpu'] = {ammo="Knobkierrie",
        head=gear.valorous_magical_wsd_head,neck="Fotia Gorget",ear1="Friomisi Earring",ear2="Moonshade Earring",
        body="Sacro Breastplate",hands="Founder's Gauntlets",ring1="Epaminondas's Ring",ring2="Karieyh Ring",
        back=gear.ws_jse_back,waist="Eschan Stone",legs="Wakido Haidate +3",feet="Founder's Greaves"}

    sets.precast.WS['Apex Arrow'] = {
        head="Ynglinga Sallet",neck="Fotia Gorget",ear1="Clearview Earring",ear2="Moonshade Earring",
        body="Kyujutsugi",hands="Buremte Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back=gear.ws_jse_back,waist="Fotia Belt",legs="Wakido Haidate +3",feet="Wakido Sune. +2"}
		
    sets.precast.WS['Apex Arrow'].SomeAcc = set_combine(sets.precast.WS['Apex Arrow'], {})
    sets.precast.WS['Apex Arrow'].Acc = set_combine(sets.precast.WS['Apex Arrow'], {})
    sets.precast.WS['Apex Arrow'].FullAcc = set_combine(sets.precast.WS['Apex Arrow'], {})
    sets.precast.WS['Apex Arrow'].Fodder = set_combine(sets.precast.WS['Apex Arrow'], {})

	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Thrud Earring",ear2="Lugra Earring +1",}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.AccDayMaxTPWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayMaxTPWSEars = {ear1="Thrud Earring",ear2="Brutal Earring",}
	sets.AccDayWSEars = {ear1="Mache Earring +1",ear2="Telos Earring"}
	sets.DayWSEars = {ear1="Thrud Earring",ear2="Moonshade Earring",}
	
    -- Midcast Sets
    sets.midcast.FastRecast = {
        head="Loess Barbuta +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
        body="Tartarus Platemail",hands="Leyline Gloves",ring1="Defending Ring",ring2="Prolix Ring",
        back="Moonlight Cape",waist="Tempus Fugit",legs="Wakido Haidate +3",feet="Amm Greaves"}
		
    -- Specific spells
    sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {back="Mujin Mantle"})
	
		
    -- Ranged gear
    sets.midcast.RA = {
        head="Flam. Zucchetto +2",neck="Combatant's Torque",ear1="Clearview Earring",ear2="Neritic Earring",
        body="Kyujutsugi",hands="Buremte Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back="Buquwik Cape",waist="Flax Sash",legs="Wakido Haidate +3",feet="Wakido Sune. +2"}

    sets.midcast.RA.Acc = {
        head="Flam. Zucchetto +2",neck="Combatant's Torque",ear1="Clearview Earring",ear2="Neritic Earring",
        body="Kyujutsugi",hands="Buremte Gloves",ring1="Ilabrat Ring",ring2="Regal Ring",
        back="Buquwik Cape",waist="Flax Sash",legs="Wakido Haidate +3",feet="Wakido Sune. +2"}


    -- Sets to return to when not performing an action.
    
    -- Resting sets
    sets.resting = {ammo="Staunch Tathlum +1",
        head=gear.valorous_wsd_head,neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Hiza. Haramaki +2",hands="Sakonji Kote +1",ring1="Defending Ring",ring2="Dark Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}


    -- Idle sets (default idle set not needed since the other three are defined, but leaving for testing purposes)

	sets.Kiting = {feet="Danzo Sune-ate"}

    sets.Reraise = {head="Twilight Helm",body="Twilight Mail"}

	sets.TreasureHunter = set_combine(sets.TreasureHunter, {})
	sets.Skillchain = {}
	
    sets.idle = {ammo="Staunch Tathlum +1",
        head="Wakido Kabuto +2",neck="Loricate Torque",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Hiza. Haramaki +2",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Karieyh Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs="Wakido Haidate +3",feet="Danzo Sune-ate"}
		
    sets.idle.Reraise = set_combine(sets.idle, sets.Reraise)

    sets.idle.Weak = {ammo="Staunch Tathlum +1",
        head="Twilight Helm",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Twilight Mail",hands="Sakonji Kote +1",ring1="Defending Ring",ring2="Dark Ring",
        back="Moonlight Cape",waist="Flume Belt +1",legs="Wakido Haidate +3",feet="Danzo Sune-ate"}
		
    sets.idle.Weak.Reraise = set_combine(sets.idle.Weak, sets.Reraise)
	
	sets.DayIdle = {}
	sets.NightIdle = {}
    
    -- Defense sets
    sets.defense.PDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back="Moonlight Cape",waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.defense.PDTReraise = set_combine(sets.defense.PDT, sets.Reraise)
		
    sets.defense.MDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Warder's Charm +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Shadow Ring",
        back="Moonlight Cape",waist="Flax Sash",legs="Wakido Haidate +3",feet="Amm Greaves"}
		
	sets.defense.MDTReraise = set_combine(sets.defense.MDT, sets.Reraise)
	
    sets.defense.MEVA = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Warder's Charm +1",ear1="Etiolation Earring",ear2="Sanare Earring",
		body="Tartarus Platemail",hands="Leyline Gloves",ring1="Vengeful Ring",Ring2="Purity Ring",
        back="Moonlight Cape",waist="Flax Sash",legs="Wakido Haidate +3",feet="Amm Greaves"}

    -- Engaged sets

    -- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
    -- sets if more refined versions aren't defined.
    -- If you create a set with both offense and defense modes, the offense mode should be first.
    -- EG: sets.engaged.Dagger.Accuracy.Evasion
    
    -- Normal melee group
    -- Delay 450 GK, 25 Save TP => 65 Store TP for a 5-hit (25 Store TP in gear)
    sets.engaged = {ammo="Aurgelmir Orb +1",
        head="Flam. Zucchetto +2",neck="Samurai's Nodowa +2",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Kasuga Domaru +1",hands="Wakido Kote +3",ring1="Flamma Ring",ring2="Petrov Ring",
        back=gear.stp_jse_back,waist="Sailfi Belt +1",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}

    sets.engaged.SomeAcc = {ammo="Aurgelmir Orb +1",
        head="Flam. Zucchetto +2",neck="Samurai's Nodowa +2",ear1="Cessance Earring",ear2="Telos Earring",
        body="Ken. Samue",hands="Wakido Kote +3",ring1="Niqmaddu Ring",ring2="Flamma Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}

    sets.engaged.Acc = {ammo="Aurgelmir Orb +1",
        head="Wakido Kabuto +2",neck="Samurai's Nodowa +2",ear1="Digni. Earring",ear2="Telos Earring",
        body="Ken. Samue",hands="Wakido Kote +3",ring1="Niqmaddu Ring",ring2="Regal Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Flam. Gambieras +2"}

    sets.engaged.FullAcc = {ammo="Aurgelmir Orb +1",
        head="Wakido Kabuto +2",neck="Samurai's Nodowa +2",ear1="Mache Earring +1",ear2="Telos Earring",
        body="Ken. Samue",hands="Wakido Kote +3",ring1="Ramuh Ring +1",ring2="Regal Ring",
        back=gear.stp_jse_back,waist="Olseni Belt",legs="Wakido Haidate +3",feet="Wakido Sune. +2"}

    sets.engaged.Fodder = {ammo="Aurgelmir Orb +1",
        head="Flam. Zucchetto +2",neck="Samurai's Nodowa +2",ear1="Dedition Earring",ear2="Brutal Earring",
        body="Kasuga Domaru +1",hands=gear.valorous_acc_hands,ring1="Niqmaddu Ring",ring2="Petrov Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Ryuo Hakama",feet="Flam. Gambieras +2"}

    sets.engaged.PDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Dark Ring",
        back="Moonlight Cape",waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.SomeAcc.PDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back="Moonlight Cape",waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.Acc.PDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back="Moonlight Cape",waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.FullAcc.PDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back="Moonlight Cape",waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.Fodder.PDT = {ammo="Staunch Tathlum +1",
        head="Loess Barbuta +1",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Sanare Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Dark Ring",
        back="Moonlight Cape",waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

	sets.engaged.DTLite = {ammo="Staunch Tathlum +1",
        head="Ynglinga Sallet",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.SomeAcc.DTLite = {ammo="Staunch Tathlum +1",
        head="Ynglinga Sallet",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Tartarus Platemail",hands=gear.valorous_acc_hands,ring1="Defending Ring",ring2="Patricius Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.Acc.DTLite = {ammo="Staunch Tathlum +1",
        head="Ynglinga Sallet",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.FullAcc.DTLite = {ammo="Staunch Tathlum +1",
        head="Ynglinga Sallet",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}

    sets.engaged.Fodder.DTLite = {ammo="Staunch Tathlum +1",
        head="Flam. Zucchetto +2",neck="Loricate Torque +1",ear1="Cessance Earring",ear2="Brutal Earring",
        body="Tartarus Platemail",hands="Wakido Kote +3",ring1="Defending Ring",ring2="Patricius Ring",
        back=gear.stp_jse_back,waist="Ioskeha Belt",legs="Wakido Haidate +3",feet="Amm Greaves"}


    sets.engaged.Reraise = set_combine(sets.engaged, sets.Reraise)
    sets.engaged.SomeAcc.Reraise = set_combine(sets.engaged.SomeAcc, sets.Reraise)
    sets.engaged.Acc.Reraise = set_combine(sets.engaged.Acc, sets.Reraise)
    sets.engaged.FullAcc.Reraise = set_combine(sets.engaged.FullAcc, sets.Reraise)
    sets.engaged.Fodder.Reraise = set_combine(sets.engaged.Fodder, sets.Reraise)

	-- Weapons sets
	sets.weapons.Dojikiri = {main="Dojikiri Yasutsuna",sub="Utu Grip"}
	sets.weapons.ProcWeapon = {main="Norifusa +1",sub="Bloodrain Strap"}
	sets.weapons.Bow = {main="Norifusa +1",sub="Utu Grip",range="Cibitshavore",ammo="Eminent Arrow"}
	
	-- Buff sets
	sets.Cure_Received = {hands="Buremte Gloves",waist="Gishdubar Sash",legs="Wakido Haidate +3"}
	sets.buff.Doom = set_combine(sets.buff.Doom, {})
	sets.buff.Sleep = {neck="Vim Torque +1"}
	sets.buff.Hasso = {hands="Wakido Kote +3"}
	sets.buff['Third Eye'] = {} --legs="Sakonji Haidate +3"
    sets.buff.Sekkanoki = {hands="Kasuga Kote +1"}
    sets.buff.Sengikori = {feet="Kas. Sune-Ate +1"}
    sets.buff['Meikyo Shisui'] = {feet="Sak. Sune-Ate +1"}
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    set_macro_page(1, 6)
end
