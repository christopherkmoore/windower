-- Pull by TC
-- maybe add sleeps with pull, and continuous pull?
-- add normalize on pull.with + insert into queue
local pull = { }

pull.target = nil

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

local function sort_closest_target(mobs) 

    local distance = nil
    local closest = nil
    for id, mob in pairs(mobs) do
        if (mob.valid_target and mob.hpp == 100) and mob.distance ~= 0 and mob.is_npc and not mob.in_party and not mob.in_alliance and mob.spawn_type == 16 then

            if distance == nil then
                distance = mob.distance
                closest = mob
            end

            if mob.distance < distance then 
                distance = mob.distance
                closest = mob
            end
        end
    end

    if closest ~= nil and math.sqrt(closest.distance) < 21 then return closest end

    return nil
end


function pull.try_pulling()
    local player = windower.ffxi.get_player()
  
    if player.status == 1 and player.target_index then
        local mob = windower.ffxi.get_mob_by_index(player.target_index)
        pull.target = mob
        return
    end

    if not user_settings.pull.enabled then return end
    if user_settings.pull.with == '' then return end 

    local now = os.clock()
    if actor:is_moving() then return end
    if now < pull.pull_tick then return end

    pull.pull_tick = now + 3

    if pull.has_target_already() then return end

    local mob = pull.find_target()
    
    if mob ~= nil then
    
        otto.assist.puller_target_and_cast(mob) -- hard coded to elegy
        
        coroutine.sleep(1)

        if pull.check_pull_success(mob) then
            otto.assist.master_target_no_close_in(pull.target.id)
        end

    end


    if pull.target ~= nil then 
        if pull.target.hpp == 0 then
            pull.target = nil
        end
    end 

end

function pull.find_target()

    local mobs = windower.ffxi.get_mob_array()
    local closest = sort_closest_target(mobs)

    if closest ~= nil then
        return closest
    end
end

function pull.has_target_already() 
    local player = windower.ffxi.get_player()

    if player.status == 1 then 
        return true 
    else 
        pull.target = nil
    end

    if pull.target == nil then return false end

    if (pull.target.valid_target) and player.target_index == pull.target.index and pull.target.status == 1 then
        log('already pulled')
        return true
     end

     return false
end

function pull.check_pull_success(mob) 
    if pull.target ~= nil then return true end
    if mob == nil then return false end

    if mob.status == 1 then 
        pull.target = mob
        return true
    end

    return false
end

return pull