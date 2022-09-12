
local events = S{ }
require('tables')



function events.outgoing_chuck(...)
    
end


function events.prerender(...)
    
end

local function aspir_command(arg)
    local allowed = T{'r', 'reload', 'tier', 't', 'on', 'enable', 'start', 'all', 'single', 'assist'}
    local command = 'help'

    if (#arg > 0) then
        command = arg[1]:lower()
    end


    if command == 'help' or command == '' or command == nil then
        windower.add_to_chat(111, 'Allowed commands for aspir are '..table.concat(allowed, ', '))
        return
    elseif command == 't' or command == 'tier' then 
        if (#arg > 1) then
            local tier = tonumber(arg[2])

            if (tier > 0 and tier < 4) then
                user_settings.aspir.tier = tier
            end
            
            windower.add_to_chat(111, 'Aspir updated tier to '..user_settings.aspir.tier)
           
            return
        end
    elseif command == 'on' or command == 'enable' or command == 'start' then 
        user_settings.aspir.enabled = true
        windower.add_to_chat(111, 'Aspir enabled at '..user_settings.aspir.casting_mp..'% mp')
        return
    elseif command == 'off' or command == 'disable' == command == 'stop' then 
        user_settings.aspir.enabled = false
       
        windower.add_to_chat(111, 'Aspiring disabled')
        return 
    elseif command == 'mp' then 
        if (#arg > 1) then
            local casting_mp = tonumber(arg[2])

            if (casting_mp > 0 and casting_mp < 101) then
                user_settings.aspir.casting_mp = casting_mp
            end
            
            windower.add_to_chat(111, 'Aspir updated for casting below '..user_settings.aspir.casting_mp..'% mp')
           
            return
        end
    elseif command == 'all' then 
        user_settings.aspir.casts_all = true

        windower.add_to_chat(111, 'Aspir Will now cast all aspir spells')
       
        return 
    elseif command == 'single' then 
        user_settings.aspir.casts_all = false

        windower.add_to_chat(111, 'Aspir Will now just cast Aspir '..user_settings.aspir.tier)
       
        return 
    else
        windower.add_to_chat(123, "That's not a command")
		windower.add_to_chat(111, 'Allowed commands for aspir are '..table.concat(allowed, ', '))
    end
end

-- TODO still work to fix out parsing commands
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

	local should_save = true

	if (command == 'help') then
		show_help()
		return
	elseif (command == 'on') then
		windower.add_to_chat(207, 'AutoMB activating')
		player = windower.ffxi.get_player()
		user_settings.magic_burst.enabled = true
    elseif (command == 'off') then
        windower.add_to_chat(207, 'AutoMB deactivating')
        user_settings.magic_burst.enabled = false
	elseif (command == 'cast' or command == 'c') then
		if (#arg < 2) then
			windower.add_to_chat(207, "Usage: autoMB cast spell|helix|jutsu Tells AutoMB what magic type to try to cast if the default is not what you want.")
		end
		if (T(magic_burst.cast_types):contains(arg[2]:lower())) then
			user_settings.magic_burst.cast_type = arg[2]:lower()
            windower.add_to_chat(207, "Spell (c)ast set to"..arg[2])
		end
	elseif (command == 'tier' or command == 't') then
		if (#arg < 2) then
			windower.add_to_chat(207, "Usage: tier 1~6\nTells autoMB what tier spell to use for Ninjutsu 1~3 will become ichi|ni|san.")
		end
		local t = tonumber(arg[2])
		if (user_settings.magic_burst.cast_type == 'jutsu') then
			if (user_settings.magic_burst.cast_tier > 0 and user_settings.magic_burst.cast_tier < 4) then
				user_settings.magic_burst.cast_tier = t
			end
		else
			if (t > 0 and t < 7) then
				user_settings.magic_burst.cast_tier = t
			end		
		end
		windower.add_to_chat(111, "Cast (t)ier set to: "..t)
	elseif (command == 'mp') then
		local n = tonumber(arg[2])
		if (n == nil or n < 0) then
			windower.add_to_chat(207, "Usage: autoMB mp #")
		end
		user_settings.magic_burst.mp = n
        windower.add_to_chat(111, 'Threshold mp set to'..n)
	elseif (command == 'delay' or command == 'd') then
		local n = tonumber(arg[2])
		if (n == nil or n < 0) then
			windower.add_to_chat(207, "Usage: autoMB (d)elay #")
		end
		user_settings.magic_burst.cast_delay = n
        windower.add_to_chat(111, 'Nuking delay set to'..n)
	elseif (command == 'frequency' or command == 'f') then
		local n = tonumber(arg[2])
		if (n == nil or n < 0) then
			windower.add_to_chat(207, "Usage: autoMB (f)requency #"..n)
		end
		user_settings.magic_burst.frequency = n
        windower.add_to_chat(207, "Set burst (f)requency to"..n)
	elseif (command == 'doubleburst' or command == 'double' or command == 'dbl') then
		local message = 'false'
		if not user_settings.magic_burst.double_burst then
			message = 'true'
		end
		user_settings.magic_burst.double_burst = not user_settings.magic_burst.double_burst
        windower.add_to_chat(207, "Double burst is now "..message)
	elseif (command == 'doubleburstdelay' or command == 'doubledelay' or command == 'dbldelay' or command == 'dbld') then
		local n = tonumber(arg[2])
		if (n == nil or n < -10 or n > 10) then
			windower.add_to_chat(207, "Usage: autoMB doubleburstdelay [-10..10]")
		end
		user_settings.magic_burst.double_burst_delay = n
	elseif (command == 'weather') then
		user_settings.magic_burst.check_weather = not user_settings.magic_burst.check_weather
		windower.add_to_chat(111, 'Will'..(user_settings.magic_burst.check_weather and ' ' or ' not ')..'use current weather bonuses')
	elseif (command == 'day') then
		user_settings.magic_burst.check_day = not user_settings.magic_burst.check_day
		windower.add_to_chat(111, 'Will'..(user_settings.magic_burst.check_day and ' ' or ' not ')..'use current day bonuses')
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
				user_settings.magic_burst.show_skillchain = not user_settings.magic_burst.show_skillchain
			else
				user_settings.magic_burst.show_skillchain = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Skillchain info will be '..(user_settings.magic_burst.show_skillchain == true and 'shown' or 'hidden'))
        end
		
		if (what == 'elements' or what == 'element' or what == 'all') then
			if (toggle == 'toggle') then
				user_settings.magic_burst.show_elements = not user_settings.magic_burst.show_elements
			else
				user_settings.magic_burst.show_elements = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Skillchain element info will be '..(user_settings.magic_burst.show_elements == true and 'shown' or 'hidden'))
        end

		if (what == 'weather' or what == 'bonus' or what == 'all') then
			if (toggle == 'toggle') then
				user_settings.magic_burst.show_bonus_elements = not user_settings.magic_burst.show_bonus_elements
			else
				user_settings.magic_burst.show_bonus_elements = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Day/Weather element info will be '..(user_settings.magic_burst.show_bonus_elements == true and 'shown' or 'hidden'))
        end

		if (what == 'spell' or what == 'sp' or what == 'all') then
			if (toggle == 'toggle') then
				user_settings.magic_burst.show_spell = not user_settings.magic_burst.show_spell
			else
				user_settings.magic_burst.show_spell = (toggle == 'on')
			end
			windower.add_to_chat(207, 'AutoMB: Spell info will be '..(user_settings.magic_burst.show_spell == true and 'shown' or 'hidden'))
		end

		return
	elseif (command == 'stepdown' or command == 'sd') then
		local txt = ''
		if (user_settings.magic_burst.step_down == 0) then
			user_settings.magic_burst.step_down = 1
			txt = 'on target change'
		elseif (user_settings.magic_burst.step_down == 1) then
			user_settings.magic_burst.step_down = 2
			txt = 'always'
		else
			user_settings.magic_burst.step_down = 0
			txt = 'never'
		end
		settings:save()
		windower.add_to_chat(111, "Double burst Step Down set to "..txt)
	elseif (command == 'gearswap' or command == 'gs') then
		if (#arg >= 2) then
			toggle = arg[2]:lower()
		end

		if (user_settings.magic_burst.gearswap) and toggle then
			if toggle == "on" then 
				user_settings.magic_burst.gearswap = true
				windower.add_to_chat(111, "Will use 'gs c bursting' and 'gs c notbursting'")
			end

			if toggle == "off" then
				user_settings.magic_burst.gearswap = false
				windower.add_to_chat(111, "Will not use 'gs c bursting' and 'gs c notbursting'")
			end
		end

		if (user_settings.magic_burst.gearswap) then
			user_settings.magic_burst.gearswap = false
		else
			user_settings.magic_burst.gearswap = true
		end
		windower.add_to_chat(111, "Will "..(user_settings.magic_burst.gearswap and '' or ' not ').."use 'gs c bursting' and 'gs c notbursting'")
	elseif (command == 'target' or command == 'tgt') then
		if (user_settings.magic_burst.change_target == nil) then
			user_settings.magic_burst.change_target = false
		end
		user_settings.magic_burst.change_target = not user_settings.magic_burst.change_target
		windower.add_to_chat(111, "Auto target swapping "..(user_settings.magic_burst.change_target and 'enabled' or 'disabled')..".")
	elseif (command == 'zone' or command == 'z') then
		user_settings.magic_burst.disable_on_zone = user_settings.magic_burst.disable_on_zone and (not user_settings.magic_burst.disable_on_zone) or true
		windower.add_to_chat(111, "Auto MB will be "..(user_settings.magic_burst.disable_on_zone and 'enabled' or 'disabled').." when zoning.")
    else 
		should_save = false
	end

	if should_save then 
		log('saving')
		user_settings:save()
	end
end

-- TODO still work to do to fix out parsing commands
local function healbot_commands(args)
	local command = 'help'
	local arg2 = '' 
	local arg3 = ''

    if (#args > 0) then
        command = args[1]:lower()
    end

	if (#args > 1) then
		arg2 = args[2]:lower()
	end

	if (#args > 2) then
		arg3 = args[3]:lower()
	end
	
    if S{'reload','unload'}:contains(command) then
        windower.send_command(('lua %s %s'):format(command, _addon.name))
    elseif command == 'refresh' then
        utils.load_configs()
    elseif S{'start','on'}:contains(command) then
        otto.activate()
    elseif S{'stop','end','off'}:contains(command) then
        otto.active = false
        utils.printStatus()
    elseif S{'disable'}:contains(command) then
        if not validate(args, 2, 'Error: No argument specified for Disable') then return end
        utils.disableCommand(arg2, true)
    elseif S{'enable'}:contains(command) then
        if not validate(args, 2, 'Error: No argument specified for Enable') then return end 
        utils.disableCommand(args[2]:lower(), false)
    elseif S{'assist','as'}:contains(command) then
        local cmd = args[2] and args[2]:lower() or (offense.assist.active and 'off' or 'resume')
        if S{'off','end','false','pause'}:contains(cmd) then
            offense.assist.active = false
            atc('Assist is now off.')
        elseif S{'resume'}:contains(cmd) then
            if (offense.assist.name ~= nil) then
                offense.assist.active = true
                atc('Now assisting '..offense.assist.name..'.')
            else
                atc(111,'Error: Unable to resume assist - no target set')
            end
        elseif S{'attack','engage'}:contains(cmd) then
            local cmd2 = args[2] and args[2]:lower() or (offense.assist.engage and 'off' or 'resume')
            if S{'off','end','false','pause'}:contains(cmd2) then
                offense.assist.engage = false
                atc('Will no longer enagage when assisting.')
            else
                offense.assist.engage = true
                atc('Will now enagage when assisting.')
            end
        else    --args[2] is guaranteed to have a value if this is reached
            offense.register_assistee(args[2])
        end
    elseif S{'ws','weaponskill'}:contains(command) then
        local lte,gte = string.char(0x81, 0x85),string.char(0x81, 0x86)
        local cmd = args[2] and args[2] or ''
        settings.ws = settings.ws or {}
        if (cmd == 'waitfor') then      --another player's TP
            local partner = utils.getPlayerName(args[3])
            if (partner ~= nil) then
                local partnertp = tonumber(args[3]) or 1000
                settings.ws.partner = {name=partner,tp=partnertp}
                atc("Will weaponskill when "..partner.."'s TP is "..gte.." "..partnertp)
            else
                atc(111,'Error: Invalid argument for ws waitfor: '..tostring(args[3]))
            end
        elseif (cmd == 'nopartner') then
            settings.ws.partner = nil
            atc('Weaponskill partner removed.')
        elseif (cmd == 'hp') then       --Target's HP
            local sign = S{'<','>'}:contains(args[3]) and args[3] or nil
            local hp = tonumber(args[4])
            if (sign ~= nil) and (hp ~= nil) then
                settings.ws.sign = sign
                settings.ws.hp = hp
                atc("Will weaponskill when the target's HP is "..sign.." "..hp.."%")
            else
                atc(111,'Error: Invalid arguments for ws hp: '..tostring(args[3])..', '..tostring(args[4]))
            end
        else
            if S{'use','set'}:contains(cmd) then    -- ws name
                table.remove(args, 1)
            end
            utils.register_ws(args)
        end
    elseif S{'spam','nuke'}:contains(command) then
        local cmd = args[2] and args[2]:lower() or (settings.spam.active and 'off' or 'on')
        if S{'on','true'}:contains(cmd) then
            settings.spam.active = true
            if (settings.spam.name ~= nil) then
                atc('Action spamming is now on. Action: '..settings.spam.name)
            else
                atc('Action spamming is now on. To set a spell to use: //otto spam use <action>')
            end
        elseif S{'off','false'}:contains(cmd) then
            settings.spam.active = false
            atc('Action spamming is now off.')
        else
            if S{'use','set'}:contains(cmd) then
                table.remove(args, 2)
            end
            utils.register_spam_action(args)
        end
    elseif S{'debuff', 'db'}:contains(command) then
		log("in debuff")
        if S{'on','true'}:contains(arg2) then
            offense.debuffing_active = true
            atc('Debuffing is now on.')
        elseif S{'off','false'}:contains(arg2) then
            offense.debuffing_active = false
            atc('Debuffing is now off.')
        elseif S{'rm','remove'}:contains(arg2) then
			local debuff = table.slice(args, 3)

            utils.register_offensive_debuff(debuff, true)
        elseif S{'ls','list'}:contains(arg2) then
            pprint_tiered(offense.debuffs)

        elseif S{'debug'}:contains(arg2) then 
            table.vprint(offense)
        elseif S{'use','set'}:contains(arg2) then
			local debuff = table.slice(args, 3)
			utils.register_offensive_debuff(debuff, false)
			-- table.remove(args, 3)
        end
    elseif command == 'mincure' then
        if not validate(args, 2, 'Error: No argument specified for minCure') then return end
        local val = tonumber(args[2])
        if (val ~= nil) and (1 <= val) and (val <= 6) then
            settings.healing.min.cure = val
            atc('Minimum cure tier set to '..val)
        else
            atc('Error: Invalid argument specified for minCure')
        end
    elseif command == 'mincuraga' then
        if not validate(args, 2, 'Error: No argument specified for minCure') then return end
        local val = tonumber(args[2])
        if (val ~= nil) and (1 <= val) and (val <= 6) then
            settings.healing.min.curaga = val
            atc('Minimum curaga tier set to '..val)
        else
            atc('Error: Invalid argument specified for minCure')
        end
    elseif command == 'reset' then
        if not validate(args, 2, 'Error: No argument specified for reset') then return end
        local rcmd = args[3]:lower()
        local b,d = false,false
        if S{'all','both'}:contains(rcmd) then
            b,d = true,true
        elseif (rcmd == 'buffs') then
            b = true
        elseif (rcmd == 'debuffs') then
            d = true
        else
            atc('Error: Invalid argument specified for reset: '..arg[1])
            return
        end
        
        local resetTarget
        if (args[3] ~= nil) and (args[4] ~= nil) and (args[3]:lower() == 'on') then
            local pname = utils.getPlayerName(args[4])
            if (pname ~= nil) then
                resetTarget = pname
            else
                atc(111,'Error: Invalid name provided as a reset target: '..tostring(args[4]))
                return
            end
        end
        resetTarget = resetTarget or 'ALL' 
        local rtmsg = resetTarget or 'all monitored players'
        if b then
            buffs.resetBuffTimers(resetTarget)
            atc(('Buff timers for %s were reset.'):format(rtmsg))
        end
        if d then
            buffs.resetDebuffTimers(resetTarget)
            atc(('Debuffs detected for %s were reset.'):format(rtmsg))
        end
    elseif command == 'buff' then
        buffs.registerNewBuff(args, true)
    elseif S{'cancelbuff','nobuff'}:contains(command) then
        buffs.registerNewBuff(args, false)
    elseif command == 'wipebuffs' then                              -- CKM added to completely clear buff lists (needed to resolve conflicting buffs -- ex barstonra / barfira)
        utils.wipe_bufflist()
    elseif command == 'wipedebuffs' then
        utils.wipe_debufflist()
    elseif S{'bufflist','bl'}:contains(command) then
        if not validate(args, 2, 'Error: No argument specified for BuffList') then return end
        utils.apply_bufflist(args)
    elseif command == 'bufflists' then
        pprint(otto.config.buff_lists)
    elseif command == 'ignore_debuff' then
        buffs.registerIgnoreDebuff(args, true)
    elseif command == 'unignore_debuff' then
        buffs.registerIgnoreDebuff(args, false)
    elseif S{'follow','f'}:contains(command) then
        local cmd = args[2] and args[2]:lower() or (settings.follow.active and 'off' or 'resume')
        if S{'off','end','false','pause','stop','exit'}:contains(cmd) then
            settings.follow.active = false
        elseif S{'distance', 'dist', 'd'}:contains(cmd) then
            local dist = tonumber(args[3])
            if (dist ~= nil) and (0 < dist) and (dist < 45) then
                settings.follow.distance = dist
                atc('Follow distance set to '..settings.follow.distance)
            else
                atc('Error: Invalid argument specified for follow distance')
            end
        elseif S{'resume'}:contains(cmd) then
            if (settings.follow.target ~= nil) then
                settings.follow.active = true
                atc('Now following '..settings.follow.target..'.')
            else
                atc(111,'Error: Unable to resume follow - no target set')
            end
        else    --args[1] is guaranteed to have a value if this is reached
            local pname = utils.getPlayerName(args[2])
            if (pname ~= nil) then
                settings.follow.target = pname
                settings.follow.active = true
                atc('Now following '..settings.follow.target..'.')
            else
                atc(111,'Error: Invalid name provided as a follow target: '..tostring(args[2]))
            end
        end
    elseif S{'ignore', 'unignore', 'watch', 'unwatch'}:contains(command) then
        monitorCommand(command, args[2])
    elseif command == 'ignoretrusts' then
        utils.toggleX(settings, 'ignoreTrusts', args[2], 'Ignoring of Trust NPCs', 'IgnoreTrusts')
    elseif command == 'packetinfo' then
        toggleMode('showPacketInfo', args[2], 'Packet info display', 'PacketInfo')
    elseif command == 'debug' then
        toggleMode('debug', args[2], 'Debug mode', 'debug mode')
    elseif command == 'independent' then
        toggleMode('independent', args[2], 'Independent mode', 'independent mode')
    elseif S{'deactivateindoors','deactivate_indoors'}:contains(command) then
        utils.toggleX(settings, 'deactivateIndoors', args[2], 'Deactivation in indoor zones', 'DeactivateIndoors')
    elseif S{'activateoutdoors','activate_outdoors'}:contains(command) then
        utils.toggleX(settings, 'activateOutdoors', args[2], 'Activation in outdoor zones', 'ActivateOutdoors')
    elseif utils.txtbox_cmd_map[command] ~= nil then
        local boxName = utils.txtbox_cmd_map[command]
        if utils.posCommand(boxName, args) then
            utils.refresh_textBoxes()
        else
            utils.toggleVisible(boxName, args[2])
        end
    elseif S{'help','--help'}:contains(command) then
        help_text()
    elseif command == 'settings' then
        for k,v in pairs(settings) do
            local kstr = tostring(k)
            local vstr = (type(v) == 'table') and tostring(T(v)) or tostring(v)
            atc(kstr:rpad(' ',15)..': '..vstr)
        end
    elseif command == 'status' then
        utils.printStatus()
    elseif command == 'info' then
        if not _libs.lor.exec then
            atc(3,'Unable to parse info.  Windower/addons/libs/lor/lor_exec.lua was unable to be loaded.')
            atc(3,'If you would like to use this function, please visit https://github.com/lorand-ffxi/lor_libs to download it.')
            return
        end
        local cmd = args[2]     --Take the first element as the command
        table.remove(args, 2)   --Remove the first from the list of args
        _libs.lor.exec.process_input(cmd, args)
    else
        atc('Error: Unknown command')
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
		elseif command == 'healbot' or command == 'hb' or command == 'healer' then
			healbot_commands(newArgs)
			return
        end
    end

end

return events