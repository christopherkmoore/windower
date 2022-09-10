
local events = S{ }
require('tables')
utilities = require('otto_utilities')
events.settings = T{ }
events.state = T{}

events.should_update_settings = false 

function events.Update()
    events.should_update_settings = false
    return events.settings
end

function events.Report()
    return events.state
end

function events.outgoing_chuck(...)
    events.state.determine_movement(...)
end


function events.prerender(...)
    events.state.determine_is_busy(...)
end

local function aspir_command(arg)
    local allowed = T{'r', 'reload', 'tier', 't', 'on', 'enable', 'start', 'all', 'single', 'assist'}
    local command = 'help'

    if (#arg > 0) then
        command = arg[1]:lower()
    end

    events.should_update_settings = true 
    
    if command == 'help' or command == '' or command == nil then
        windower.add_to_chat(123, 'Allowed commands for aspir are '..table.concat(allowed, ', '))
        return
    elseif command == 't' or command == 'tier' then 
        if (#arg > 1) then
            local tier = tonumber(arg[2])

            if (tier > 0 and tier < 4) then
                events.settings.aspir.tier = tier
            end
            
            windower.add_to_chat(123, 'Updated tier to '..events.settings.aspir.tier)
           
            return
        end
    elseif command == 'on' or command == 'enable' or command == 'start' then 
        events.settings.aspir.enabled = true
        windower.add_to_chat(123, 'now aspiring at '..events.settings.aspir.casting_mp..' mp')
        return
    elseif command == 'off' or command == 'disable' == command == 'stop' then 
        events.settings.aspir.enabled = false
       
        windower.add_to_chat(123, 'Aspiring disabled')
        return 
    elseif command == 'mp' then 
        if (#arg > 1) then
            local casting_mp = tonumber(arg[2])

            if (casting_mp > 0 and casting_mp < 101) then
                events.settings.aspir.casting_mp = casting_mp
            end
            
            windower.add_to_chat(123, 'Updated spells to cast below '..events.settings.aspir.casting_mp..' mp')
           
            return
        end
    elseif command == 'all' then 
        events.settings.aspir.casts_all = true

        windower.add_to_chat(123, 'Will now cast all aspir spells')
       
        return 
    elseif command == 'single' then 
        events.settings.aspir.casts_all = false

        windower.add_to_chat(123, 'Will now just cast Aspir '..events.settings.aspir.tier)
       
        return 
    elseif command == 'assist' then
        -- TODO left off here.
        if (#arg > 1) then
            local asistee = arg[2]

            local pname = utilities.getPlayerName(asistee)
            if (pname ~= nil) then
                events.settings.assistee = pname
                events.settings.active = true
                windower.add_to_chat(123, 'Now assisting '..pname)
            else
                windower.add_to_chat(123,'Error: Invalid name provided as an assist target: '..arg[2])
            end        
           
        end
        return 
    else
        windower.add_to_chat(123, "That's not a command")
        events.should_update_settings = false 
    end
end

local function magic_burst_command(arg)
    local allowed = T{'test', 'help', 'status', 'show'}
    local command = 'help'

    function show_help()
        windower.add_to_chat(207, _addon.name..': Usage:\nautoMB on|off - turn auto magic bursting on or off\nautoMB show on|off - display messages about skillchains|magic bursts')
        windower.add_to_chat(207, _addon.name..': Auto Bursts: \t\t'..(settings.magic_burst_enabled and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Magic Burst Type: \t'..settings.magic_burst_cast_type..' Tier: \t'..(settings.magic_burst_tier))
        windower.add_to_chat(207, _addon.name..': Min MP: \t\t'..settings.magic_burst_mp)
        windower.add_to_chat(207, _addon.name..': Cast Delay: '..settings.magic_burst_cast_delay..' seconds')
        windower.add_to_chat(207, _addon.name..': Double Burst: '..(settings.magic_burst_double_burst and ('On'..' delay '..settings.magic_burst_double_burst_delay..' seconds') or 'Off'))
        windower.add_to_chat(207, _addon.name..': Check Elements - Day: '..(settings.magic_burst_check_day and 'On' or 'Off')..' Weather: '..(settings.magic_burst_check_weather and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Show Skillchain: \t\t'..(settings.magic_burst_show_skillchain and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Show Skillchain Elements: \t'..(settings.magic_burst_show_elements and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Show Day|Weather Elements: \t'..(settings.magic_burst_show_bonus_elements and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Show Spell: \t'..(settings.magic_burst_show_spell and 'On' or 'Off'))
    end
    
    if (#arg > 0) then
        command = arg[1]:lower()
    end

    events.should_update_settings = true 


	if (command == 'help') then
		show_help()
		return
	elseif (command == 'on') then
		windower.add_to_chat(207, 'AutoMB activating')
		player = windower.ffxi.get_player()
		magic_burst.settings.magic_burst_enabled = true
        return
    elseif (command == 'off') then
        windower.add_to_chat(207, 'AutoMB deactivating')
        magic_burst.settings.magic_burst_enabled = false
		return
	elseif (command == 'cast' or command == 'c') then
		if (#arg < 2) then
			windower.add_to_chat(207, "Usage: autoMB cast spell|helix|jutsu\nTells AutoMB what magic type to try to cast if the default is not what you want.")
		end
		if (T(magic_burst.cast_types):contains(arg[2]:lower())) then
			settings.cast_type = arg[2]:lower()
		end
		settings:save()
		return
	elseif (command == 'tier' or command == 't') then
		if (#arg < 2) then
			windower.add_to_chat(207, "Usage: tier 1~6\nTells autoMB what tier spell to use for Ninjutsu 1~3 will become ichi|ni|san.")
			return
		end
		local t = tonumber(arg[2])
		if (settings.cast_type == 'jutsu') then
			if (settings.cast_tier > 0 and settings.cast_tier < 4) then
				settings.cast_tier = t
			end
		else
			if (t > 0 and t < 7) then
				settings.cast_tier = t
			end		
		end
		settings:save()
		windower.add_to_chat(123, "Cast Tier set to: "..t.." ["..(settings.cast_type == 'jutsu' and jutsu_tiers[settings.cast_tier].suffix or magic_tiers[settings.cast_tier].suffix).."]")
		return
	elseif (command == 'mp') then
		local n = tonumber(arg[2])
		if (n == nil or n < 0) then
			windower.add_to_chat(207, "Usage: autoMB mp #")
			return
		end
		settings.mp = n
		settings:save()
		return
	elseif (command == 'delay' or command == 'd') then
		local n = tonumber(arg[2])
		if (n == nil or n < 0) then
			windower.add_to_chat(207, "Usage: autoMB delay #")
			return
		end
		settings.cast_delay = n
		settings:save()
		return
	elseif (command == 'frequency' or command == 'f') then
		local n = tonumber(arg[2])
		if (n == nil or n < 0) then
			windower.add_to_chat(207, "Usage: autoMB (f)requency #")
			return
		end
		settings.frequency = n
		settings:save()
		return
	elseif (command == 'doubleburst' or command == 'double' or command == 'dbl') then
		settings.double_burst = not settings.double_burst
		settings:save()
		return
	elseif (command == 'doubleburstdelay' or command == 'doubledelay' or command == 'dbldelay' or command == 'dbld') then
		local n = tonumber(arg[2])
		if (n == nil or n < -10 or n > 10) then
			windower.add_to_chat(207, "Usage: autoMB doubleburstdelay [-10..10]")
			return
		end
		settings.double_burst_delay = n
		settings:save()
		return
	elseif (command == 'weather') then
		settings.check_weather = not settings.check_weather
		windower.add_to_chat(123, 'Will'..(settings.check_weather and ' ' or ' not ')..'use current weather bonuses')
	elseif (command == 'day') then
		settings.check_day = not settings.check_day
		windower.add_to_chat(123, 'Will'..(settings.check_day and ' ' or ' not ')..'use current day bonuses')
	elseif (command == 'toggle' or command == 'tog') then
		local what = 'all'
		local toggle = 'toggle'

		if (#arg > 1) then
			what = arg[2]:lower()
		end

		if (#arg > 2) then
			toggle = arg[3]:lower()
		end

		-- Show/Hide skillchain name/elements and spell(s) to be cast
		if (what == 'skillchain' or what == 'sc' or what == 'all') then
			if (toggle == '' or toggle == 'toggle') then
				settings.show_skillchain = not settings.show_skillchain
			else
				settings.show_skillchain = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Skillchain info will be '..(settings.show_skillchain == true and 'shown' or 'hidden'))
        end
		
		if (what == 'elements' or what == 'element' or what == 'all') then
			if (toggle == 'toggle') then
				settings.show_elements = not settings.show_elements
			else
				settings.show_elements = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Skillchain element info will be '..(settings.show_elements == true and 'shown' or 'hidden'))
        end

		if (what == 'weather' or what == 'bonus' or what == 'all') then
			if (toggle == 'toggle') then
				settings.show_bonus_elements = not settings.show_bonus_elements
			else
				settings.show_bonus_elements = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Day/Weather element info will be '..(settings.show_bonus_elements == true and 'shown' or 'hidden'))
        end

		if (what == 'spell' or what == 'sp' or what == 'all') then
			if (toggle == 'toggle') then
				settings.show_spell = not settings.show_spell
			else
				settings.show_spell = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Spell info will be '..(settings.show_spell == true and 'shown' or 'hidden'))
		end

		settings:save()
		return
	elseif (command == 'stepdown' or command == 'sd') then
		local txt = ''
		if (settings.step_down == 0) then
			settings.step_down = 1
			txt = 'on target change'
		elseif (settings.step_down == 1) then
			settings.step_down = 2
			txt = 'always'
		else
			settings.step_down = 0
			txt = 'never'
		end
		settings:save()
		windower.add_to_chat(123, "Double burst Step Down set to "..txt)
		return
	elseif (command == 'gearswap' or command == 'gs') then
		if (#arg >= 2) then
			toggle = arg[2]:lower()
		end

		if (settings.gearswap) and toggle then
			if toggle == "on" then 
				settings.gearswap = true
				windower.add_to_chat(123, "Will use 'gs c bursting' and 'gs c notbursting'")
				return
			end

			if toggle == "off" then
				settings.gearswap = false
				windower.add_to_chat(123, "Will not use 'gs c bursting' and 'gs c notbursting'")
				return 
			end
		end

		if (settings.gearswap) then
			settings.gearswap = false
		else
			settings.gearswap = true
		end
		windower.add_to_chat(123, "Will "..(settings.gearswap and '' or ' not ').."use 'gs c bursting' and 'gs c notbursting'")
		settings:save()
		return
	elseif (command == 'target' or command == 'tgt') then
		if (settings.change_target == nil) then
			settings.change_target = false
		end
		settings.change_target = not settings.change_target
		windower.add_to_chat(123, "Auto target swapping "..(settings.change_target and 'enabled' or 'disabled')..".")
		settings:save()
	elseif (command == 'zone' or command == 'z') then
		settings.disable_on_zone = settings.disable_on_zone and (not settings.disable_on_zone) or true
		windower.add_to_chat(123, "Auto MB will be "..(settings.disable_on_zone and 'enabled' or 'disabled').." when zoning.")
		settings:save()
    end
end


-- addon load. parses commands passed to otto
function events.addon_command(...)
    args = T { ... }
    local command = 'help'

    if (#args > 0) then
        command = args[1]:lower()
    end

    if (#args > 1) then
        local newArgs = table.slice(args, 2)
        if command == 'aspir' then
            aspir_command(newArgs)
            return
        elseif command == 'magicburst' or command == 'magic_burst' or command == 'mb' or command == 'amb' then
            magic_burst_command(newArgs)
            return
        end
    end

end

return events