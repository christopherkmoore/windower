
local events = S{ }
settings = T{}

Logger = require('otto_logging')
require('pack')
local files = require('files')

events.is_busy = 0
events.last_check_time = os.clock()
events.recast = 0

events.aspir = {}

-- Movement Handling
lastlocation = 'fff':pack(0,0,0)
events.moving = false


function events.on_load()

    local file = files.new('data/mob_immunities.lua')

    file:write('Something')
    file:append('... or other')

    file:exists()

    lines = file:readlines()
    lines2 = files.readlines('test.txt')

    require('tables')

    if lines:equals(lines2) then
        lines2:append('last line')
        file:writelines(lines2)
    end
end

function events.determine_movement(id, data, modified, is_injected, is_blocked)

    if id == 0x015 then
        local update = lastlocation ~= modified:sub(5, 16) 
        events.moving = update
        lastlocation = modified:sub(5, 16)

    end

end

function events.prerender(...)
	local time = os.clock()
	local delta_time = time - events.last_check_time
    
    events.recast = events.recast + delta_time

	events.last_check_time = time

	if (events.is_busy > 0) then
		events.is_busy = (events.is_busy - delta_time) < 0 and 0 or (events.is_busy - delta_time)
	end
end



-- addon load. parses commands passed to otto
function events.addon_command(...)
    local allowed = S{'r', 'reload', 'tier', 't', 'on', 'enabled', 'start'}
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
        if (#arg >= 2) then
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

    elseif command == 'mp' then 
        if (#arg >= 2) then
            local casting_mp = tonumber(arg[2])

            if (casting_mp > 0 and casting_mp < 101) then
                settings.casting_mp = casting_mp
            end
            
            windower.add_to_chat(123, 'updated spells to cast below '..settings.casting_mp..' mp')
            settings:save()
            return
        end
    else 
        Logger.log("that's not a command")
    end
end

return events