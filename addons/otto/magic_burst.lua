--[[
    I am not the original author of this, credit goes to Ekrividus. All I've done is ported it, cleaned up a bit and consolidated.
    -- TC

	_addon.version = '0.7.0'
	_addon.name = 'autoMB'
	_addon.author = 'Ekrividus'
	_addon.commands = {'autoMB','amb'}
	_addon.lastUpdate = '6/11/2020'
	_addon.windower = '4'
]]

local magic_burst = T{ defaults = {}, settings = {}, state = {} }

require('luau')
require('actions')

magic_burst.should_report_state = false

function magic_burst.New(self, settings, state)
    self.settings = settings
    self.state = state

	local defaults = T{ magic_burst = {}}
	defaults.magic_burst.enabled = true
	defaults.magic_burst.show_skillchain = false -- Whether or not to show skillchain name
	defaults.magic_burst.show_elements = false -- Whether or not to show skillchain element info
	defaults.magic_burst.show_bonus_elements = false -- Whether or not to show Storm/Weather/Day elements
	defaults.magic_burst.show_spell = false -- Whether or not to post the spell selection to chat
	defaults.magic_burst.check_day = false -- Whether or not to use day bonus spell
	defaults.magic_burst.check_weather = false -- Whether or not to use weather bonus, probably turn on if storms are being used
	defaults.magic_burst.cast_delay = 0.25 -- Delay from when skillchain occurs to when first spell is cast
	defaults.magic_burst.double_burst = false -- Not implemented yet
	defaults.magic_burst.double_burst_delay = 1 -- Time from when first spell starts casting to when second spell starts casting
	defaults.magic_burst.mp = 100 -- Don't burst if it will leave you below this mark
	defaults.magic_burst.cast_type = 'spell' -- Type of MB spell|jutsu|helix|ga|ja|ra
	defaults.magic_burst.cast_tier = 2 -- What tier should we try to cast
	defaults.magic_burst.step_down = 0 -- Step down a tier for double bursts (0: Never, 1: If target changed, 2: Always)
	defaults.magic_burst.gearswap = true -- Tell gearswap when we're bursting
	defaults.magic_burst.change_target = true -- Swap targets automatically for MBs
	
	return defaults
end

function magic_burst.Update(self, settings, state)
    self.settings = settings
    self.state = state

    return magic_burst.should_report_state
end

function magic_burst.Report_state()
	log(magic_burst.state.is_busy)
    magic_burst.should_report_state = false
    return magic_burst.state.is_busy    
end

res = require('resources')
packets = require('packets')

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
magic_burst.spell_users = {'BLM', 'RDM', 'DRK', 'GEO'}
magic_burst.jutsu_users = {'NIN'}
magic_burst.helix_users = {'SCH'}

local last_skillchain = nil
local player = nil

local finish_act = L{2,3,5}
local start_act = L{7,8,9,12}

local ability_delay = 1.3
local after_cast_delay = 2
local failed_cast_delay = 2

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
    if (mp_cost == nil or (player.vitals.mp - mp_cost <= magic_burst.settings.magic_burst.mp)) then
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

function clear_skillchain()
	last_skillchain = {}
	last_skillchain.english = 'None'
	last_skillchain.elements = {}
end

function cast_spell(spell_cmd, target) 
	if (magic_burst.settings.magic_burst.show_spell) then
		windower.add_to_chat(123, "Casting - "..spell_cmd..' for the burst!')
	end
	
	windower.send_command('input /ma "'..spell_cmd..'" <t>')
	magic_burst.should_report_state = true
	magic_burst.state.is_busy = 3
end

function get_spell(skillchain, last_spell, second_burst, target_change)
	local spell_element = ''
	local weather_element, day_element = get_bonus_elements()
	local spell = ''
	local step_down = 0

	if (not second_burst or last_spell == nil) then
		last_spell = ''
	end

	if (second_burst) then
		if (magic_burst.magic_burst.step_down == 2 or (magic_burst.magic_burst.step_down == 1 and target_change ~= nil and target_change > 0)) then
			step_down = 1
		end
	end

	if (magic_burst.settings.magic_burst.check_weather and T(skillchain.elements):contains(weather_element)) then
		spell_element = weather_element
	elseif (magic_burst.settings.magic_burst.check_day and T(skillchain.elements):contains(day_element)) then
		spell_element = day_element
	else
		for i=1,#spell_priorities do
			if (T(skillchain.elements):contains(spell_priorities[i].element)) then
				spell_element = spell_priorities[i].element
				break
			end 
		end
	end

	local tier = magic_burst.settings.magic_burst.cast_tier - step_down
	-- Find spell/helix/jutsu that will be best based on best element
	if (elements[spell_element] ~= nil and elements[spell_element][magic_burst.settings.magic_burst.cast_type] ~= nil) then
		spell = elements[spell_element][magic_burst.settings.magic_burst.cast_type]

		tier = (tier >= 1 and tier or 1)
		spell = spell..(magic_burst.settings.magic_burst.cast_type == 'jutsu' and ':' or '')..(tier > 1 and ' ' or '')
		spell = spell..(magic_burst.settings.magic_burst.cast_type == 'jutsu' and jutsu_tiers[tier].suffix or magic_tiers[tier].suffix)

		local recast = check_recast(spell)
		if (recast > 0) then
			spell = ''
		end
	end

	if (spell == nil or spell == '') then
		for _,element in pairs(skillchain.elements) do
			if (elements[element] ~= nil and elements[element][magic_burst.settings.magic_burst.cast_type] ~= nil) then
				spell = elements[element][magic_burst.settings.magic_burst.cast_type]

				tier = (tier >= 1 and tier or 1)
				spell = spell..(magic_burst.settings.magic_burst.cast_type == 'jutsu' and ':' or '')..(tier > 1 and ' ' or '')
				spell = spell..(magic_burst.settings.magic_burst.cast_type == 'jutsu' and jutsu_tiers[tier].suffix or magic_tiers[tier].suffix)
			
				local recast = check_recast(spell)
				if (recast == 0) then
					break
				end
			end
		end
	end

	-- Display some skillchain/magic burst info, can show up whether auto bursts are on or not
	local element_list = ''
	local sc_info = _addon.name..': '

	for i=1,#skillchain.elements do
		element_list = element_list..skillchain.elements[i]..(i<#skillchain.elements and ', ' or '')
	end
	
	if (magic_burst.settings.magic_burst.show_skillchain) then sc_info = sc_info..'Skillchain effect '..skillchain.english..' ' end
	if (magic_burst.settings.magic_burst.show_elements) then sc_info = sc_info..'['..element_list..'] ' end
	if (magic_burst.settings.magic_burst.show_bonus_elements) then sc_info = sc_info..'Weather: '.. weather_element..' Day: '..day_element..' ' end
	if (magic_burst.settings.magic_burst.show_skillchain or magic_burst.settings.magic_burst.show_elements or magic_burst.settings.magic_burst.show_bonus_elements) then windower.add_to_chat(207, sc_info) end

	return spell
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

function do_burst(target, skillchain, second_burst, last_spell)
	if magic_burst.settings.magic_burst.gearswap then
		windower.send_command('gs c bursting')
	end

	player = windower.ffxi.get_player()
	if (target == nil or not target.valid_target or target.hpp <= 0) then
		windower.add_to_chat(123, "Bad Target!")
		return
	end

	local target_delay = 0
	if (magic_burst.settings.magic_burst.change_target) then
		target_delay = set_target(target)
	end

	local spell = get_spell(skillchain, last_spell, second_burst, target_delay >= 1)

	if (spell == nil or spell == '') then
		if (magic_burst.settings.magic_burst.show_spell) then
			windower.add_to_chat(123, "No spell found for burst!")
		end
		if magic_burst.settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end
		return
	elseif (disabled()) then
		windower.add_to_chat(123, "Unable to cast, disabled!")
		if magic_burst.settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end		return
	elseif (low_mp(spell)) then
		windower.add_to_chat(123, "Not enough MP for MB!")
		if magic_burst.settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end		return
	elseif (magic_burst.state.is_busy > 0) then
		windower.add_to_chat(123, "Busy for "..magic_burst.state.is_busy.." seconds, delaying MB")
		coroutine.schedule(do_burst:prepare(target, skillchain, second_burst, last_spell), magic_burst.state.is_busy)
		return
	end
	
	local cast_delay = math.random(0.1, magic_burst.settings.magic_burst.cast_delay)
	coroutine.schedule(cast_spell:prepare(spell, target), target_delay + cast_delay)

	if (magic_burst.settings.magic_burst.double_burst and not second_burst) then
		windower.add_to_chat(123, "Setting up double burst")
		local cast_time = res.spells:with('name', spell) and res.spells:with('name', spell).cast_time or nil
		if (cast_time == nil) then
			finish_burst()
			return
		end
		local d = cast_time + magic_burst.settings.magic_burst.double_burst_delay + target_delay + 2
		coroutine.schedule(do_burst:prepare(target, skillchain, true, spell), d)
	else
		local cast_time = res.spells:with('name', spell) and res.spells:with('name', spell).cast_time or nil
		if (cast_time == nil) then
			finish_burst()
			return
		end
		local d = cast_time + target_delay
		coroutine.schedule(finish_burst, d)
	end
end

function finish_burst()
	clear_skillchain()
	if magic_burst.settings.magic_burst.gearswap then
		windower.send_command('gs c notbursting')
	end
end

-- MARK: Events

windower.register_event('incoming chunk', function(id, packet, data, modified, is_injected, is_blocked)
	if (id ~= 0x28 or not magic_burst.settings.magic_burst.enabled) then
		return
	end

	local actions_packet = windower.packets.parse_action(packet)
	local mob_array = windower.ffxi.get_mob_array()
	local valid = false
	local party = windower.ffxi.get_party()
	local party_ids = T{}

	player = windower.ffxi.get_player()

	if (data:unpack('I', 6) == player.id) then 
		local category, param = data:unpack( 'b4b16', 11, 3)
		local recast, targ_id = data:unpack('b32b32', 15, 7)
		local effect, message = data:unpack('b17b10', 27, 6)
		
		if start_act:contains(category) then
			if param == 24931 then                  -- Begin Casting/WS/Item/Range
			elseif param == 28787 then              -- Failed Casting/WS/Item/Range
				magic_burst.state.is_busy = failed_cast_delay
			end
		elseif category == 6 then                   -- Use Job Ability
			magic_burst.state.is_busy = ability_delay
		elseif category == 4 then                   -- Finish Casting
			magic_burst.state.is_busy = after_cast_delay
		elseif finish_act:contains(category) then   -- Finish Range/WS/Item Use
		end
	end

	-- Get ids of all current party member
	for _, member in pairs (party) do
		if (type(member) == 'table' and member.mob) then
			party_ids:append(member.mob.id)
		end
	end

	local cur_t = windower.ffxi.get_mob_by_target('t')
	local bt = windower.ffxi.get_mob_by_target('bt')
	
	for _, target in pairs(actions_packet.targets) do
		local t = windower.ffxi.get_mob_by_id(target.id)
		-- Make sure the mob is claimed by our alliance then
		if (t ~= nil and ((cur_t and cur_t.id == t.id) or (bt and bt.id == t.id) or party_ids:contains(t.claim_id))) then
			-- Make sure the mob is a valid MB target
			if (t and (t.is_npc and t.valid_target and not t.in_party and not t.charmed) and t.distance:sqrt() < 22) then
				for _, action in pairs(target.actions) do
					if (action.add_effect_message > 287 and action.add_effect_message < 302) then
						last_skillchain = skillchains[action.add_effect_message]
						coroutine.schedule(do_burst:prepare(t, last_skillchain, false, '', 0), magic_burst.settings.magic_burst.cast_delay)
					end
				end
			end
		end
	end
end)


-- Change spell type based on job/sub
windower.register_event('job change', function(main_id, main_lvl, sub_id, sub_lvl)
	local main = res.jobs[main_id].english_short
	local sub = res.jobs[sub_id].english_short

	-- Set magic_burst.cast_type to 'none' to stop casting if job/sub doesn't support casting
	magic_burst.settings.magic_burst.cast_type = 'none'

	if (T(magic_burst.spell_users):contains(main)) then
		magic_burst.settings.magic_burst.cast_type = 'spell'
	elseif (T(magic_burst.jutsu_users):contains(main)) then
		magic_burst.settings.magic_burst.cast_type = 'jutsu'
	elseif (T(magic_burst.helix_users):contains(main)) then
		magic_burst.settings.magic_burst.cast_type = 'helix'
	elseif (T(magic_burst.spell_users):contains(sub)) then
		magic_burst.settings.magic_burst.cast_type = 'spell'
	elseif (T(magic_burst.jutsu_users):contains(sub)) then
		magic_burst.settings.magic_burst.cast_type = 'jutsu'
	elseif (T(magic_burst.helix_users):contains(sub)) then
		magic_burst.settings.magic_burst.cast_type = 'helix'
	end
	windower.add_to_chat(123, '> Cast type set to: '..magic_burst.settings.magic_burst.cast_type)
end)


return magic_burst