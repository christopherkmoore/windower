local events = T {}
require('tables')


local function aspir_command(arg)
    local allowed = T { 'r', 'reload', 'tier', 't', 'on', 'enable', 'start', 'all', 'single', 'assist' }
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
        message = 'Allowed commands for aspir are ' .. table.concat(allowed, ', ')
    elseif command == 't' or command == 'tier' then
        local tier = tonumber(arg2)

        if (tier > 0 and tier < 4) then
            user_settings.aspir.tier = tier
            message = 'Aspir updated tier to ' .. user_settings.aspir.tier
        else
            windower.add_to_chat(3, 'Aspir tier ' .. user_settings.aspir.tier .. ' is out of bounds')
        end
    elseif command == 'on' or command == 'enable' or command == 'start' then
        user_settings.aspir.enabled = true
        message = 'Aspir enabled at ' .. user_settings.aspir.casting_mp .. '% mp'
        otto.aspir.init()
    elseif command == 'off' or command == 'disable' == command == 'stop' then
        user_settings.aspir.enabled = false
        message = 'Aspiring is disabled'
        otto.aspir.deinit()
    elseif command == 'mp' then
        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(3, 'otto aspir mp requires a mp percent')
            return
        end

        local casting_mp = tonumber(arg2)

        if (casting_mp > 0 and casting_mp < 101) then
            user_settings.aspir.casting_mp = casting_mp
            message = 'Aspir updated for casting below ' .. user_settings.aspir.casting_mp .. '% mp'
        else
            windower.add_to_chat(3, 'Aspir mp percent range ' .. casting_mp .. ' is out of bounds between 0 - 100%')
        end
    elseif command == 'all' then
        user_settings.aspir.casts_all = true
        message = 'Aspir Will now cast all aspir spells'
    elseif command == 'single' then
        user_settings.aspir.casts_all = false
        message = 'Aspir Will now just cast Aspir ' .. user_settings.aspir.tier
    else
        should_save = false
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(3, 'Allowed commands for aspir are ' .. table.concat(allowed, ', '))
    end

    if should_save then
        windower.add_to_chat(3, message)
        user_settings:save()
    end
end

local function magic_burst_command(arg)
    local allowed = T { 'test', 'help', 'status', 'show' }
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
        windower.add_to_chat(2,
        _addon.name ..
        ': magic burst on|off - turn auto magic bursting on or off\n magic bursts show on|off - display messages about skillchains|magic bursts')
        windower.add_to_chat(2,
        _addon.name .. ': Auto Bursts: \t\t' .. (user_settings.magic_burst.enabled and 'On' or 'Off'))
        windower.add_to_chat(2,
        _addon.name ..
        ': Magic Burst Type: \t' ..
        user_settings.magic_burst.cast_type .. ' Tier: \t' .. (user_settings.magic_burst.cast_tier))
        windower.add_to_chat(2, _addon.name .. ': Min MP: \t\t' .. user_settings.magic_burst.mp)
        windower.add_to_chat(2,
        _addon.name ..
        ': Double Burst: ' ..
        (user_settings.magic_burst.double_burst and ('On' .. ' delay ' .. user_settings.magic_burst.double_burst_delay .. ' seconds') or 'Off'))
        windower.add_to_chat(2,
        _addon.name ..
        ': Check Elements - Day: ' ..
        (user_settings.magic_burst.check_day and 'On' or 'Off') ..
        ' Weather: ' .. (user_settings.magic_burst.check_weather and 'On' or 'Off'))
        windower.add_to_chat(2,
        _addon.name .. ': Show Spell: \t' .. (user_settings.magic_burst.show_spell and 'On' or 'Off'))
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
            windower.add_to_chat(3,
            "Usage: otto mb cast spell|helix|jutsu Tells AutoMB what magic type to try to cast if the default is not what you want.")
            return
        end
        local cast_types = utils.cast_types()
        if cast_types:contains(arg2:lower()) then
            user_settings.magic_burst.cast_type = arg2:lower()
            message = 'Spell (c)ast set to ' .. arg2
        else
            windower.add_to_chat(3, 'Unsupported spell type ' .. arg2)
            return
        end
    elseif (command == 'tier' or command == 't') then
        if arg2 == nil or arg2 == '' or not tonumber(arg2) then
            windower.add_to_chat(3,
            "Usage: tier 1~6 tells autoMB what tier spell to use for Ninjutsu 1~3 will become ichi|ni|san.")
            return
        end

        local t = tonumber(arg2)

        if user_settings.magic_burst.cast_type == 'jutsu' and (user_settings.magic_burst.cast_tier > 0 and user_settings.magic_burst.cast_tier < 4) then
            user_settings.magic_burst.cast_tier = t
            message = 'magic burst (t)ier updated to ' .. arg2
        elseif (t > 0 and t < 7) then
            user_settings.magic_burst.cast_tier = t
            message = 'magic burst (t)ier updated to ' .. arg2
        elseif (t < 0 or t > 7) then
            windower.add_to_chat(3, 'Provide a tier in the appropriate range.')
            return
        end
    elseif (command == 'mp') then
        if arg2 == nil or arg2 == '' or not tonumber(arg2) then
            windower.add_to_chat(3, "provide a threshold mp at which to stop nuking.")
            should_save = false
            return
        end

        local n = tonumber(arg2)
        user_settings.magic_burst.mp = n
        message = 'Threshold mp set to' .. arg2
    elseif (command == 'doubleburst' or command == 'double' or command == 'dbl' or command == 'db') then
        local parsed = ' not'
        if not user_settings.magic_burst.double_burst then
            parsed = ''
        end

        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(3, 'Provide an additional on | off for this command.')
            return
        end

        if arg2 == 'off' then
            user_settings.magic_burst.double_burst = false
            parsed = ' not'
        elseif arg2 == 'on' then
            user_settings.magic_burst.double_burst = true
            parsed = ''
        end

        message = 'Will' .. parsed .. ' use double bursting.'
    elseif (command == 'death') then
        local parsed = ' not'
        if not user_settings.magic_burst.death then
            parsed = ''
        end

        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(3, 'Provide an additional on | off for this command.')
            return
        end

        if arg2 == 'off' then
            user_settings.magic_burst.death = false
            parsed = ' not'
        elseif arg2 == 'on' then
            user_settings.magic_burst.death = true
            parsed = ''
        end

        message = 'Will' .. parsed .. ' burst death.'
    elseif (command == 'weather') then
        local parsed = ' not'
        if not user_settings.magic_burst.check_weather then
            parsed = ''
        end

        user_settings.magic_burst.check_weather = not user_settings.magic_burst.check_weather
        message = 'Will' .. parsed .. ' use current weather bonuses'
    elseif (command == 'day') then
        local parsed = ' not'
        if not user_settings.magic_burst.check_day then
            parsed = ''
        end
        user_settings.magic_burst.check_day = not user_settings.magic_burst.check_day
        message = 'Will' .. parsed .. ' use current day bonuses'
    elseif (command == 'gearswap' or command == 'gs') then
        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(3, 'Provide an additional on | off for this command.')
            return
        end

        if not T { 'on', 'off' }:contains(arg2) then
            windower.add_to_chat(3, 'Provide the command on | off for this command instead of ' .. arg2)
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

        message = 'Will' .. parsed .. ' use gs c bursting and gs c notbursting'
    elseif (command == 'target' or command == 'tgt') then
        if (user_settings.magic_burst.change_target == nil) then
            user_settings.magic_burst.change_target = false
        end

        user_settings.magic_burst.change_target = not user_settings.magic_burst.change_target
        message = "Auto target swapping " .. (user_settings.magic_burst.change_target and 'enabled' or 'disabled') .. "."
    elseif command == "nukewall" then
        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(3, 'Provide an integer 1-5.')
            return
        end
        local n = tonumber(arg2)

        user_settings.magic_burst.nuke_wall_offest = n
        message = 'Nuke wall offest set to '..n
    else
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

local function healer_commands(args)
    local command = 'help'
    local allowed = T { 'test', 'help', 'status', 'show' }
    local message = ''
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

    local should_save = true

    if command == 'on' or command == 'enable' then
        user_settings.healer.enabled = true
        utils.disableCommand('cure', false)
        message = 'Healing has been enabled'
    elseif command == 'off' or command == 'disable' then
        user_settings.healer.enabled = false
        utils.disableCommand('cure', true)
        message = 'Healing has been disabled'
    elseif command == 'mincure' then
        local val = tonumber(arg2)
        if (val ~= nil) and (1 <= val) and (val <= 6) then
            user_settings.healer.healing.min.cure = val
            atc('Minimum cure tier set to ' .. val)
        else
            atc('Error: Invalid argument specified for minCure')
        end
    elseif command == 'mincuraga' then
        local val = tonumber(arg2)
        if (val ~= nil) and (1 <= val) and (val <= 6) then
            user_settings.healer.healing.min.curaga = val
            atc('Minimum curaga tier set to ' .. val)
        else
            atc('Error: Invalid argument specified for minCure')
        end
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end
        user_settings:save()
    end
end

local function weaponskill_commands(args)
    local command = 'help'
    local allowed = T { 'test', 'help', 'status', 'show' }
    local message = ''
    local arg2 = ''
    local arg3 = ''
    local arg4 = ''

    if (#args > 0) then
        command = args[1]:lower()
    end

    if (#args > 1) then
        arg2 = args[2]:lower()
    end

    if (#args > 2) then
        arg3 = args[3]:lower()
    end

    if (#args > 3) then
        arg3 = args[4]:lower()
    end

    if (#args > 4) then
        arg4 = args[5]:lower()
    end

    local should_save = true

    if command == 'on' then
        user_settings.weaponskill.enabled = true
    elseif command == 'off' then
        user_settings.weaponskill.enabled = false
    elseif (command == 'partner') then --another player's TP
        if arg2 == 'off' then
            user_settings.weaponskill.partner = 'none'
            atc('Weaponskill partner removed.')
            user_settings:save()
            return
        end
        
        local partner = windower.ffxi.get_mob_by_name(arg2:ucfirst()).name
        local ws = arg3:ucfirst()..' '..arg4:ucfirst()
        local partner_weaponskill = utils.get_weaponskill(ws)

        if (partner ~= nil and partner_weaponskill ~= nil) then
            local partnertp = tonumber(args3) or 1000
            user_settings.weaponskill.enabled = true
            user_settings.weaponskill.partner = { name = partner, tp = partnertp, weaponskill = partner_weaponskill }
            atc("Will attempt to skillchain with " .. partner .. " when TP is " .. partnertp)
        else
            atc("Invalid args. Ex structure is:")
            atc("otto ws partner Twochix 1000 Tachi: Fudo")
            atc(6, 'Error: Invalid argument for ws waitfor: ' .. tostring(args[3]))
        end
    elseif (command == 'hp') then --Target's HP
        local hp = tonumber(arg2)
        if (hp ~= nil) then
            user_settings.weaponskill.min_hp = hp
            atc("Will weaponskill when the target's HP% is above " .. hp .. "%")
        else
            atc(6, 'Error: Invalid arguments for ws hp%: ' .. arg2)
        end
    elseif (command == 'clear') then -- Completely clear Skillchain configuration
        user_settings.weaponskill.enabled = false
        user_settings.weaponskill.min_hp = nil
        user_settings.weaponskill.name = nil
        user_settings.weaponskill.partner = nil
        atc('Weaponskill settings cleared.')
    else
        local ws_string = command:ucfirst()..' '..arg2:ucfirst()
        local weaponskill = utils.get_weaponskill(ws_string)

        if (weaponskill ~= nil) then
            user_settings.weaponskill.name = weaponskill.en
            atcfs('Will now use %s', weaponskill.en)
        else
            atcfs(123,'Error: Invalid weaponskill name: %s', ws_string)
        end
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end
        
        user_settings:save()
    end
end

local function buffs_commands(args)
    local command = 'help'

    if (#args > 0) then
        command = args[1]:lower()
    end

    if command == 'wipebuffs' then -- CKM added to completely clear buff lists (needed to resolve conflicting buffs -- ex barstonra / barfira)
        otto.buffs.wipe_bufflist()
    elseif command == 'help' then
        error()
    else
        otto.buffs.register_new_buff(args)
    end
end

local function debuffs_commands(args)
    local command = 'help'

    if (#args > 0) then
        command = args[1]:lower()
    end

    if command == 'wipedebuffs' then -- CKM added to completely clear buff lists (needed to resolve conflicting buffs -- ex barstonra / barfira)
        otto.buffs.wipe_debufflist()
    elseif command == 'ignore' then
        table.remove(args, 1)
        otto.buffs.register_ignore_debuff(args, true)
    elseif command == 'unignore' then
        table.remove(args, 1)
        otto.buffs.register_ignore_debuff(args, false)
    elseif command == 'help' then

    else
        otto.buffs.register_offensive_debuff(args)
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

    if S { 'off', 'end', 'false', 'pause', 'stop', 'exit' }:contains(arg1) then
        user_settings.follow.active = false
    elseif S { 'distance', 'dist', 'd' }:contains(arg1) then
        local dist = tonumber(arg2)
        if (dist ~= nil) and (0 < dist) and (dist < 45) then
            user_settings.follow.distance = dist
            atc('Follow distance set to ' .. user_settings.follow.distance)
        else
            atc('Error: Invalid argument specified for follow distance')
            return
        end
    elseif S { 'resume', 'on' }:contains(arg1) then
        if (user_settings.follow.target ~= nil) then
            user_settings.follow.active = true
            atc('Now following ' .. user_settings.follow.target .. '.')
        else
            atc(6, 'Error: Unable to resume follow - no target set')
            return
        end
    else --args[1] is guaranteed to have a value if this is reached
        local pname = windower.ffxi.get_mob_by_name(arg1:ucfirst()).name
        if (pname ~= nil) then
            user_settings.follow.target = pname
            user_settings.follow.active = true
            atc('Now following ' .. user_settings.follow.target .. '.')
        else
            should_save = false
            atc(6, 'Error: Invalid name provided as a follow target: ' .. tostring(arg1))
        end
    end

    if should_save then
        user_settings:save()
    end
end

local function assist_commands(args)
    local allowed = T { 'on | off | enabled | disable', 'yalmfightrange', 'role', 'master', 'slave', 'target' }
    local command = 'help'
    local message = ''
    local arg2 = ''
    local arg3 = ''
    if (#args > 0) then
        command = args[1]
    end

    if (#args > 1) then
        arg2 = args[2]
    end

    if (#args > 2) then
        arg3 = args[3]
    end

    local should_save = true

    if command == 'on' or command == 'enable' then
        user_settings.assist.enabled = true
        message = 'Assist is now on! Remember to set your role, yalmfightrange and master | slave'
    elseif command == 'off' or command == 'disable' then
        user_settings.assist.enabled = false
        message = 'Assiting has been toggled off.'
    elseif command == 'master' then
        if arg2 == 'off' then
            user_settings.assist.master = ''
            windower(3, 'Assist not configured with a master')
            user_settings:save()
            return
        end
        user_settings.assist.master = windower.ffxi.get_player().name
        message = 'Assist configured with ' .. user_settings.assist.master .. ' as master'
        windower.send_command('send @others otto assist role slave')
    elseif command == 'slave' then -- don't call this, only set the master and the others become slaves by default
        local name = windower.ffxi.get_player().name
        local inSet = S(user_settings.assist.slaves):contains(name)
        if inSet or arg2 == 'off' then
            user_settings.assist.slaves[name] = nil

            message = 'Assist is removing you as a slave... be free.'
            windower.send_command('input /autotarget on')
        elseif not inSet or arg2 == 'on' then
            user_settings.assist.slaves[name] = ''
            message = 'Assist configured with ' .. name .. ' as a slave'
            windower.send_command('input /autotarget off')
        end
    elseif command == 'role' then
        if arg2 == nil then
            message =
            'Please provide a role of: frontline | backline \n frontline will engage melee while backline support from afar'
        end

        if arg2 == 'frontline' or arg2 == 'backline' or arg2 == 'puller' or arg2 =='tank' then
            local name = windower.ffxi.get_player().name
            user_settings.assist.slaves[name] = arg2:lower()
            message = 'Assist role is selected as ' .. arg2 .. '. Setting a role means you are a slave.'
            windower.send_command('send @others otto assist set '..name..' '..arg2)
        else
            message = 'Please provide a role of: frontline | backline \n frontline will engage melee while backline support from afar'
        end

    elseif command == 'set' then
        if arg2 == nil or arg3 == nil then
            message = "Don't call this command, it's for automagic updating"
        end
        
        local name = arg2
        local role = arg3

        user_settings.assist.slaves[name] = role

    elseif command == 'yalmfightrange' or command == 'range' or command == 'yalm' or command == 'y' or command == 'r' then
        if arg2 == nil or arg2 == '' then
            windower.add_to_chat(3, 'You need to provide a range between 0-5')
            return
        end

        local yalms = tonumber(arg2)
        if yalms < 0 or yalms > 5 then
            windower.add_to_chat(3, 'You need to provide a range between 0-5')
            return
        end

        if yalms > 0 and yalms < 5 then
            user_settings.assist.yalm_fight_range = yalms
            message = 'Assists will engage at a distance of ' .. arg2 .. ' yalms'
        end
    elseif command == 'engages' then
        if arg2 == 'off' then
            user_settings.assist.should_engage = false
            message = 'Auto engage disabled'
         end

         if arg2 == 'on' then
            user_settings.assist.should_engage = true
            message = 'Auto engage enabled'
         end
    elseif command == 'config' then
        if arg2 == 'refresh' then
            utils.refresh_config()
        end
    else
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(6, 'Allowed commands for assist are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

local function pull_commands(args)
    local command = 'help'

    if (#args > 0) then
        command = args[1]:lower()
    end

    if command == 'on' then
        user_settings.pull.enabled = true
        otto.assist.locked_closing_in = true
        windower.add_to_chat(6, 'Auto pulling enabled')
    elseif command == 'off' then
        user_settings.pull.enabled = false
        otto.assist.locked_closing_in = false
        windower.add_to_chat(6, 'Auto pulling disabled')
    else
        local input = (' '):join(args)
        user_settings.pull.with = input
        windower.add_to_chat(6, 'will attempt to pull with command ' .. input)
    end

    user_settings:save()
end

local function dispel_commands(args)
    local command = 'help'

    if (#args > 0) then
        command = args[1]:lower()
    end

    if command == 'on' then
        user_settings.dispel.enabled = true
        user_settings:save()
        windower.add_to_chat(6, 'Auto dispel enabled')
    elseif command == 'off' then
        user_settings.dispel.enabled = false
        user_settings:save()
        windower.add_to_chat(6, 'Auto dispel disabled')
    else
        windower.add_to_chat(6, 'There is just one command to toggle on | off and you are fucking it up.')
    end
end


-- TODO this was added quickly, I should go back and account for entry errors and return errors.
-- TODO add indi command
local function geomancer(args)
    local allowed = T { 'on | off | enabled | disable', 'bubble', 'entrust', 'cooldowns' }
    local command = 'help'
    local message = ''
    local arg2 = ''
    local arg3 = ''
    local arg4 = 8 -- default bubble recast distance.

    if (#args > 0) then
        command = args[1]
    end

    if (#args > 1) then
        arg2 = args[2]
    end

    if (#args > 2) then
        arg3 = args[3]
    end

    if (#args > 3) then
        arg4 = args[4]
    end

    local should_save = true

    if command == 'on' or command == 'enable' then
        user_settings.job.geomancer.enabled = true
        otto.geomancer.init()
        message = 'Geomancer on.'
    elseif command == 'off' or command == 'disable' then
        user_settings.job.geomancer.enabled = false
        otto.geomancer.deinit()
        message = 'Geomancer off.'
    elseif command == 'cooldowns' then
        if arg2 == 'on' then
            user_settings.job.geomancer.cooldowns = true
            message = 'Geomancer will blow cooldowns.'
        end

        if arg2 == 'off' then
            user_settings.job.geomancer.cooldowns = false
            message = 'Geomancer will save cooldowns.'
        end
    elseif command == 'indi' then
        if arg2 == 'off' then
            user_settings.job.geomancer.indi = ''
            message = 'Will stop using Geo-spells .'
        end

        local action = utils.normalize_action(arg2, 'spells')

        if action then
            user_settings.job.geomancer.indi = action.en
            message = 'Will use ' .. action.en
        end
    elseif command == 'bubble' then
        if arg2 == 'off' then
            user_settings.job.geomancer.geo = ''
            message = 'Will stop using Geo-spells .'
        end

        if arg2 and arg2 ~= 'off' then
            user_settings.job.geomancer.bubble.target = arg2
        end

        local action = utils.normalize_action(arg3, 'spells')

        if action then
            user_settings.job.geomancer.geo = action.en
            message = 'Will use ' ..
            action.en .. ' using' .. arg2 .. ' to determine Full Circle usage at yalm distance of ~' .. arg4
        end

        if arg4 then
            user_settings.job.geomancer.bubble.distance = tonumber(arg4)
        end

        otto.geomancer.should_full_circle = true
    elseif command == 'entrust' then
        if arg2 then
            user_settings.job.geomancer.entrust.target = arg2
        end

        if arg3 then
            local action = utils.normalize_action(arg3, 'spells')
            if action then
                user_settings.job.geomancer.entrust.indi = action.en
                message = 'Will entrust ' .. action.en .. ' on ' .. arg2
            else
                log('ERROR: registering entrust indi spell')
            end
        end
    else
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(3, 'Allowed commands for assist are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

local function paladin(args)
    local allowed = T { 'on | off | enabled | disable'}
    local command = 'help'
    local message = ''
    local should_save = true
    local arg2 = ''
    local arg3 = ''
    if (#args > 0) then
        command = args[1]
    end

    if (#args > 1) then
        arg2 = args[2]
    end

    if command == 'on' or command == 'enable' then
        user_settings.job.paladin.enabled = true
        message = 'Paladin on.'
        otto.paladin.init()
    elseif command == 'off' or command == 'disable' then
        user_settings.job.paladin.enabled = false
        message = 'Paladin off.'
        otto.buffs.wipe_debufflist()
        otto.buffs.wipe_bufflist()
        otto.paladin.deinit()
    else
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(3, 'Allowed commands for assist are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

local function debug(args)
    local allowed = T { 'on | off | enabled | disable' }
    local command = 'help'
    local message = ''
    local should_save = true
    
    if (#args > 0) then
        command = args[1]
    end

    if command == 'on' or command == 'enable' then
        windower.send_command('send @others otto debug off')
        user_settings.debug.enabled = true
        
        message = 'Debug mode turned on. Others have had debug mode turned off.'
    elseif command == 'off' or command == 'disable' then
        user_settings.debug.enabled = false
        message = 'Debug mode turned off.'
    else
        windower.add_to_chat(3, "Bruh it's not hard")
        windower.add_to_chat(3, 'Allowed commands for assist are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

-- TODO this was added quickly, I should go back and account for entry errors and return errors.
-- TODO add indi command
-- copied from geomancer for BLM
local function blackmage(args)
    local allowed = T { 'on | off | enabled | disable', 'bubble', 'entrust', 'cooldowns' }
    local command = 'help'
    local message = ''
    local should_save = true
    local arg2 = ''
    local arg3 = ''
    local arg4 = 8 -- default bubble recast distance.

    if (#args > 0) then
        command = args[1]
    end

    if (#args > 1) then
        arg2 = args[2]
    end

    if command == 'on' or command == 'enable' then
        user_settings.job.blackmage.enabled = true
        otto.blackmage.init()
        message = 'Blackmage on.'
    elseif command == 'off' or command == 'disable' then
        user_settings.job.blackmage.enabled = false
        otto.blackmage.deinit()
        message = 'Blackmage off.'
    elseif command == 'cooldowns' then
        if arg2 == 'on' then
            user_settings.job.blackmage.cooldowns = true
            message = 'Blackmage will blow cooldowns.'
        end

        if arg2 == 'off' then
            user_settings.job.blackmage.cooldowns = false
            message = 'Blackmage will save cooldowns.'
        end
    else
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(3, 'Allowed commands for assist are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

local function bard(args)
    local allowed = T { 'on | off | enabled | disable', 'fight', 'song', 'songs', 'debuff' }
    local message = ''
    local should_save = true
    local command = ''
    local arg2 = ""
    local arg3 = 1
    local arg4 = 1
    if (#args > 0) then
        command = args[1]
    end

    if (#args > 1) then
        arg2 = args[2]
    end

    if (#args > 2) then
        arg3 = args[3]
    end

    if (#args > 3) then
        arg4 = args[4]
    end


    if command == 'on' or command == 'enable' then
        user_settings.job.bard.settings.enabled = true
        message = 'Bard on.'
        otto.bard.init()
    elseif command == 'off' or command == 'disable' then
        user_settings.job.bard.settings.enabled = false
        message = 'Bard off.'
        otto.buffs.wipe_debufflist()
        otto.buffs.wipe_bufflist()
        otto.bard.deinit()
    elseif command == 'fight' then 
        local allowed_fight_commands = S{'xp', 'boss', 'savetimers', 'normal'}
        if allowed_fight_commands:contains(arg2) then 
            message = 'Bard fight mode set: '..arg2
            user_settings.job.bard.settings.fight_type = arg2
            otto.bard.check_fight_type()
        else 
            message = 'Allowed fight commands are '.. table.concat(allowed_fight_commands, ', ')
        end
    elseif command == 'songs' then
        if arg2 == 'clear' then
            user_settings.job.bard.songs = L{}
            user_settings:save()
            return
        end
        if arg2 == '' then
            message = 'Need to supply a song name.'
        else
            local songs = otto.event_statics.songs[arg2]

            local songlist = user_settings.job.bard.songs
            local n = arg3
            n = tonumber(arg3)

            if n == 0 then
                for x = #songs, 1, -1 do
                    local song = songlist:find(songs[x])
                    -- remove song   
                    if song then
                        songlist:remove(song)
                    end
                end

            else
                -- add many songs
                for x = 1, n do 
                    local song = songs[x]

                    if not songlist:find(song) then
                        if #songlist >= 5 then
                        end
                        songlist:insert(1, song)
                    end
                end
            end
        end    
    elseif command == 'debuff' then
        if arg2 == 'clear' then
            user_settings.job.bard.debuffs = L{}
            user_settings:save()
            return
        else
            if otto.event_statics.debuffs[arg2] then
                local debuff = otto.event_statics.debuffs[arg2][arg3]
                if not debuff then return end
        
                local to_remove = user_settings.job.bard.debuffs:find(debuff)
                if to_remove then
                    user_settings.job.bard.debuffs:remove(to_remove)
                else
                    user_settings.job.bard.debuffs:append(debuff)
                end
            else
                message = 'not a valid song choice'
            end
           
        end
        
    elseif command == 'song' then
        if arg2 == 'clear' then
            for k, value in pairs(user_settings.job.bard.song) do
                user_settings.job.bard.song[k] = L{}
            end
        else
            local target = otto.bard.support.party_member(arg2)
            local songs = otto.event_statics.songs[arg3]
            local songlist = user_settings.job.bard.song[target.name]
            local n = arg4
            n = tonumber(arg4)
    
            if n == 0 then
                for x = #songs, 1, -1 do
                    local song = songlist:find(songs[x])
                    -- remove song   
                    if song then
                        songlist:remove(song)
                    end
                end
    
            else
                -- add many songs
                for x = 1, n do 
                    local song = songs[x]
    
                    if not songlist:find(song) then
                        if #songlist >= 5 then
                        end
                        songlist:insert(1, song)
                    end
                end
            end
        end
    else
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(3, 'Allowed commands for bard are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

        user_settings:save()
    end
end

local function whitemage(args)
    local allowed = T { 'on | off | enabled | disable', 'fight', 'song', 'songs', 'debuff' }
    local message = ''
    local should_save = true
    local command = ''
    local arg2 = ""
    local arg3 = 1
    local arg4 = 1
    if (#args > 0) then
        command = args[1]
    end

    if (#args > 1) then
        arg2 = args[2]
    end

    if (#args > 2) then
        arg3 = args[3]
    end

    if (#args > 3) then
        arg4 = args[4]
    end


    if command == 'on' or command == 'enable' then
        otto.whitemage.init()

        user_settings.job.whitemage.enabled = true
        message = 'White mage on.'
    elseif command == 'off' or command == 'disable' then
        user_settings.job.whitemage.enabled = false
        message = 'White mage off.'
        otto.buffs.wipe_debufflist()
        otto.buffs.wipe_bufflist()
        otto.whitemage.deinit()
    else
        windower.add_to_chat(3, "That's not a command")
        windower.add_to_chat(3, 'Allowed commands for whm are ' .. table.concat(allowed, ', '))
        should_save = false
    end

    if should_save then
        if message ~= '' then
            windower.add_to_chat(6, message)
        end

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
        if command == 'debug' then
            debug(newArgs)
        elseif command == 'aspir' then
            aspir_command(newArgs)
        elseif command == 'magicburst' or command == 'magic_burst' or command == 'mb' or command == 'amb' then
            magic_burst_command(newArgs)
        elseif command == 'follow' or command == 'f' then
            follow_commands(newArgs)
        elseif command == 'assist' or command == 'a' then
            assist_commands(newArgs)
        elseif command == 'healer' or command == 'h' then
            healer_commands(newArgs)
        elseif command == 'buff' or command == 'b' then
            buffs_commands(newArgs)
        elseif command == 'debuff' or command == 'd' then
            debuffs_commands(newArgs)
        elseif command == 'weaponskill' or command == 'ws' then
            weaponskill_commands(newArgs)
        elseif command == 'pull' or command == 'p' then
            pull_commands(newArgs)
        elseif command == 'dispel' then
            dispel_commands(newArgs)
        elseif command == 'geo' or command == 'geomancer' then
            geomancer(newArgs)
        elseif command == 'blm' or command == 'blackmage' then
            blackmage(newArgs)
        elseif command == 'pld' or command == 'paladin' then
            paladin(newArgs)
        elseif command == 'brd' or command == 'bard' then 
            bard(newArgs)
        elseif command == 'whm' or command == 'whitemage' then
            whitemage(newArgs)
        end
        -- MARK: commands to local otto
    end

    if command == 'refresh' then
        utils.load_configs()
    elseif S { 'r', 'reload' }:contains(command) then
        if args[2] ~= nil and args[2]:lower() == 'all' then
            for player, _ in pairs(otto.config.ipc_monitored_boxes) do
                windower.send_command('send ' .. player .. ' otto r')
                windower.add_to_chat(5, 'Refreshing ' .. player)
            end
        end
        windower.send_command('lua reload otto')
    elseif S { 'help', 'man', '?' }:contains(command) then
        windower.add_to_chat(6, 'Top level commands are:')
        windower.add_to_chat(6, 'aspir - configure auto aspir!')
        windower.add_to_chat(6, 'magicburst | mb - make things explody.')
        windower.add_to_chat(6, 'healbot | hb - leftover healbot commands')
        windower.add_to_chat(6, 'follow | f - commands for following.')
        windower.add_to_chat(6, 'assist | f - set an alts role to either engage or support master\'s target.')
        windower.add_to_chat(6, 'healer | f - your beloved healer -- and a white mage that will never talk back!')
        windower.add_to_chat(6, 'buff | f - buffs across multiple jobs')
        windower.add_to_chat(6, 'debuff | f - debuffs...')
        windower.add_to_chat(6, 'weaponskill | f - sets up weaponskills / skillchains.')
        windower.add_to_chat(6, 'dispel | f - similar to aspir, toggle auto-dispeling under the right conditions.')
        windower.add_to_chat(6, 'pull | f - an otto puller')
        windower.add_to_chat(6, 'geo | f - otto geo.')
    elseif S { 'start', 'on' }:contains(command) then
        otto.activate = true
        windower.add_to_chat(5, 'Otto is live!')
    elseif S { 'stop', 'off' }:contains(command) then
        otto.activate = off
        healer_commands('off')
        otto.buffs.wipe_bufflist()
        otto.buffs.wipe_debufflist()
        -- otto.assist.locked_closing_in = false
        windower.add_to_chat(147, 'Otto powering dooow~~!')
    elseif command == 'echo' then
        table.vprint(user_settings)
    end
end

return events
