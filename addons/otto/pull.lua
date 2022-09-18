local pull = { }

function pull.init() 

    local defaults = { }
	defaults.enabled = false       -- top level enable toggle. on | off
	defaults.with = ''            -- stop bursting below this amount of mp%.
	
    if user_settings.pull == nil then
        user_settings.pull = defaults
        user_settings:save()
    end
end


function pull.try_pulling()
    if not user_settings.pull.enabled then return end
    if user_settings.pull.with == '' then return end 

    local player = windower.ffxi.get_player()
    if player.status == 1 then return end

    local mob = pull.find_target()

    assist.all_target_master(mob.id) -- doesn't actually all target, just the puller targets.
    windower.chat.input(with)

    coroutine.sleep(0.5)

    if pull.check_pull_success(mob) then return else pull.try_pulling end

end

function pull.find_target()
    local id = 0
    local distance = 1000
    local mobs = windower.ffxi.get_mob_array()

    table.sort(mobs, sort_closest_target(a, b))

    if mobs[1] ~= nil then
        return mobs[1]
    end
end

function pull.check_pull_success(mob) 
    local player = windower.ffxi.get_player()

    if mob.valid_target and player.status == 1 and player.target_index == mob.index then 
        return true
    end

    return false
then

function sort_closest_target(a, b) 
    if (a.valid_target and a.hpp == 100) and (b.valid_target and b.hpp == 100) then
        if a.distance < b.distance then return a
        else return b end
    end

    if not a.valid_target then return b end
    if not b.valid_target then return a end
end

return pull