
local events = T{ }
require('tables')


local function aspir_command(arg)
    local allowed = T{'r', 'reload', 'tier', 't', 'on', 'enable', 'start', 'all', 'single', 'assist'}
    local command = 'help'
	local message = ''
	local arg2 = ''

    if (#arg > 0) then
        command = arg[1]:lower()
    end

	if (#arg > 1) then
		arg2 = arg[2]
	end

	local should_save = true 

    if command == 'help' or command == '' or command == nil then
        should_save = false
		message = 'Allowed commands for aspir are '..table.concat(allowed, ', ')
    elseif command == 't' or command == 'tier' then 
        local tier = tonumber(arg2)

		if (tier > 0 and tier < 4) then
			user_settings.aspir.tier = tier
			message = 'Aspir updated tier to '..user_settings.aspir.tier
		else 
			windower.add_to_chat(123, 'Aspir tier '..user_settings.aspir.tier..' is out of bounds')
		end
    elseif command == 'on' or command == 'enable' or command == 'start' then 
        user_settings.aspir.enabled = true
        message = 'Aspir enabled at '..user_settings.aspir.casting_mp..'% mp'
    elseif command == 'off' or command == 'disable' == command == 'stop' then 
        user_settings.aspir.enabled = false
        message = 'Aspiring is disabled'
    elseif command == 'mp' then 
        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(123, 'otto aspir mp requires a mp percent')
            return
        end

		local casting_mp = tonumber(arg2)

		if (casting_mp > 0 and casting_mp < 101) then
			user_settings.aspir.casting_mp = casting_mp
			message = 'Aspir updated for casting below '..user_settings.aspir.casting_mp..'% mp'
		else 
			windower.add_to_chat(123, 'Aspir mp percent range '..casting_mp..' is out of bounds between 0 - 100%')
		end

	elseif command == 'all' then 
        user_settings.aspir.casts_all = true
        message = 'Aspir Will now cast all aspir spells'
    elseif command == 'single' then 
        user_settings.aspir.casts_all = false
        message = 'Aspir Will now just cast Aspir '..user_settings.aspir.tier
    else
		should_save = false
        windower.add_to_chat(123, "That's not a command")
		windower.add_to_chat(111, 'Allowed commands for aspir are '..table.concat(allowed, ', '))
    end

	if should_save then
		windower.add_to_chat(111, message)
		user_settings:save()
	end

end

local function magic_burst_command(arg)
    local allowed = T{'test', 'help', 'status', 'show'}
    local message = ''
    local command = 'help'
	local arg2 = ''

    if (#arg > 0) then
        command = arg[1]:lower()
    end

	if (#arg > 1) then
		arg2 = arg[2]
	end

    function show_help()
        windower.add_to_chat(207, _addon.name..': magic burst on|off - turn auto magic bursting on or off\n magic bursts show on|off - display messages about skillchains|magic bursts')
        windower.add_to_chat(207, _addon.name..': Auto Bursts: \t\t'..(user_settings.magic_burst.enabled and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Magic Burst Type: \t'..user_settings.magic_burst.cast_type..' Tier: \t'..(user_settings.magic_burst.cast_tier))
        windower.add_to_chat(207, _addon.name..': Min MP: \t\t'..user_settings.magic_burst.mp)
        windower.add_to_chat(207, _addon.name..': Double Burst: '..(user_settings.magic_burst.double_burst and ('On'..' delay '..user_settings.magic_burst.double_burst_delay..' seconds') or 'Off'))
        windower.add_to_chat(207, _addon.name..': Check Elements - Day: '..(user_settings.magic_burst.check_day and 'On' or 'Off')..' Weather: '..(user_settings.magic_burst.check_weather and 'On' or 'Off'))
        windower.add_to_chat(207, _addon.name..': Show Spell: \t'..(user_settings.magic_burst.show_spell and 'On' or 'Off'))
    end

	local should_save = true

	if (command == 'help') then
        should_save = false
		show_help()
		return
	elseif (command == 'on') then
		message = 'AutoMB activating'
		user_settings.magic_burst.enabled = true
    elseif (command == 'off') then
        message = 'AutoMB deactivating'
        user_settings.magic_burst.enabled = false
	elseif (command == 'cast' or command == 'c') then
		if arg2 == nil or arg2 == '' then
			windower.add_to_chat(123, "Usage: otto mb cast spell|helix|jutsu Tells AutoMB what magic type to try to cast if the default is not what you want.")
            return
		end
        local cast_types = utils.cast_types()
		if cast_types:contains(arg2:lower()) then
			user_settings.magic_burst.cast_type = arg2:lower()
            message = 'Spell (c)ast set to '..arg2
        else 
            windower.add_to_chat(123, 'Unsupported spell type '..arg2)
            return
		end
	elseif (command == 'tier' or command == 't') then
		if arg2 == nil or arg2 == '' or not tonumber(arg2) then
			windower.add_to_chat(123, "Usage: tier 1~6 tells autoMB what tier spell to use for Ninjutsu 1~3 will become ichi|ni|san.")
            return
		end
		
        local t = tonumber(arg2)
		
        if user_settings.magic_burst.cast_type == 'jutsu' and (user_settings.magic_burst.cast_tier > 0 and user_settings.magic_burst.cast_tier < 4) then
			user_settings.magic_burst.cast_tier = t
            message = 'magic burst (t)ier updated to '..arg2
		elseif (t > 0 and t < 7) then
            user_settings.magic_burst.cast_tier = t
            message = 'magic burst (t)ier updated to '..arg2
        elseif (t < 0 or t > 7) then
            windower.add_to_chat(123, 'Provide a tier in the appropriate range.')
            return
        end

	elseif (command == 'mp') then
        if arg2 == nil or arg2 == '' or not tonumber(arg2) then
            windower.add_to_chat(123, "provide a threshold mp at which to stop nuking.")
            should_save = false
            return
        end

		local n = tonumber(arg2)
		user_settings.magic_burst.mp = n
        message = 'Threshold mp set to'..arg2
	elseif (command == 'doubleburst' or command == 'double' or command == 'dbl') then
		local parsed = ' not'
		if not user_settings.magic_burst.double_burst then
			parsed = ''
		end
		user_settings.magic_burst.double_burst = not user_settings.magic_burst.double_burst
        message = 'Will'..parsed..' use double bursting.'
	elseif (command == 'weather') then
        local parsed = ' not'
		if not user_settings.magic_burst.check_weather then
			parsed = ''
		end

		user_settings.magic_burst.check_weather = not user_settings.magic_burst.check_weather
		message = 'Will'..parsed..' use current weather bonuses'
	elseif (command == 'day') then
        local parsed = ' not'
		if not user_settings.magic_burst.check_day then
			parsed = ''
		end
		user_settings.magic_burst.check_day = not user_settings.magic_burst.check_day
		message = 'Will'..parsed..' use current day bonuses'
	elseif (command == 'gearswap' or command == 'gs') then
		if arg2 == nil or arg2 == '' then
            windower.add_to_chat(123, 'Provide an additional on | off for this command.')
            return
        end
        
        if not T{'on', 'off'}:contains(arg2) then 
            windower.add_to_chat(123, 'Provide the command on | off for this command instead of '..arg2)
            return
        end

        local parsed = ''
        if arg2 == "on" then 
            user_settings.magic_burst.gearswap = true
        end

        if arg2 == "off" then
            parsed = ' not'
            user_settings.magic_burst.gearswap = false
        end

		message ='Will'..parsed..' use gs c bursting and gs c notbursting'
	elseif (command == 'target' or command == 'tgt') then
		if (user_settings.magic_burst.change_target == nil) then
			user_settings.magic_burst.change_target = false
		end

		user_settings.magic_burst.change_target = not user_settings.magic_burst.change_target
		message ="Auto target swapping "..(user_settings.magic_burst.change_target and 'enabled' or 'disabled').."."
    else 
		should_save = false
	end

	if should_save then 
        windower.add_to_chat(111, message)
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

    if S{'disable'}:contains(command) then
        if not validate(args, 2, 'Error: No argument specified for Disable') then return end
        utils.disableCommand(arg2, true)
    elseif S{'enable'}:contains(command) then
        if not validate(args, 2, 'Error: No argument specified for Enable') then return end 
        utils.disableCommand(args[2]:lower(), false)
    
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


local function follow_commands(args)
	local arg1 = ''
	local arg2 = ''

    if (#args > 0) then
        arg1 = args[1]:lower()
    end

	if (#args > 1) then
		arg2 = args[2]:lower()
	end
    
    local should_save = true

    if S{'off','end','false','pause','stop','exit'}:contains(arg1) then
        user_settings.follow.active = false
    elseif S{'distance', 'dist', 'd'}:contains(arg1) then
        local dist = tonumber(arg2)
        if (dist ~= nil) and (0 < dist) and (dist < 45) then
            user_settings.follow.distance = dist
            atc('Follow distance set to '..user_settings.follow.distance)
        else
            atc('Error: Invalid argument specified for follow distance')
            return
        end
    elseif S{'resume', 'on'}:contains(arg1) then
        if (user_settings.follow.target ~= nil) then
            user_settings.follow.active = true
            atc('Now following '..user_settings.follow.target..'.')
        else
            atc(111,'Error: Unable to resume follow - no target set')
            return
        end
    else    --args[1] is guaranteed to have a value if this is reached
        local pname = utils.getPlayerName(arg1)
        if (pname ~= nil) then
            user_settings.follow.target = pname
            user_settings.follow.active = true
            atc('Now following '..user_settings.follow.target..'.')
        else
            should_save = false
            atc(111,'Error: Invalid name provided as a follow target: '..tostring(arg1))
        end
    end

    if should_save then
		user_settings:save()
	end
end

local function assist_commands(args)
    local allowed = T{'on | off | enabled | disable', 'yalmfightrange', 'role', 'master', 'slave'}
    local command = 'help'
	local message = ''
	local arg2 = ''

    if (#args > 0) then
        command = args[1]
    end

	if (#args > 1) then
		arg2 = args[2]
	end

	local should_save = true 
    user_settings = lor_settings.load('data/user_settings.lua')
    
    if command == 'on' or command == 'enable' then
        user_settings.assist.enabled = true
        otto.assist.toggle_register_windower_events()
        message = 'Assist is now on! Remember to set your role, yalmfightrange and master | slave'
    elseif command == 'off' or command == 'disable' then
        user_settings.assist.enabled = false
        otto.assist.toggle_register_windower_events()
        message = 'Assiting has been toggled off.'
    elseif command == 'master' then
        if arg2 == 'off' then
            user_settings.assist.master = ''
            windower(123, 'Assist not configured with a master')
            user_settings:save()
            return
        end
        user_settings.assist.master = windower.ffxi.get_player().name
        message = 'Assist configured with '..user_settings.assist.master..' as master'
    elseif command == 'slave' then
        local name = windower.ffxi.get_player().name
        local inSet = S(user_settings.assist.slaves):contains(name)
        if inSet or arg2 == 'off' then
            table.remove(user_settings.assist.slaves, name)
            message = 'Assist is removing you as a slave... be free.'
            windower.send_command('input /autotarget on')
        elseif not inSet or arg2 == 'on' then 
            table.insert(user_settings.assist.slaves, name)
            message = 'Assist configured with '..name..' as a slave'
            windower.send_command('input /autotarget off')
        end	
	elseif command == 'role' then
		if arg2 == nil then
            message = 'Please provide a role of: frontline | backline \n frontline will engage melee while backline support from afar'
            should_save = false
        end

        if arg2 == 'frontline' or arg2 == 'backline' then 
            local name = windower.ffxi.get_player().name
            user_settings.assist.slaves[name] = arg2:lower()
            message = 'Assist role is selected as '..arg2..'. Setting a role means you are a slave.'
        end
    elseif command == 'yalmfightrange' or command == 'range' or command == 'yalm' or command == 'y' or command == 'r' then
        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(123, 'You need to provide a range between 0-5')
            return
        end
        local yalms = tonumber(arg2)
        if yalms <= 0 or yalms >= 5 then
            windower.add_to_chat(123, 'You need to provide a range between 0-5')
            return
        end

        if yalms > 0 and yalms > 5 then
            user_settings.assist.yalm_fight_range = yalms
            message = 'Assists will engage at a distance of '..arg2..' yalms'
        end
    else
        windower.add_to_chat(123, "That's not a command")
		windower.add_to_chat(111, 'Allowed commands for assist are '..table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
		windower.add_to_chat(111, message)
		user_settings:save()
	end

end


-- addon load. parses commands passed to otto
function events.addon_command(...)
    local args = T { ... }
    local command = 'help'

    if (#args > 0) then
        command = args[1]:lower()
    end

    if (#args > 1) then
        local newArgs = table.slice(args, 2)
        -- MARK: commands to sub programs
        if command == 'aspir' then
            aspir_command(newArgs)
            return
        elseif command == 'magicburst' or command == 'magic_burst' or command == 'mb' or command == 'amb' then
            magic_burst_command(newArgs)
            return
		elseif command == 'healbot' or command == 'hb' or command == 'healer' then
			healbot_commands(newArgs)
			return
        elseif command == 'follow' or command == 'f' then
            follow_commands(newArgs)
        elseif command == 'assist' or command == 'a' then
            assist_commands(newArgs)
            -- todo merge with awm
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

        -- MARK: commands to local otto

        end
    end

	if (#args == 1) then
		if command == 'refresh' then
			utils.load_configs()
        elseif S{'r','reload'}:contains(command) then
            windower.send_command('lua reload otto')
        elseif S{'help','man', '?'}:contains(command) then
            windower.add_to_chat(144, 'Top level commands are:')
            windower.add_to_chat(144, 'aspir - configure auto aspir!')
            windower.add_to_chat(144, 'magicburst | mb - make things explody')
            windower.add_to_chat(144, 'healbot | hb - your beloved healer -- and a white mage that will never talk back!')
            windower.add_to_chat(144, 'follow | f - commands for following a master')
        elseif S{'start','on'}:contains(command) then
            otto.activate = true
            windower.add_to_chat(144, 'Otto is live!')
            user_settings:save()
        elseif S{'stop','off'}:contains(command) then
            otto.activate = true
            windower.add_to_chat(144, 'Otto powering dooow--!')
            user_settings:save()
        end
    end
end

return events