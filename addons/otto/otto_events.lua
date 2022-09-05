
local events = S{ }
utilities = require('otto_utilities')
events.settings = T{ }
state = T{}


function events.outgoing_chuck(...)
    events.state.determine_movement(...)
end


function events.prerender(...)
    events.state.determine_is_busy(...)
end

-- addon load. parses commands passed to otto
function events.addon_command(...)
    local allowed = S{'r', 'reload', 'tier', 't', 'on', 'enabled', 'start', 'all'}
    arg = { ... }
    local command = 'help'

    if (#arg > 0) then
        command = arg[1]:lower()
    end

    if command == 'help' then
        return
    -- elseif command == 'r' or command == 'reload' then -- To Do 
    --     refresh_user_env()
    elseif command == 't' or command == 'tier' then 
        if (#arg > 1) then
            local tier = tonumber(arg[2])

            if (tier > 0 and tier < 4) then
                events.settings.tier = tier
            end
            
            windower.add_to_chat(123, "updated tier to "..events.settings.tier)
            events.settings:save()
            return
        end
    elseif command == 'on' or command == 'enabled' or command == 'start' then 
        events.settings.enabled = true
        events.settings:save()
        
        return
    elseif command == 'off' or command == 'disable' == command == 'stop' then 
        events.settings.enabled = false
        events.settings:save()
        
        return 
    elseif command == 'mp' then 
        if (#arg > 1) then
            local casting_mp = tonumber(arg[2])

            if (casting_mp > 0 and casting_mp < 101) then
                events.settings.casting_mp = casting_mp
            end
            
            windower.add_to_chat(123, 'updated spells to cast below '..events.settings.casting_mp..' mp')
            events.settings:save()
            return
        end
    elseif command == 'all' then 
        events.settings.casts_all = true

        windower.add_to_chat(123, 'Will now cast all aspir spells')
        events.settings:save()
        return 
    elseif command == 'single' then 
        events.settings.casts_all = false

        windower.add_to_chat(123, 'Will now just cast Aspir '..events.settings.tier)
        events.settings:save()
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
            events.settings:save()
        end
        return 
    else
        windower.add_to_chat(123, "that's not a command")
    end
end

return events