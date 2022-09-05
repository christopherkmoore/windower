
local events = S{ }
utilities = require('otto_utilities')
settings = T{assist = {active = false, engage = false}}
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
                settings.tier = tier
            end
            
            windower.add_to_chat(123, "updated tier to "..settings.tier)
            settings:save()
            return
        end
    elseif command == 'on' or command == 'enabled' or command == 'start' then 
        settings.enabled = true
        settings:save()
        
        return
    elseif command == 'off' or command == 'disable' == command == 'stop' then 
        settings.enabled = false
        settings:save()
        
        return 
    elseif command == 'mp' then 
        if (#arg > 1) then
            local casting_mp = tonumber(arg[2])

            if (casting_mp > 0 and casting_mp < 101) then
                settings.casting_mp = casting_mp
            end
            
            windower.add_to_chat(123, 'updated spells to cast below '..settings.casting_mp..' mp')
            settings:save()
            return
        end
    elseif command == 'all' then 
        settings.casts_all = true

        windower.add_to_chat(123, 'Will now cast all aspir spells')
        settings:save()
        return 
    elseif command == 'single' then 
        settings.casts_all = false

        windower.add_to_chat(123, 'Will now just cast Aspir '..settings.tier)
        settings:save()
        return 
    elseif command == 'assist' then
        -- TODO left off here.
        if (#arg > 1) then
            local asistee = arg[2]

            local result = utilities.register_assistee(asistee)
            log(result)
            settings.assist.active = result.active
            settings.assist.engate = result.engage
            settings.assist.name = result.name
            settings:save()
        end
        return 
    else
        windower.add_to_chat(123, "that's not a command")
    end
end

return events