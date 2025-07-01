

-- utilities for the follow command
local follow = {}

function follow.init()
    -- create user_settings defaults when they don't exist

    if user_settings.follow == nil then
        local follow = { }
        follow.target = nil
        follow.active = false
        follow.pause = nil
        follow.distance = 5
        follow.delay = 0.2
    
        user_settings.follow = follow
        user_settings:save()
    end
end

-- TODO CKM consider replacing follows scripts with this, toggling on / off?
function follow.target_exists()
    if (user_settings.follow.target == nil) then return end
    
    local ft = windower.ffxi.get_mob_by_name(user_settings.follow.target)
    
    if user_settings.follow.active and (ft == nil) then
        user_settings.follow.pause = true
        user_settings.follow.active = false
    elseif user_settings.follow.pause and (ft ~= nil) then
        user_settings.follow.pause = nil
        user_settings.follow.active = true
    end
end


function follow.auto_movement_active()
    return user_settings.follow.active or (offense.assist.active and offense.assist.engage)
end

-- determines if movement should happen towards the target set.
function follow.prerender()

    local now = os.clock()
    follow.target_exists()   --Attempts to prevent autorun problems

    local follow = user_settings.follow

    if otto.follow.auto_movement_active() then
        if ((now - actor.last_move_check) > follow.delay) then
            local should_move = false
            if (partner ~= nil) and (targ ~= nil) and (player.target_index == partner.target_index) then
                if offense.assist.engage and (partner.status == 1) then
                    if actor:dist_from(targ.id) > 3 then
                        should_move = true
                        actor:move_towards(targ.id)
                    end
                end
            end
            if (not should_move) and follow.active and (actor:dist_from(follow.target) > follow.distance) then
                should_move = true
                actor:move_towards(follow.target)
            end
            if (not should_move) then
                if follow.active then
                    windower.ffxi.run(false)
                end
            else
                moving = true
            end
            actor.last_move_check = now      --Refresh stored movement check time
        end
    end
end


return follow