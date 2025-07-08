--[[
	original credit goes to

	_addon.version = '0.7.0'
	_addon.name = 'autoMB'
	_addon.author = 'Ekrividus'
	_addon.commands = {'autoMB','amb'}
	_addon.lastUpdate = '6/11/2020'
	_addon.windower = '4'

	modified and edited by TC

	TODO: maybe open / close window from ws? use to know when to burst.
	filtering burst targets by if window was opened by a teammate?
	during window add a debuff to the monster 'burst-window-open'?
]]

local magic_burst = T{ }

magic_burst.cast_types = {'spell', 'helix', 'ga', 'ja', 'ra', 'jutsu', 'white', 'holy' }
magic_burst.spell_users = {'BLM', 'RDM', 'DRK', 'GEO', 'WHM'}
magic_burst.jutsu_users = {'NIN'}
magic_burst.helix_users = {'SCH'}

magic_burst.window_open = 0
magic_burst.window_close = 0
magic_burst.window_open_target = nil
magic_burst.window_open_spell = nil
magic_burst.window_open_double_burst_spell = nil

function magic_burst.init()
    local defaults = { }
	defaults.enabled = true         -- top level enable toggle. on | off
	defaults.gearswap = true        -- You will have to add a hook into gearswap to use this, but it allows proper bursting sets to be used. see my geo gearswap if you'd like to see how it can be done.
	defaults.mp = 100               -- stop bursting below this amount of mp. note that this is flat amount, not mp percent
    defaults.cast_tier = 3          -- nuke tier to mb with
    defaults.cast_type = "spell"    -- the spell type to cast with. values can be 'spell', 'helix', 'ga', 'ja', 'ra', 'jutsu', 'white'
    defaults.check_day = true       -- evaluates current vanadiel day
	defaults.check_weather = true   -- default true, you probably just want this true
	defaults.double_burst = false   -- single burst is false, double burst is true
	defaults.show_spell = false     -- mostly debuging
	defaults.death = false

	defaults.nuke_wall_offest = 0       -- CKM todo add this to avoid bursting same element (to avoid nuke wall penalties)

    if user_settings.magic_burst == nil then
        user_settings.magic_burst = defaults
        user_settings:save()
    end
end

function magic_burst.deinit()
	-- not used for now, but can clean up handlers I suppose?
end


local function check_recast(spell_name)
    local recasts = windower.ffxi.get_spell_recasts()
	local spell = res.spells:with('name', spell_name)
	if (spell == nil) then
		return 0
	end

	local recast = recasts[spell.id]

    return recast
end

local function get_bonus_elements()
	-- Use best possible bonus element, default to day
	local day_element = res.elements[res.days[windower.ffxi.get_info().day].element].en
	local weather_id = windower.ffxi.get_info().weather
	local player = windower.ffxi.get_player()

	-- Is a storm active, it wins
	if (#player.buffs > 0) then
		for i=1,#player.buffs do
			local buff = player.buffs[i]

			for _, storm in pairs(otto.event_statics.storms) do
				if (storm.id == buff) then
					weather_id = storm.weather
				end
			end
		end
	end
	local weather_element = res.elements[res.weather[weather_id].element].en

	return weather_element, day_element
end

local function close_window()	
	if user_settings.magic_burst.gearswap then
		windower.send_command('gs c notbursting')
	end
	magic_burst.window_close = 0
	magic_burst.window_open = 0
	magic_burst.window_open_target = nil
	magic_burst.window_open_spell = nil
	magic_burst.window_open_double_burst_spell = nil
end

local function check_burst_window_close()
	local now = os.time()
	if now > magic_burst.window_close then 
		close_window()
	end
end

local function should_cast_death(skillchain) 
	local job = windower.ffxi.get_player().main_job
	local death = res.spells:with('name', "Death")
	local knowsDeath = windower.ffxi.get_spells()[death.id]
	local deathRecast = check_recast(death.name)
	
	if skillchain.english == 'Darkness' and job == 'BLM' and knowsDeath and deathRecast == 0 and user_settings.magic_burst.death then
		return true
	end

	return false
end

local function window_ready(target, skillchain)
	if user_settings.magic_burst.gearswap then
		windower.send_command('gs c bursting')
	end

	if not target or not target.valid_target or not target.hpp <= 0 then
		windower.add_to_chat(123, "Bad Target!")
		return
	end

	local spell = magic_burst.get_spell(skillchain, false)

	if not spell or spell == '' or otto.player_check.mage_disabled() then
		if user_settings.magic_burst.gearswap then
			windower.send_command('gs c notbursting')
		end	
		return
	end
	
	magic_burst.window_open = os.time()
	magic_burst.window_open_target = target
	magic_burst.window_open_spell = spell

	if (user_settings.magic_burst.double_burst) then
		local spell = magic_burst.get_spell(skillchain, true)
		magic_burst.window_open_double_burst_spell = spell
	end

	coroutine.schedule(burst_window_close:prepare(), 9)
end

function magic_burst.get_spell(skillchain, doubleBurst)
	local spell_element = ''
	local weather_element, day_element = get_bonus_elements()
	local spell = ''

	if (user_settings.magic_burst.check_weather and skillchain ~= nil and T(skillchain.elements):contains(weather_element)) then
		spell_element = weather_element
	elseif (user_settings.magic_burst.check_day and T(skillchain.elements):contains(day_element)) then
		spell_element = day_element
	else
		for i=1,#otto.event_statics.spell_priorities do
			if (T(skillchain.elements):contains(otto.event_statics.spell_priorities[i].element)) then
				spell_element = otto.event_statics.spell_priorities[i].element
				break
			end 
		end
	end

	local tier = user_settings.magic_burst.cast_tier 
	if doubleBurst and tier - 1 ~= 0 then tier = tier - 1 end

	-- Find spell/helix/jutsu that will be best based on best element
	if (otto.event_statics.elements[spell_element] ~= nil and otto.event_statics.elements[spell_element][user_settings.magic_burst.cast_type] ~= nil) then

		spell = otto.event_statics.elements[spell_element][user_settings.magic_burst.cast_type]

		tier = (tier >= 1 and tier or 1)
		spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and ':' or '')..(tier > 1 and ' ' or '')
		spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and otto.event_statics.jutsu_tiers[tier].suffix or otto.event_statics.magic_tiers[tier].suffix)

		local recast = check_recast(spell)
		if (recast > 0) then
			spell = ''
		end
	end

	if (spell == nil or spell == '') then
		for _,element in pairs(skillchain.elements) do
			if (otto.event_statics.elements[element] ~= nil and otto.event_statics.elements[element][user_settings.magic_burst.cast_type] ~= nil) then
				spell = otto.event_statics.elements[element][user_settings.magic_burst.cast_type]

				tier = (tier >= 1 and tier or 1)
				spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and ':' or '')..(tier > 1 and ' ' or '')
				spell = spell..(user_settings.magic_burst.cast_type == 'jutsu' and otto.event_statics.jutsu_tiers[tier].suffix or otto.event_statics.magic_tiers[tier].suffix)
			
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
	
	if should_cast_death(skillchain) then
		resSpell = res.spells:with('name', "Death")
	end

	return resSpell
end

-- MARK: Events

function magic_burst.action_handler(category, action, actor, add_effect, target)

	if not user_settings.magic_burst.enabled then return end

	local categories = S{     
		'weaponskill_finish',
    	'mob_tp_finish',
    	'avatar_tp_finish',
	 }
	
    if not categories:contains(category) or action.param == 0 then
        return
    end

	local mob = otto.fight.my_targets[target.id]
    local ally = otto.fight.my_allies[actor]

	
	if not mob then return end       -- not my mob, not my problem.                          
	if not ally then return end      -- not my ally closing sc, not my problem.
	if not otto.cast.is_mob_valid_target(mob) then return end

    if add_effect and otto.event_statics.skillchain_ids:contains(add_effect.message_id) then

		magic_burst.window_open = os.time() 
		magic_burst.window_close = magic_burst.window_open + 8

		local last_skillchain = otto.event_statics.skillchain[add_effect.message_id]
		magic_burst.window_open_target = target

		window_ready(target, last_skillchain)
	else
		-- any ws that doesn't open a skillchain will close one, and disable magic bursting.
		close_window()
	end
end


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

	user_settings:save()
	windower.add_to_chat(123, '> Cast type set to: '..user_settings.magic_burst.cast_type)
end)

return magic_burst