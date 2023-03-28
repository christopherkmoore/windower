function user_job_setup()
	-- Options: Override default values
    state.OffenseMode:options('Normal','Acc')
    state.CastingMode:options('Normal','Resistant','AoE')
    state.IdleMode:options('Normal','NoRefresh','DT')
	state.Weapons:options('None','Aeneas','DualWeapons','DualNaegling','DualTauret','DualNukeWeapons')

	-- Adjust this if using the Terpander (new +song instrument)
    info.ExtraSongInstrument = 'Blurred Harp +1'
	-- How many extra songs we can keep from Daurdabla/Terpander
    info.ExtraSongs = 1
	
	-- Set this to false if you don't want to use custom timers.
    state.UseCustomTimers = M(false, 'Use Custom Timers')
	
	-- Additional local binds
    send_command('bind ^` gs c cycle ExtraSongsMode')
	send_command('bind !` input /ma "Chocobo Mazurka" <me>')
	send_command('bind @` gs c cycle MagicBurstMode')
	send_command('bind @f10 gs c cycle RecoverMode')
	send_command('bind @f8 gs c toggle AutoNukeMode')
	send_command('bind !q gs c weapons NukeWeapons;gs c update')
	send_command('bind ^q gs c weapons Swords;gs c update')

	select_default_macro_book()
end

function init_gear_sets()

	sets.warp = set_combine(sets.idle, {ring2="Warp Ring"})

	-- commented out because something in here was causing the head to be set to empty (couldn't equip anything). can remake as I get gear. CKM
	--------------------------------------
	-- Start defining the sets
	--------------------------------------

	-- Weapons sets
	sets.weapons.Aeneas = {main="Aeneas",sub="Genmei Shield"}
	sets.weapons.DualWeapons = {main="Aeneas",sub="Blurred Knife +1"}
	sets.weapons.DualNaegling = {main="Naegling",sub="Blurred Knife +1"}
	sets.weapons.DualTauret = {main="Tauret",sub="Blurred Knife +1"}
	sets.weapons.DualNukeWeapons = {main="Malevolence",sub="Malevolence"}

    sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
	
	-- Precast Sets

	-- Fast cast sets for spells
	sets.precast.FC = {main="Kali",sub="Clerisy Strap +1",ammo="Impatiens",
		head="Fili Calot +2",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Inyanga Jubbah +1",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Weatherspoon Ring",                              --ring2="Lebeche Ring",  
		back=gear.capeFC,waist="Witful Belt",legs="Aya. Cosciales +2",feet="Fili Cothurnes +2"}

	sets.precast.FC.Cure = set_combine(sets.precast.FC, {feet="Vanya Clogs"})

	sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})
	
	sets.precast.FC.BardSong = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",range="Gjallarhorn",ammo=empty,
		head="Fili Calot +2",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Inyanga Jubbah +1",hands="Leyline Gloves",ring1="Kishar Ring", ring2="Weatherspoon Ring",                             -- ring2="Lebeche Ring",
		back=gear.capeFC,waist="Witful Belt",legs="Aya. Cosciales +2",feet="Fili Cothurnes +2"}

	sets.precast.FC.SongDebuff = set_combine(sets.precast.FC.BardSong,{range="Marsyas"})
	sets.precast.FC.SongDebuff.Resistant = set_combine(sets.precast.FC.BardSong,{range="Gjallarhorn"})
	sets.precast.FC.Lullaby = {range="Marsyas"}
	sets.precast.FC.Lullaby.Resistant = {range="Gjallarhorn"}
	sets.precast.FC['Horde Lullaby'] = {range="Marsyas"}
	sets.precast.FC['Horde Lullaby'].Resistant = {range="Gjallarhorn"}
	sets.precast.FC['Horde Lullaby'].AoE = {range="Gjallarhorn"}
	sets.precast.FC['Horde Lullaby II'] = {range="Marsyas"}
	sets.precast.FC['Horde Lullaby II'].Resistant = {range="Gjallarhorn"}
	sets.precast.FC['Horde Lullaby II'].AoE = {range="Gjallarhorn"}
		
	sets.precast.FC.Mazurka = set_combine(sets.precast.FC.BardSong,{range="Marsyas"})
	sets.precast.FC['Honor March'] = set_combine(sets.precast.FC.BardSong,{range="Marsyas"})

	sets.precast.FC.Daurdabla = set_combine(sets.precast.FC.BardSong, {range=info.ExtraSongInstrument})
	sets.precast.DaurdablaDummy = sets.precast.FC.Daurdabla
		
	
	-- Precast sets to enhance JAs
	
	sets.precast.JA.Nightingale = {feet="Bihu Slippers +1"}
	sets.precast.JA.Troubadour = {body="Bihu Jstcorps +1"}
	sets.precast.JA['Soul Voice'] = {legs="Bihu Cannions +1"}

	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}

	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {ammo="Hasty Pinion +1",
		head="Fili Calot +2",neck="Sanctity Necklace",ear1="Moonshade Earring",ear2="Ishvara Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Ramuh Ring +1",ring2="Ilabrat Ring",
		back="Ground. Mantle +1",waist="Grunfeld Rope",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}


	sets.precast["Savage Blade"] = set_combine(sets.precast.WS, {
		back=gear.cape_ws_sb
	})
		
		
	-- Swap to these on Moonshade using WS if at 3000 TP
	sets.MaxTP = {ear1="Ishvara Earring",ear2="Telos Earring",}
	sets.AccMaxTP = {ear1="Mache Earring +1",ear2="Telos Earring"}

	-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.


	-- Midcast Sets

	-- General set for recast times.
	sets.midcast.FastRecast = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",ammo="Hasty Pinion +1",
		head="Nahtirah Hat",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Inyanga Jubbah +1",hands="Leyline Gloves",ring1="Kishar Ring",ring2="Lebeche Ring",
		back=gear.capeFC,waist="Witful Belt",legs="Aya. Cosciales +2",feet="Gende. Galosh. +1"}

	-- Gear to enhance certain classes of songs
	sets.midcast.Ballad = {legs="Fili Rhingrave +2"}
	sets.midcast.Lullaby = {range="Marsyas"}
	sets.midcast.Lullaby.Resistant = {range="Gjallarhorn"}
	sets.midcast['Horde Lullaby'] = {range="Marsyas"}
	sets.midcast['Horde Lullaby'].Resistant = {range="Gjallarhorn"}
	sets.midcast['Horde Lullaby'].AoE = {range="Gjallarhorn"}
	sets.midcast['Horde Lullaby II'] = {range="Marsyas"}
	sets.midcast['Horde Lullaby II'].Resistant = {range="Gjallarhorn"}
	sets.midcast['Horde Lullaby II'].AoE = {range="Gjallarhorn"}
	sets.midcast.Madrigal = {head="Fili Calot +2"}
	sets.midcast.Paeon = {}
	sets.midcast.March = {hands="Fili Manchettes +2"}
	sets.midcast['Honor March'] = set_combine(sets.midcast.March,{range="Marsyas"})
	sets.midcast.Minuet = {body="Fili Hongreline +2"}
	sets.midcast.Minne = {}
	sets.midcast.Carol = {}
	sets.midcast["Sentinel's Scherzo"] = {feet="Fili Cothurnes +2"}
	sets.midcast['Magic Finale'] = {range="Gjallarhorn"}
	sets.midcast.Mazurka = {range="Marsyas"}
	sets.midcast["Knight's Minne"] = set_combine(sets.precast.FC.BardSong, sets.precast.DaurdablaDummy)
	sets.midcast["Knight's Minne II"] = set_combine(sets.precast.FC.BardSong, sets.precast.DaurdablaDummy)

	-- For song buffs (duration and AF3 set bonus)
	sets.midcast.SongEffect = {main="Kali",sub="Genmei Shield",range="Gjallarhorn",ammo=empty,
		head="Fili Calot +2",neck="Moonbow Whistle +1",ear1="Bragi Earring",ear2="Dellingr Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Stikini Ring +1", ring2="Weatherspoon Ring",                                      -- ring2="Stikini Ring +1",
		back=gear.capeFC,waist="Witful Belt",legs="Inyanga Shalwar +2",feet="Fili Cothurnes +2"}
		
	sets.midcast.SongEffect.DW = {main="Kali",sub="Kali"}

	-- For song defbuffs (duration primary, accuracy secondary)
	sets.midcast.SongDebuff = {main="Kali",sub="Ammurapi Shield",range="Gjallarhorn",ammo=empty,
		head="Fili Calot +2",neck="Moonbow Whistle +1",ear1="Bragi Earring",ear2="Dellingr Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Stikini Ring +1",ring2="Weatherspoon Ring",                                   --ring2="Stikini Ring +1",
		back=gear.capeFC,waist="Harfner's Sash",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}
		
	sets.midcast.SongDebuff.DW = {main="Kali",sub="Kali"}

	-- For song defbuffs (accuracy primary, duration secondary)
	sets.midcast.SongDebuff.Resistant = {main="Daybreak",sub="Ammurapi Shield",range="Gjallarhorn",ammo=empty,
		head="Fili Calot +2",neck="Moonbow Whistle +1",ear1="Regal Earring",ear2="Digni. Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Stikini Ring +1", ring2="Weatherspoon Ring",                                    --ring2="Stikini Ring +1",
		back=gear.capeFC,waist="Acuity Belt +1",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}

	-- Song-specific recast reduction
	sets.midcast.SongRecast = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",range="Gjallarhorn",ammo=empty,
		head="Fili Calot +2",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Loquac. Earring",
		body="Fili Hongreline +2",hands="Gendewitha Gages +1",ring1="Kishar Ring",ring2="Prolix Ring",
		back=gear.capeFC,waist="Witful Belt",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}
		
	sets.midcast.SongDebuff.DW = {}

	-- Cast spell with normal gear, except using Daurdabla instead
    sets.midcast.Daurdabla = {range=info.ExtraSongInstrument}

	-- Dummy song with Daurdabla; minimize duration to make it easy to overwrite.
    sets.midcast.DaurdablaDummy = set_combine(sets.midcast.SongRecast, {range=info.ExtraSongInstrument})

	-- Other general spells and classes.
	sets.midcast.Cure = {main="Serenity",sub="Curatio Grip",ammo="Pemphredo Tathlum",
        head="Gende. Caubeen +1",neck="Incanter's Torque",ear1="Gifted Earring",ear2="Mendi. Earring",
        body="Kaykaus Bliaut",hands="Kaykaus Cuffs",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Tempered Cape +1",waist="Luminary Sash",legs="Carmine Cuisses +1",feet="Kaykaus Boots"}
		
	sets.midcast.Curaga = sets.midcast.Cure
		
	sets.Self_Healing = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",hands="Buremte Gloves",ring2="Kunaji Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {back="Grapevine Cape",waist="Gishdubar Sash"}
		
	sets.midcast['Enhancing Magic'] = {main="Serenity",sub="Fulcio Grip",ammo="Hasty Pinion +1",
		head="Telchine Cap",neck="Voltsurge Torque",ear1="Andoaa Earring",ear2="Gifted Earring",
		body="Telchine Chas.",hands="Telchine Gloves",ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back=gear.capeFC,waist="Embla Sash",legs="Telchine Braconi",feet="Telchine Pigaches"}
		
	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
		
	sets.midcast['Elemental Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
		head="C. Palug Crown",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Crematio Earring",
		body="Chironic Doublet",hands="Volte Gloves",ring1="Shiva Ring +1",ring2="Shiva Ring +1",
		back="Toro Cape",waist="Sekhmet Corset",legs="Gyve Trousers",feet=gear.chironic_nuke_feet}
		
	sets.midcast['Elemental Magic'].Resistant = {main="Daybreak",sub="Ammurapi Shield",ammo="Dosis Tathlum",
		head="C. Palug Crown",neck="Sanctity Necklace",ear1="Friomisi Earring",ear2="Crematio Earring",
		body="Chironic Doublet",hands="Volte Gloves",ring1="Shiva Ring +1",ring2="Shiva Ring +1",
		back="Toro Cape",waist="Yamabuki-no-Obi",legs="Gyve Trousers",feet=gear.chironic_nuke_feet}
		
	sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {neck="Debilis Medallion",hands="Hieros Mittens",
		back="Oretan. Cape +1",ring1="Haoma's Ring",ring2="Menelaus's Ring",waist="Witful Belt",feet="Vanya Clogs"})
		
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main=gear.grioavolr_fc_staff,sub="Clemency Grip"})

	-- Resting sets
	sets.resting = {main="Chatoyant Staff",sub="Oneiros Grip",ammo="Staunch Tathlum +1",
		head="Fili Calot +2",neck="Loricate Torque",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Defending Ring",ring2="Dark Ring",                            --body="Respite Cloak" resting, idle, defense.PDT, defense.MDT repalced CKM
		back="Umbra Cape",waist="Flume Belt +1",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}
	
	sets.idle = {sub="Genmei Shield",ammo="Staunch Tathlum +1",                                                           -- main="Daybreak" removed from idle, .NoRefresh and .DT
		head="Fili Calot +2",neck="Loricate Torque",ear1="Eabani Earring",ear2="Ethereal Earring",                                     
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back=gear.capeTP,waist="Flume Belt +1",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}
		
	sets.idle.NoRefresh = {sub="Genmei Shield",ammo="Staunch Tathlum +1",
		head="Fili Calot +2",neck="Loricate Torque",ear1="Etiolation Earring",ear2="Sanare Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Defending Ring",ring2="Shadow Ring",
		back="Moonlight Cape",waist="Carrier's Sash",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}

	sets.idle.DT = {sub="Genmei Shield",ammo="Staunch Tathlum +1",
		head="Fili Calot +2",neck="Loricate Torque",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Defending Ring",ring2="Shadow Ring",
		back="Moonlight Cape",waist="Flume Belt +1",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}
	
	-- Defense sets

	sets.defense.PDT = {main="Terra's Staff", sub="Umbra Strap",ammo="Staunch Tathlum +1",
		head="Fili Calot +2",neck="Loricate Torque",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flume Belt +1",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}

	sets.defense.MDT = {main="Terra's Staff", sub="Umbra Strap",ammo="Staunch Tathlum +1",
		head="Fili Calot +2",neck="Loricate Torque",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Fili Hongreline +2",hands="Fili Manchettes +2",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flume Belt +1",legs="Fili Rhingrave +2",feet="Fili Cothurnes +2"}

	sets.Kiting = {feet="Fili Cothurnes +2"}
	sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.TPEat = {neck="Chrys. Torque"}

	-- Engaged sets

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion
	
	sets.engaged = {main="Naegling",sub="Genmei Shield",ammo="Aurgelmir Orb +1",
		head="Fili Calot +2",neck="Bard's Charm +1",ear1="Cessance Earring",ear2="Brutal Earring",
		body="Ayanmo Corazza +2",hands="Fili Manchettes +2",ring1="Petrov Ring",ring2="Rajas Ring",
		back=gear.capeTP,waist="Sailfi Belt +1",legs="Fili Rhingrave +2",feet="Aya. Gambieras +2"}                                   -- back="Bleating Mantle"
	sets.engaged.Acc = {main="Naegling",sub="Genmei Shield",ammo="Aurgelmir Orb +1",
		head="Fili Calot +2",neck="Bard's Charm +1",ear1="Digni. Earring",ear2="Telos Earring",
		body="Ayanmo Corazza +2",hands="Fili Manchettes +2",ring1="Ramuh Ring +1",ring2="Ilabrat Ring",
		back=gear.capeTP,waist="Olseni Belt",legs="Fili Rhingrave +2",feet="Aya. Gambieras +2"}                                        -- back="Letalis Mantle"
	sets.engaged.DW = {main="Naegling",sub="Kali",ammo="Aurgelmir Orb +1",
		head="Fili Calot +2",neck="Bard's Charm +1",ear1="Suppanomimi",ear2="Brutal Earring",
		body="Ayanmo Corazza +2",hands="Fili Manchettes +2",ring1="Rajas Ring",ring2="Ilabrat Ring",
		back=gear.capeTP ,waist="Sailfi Belt +1",legs="Fili Rhingrave +2",feet="Aya. Gambieras +2"}                                         -- back="Bleating Mantle"
	sets.engaged.DW.Acc = {main="Naegling",sub="Kali",ammo="Aurgelmir Orb +1",
		head="Fili Calot +2",neck="Bard's Charm +1",ear1="Suppanomimi",ear2="Telos Earring",
		body="Ayanmo Corazza +2",hands="Fili Manchettes +2",ring1="Ramuh Ring +1",ring2="Ilabrat Ring",
		back=gear.capeTP,waist="Reiki Yotai",legs="Fili Rhingrave +2",feet="Aya. Gambieras +2"}

		sets.moving = { feet="Fili Cothurnes +2" }

end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	set_macro_page(10, 10)
end