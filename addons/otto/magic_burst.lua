--[[
    I am not the original author of this, credit goes to Ekrividus. All I've done is ported it, cleaned up a bit and consolidated.
    -- TC

	-- todo add lock_element argument for forcing MB spell type (useful for resistances and bosses that absorb)

	todo spells need to be removed as they're finished.
	 

	_addon.version = '0.7.0'
	_addon.name = 'autoMB'
	_addon.author = 'Ekrividus'
	_addon.commands = {'autoMB','amb'}
	_addon.lastUpdate = '6/11/2020'
	_addon.windower = '4'
]]

local magic_burst = T{ }

require('luau')
require('actions')

res = require('resources')
packets = require('packets')
skills = require('skills')

skillchain_ids = S{288,289,290,291,292,293,294,295,296,297,298,299,300,301,385,386,387,388,389,390,391,392,393,394,395,396,397,767,768,769,770}

sc_info = {
    Radiance = {'Fire','Wind','Lightning','Light', lvl=4},
    Umbra = {'Earth','Ice','Water','Dark', lvl=4},
    Light = {'Fire','Wind','Lightning','Light', Light={4,'Light','Radiance'}, lvl=3},
    Darkness = {'Earth','Ice','Water','Dark', Darkness={4,'Darkness','Umbra'}, lvl=3},
    Gravitation = {'Earth','Dark', Distortion={3,'Darkness'}, Fragmentation={2,'Fragmentation'}, lvl=2},
    Fragmentation = {'Wind','Lightning', Fusion={3,'Light'}, Distortion={2,'Distortion'}, lvl=2},
    Distortion = {'Ice','Water', Gravitation={3,'Darkness'}, Fusion={2,'Fusion'}, lvl=2},
    Fusion = {'Fire','Light', Fragmentation={3,'Light'}, Gravitation={2,'Gravitation'}, lvl=2},
    Compression = {'Darkness', Transfixion={1,'Transfixion'}, Detonation={1,'Detonation'}, lvl=1},
    Liquefaction = {'Fire', Impaction={2,'Fusion'}, Scission={1,'Scission'}, lvl=1},
    Induration = {'Ice', Reverberation={2,'Fragmentation'}, Compression={1,'Compression'}, Impaction={1,'Impaction'}, lvl=1},
    Reverberation = {'Water', Induration={1,'Induration'}, Impaction={1,'Impaction'}, lvl=1},
    Transfixion = {'Light', Scission={2,'Distortion'}, Reverberation={1,'Reverberation'}, Compression={1,'Compression'}, lvl=1},
    Scission = {'Earth', Liquefaction={1,'Liquefaction'}, Reverberation={1,'Reverberation'}, Detonation={1,'Detonation'}, lvl=1},
    Detonation = {'Wind', Compression={2,'Gravitation'}, Scission={1,'Scission'}, lvl=1},
    Impaction = {'Lightning', Liquefaction={1,'Liquefaction'}, Detonation={1,'Detonation'}, lvl=1},
}

local skillchains = {
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
	[301] = {id=301,english='Impaction',elements={'Thunder'}}
}

local magic_tiers = {
	[1] = {suffix=''},
	[2] = {suffix='II'},
	[3] = {suffix='III'},
	[4] = {suffix='IV'},
	[5] = {suffix='V'},
	[6] = {suffix='VI'}
}

local jutsu_tiers = {
    [1] = {suffix='Ichi'},
    [2] = {suffix='Ni'},
    [3] = {suffix='San'}
}

local spell_priorities = {
	[1] = {element='Thunder'},
	[2] = {element='Ice'},
	[3] = {element='Wind'},
	[4] = {element='Fire'},
	[5] = {element='Water'},
	[6] = {element='Earth'},
	[7] = {element='Dark'},
	[8] = {element='Light'}
}

local storms = {
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

local elements = {
	['Light'] = {spell=nil,helix='Luminohelix',ga=nil,ja=nil,ra=nil,jutsu=nil,white='Banish',holy="Holy"},
	['Dark'] = {spell=nil,helix='Noctohelix',ga=nil,ja=nil,ra=nil,jutsu=nil,white=nil,holy=nil},
	['Thunder'] = {spell='Thunder',helix='Ionohelix',ga='Thundaga',ja='Thundaja',ra='Thundara',jutsu='Raiton',white=nil,holy=nil},
	['Ice'] = {spell='Blizzard',helix='Cryohelix',ga='Blizzaga',ja='Blizzaja',ra='Blizzara',jutsu='Hyoton',white=nil,holy=nil},
	['Fire'] = {spell='Fire',helix='Pyrohelix',ga='Firaga',ja='Firaja',ra='Fira',jutsu='Katon',white=nil,holy=nil},
	['Wind'] = {spell='Aero',helix='Anemohelix',ga='Aeroga',ja='Aeroja',ra='Aerora',jutsu='Huton',white=nil,holy=nil},
	['Water'] = {spell='Water',helix='Hydrohelix',ga='Waterga',ja='Waterja',ra='Watera',jutsu='Suiton',white=nil,holy=nil},
	['Earth'] = {spell='Stone',helix='Geohelix',ga='Stonega',ja='Stoneja',ra='Stonera',jutsu='Doton',white=nil,holy=nil},
}

magic_burst.cast_types = {'spell', 'helix', 'ga', 'ja', 'ra', 'jutsu', 'white', 'holy'}
magic_burst.spell_users = {'BLM', 'RDM', 'DRK', 'GEO', 'WHM'}
magic_burst.jutsu_users = {'NIN'}
magic_burst.helix_users = {'SCH'}

local last_skillchain = nil
local player = nil
local last_skillchain_tick = nil

function buff_active(id)
    if T(windower.ffxi.get_player().buffs):contains(id) == true then
        return true
    end
    return false
end

function disabled()
    if (buff_active(0)) then -- KO
        return true
    elseif (buff_active(2)) then -- Sleep
        return true
    elseif (buff_active(6)) then -- Silence
        return true
    elseif (buff_active(7)) then -- Petrification
        return true
    elseif (buff_active(10)) then -- Stun
        return true
    elseif (buff_active(14)) then -- Charm
        return true
    elseif (buff_active(28)) then -- Terrorize
        return true
    elseif (buff_active(29)) then -- Mute
        return true
    elseif (buff_active(193)) then -- Lullaby
        return true
    elseif (buff_active(262)) then -- Omerta
        return true
    end
    return false
end

function low_mp(spell)
	local sp = res.spells:with('name', spell)
	if (sp == nil) then
		return false
	end

	local mp_cost = sp.mp_cost
    if (mp_cost == nil or (player.vitals.mp - mp_cost <= user_settings.magic_burst.mp)) then
        return true
    end

	return false
end

function check_recast(spell_name)
    local recasts = windower.ffxi.get_spell_recasts()
	local spell = res.spells:with('name', spell_name)
	if (spell == nil) then
		return 0
	end

	local recast = recasts[spell.id]

    return recast
end

function get_bonus_elements()
	-- Use best possible bonus element, default to day
	local day_element = res.elements[res.days[windower.ffxi.get_info().day].element].en
	local weather_id = windower.ffxi.get_info().weather
	local player = windower.ffxi.get_player()

	-- Is a storm active, it wins
	if (#player.buffs > 0) then
		for i=1,#player.buffs do
			local buff = player.buffs[i]

			for _, storm in pairs(storms) do
				if (storm.id == buff) then
					weather_id = storm.weather
				end
			end
		end
	end
	weather_element = res.elements[res.weather[weather_id].element].en

	return weather_element, day_element
end

function burst_window_close()
	local now = os.clock()
	-- the times aren't always accurate 0.5 seconds is a rounding to favor closing the bursting window
	local bursting_window_close_time = last_skillchain_tick + 8.5 

	log(''..now..' >'..bursting_window_close_time )
	if now > bursting_window_close_time then -- CKM test this is working. Fucking coroutines failed me.
		log('bursting window closed')
		actions.remove_bursting_spells()
		
		last_skillchain = {}
		last_skillchain.english = 'None'
		last_skillchain.elements = {}
	
		if user_settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end
	end
end

function cast_spell(spell) 
	if (user_settings.magic_burst.show_spell) then
		windower.add_to_chat(123, "Casting - "..spell.name..' for the burst!')
	end

	local target = windower.ffxi.get_mob_by_target()
	offense.addToNukeingQueue(spell, target)
end

function get_spell(skillchain, doubleBurst)
	local spell_element = ''
	local weather_element, day_element = get_bonus_elements()
	local spell = ''

	if (user_settings.magic_burst.check_weather and T(skillchain.elements):contains(weather_element)) then
		spell_element = weather_element
	elseif (user_settings.magic_burst.check_day and T(skillchain.elements):contains(day_element)) then
		spell_element = day_element
	else
		for i=1,#spell_priorities do
			if (T(skillchain.elements):contains(spell_priorities[i].element)) then
				spell_element = spell_priorities[i].element
				break
			end 
		end
	end

	local tier = user_settings.magic_burst.cast_tier 
	if doubleBurst and tier - 1 ~= 0 then tier = tier - 1 end

	-- Find spell/helix/jutsu that will be best based on best element
	if (elements[spell_element] ~= nil and elements[spell_element][user_settings.magic_burst.cast_type] ~= nil) then
		spell = elements[spell_element][user_settings.magic_burst.cast_type]

		tier = (tier >= 1 and tier or 1)
		spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and ':' or '')..(tier > 1 and ' ' or '')
		spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and jutsu_tiers[tier].suffix or magic_tiers[tier].suffix)

		local recast = check_recast(spell)
		if (recast > 0) then
			spell = ''
		end
	end

	if (spell == nil or spell == '') then
		for _,element in pairs(skillchain.elements) do
			if (elements[element] ~= nil and elements[element][user_settings.magic_burst.cast_type] ~= nil) then
				spell = elements[element][user_settings.magic_burst.cast_type]

				tier = (tier >= 1 and tier or 1)
				spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and ':' or '')..(tier > 1 and ' ' or '')
				spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and jutsu_tiers[tier].suffix or magic_tiers[tier].suffix)
			
				local recast = check_recast(spell)
				if (recast == 0) then
					break
				end
			end
		end
	end

	-- Display some skillchain/magic burst info, can show up whether auto bursts are on or not
	local element_list = ''

	for i=1,#skillchain.elements do
		element_list = element_list..skillchain.elements[i]..(i<#skillchain.elements and ', ' or '')
	end
	
	local resSpell = res.spells:with('name', spell)

	return resSpell
end

function set_target(target)
	local cur_target = nil
	if (player.target_index) then
		cur_target = windower.ffxi.get_mob_by_index(player.target_index)
	end

	if (target == nil or not target.valid_target or not target.is_npc or target.hpp == nil or target.hpp <= 0) then
		return 0
	end

	if (cur_target ~= nil and cur_target.id == target.id) then
		return 0
	end

	packets.inject(packets.new('incoming', 0x058, {
		['Player'] = player.id,
		['Target'] = target.id,
		['Player Index'] = player.index,
	}))

	return 1
end

function do_burst(target, skillchain)
	if user_settings.magic_burst.gearswap then
		windower.send_command('gs c bursting')
	end

	player = windower.ffxi.get_player()
	if (target == nil or not target.valid_target or target.hpp <= 0) then
		windower.add_to_chat(123, "Bad Target!")
		return
	end

	if (user_settings.magic_burst.change_target) then
		set_target(target)
	end

	local spell = get_spell(skillchain, false)

	if (spell == nil or spell == '') then
		if (user_settings.magic_burst.show_spell) then
			windower.add_to_chat(123, "No spell found for burst!")
		end
		if user_settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end
		return
	elseif (disabled()) then
		windower.add_to_chat(123, "Unable to cast, disabled!")
		if user_settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end		
		return
	end
	
	cast_spell(spell)

	if (user_settings.magic_burst.double_burst) then
		local spell = get_spell(skillchain, true)
		cast_spell(spell)
	end

	last_skillchain_tick = os.clock()
	coroutine.schedule(burst_window_close:prepare(), 9)

end

-- MARK: Events

local function action_handler(raw_actionpacket)
	
	if not user_settings.magic_burst.enabled then return end

    local actionpacket = ActionPacket.new(raw_actionpacket)	
	local category = actionpacket:get_category_string()
	local categories = S{     
		'weaponskill_finish',
    	'mob_tp_finish',
    	'avatar_tp_finish',
	 }

    if not categories:contains(category) or raw_actionpacket.param == 0 then
        return
    end

    local actor = actionpacket:get_id()
    local target = actionpacket:get_targets()()
    local action = target:get_actions()()
    local add_effect = action:get_add_effect()

    if add_effect and skillchain_ids:contains(add_effect.message_id) then

		actions.remove_bursting_spells()

		local party = windower.ffxi.get_party()
		local party_ids = T{}
	
		for _, member in pairs (party) do
			if (type(member) == 'table' and member.mob) then
				party_ids:append(member.mob.id)
			end
		end

		last_skillchain = skillchains[add_effect.message_id]

		local cur_t = windower.ffxi.get_mob_by_target('t')
		local bt = windower.ffxi.get_mob_by_target('bt')
		local target = windower.ffxi.get_mob_by_id(target.id)

		-- Make sure the mob is claimed by our alliance then
		if (target ~= nil and ((cur_t and cur_t.id == target.id) or (bt and bt.id == target.id) or party_ids:contains(target.claim_id))) then
			-- Make sure the mob is a valid MB target
			if (target and (target.is_npc and target.valid_target and not target.in_party and not target.charmed) and target.distance:sqrt() < 22) then
				if not closed then
					do_burst(target, last_skillchain, false)
					return
				end
			end
		end
	else
		if actions.has_bursting_spells() then			
			actions.remove_bursting_spells()
		end
	end
end


ActionPacket.open_listener(action_handler)

-- Change spell type based on job/sub
windower.register_event('job change', function(main_id, main_lvl, sub_id, sub_lvl)
	local main = res.jobs[main_id].english_short
	local sub = res.jobs[sub_id].english_short

	-- Set magic_burst.cast_type to 'none' to stop casting if job/sub doesn't support casting
	user_settings.magic_burst.cast_type = 'none'

	if (T(magic_burst.spell_users):contains(main)) then
		user_settings.magic_burst.cast_type = 'spell'
	elseif (T(magic_burst.jutsu_users):contains(main)) then
		user_settings.magic_burst.cast_type = 'jutsu'
	elseif (T(magic_burst.helix_users):contains(main)) then
		user_settings.magic_burst.cast_type = 'helix'
	elseif (T(magic_burst.spell_users):contains(sub)) then
		user_settings.magic_burst.cast_type = 'spell'
	elseif (T(magic_burst.jutsu_users):contains(sub)) then
		user_settings.magic_burst.cast_type = 'jutsu'
	elseif (T(magic_burst.helix_users):contains(sub)) then
		user_settings.magic_burst.cast_type = 'helix'
	end
	windower.add_to_chat(123, '> Cast type set to: '..user_settings.magic_burst.cast_type)
end)


return magic_burst