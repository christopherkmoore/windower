-- Pull by TC
-- maybe add sleeps with pull, and continuous pull?
-- add big pulls and moving.
-- add normalize on pull.with + insert into queue
local pull = { }

pull.target = nil
pull.pulling_until = 2
pull.targets = {}
pull.pull_tick = os.clock() 

function pull.init() 

    local defaults = { }
	defaults.enabled = false       -- top level enable toggle. on | off
	defaults.with = ''            -- stop bursting below this amount of mp%.
	
    if user_settings.pull == nil then
        user_settings.pull = defaults
        user_settings:save()
    end
end

local function sort_closest_target() 
    local mobs = windower.ffxi.get_mob_array()

    local distance = nil
    local closest = nil

    for id, mob in pairs(mobs) do

        if (mob.valid_target and mob.hpp == 100) and mob.distance ~= 0 and mob.is_npc and not mob.in_party and not mob.in_alliance and mob.spawn_type == 16 then
            if distance == nil then
                distance = mob.distance
                closest = mob
            end

            if mob.distance < distance then 
                if pull.targets[id] == nil then
                    distance = mob.distance
                    closest = mob
                end
            end
        end
    end
    
    if closest ~= nil and math.sqrt(closest.distance) < 21 then 
        return closest 
    end

    return nil
end


function pull.try_pulling()
    if not user_settings.pull.enabled then return end
    if user_settings.pull.with == '' then return end 

    local now = os.clock()
    if actor:is_moving() then return end
    if now < pull.pull_tick then return end

    pull.pull_tick = now + 3

    if pull.has_target_already() then return end
    local closest = sort_closest_target()

    if closest ~= nil and pull.targets[closest.id] == nil then

        otto.assist.puller_target_and_cast(closest, 422) -- hard coded to elegy
        coroutine.sleep(1)
        if pull.check_pull_success(closest) then
            otto.assist.master_target_no_close_in(closest.id)
        end
    end

end


function pull.has_target_already() 
    local count = 0
    for _, k in pairs(pull.targets) do 
        count = count + 1
    end

    if count >= pull.pulling_until then return true end
end

function pull.check_pull_success(mob) 
    if mob == nil then return false end

    if mob.status == 1 then 
        local effect = otto.bard.song_timers.song_debuffs[194]

        pull.targets[mob.id] = mob
        return true
    end

    return false
end

return pull