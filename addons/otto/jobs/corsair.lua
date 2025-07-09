

-- otto cor by TC

local corsair = { }
local player = windower.ffxi.get_player()
corsair.timers = {buffs={}}

-- job check ticks
corsair.check_interval = 0.4
corsair.delay = 4
corsair.counter = 0

function corsair.init()
    local defaults = { enabled = true }
    defaults.enabled = true
    defaults.cooldowns = true

    if user_settings.job.corsair == nil then
        user_settings.job.corsair = defaults
        user_settings:save()
    end

    corsair.check_pld:loop(corsair.check_interval)
end

function corsair.deinit() 
end



function corsair.check_pld()
    if not user_settings.job.corsair.enabled then return end
    corsair.counter = corsair.counter + corsair.check_interval

    if corsair.counter >= corsair.delay then
        corsair.counter = 0
        corsair.delay = corsair.check_interval

        local target = windower.ffxi.get_mob_by_target()
        -- start 

        -- weaponskills
        if otto.weaponskill.action() ~= nil then
            local weaponskill = otto.weaponskill.action()
            local can_ws_target = otto.cast.is_mob_valid_target(target, weaponskill.range + 2) -- 2 yalms seems hella small
            local has_juice = (player.status == 1) and (player.vitals.tp > 999) 
            local ws_target = otto.weaponskill.target or target
            
            if weaponskill and otto.fight.my_targets[target.id] and can_ws_target and has_juice then
                otto.cast.weapon_skill(weaponskill)
            end
        end

    end
end


        
function corsair.action_handler(category, action, actor_id, add_effect, target)
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
        corsair.delay = 5
    end

    if category == 'item_finish' then 
        corsair.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            corsair.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            corsair.delay = 2.2
        end
    end

end


return corsair