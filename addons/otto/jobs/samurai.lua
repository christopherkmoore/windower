

-- otto sam by TC

local samurai = { }
local player = windower.ffxi.get_player()
samurai.timers = {buffs={}}

-- job check ticks
samurai.check_interval = 0.4
samurai.delay = 4
samurai.counter = 0

function samurai.init()
    local defaults = { enabled = true }
    defaults.enabled = true
    defaults.cooldowns = true

    if user_settings.job.samurai == nil then
        user_settings.job.samurai = defaults
        user_settings:save()
    end


    samurai.check_pld:loop(samurai.check_interval)
end

function samurai.deinit() 
end



function samurai.check_pld()
    if not user_settings.job.samurai.enabled then return end
    samurai.counter = samurai.counter + samurai.check_interval

    if samurai.counter >= samurai.delay then

        samurai.counter = 0
        samurai.delay = samurai.check_interval
        local player = windower.ffxi.get_player()
        local target = windower.ffxi.get_mob_by_target()

        -- start 
        local weaponskill = otto.weaponskill.action()
        if weaponskill then
            local can_ws_target = otto.cast.is_mob_valid_target(target, weaponskill.range + 2) -- 2 yalms seems hella small
            local has_juice = (player.status == 1) and (player.vitals.tp > 999) 
            local ws_target = otto.weaponskill.target or target
            
            if weaponskill and otto.fight.my_targets[target.id] and can_ws_target and has_juice then
                otto.cast.weapon_skill(weaponskill)
            end
        end
    end
end


        
function samurai.action_handler(category, action, actor_id, add_effect, target)
	local categories = S{     
    	'job_ability',
    	'casting_begin',
        'spell_finish',
        'item_finish',
        'item_begin'
	 }

     local start_categories = S{ 'casting_begin', 'item_begin'}

    if not categories:contains(category) or action.param == 0 then
        return
    end

    if actor_id ~= player.id then return end

    -- Casting finish
    if category == 'spell_finish' then
        samurai.delay = 5
    end

    if category == 'item_finish' then 
        samurai.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            samurai.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            samurai.delay = 2.2
        end
    end

end


return samurai