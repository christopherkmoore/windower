function user_job_setup()

	-- Options: Override default values
    state.OffenseMode:options('Normal')
	state.CastingMode:options('Normal', 'Resistant', 'Fodder', 'Proc')
    state.IdleMode:options('Normal','PDT')
	state.PhysicalDefenseMode:options('PDT', 'NukeLock', 'GeoLock', 'PetPDT')
	state.MagicalDefenseMode:options('MDT', 'NukeLock')
	state.ResistDefenseMode:options('MEVA')
	state.Weapons:options('None','Nehushtan','DualWeapons')
	
	gear.obi_cure_back = "Tempered Cape +1"
	gear.obi_cure_waist = "Witful Belt"

	gear.obi_low_nuke_back = gear.capeMB
	gear.obi_low_nuke_waist = "Sekhmet Corset"

	gear.obi_high_nuke_back = gear.capeMB
	gear.obi_high_nuke_waist = "Refoccilation Stone"
	
	autoindi = "Haste"
	autogeo = "Frailty"
	
	-- Additional local binds
	send_command('bind ^` gs c cycle ElementalMode')
	send_command('bind !` input /ja "Full Circle" <me>')
	send_command('bind @f8 gs c toggle AutoNukeMode')
	send_command('bind @` gs c cycle MagicBurstMode')
	send_command('bind @f10 gs c cycle RecoverMode')
	send_command('bind ^backspace input /ja "Entrust" <me>')
	send_command('bind !backspace input /ja "Life Cycle" <me>')
	send_command('bind @backspace input /ma "Sleep II" <t>')
	send_command('bind ^delete input /ma "Aspir III" <t>')
	send_command('bind @delete input /ma "Sleep" <t>')
	
	indi_duration = 290
	
	select_default_macro_book()
end

function init_gear_sets()
	

	sets.warp = set_combine(sets.idle, {ring2="Warp Ring"})

	--------------------------------------
	-- Precast sets
	--------------------------------------

	-- Precast sets to enhance JAs
	sets.precast.JA.Bolster = {body="Bagua Tunic +1"}
	sets.precast.JA['Life Cycle'] = {body="Geomancy Tunic +2",back=gear.cape_loupan_idle}
	sets.precast.JA['Radial Arcana'] = {feet="Bagua Sandals +1"}
	sets.precast.JA['Mending Halation'] = {legs="Bagua Pants +1"}
	sets.precast.JA['Full Circle'] = {head="Azimuth Hood +2",hands="Bagua Mitaines +1"}
	
	-- Indi Duration in slots that would normally have skill here to make entrust more efficient.
	sets.buff.Entrust = {}
	
	-- Relic hat for Blaze of Glory HP increase.
	sets.buff['Blaze of Glory'] = {}
	
	-- Fast cast sets for spells

	sets.precast.FC = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",ammo="Impatiens",
		head="Psycloth Tiara",neck="Voltsurge Torque",ear1="Malignance earring",ear2="Azimuth Earring",
		body="Vrikodara Jupon",hands="Volte Gloves",ring1="Kishar Ring",ring2="Weatherspoon Ring",                                                          --ring2="Lebeche Ring",
		back=gear.capeFC,waist="Witful Belt",legs="Geo. Pants +2",feet="Regal Pumps"}

	sets.precast.FC.Geomancy = set_combine(sets.precast.FC, {range="Dunna",ammo=empty})
	
    sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {ear2="Malignance earring",hands="Bagua Mitaines +1"})

	sets.precast.FC.Cure = set_combine(sets.precast.FC, {main="Serenity",sub="Clerisy Strap +1"})
		
	sets.precast.FC.Curaga = sets.precast.FC.Cure
	
	sets.Self_Healing = {neck="Phalaina Locket",ring1="Kunaji Ring",ring2="Asklepian Ring",waist="Gishdubar Sash"}
	sets.Cure_Received = {neck="Phalaina Locket",ring1="Kunaji Ring",ring2="Asklepian Ring",waist="Gishdubar Sash"}
	sets.Self_Refresh = {back="Grapevine Cape",waist="Gishdubar Sash",feet="Inspirited Boots"}
	
    sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})

    sets.precast.FC.Stoneskin = set_combine(sets.precast.FC['Enhancing Magic'], {})

	sets.precast.FC.Impact = {ammo="Impatiens",
		head=empty,neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Malignance earring",
		body="Twilight Cloak",hands="Volte Gloves",ring1="Kishar Ring",ring2="Lebeche Ring",
		back="Lifestream Cape",waist="Witful Belt",legs="Geo. Pants +2",feet="Regal Pumps"}
		
	sets.precast.FC.Dispelga = set_combine(sets.precast.FC, {main="Daybreak",sub="Genmei Shield"})
	
	-- Weaponskill sets
	-- Default set for any weaponskill that isn't any more specifically defined
	sets.precast.WS = {}


	--------------------------------------
	-- Midcast sets
	--------------------------------------

    sets.midcast.FastRecast = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",
		head="Amalric Coif +1",neck="Voltsurge Torque",ear1="Enchntr. Earring +1",ear2="Malignance earring",
		body="Zendik Robe",hands="Volte Gloves",ring1="Kishar Ring",ring2="Prolix Ring",
		back="Lifestream Cape",waist="Witful Belt",legs="Geo. Pants +2",feet="Regal Pumps"}

	sets.midcast.Geomancy = {main="Solstice",sub="Genmei Shield",range="Dunna",
		head="Azimuth Hood +2",neck="Bagua Charm +1",ear1="Gna Earring",ear2="Fulla Earring",           -- neck="Incanter's Torque" ,ear1="Gifted Earring",ear2="Malignance earring",  
		body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Defending Ring",ring2="Dark Ring",
		back="Solemnity Cape",waist="Austerity Belt",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}


	--Extra Indi duration as long as you can keep your 900 skill cap.
	sets.midcast.Geomancy.Indi = set_combine(sets.midcast.Geomancy, {back="Lifestream Cape",legs="Bagua Pants +1",feet="Azimuth Gaiters +2"})
		
    sets.midcast.Cure = {main=gear.gada_healing_club,sub="Sors Shield",ammo="Hasty Pinion +1",
        head="Amalric Coif +1",neck="Incanter's Torque",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Telchine Gloves",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Tempered Cape +1",waist="Witful Belt",legs="Geo. Pants +2",feet="Vanya Clogs"}
		
    sets.midcast.LightWeatherCure = {main="Chatoyant Staff",sub="Kaja Grip",ammo="Hasty Pinion +1",
        head="Amalric Coif +1",neck="Phalaina Locket",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Vrikodara Jupon",hands="Telchine Gloves",ring1="Janniston Ring",ring2="Menelaus's Ring",
        back="Twilight Cape",waist="Hachirin-no-Obi",legs="Geo. Pants +2",feet="Vanya Clogs"}
		
		--Cureset for if it's not light weather but is light day.
    sets.midcast.LightDayCure = {main=gear.gada_healing_club,sub="Sors Shield",ammo="Hasty Pinion +1",
        head="Amalric Coif +1",neck="Incanter's Torque",ear1="Gifted Earring",ear2="Etiolation Earring",
        body="Zendik Robe",hands="Telchine Gloves",ring1="Janniston Ring",ring2="Lebeche Ring",
        back="Twilight Cape",waist="Hachirin-no-Obi",legs="Geo. Pants +2",feet="Vanya Clogs"}

    sets.midcast.Curaga = set_combine(sets.midcast.Cure, {main="Daybreak",sub="Sors Shield"})

	sets.midcast.Cursna =  set_combine(sets.midcast.Cure, {neck="Debilis Medallion",hands="Hieros Mittens",
		back="Oretan. Cape +1",ring1="Haoma's Ring",ring2="Menelaus's Ring",waist="Witful Belt",feet="Vanya Clogs"})
	
	sets.midcast.StatusRemoval = set_combine(sets.midcast.FastRecast, {main=gear.grioavolr_fc_staff,sub="Clemency Grip"})
	
	sets.midcast['Elemental Magic'] = {main=gear.grioavolr_MB,ammo="Dosis Tathlum",
		head="Geo. Galero +2",neck="Sanctity Necklace",ear1="Malignance earring",ear2="Azimuth Earring",         -- neck="Saevus Pendant +1" replaced for Quanpur necklace           ear1="Crematio Earring"
		body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Resonance Ring",ring2="Weatherspoon Ring",
		back=gear.capeMB,waist=gear.ElementalObi,legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}

    sets.midcast['Elemental Magic'].Resistant = {main=gear.grioavolr_MB,ammo="Pemphredo Tathlum",
        head="Geo. Galero +2",neck="Sanctity Necklace",ear1="Malignance earring",ear2="Azimuth Earring",                     -- ear1="Regal Earring"
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Resonance Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist="Yamabuki-no-Obi",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
    sets.midcast['Elemental Magic'].Proc = {main=gear.grioavolr_MB,sub=empty,ammo="Impatiens",
        head="Geo. Galero +2",neck="Loricate Torque +1",ear1="Gifted Earring",ear2="Loquac. Earring",                             --head="Nahtirah Hat"
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Kishar Ring",ring2="Weatherspoon Ring",
        back="Swith Cape +1",waist="Witful Belt",legs="Azimuth Tights +2",feet="Regal Pumps"}
		
    sets.midcast['Elemental Magic'].Fodder = {main=gear.grioavolr_MB,ammo="Dosis Tathlum",
        head="Azimuth Hood +2",neck="Sanctity Necklace",ear1="Malignance earring",ear2="Azimuth Earring",
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Resonance Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist=gear.ElementalObi,legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
    sets.midcast['Elemental Magic'].HighTierNuke = {main=gear.grioavolr_MB,ammo="Pemphredo Tathlum",
        head="Geo. Galero +2",neck="Sanctity Necklace", ear1="Malignance earring",ear2="Azimuth Earring",
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Resonance Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist=gear.ElementalObi,legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
    sets.midcast['Elemental Magic'].HighTierNuke.Resistant = {main=gear.grioavolr_MB,ammo="Pemphredo Tathlum",
        head="Geo. Galero +2",neck="Sanctity Necklace",ear1="Malignance earring",ear2="Azimuth Earring",
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Resonance Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist="Yamabuki-no-Obi",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}

	sets.midcast['Elemental Magic'].HighTierNuke.Fodder = {main=gear.grioavolr_MB,ammo="Pemphredo Tathlum",
        head="Azimuth Hood +2",neck="Sanctity Necklace",ear1="Malignance earring",ear2="Azimuth Earring",
        body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Resonance Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist=gear.ElementalObi,legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
    sets.midcast['Dark Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Azimuth Hood +2",neck="Erra Pendant",ear1="Malignance Earring",ear2="Friomisi Earring",
        body="Geomancy Tunic +2",hands="Azimuth Gloves +2",ring1="Excelsis Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist="Yamabuki-no-Obi",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
    sets.midcast.Drain = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
        head="Azimuth Hood +2",neck="Erra Pendant",ear1="Malignance earring",ear2="Azimuth Earring", --head="Pixie Hairpin +1"
        body="Geomancy Tunic +2",hands="Azimuth Gloves +2",ring1="Excelsis Ring",ring2="Weatherspoon Ring",
        back=gear.capeMB,waist="Fucho-no-obi",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
    
    sets.midcast.Aspir = sets.midcast.Drain
		
	sets.midcast.Stun = {main=gear.grioavolr_fc_staff,sub="Clerisy Strap +1",ammo="Hasty Pinion +1",
		head="Amalric Coif +1",neck="Erra Pendant",ear1="Enchntr. Earring +1",ear2="Malignance earring",
		body="Zendik Robe",hands="Volte Gloves",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back="Lifestream Cape",waist="Witful Belt",legs="Psycloth Lappas",feet="Regal Pumps"}
		
	sets.midcast.Stun.Resistant = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Amalric Coif +1",neck="Erra Pendant",ear1="Regal Earring",ear2="Malignance earring",
		body="Zendik Robe",hands="Amalric Gages +1",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.capeMB,waist="Acuity Belt +1",legs="Merlinic Shalwar",feet="Azimuth Gaiters +2"}
		
	sets.midcast.Impact = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head=empty,neck="Erra Pendant",ear1="Regal Earring",ear2="Malignance earring",
		body="Twilight Cloak",hands="Regal Cuffs",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.capeMB,waist="Acuity Belt +1",legs="Merlinic Shalwar",feet=gear.merlinic_nuke_feet}
		
	sets.midcast.Dispel = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Amalric Coif +1",neck="Erra Pendant",ear1="Regal Earring",ear2="Azimuth Earring",
		body="Zendik Robe",hands="Azimuth Gloves +2",ring1="Metamor. Ring +1",ring2="Stikini Ring +1",
		back=gear.capeMB,waist="Acuity Belt +1",legs="Merlinic Shalwar",feet="Azimuth Gaiters +2"}

	sets.midcast.Dispelga = set_combine(sets.midcast.Dispel, {main="Daybreak",sub="Ammurapi Shield"})
		
	sets.midcast['Enfeebling Magic'] = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Azimuth Hood +2",neck="Sanctity Necklace",ear1="Regal Earring",ear2="Azimuth Earring",
		body="Azimuth Coat +2",hands="Azimuth Gloves +2",ring1="Etana Ring",ring2="Weatherspoon Ring",
		back=gear.capeMB,waist="Luminary Sash",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
	sets.midcast['Enfeebling Magic'].Resistant = {main="Daybreak",sub="Ammurapi Shield",ammo="Pemphredo Tathlum",
		head="Azimuth Hood +2",neck="Sanctity Necklace",ear1="Regal Earring",ear2="Azimuth Earring",
		body="Azimuth Coat +2",hands="Regal Cuffs",ring1="Etana Ring",ring2="Weatherspoon Ring",
		back=gear.capeMB,waist="Luminary Sash",legs="Azimuth Tights +2",feet="Azimuth Gaiters +2"}
		
    sets.midcast.ElementalEnfeeble = set_combine(sets.midcast['Enfeebling Magic'], {head="Amalric Coif +1",ear2="Azimuth Earring",waist="Acuity Belt +1"})
    sets.midcast.ElementalEnfeeble.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {head="Amalric Coif +1",ear2="Azimuth Earring",waist="Acuity Belt +1"})
	
	sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {head="Amalric Coif +1",ear2="Azimuth Earring",waist="Acuity Belt +1"})
	sets.midcast.IntEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {head="Amalric Coif +1",ear2="Azimuth Earring",waist="Acuity Belt +1"})
	
	sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {range=empty,ring1="Stikini Ring +1"})
	sets.midcast.MndEnfeebles.Resistant = set_combine(sets.midcast['Enfeebling Magic'].Resistant, {range=empty,ring1="Stikini Ring +1"})
	
	sets.midcast.Dia = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Dia II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	
	sets.midcast.Bio = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	sets.midcast['Bio II'] = set_combine(sets.midcast['Enfeebling Magic'], sets.TreasureHunter)
	
	sets.midcast['Divine Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {ring1="Stikini Ring +1"})
		
	sets.midcast['Enhancing Magic'] = {main=gear.gada_enhancing_club,sub="Ammurapi Shield",ammo="Hasty Pinion +1",
		head="Telchine Cap",neck="Incanter's Torque",ear1="Andoaa Earring",ear2="Gifted Earring",
		body="Telchine Chas.",hands="Telchine Gloves",ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back="Perimede Cape",waist="Embla Sash",legs="Telchine Braconi",feet="Telchine Pigaches"}
		
	sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {neck="Nodens Gorget",ear2="Earthcry Earring",waist="Siegel Sash",legs="Shedir Seraweels"})
	
	sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {head="Amalric Coif +1"})
	
	sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {main="Vadose Rod",sub="Genmei Shield",head="Amalric Coif +1",hands="Regal Cuffs",waist="Emphatikos Rope",legs="Shedir Seraweels"})
	
	sets.midcast.BarElement = set_combine(sets.precast.FC['Enhancing Magic'], {legs="Shedir Seraweels"})
	
	sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring",ear1="Gifted Earring",ear2="Malignance earring",waist="Sekhmet Corset"})
	sets.midcast.Protectra = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring",ear1="Gifted Earring",ear2="Malignance earring",waist="Sekhmet Corset"})
	sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring",ear1="Gifted Earring",ear2="Malignance earring",waist="Sekhmet Corset"})
	sets.midcast.Shellra = set_combine(sets.midcast['Enhancing Magic'], {ring2="Sheltered Ring",ear1="Gifted Earring",ear2="Malignance earring",waist="Sekhmet Corset"})

	--------------------------------------
	-- Idle/resting/defense/etc sets
	--------------------------------------

	-- Resting sets
	sets.resting = {main="Chatoyant Staff",sub="Kaja Grip",
		head="Azimuth Hood +2",neck="Chrys. Torque",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Jhakri Robe +2",hands="Bagua mitaines +1",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",legs="Assid. Pants +1",feet="Azimuth Gaiters +2"}

	-- Idle sets

	sets.idle = {main="Malignance Pole",sub="Kaja Grip",ammo="Staunch Tathlum +1",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Eabani Earring",ear2="Azimuth Earring",
		body="Azimuth Coat +2",hands="Bagua mitaines +1",ring1="Stikini Ring +1",ring2="Stikini Ring +1",
		back=gear.cape_loupan_idle,waist="Shinjutsu-no-Obi",legs="Assid. Pants +1",feet="Azimuth Gaiters +2"}
		
	sets.idle.PDT = {main="Malignance Pole",sub="Kaja Grip",ammo="Staunch Tathlum +1",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Genmei Earring",ear2="Ethereal Earring",
		body="Azimuth Coat +2",hands="Hagondes Cuffs +1",ring1="Defending Ring",ring2="Shadow Ring",
		back="Shadow Mantle",waist="Flax Sash",legs="Hagondes Pants +1",feet="Azimuth Gaiters +2"}

	-- .Pet sets are for when Luopan is present.
	sets.idle.Pet = {main="Sucellus",sub="Genmei Shield",range="Dunna",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Handler's Earring",ear2="Handler's Earring +1",
		body="Azimuth Coat +2",hands="Geo. Mitaines +2",ring1="Defending Ring",ring2="Dark Ring",
		back=gear.cape_loupan_idle,waist="Isa Belt",legs="Psycloth Lappas",feet="Bagua Sandals +1"}

	sets.idle.PDT.Pet = {main="Malignance Pole",sub="Kaja Grip",range="Dunna",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Handler's Earring",ear2="Handler's Earring +1",
		body="Azimuth Coat +2",hands="Geo. Mitaines +2",ring1="Defending Ring",ring2="Dark Ring",
		back=gear.cape_loupan_idle,waist="Isa Belt",legs="Hagondes Pants +1",feet="Bagua Sandals +1"}

	-- .Indi sets are for when an Indi-spell is active.
	sets.idle.Indi = set_combine(sets.idle, {})
	sets.idle.Pet.Indi = set_combine(sets.idle.Pet, {}) 
	sets.idle.PDT.Indi = set_combine(sets.idle.PDT, {}) 
	sets.idle.PDT.Pet.Indi = set_combine(sets.idle.PDT.Pet, {})

	sets.idle.Weak = {main="Bolelabunga",sub="Genmei Shield",ammo="Staunch Tathlum +1",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Ethereal Earring",
		body="Azimuth Coat +2",hands=gear.merlinic_refresh_hands,ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flax Sash",legs="Assid. Pants +1",feet="Azimuth Gaiters +2"}

	-- Defense sets
	
	sets.defense.PDT = {main="Malignance Pole",sub="Kaja Grip",ammo="Staunch Tathlum +1",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Handler's Earring +1",
		body="Azimuth Coat +2",hands="Hagondes Cuffs +1",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flax Sash",legs="Hagondes Pants +1",feet="Azimuth Gaiters +2"}

	sets.defense.MDT = {main="Malignance Pole",sub="Kaja Grip",ammo="Staunch Tathlum +1",
		head="Azimuth Hood +2",neck="Loricate Torque +1",ear1="Etiolation Earring",ear2="Handler's Earring +1",
		body="Azimuth Coat +2",hands="Hagondes Cuffs +1",ring1="Defending Ring",ring2="Dark Ring",
		back="Umbra Cape",waist="Flax Sash",legs="Hagondes Pants +1",feet="Azimuth Gaiters +2"}
		
    sets.defense.MEVA = {main="Malignance Pole",sub="Enki Strap",ammo="Staunch Tathlum +1",
        head="Azimuth Hood +2",neck="Warder's Charm +1",ear1="Etiolation Earring",ear2="Sanare Earring",
		body="Azimuth Coat +2",hands="Telchine Gloves",ring1="Vengeful Ring",Ring2="Purity Ring",
        back=gear.cape_loupan_idle,waist="Luminary Sash",legs="Telchine Braconi",feet="Azimuth Gaiters +2"}
		
	sets.defense.PetPDT = sets.idle.PDT.Pet
		
	sets.defense.NukeLock = sets.midcast['Elemental Magic']
	
	sets.defense.GeoLock = sets.midcast.Geomancy.Indi

	sets.Kiting = {feet="Herald's Gaiters"}
	sets.latent_refresh = {waist="Fucho-no-obi"}
	sets.latent_refresh_grip = {sub="Oneiros Grip"}
	sets.TPEat = {neck="Chrys. Torque"}
	sets.DayIdle = {}
	sets.NightIdle = {}
	sets.TreasureHunter = set_combine(sets.TreasureHunter, {feet=gear.merlinic_treasure_feet})
	
	sets.HPDown = {head="Pixie Hairpin +1",ear1="Mendicant's Earring",ear2="Evans Earring",
		body="Azimuth Hood +2",hands="Azimuth Gloves +2",ring1="Mephitas's Ring +1",ring2="Mephitas's Ring",
		back="Swith Cape +1",legs="Shedir Seraweels",feet="Azimuth Gaiters +2"}
	
	sets.buff.Doom = set_combine(sets.buff.Doom, {})

	--------------------------------------
	-- Engaged sets
	--------------------------------------

	-- Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
	-- sets if more refined versions aren't defined.
	-- If you create a set with both offense and defense modes, the offense mode should be first.
	-- EG: sets.engaged.Dagger.Accuracy.Evasion

	-- Normal melee group
	sets.engaged = {main="Solstice", sub="Harpy Shield", ammo="Hasty Pinion +1",
		head="Befouled Crown",neck="Asperity Necklace",ear1="Cessance Earring",ear2="Brutal Earring",
		body="Azimuth Coat +2",hands="Gazu Bracelet +1",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
		back="Kayapa Cape",waist="Witful Belt",legs="Assid. Pants +1",feet="Bagua Sandals +1"}
		
	sets.engaged.DW = {ammo="Hasty Pinion +1",
		head="Befouled Crown",neck="Asperity Necklace",ear1="Dudgeon Earring",ear2="Heartseeker Earring",
		body="Azimuth Coat +2",hands="Regal Cuffs",ring1="Ramuh Ring +1",ring2="Ramuh Ring +1",
		back="Kayapa Cape",waist="Witful Belt",legs="Assid. Pants +1",feet="Battlecast Gaiters"}

	--------------------------------------
	-- Custom buff sets
	--------------------------------------
	
	-- Gear that converts elemental damage done to recover MP.	
	sets.RecoverMP = {body="Seidr Cotehardie"}
	
	-- Gear for Magic Burst mode.
    sets.MagicBurst = { main=gear.grioavolr_MB,sub="Alber Strap",head="Ea Hat",neck="Sanctity Necklace", back = gear.capeMB,                                     --neck="Mizu. Kubikazari"
	body="Ea Houppelande", hands = "Ea Cuffs", ring1="Mujin Band",legs="Ea Slops",feet="Ea Pigaches"}

	sets.ResistantMagicBurst = {main=gear.grioavolr_MB,sub="Enki Strap", back = gear.capeMB,
	head="Ea Hat",neck="Mizu. Kubikazari", hands = "Ea Cuffs", body="Ea Houppelande",ring1="Mujin Band",legs="Ea Slops",feet="Ea Pigaches"}

	
	sets.buff.Sublimation = {waist="Embla Sash"}
    sets.buff.DTSublimation = {waist="Embla Sash"}
	
	-- Weapons sets
	sets.weapons.Nehushtan = {main='Nehushtan',sub='Genmei Shield'}
	sets.weapons.DualWeapons = {main='Nehushtan',sub='Nehushtan'}

	sets.moving = { feet="Geo. Sandals +2" }
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
	set_macro_page(4, 10)
end