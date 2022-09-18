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
        if (mob.valid_target and mob.hpp == 100) and mob.distance ~= 0 and mob.is_npc then
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

    if math.sqrt(closest.distance) < 20 then return closest end

    return nil
end


function pull.try_pulling()
    if not user_settings.pull.enabled then return end
    if user_settings.pull.with == '' then return end 

    local now = os.clock()
    if actor:is_moving() then return end
    if now < pull.pull_tick then return end

    pull.pull_tick = now + 1

    if pull.has_target_already() then return end

    local mob = pull.find_target()

    if mob ~= nil then
        otto.assist.all_target_master(mob.id) -- doesn't actually all target, just the puller targets.

        local player = windower.ffxi.get_player()
        
        if player.target_index == mob.index then 
            windower.chat.input(user_settings.pull.with.." <t>")
        end

    end

    coroutine.sleep(0.5)

    if pull.check_pull_success(mob) then 
        coroutine.sleep(3)
        otto.assist.master_target_no_close_in(mob.id)
        return 
    else pull.try_pulling() end

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

    if player.status == 1 then return true end
    if pull.target == nil then return false end

    if (pull.target.valid_target) and player.target_index == pull.target.index and pull.target.status == 1 then
        log('already pulled')
        return true
     end

     return false
end

function pull.check_pull_success(mob) 
    if mob == nil then return false end
    local player = windower.ffxi.get_player()

    if (mob.valid_target ) and player.target_index == mob.index and mob.status == 1 then 
        pull.target = mob
        return true
    end

    return false
end

return pull