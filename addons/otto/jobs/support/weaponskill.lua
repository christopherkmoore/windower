
-- Weaponskills by TC

-- Notes
-- would be cool to add a user_settings property for step, which allows partners to wait until a certain step to ws.
-- ex step 1 something
-- ex step 2 something > Liquification
-- ex step 3 something > Light
-- skillchains addons has code for steps I believe.

-- min_hp not implemented. I don't think the partner.tp is either

local weaponskill = { }

weaponskill.check_interval = 0.4

function weaponskill.init()
    local defaults = { }
    defaults.enabled = true              -- top level enable toggle. on | off
	defaults.partner = 'none'            -- weaponskill partner to create skillchains with
	defaults.min_hp = 80                 -- Don't weaponskill below this hp%
	defaults.name = 'Savage Blade'       -- Weaponskill to use
    defaults.close = true                -- set these to determine who to close or open
    defaults.open = true                 -- having both be true means they will skillchain with themselves
    
    if user_settings.weaponskill == nil then
        user_settings.weaponskill = defaults
        user_settings:save()
    end

    weaponskill.check_should_window_close:loop(weaponskill.check_interval)
end

function weaponskill.deinit()
end

weaponskill.skillchain_active = false
weaponskill.first_step_started = 0
weaponskill.window_open = 0
weaponskill.window_close = 0
weaponskill.can_skillchain_to_close = false
weaponskill.target = nil


function weaponskill.should_weaponskill_to_close()
    local player = windower.ffxi.get_player()
    local now = os.clock() 
    local closes = user_settings.weaponskill.close

    local window_open = now < weaponskill.window_close and now > weaponskill.window_open
    if weaponskill.skillchain_active and weaponskill.can_skillchain_to_close and window_open and closes then
        return true
    end

    return false
end

function weaponskill.should_weaponskill_to_open()
    if weaponskill.skillchain_active or weaponskill.can_skillchain_to_close then return end
    
    local now = os.clock() 
    local should_open = user_settings.weaponskill.open
    if should_open and weaponskill.first_step_started == 0 then
        local target = windower.ffxi.get_mob_by_target()
        weaponskill.open_window(target) 
        return true
    end

    return false
end

function weaponskill.open_window(for_target) 
    weaponskill.skillchain_active = true
    weaponskill.first_step_started = os.clock() 
    weaponskill.window_open = weaponskill.first_step_started + 3
    weaponskill.window_close = weaponskill.window_open + 7
    weaponskill.target = for_target
end

function weaponskill.close_window()
    weaponskill.skillchain_active = false
    weaponskill.first_step_started = 0
    weaponskill.window_open = 0
    weaponskill.window_close = 0
    weaponskill.can_skillchain_to_close = false
    weaponskill.target = nil

end

function weaponskill.close_and_reopen_window(target)
    weaponskill.skillchain_active = false
    weaponskill.first_step_started = 0
    weaponskill.window_open = 0
    weaponskill.window_close = 0
    weaponskill.open_window(target)
end

function weaponskill.check_should_window_close() 
    if weaponskill.target then
        local target = otto.fight.my_targets[weaponskill.target.id]

        if not target or os.clock() > weaponskill.window_close then
            weaponskill.close_window()
        end
    end
end

function weaponskill.action()
    local player = windower.ffxi.get_player()

    if user_settings.weaponskill.enabled and (user_settings.weaponskill.name ~= nil) and (player.status == 1) and (player.vitals.tp > 999) then
        local target = windower.ffxi.get_mob_by_target()
        local can_ws_target = otto.cast.is_mob_valid_target(target, 4) -- 2 yalms seems hella small
        if can_ws_target  then

            if weaponskill.should_weaponskill_to_close() or weaponskill.should_weaponskill_to_open() then
                local ws = utils.get_weaponskill(user_settings.weaponskill.name)
                otto.cast.weapon_skill(ws, '<t>')
            end
        end
    end
    
end

function weaponskill.action_handler(category, action, actor_id, add_effect, target)
	if not user_settings.weaponskill.enabled then return end
    if user_settings.weaponskill.partner == nil or user_settings.weaponskill.partner == 'none' then return end

	local categories = S{     
		'weaponskill_finish',
    	'mob_tp_finish',
    	'avatar_tp_finish',
	 }

    if not categories:contains(category) or action.param == 0 then
        return
    end

    local ally = otto.fight.my_allies[actor_id]
    local mob = otto.fight.my_targets[target.id]
    
    if not otto.cast.is_mob_valid_target(mob, 20) then return end   -- if the action was taken on a target that's not one of mine, don't care.
	if not ally then return end                                     -- not my allys ws, not my problem.
    if not mob then return end                        	            -- not my mob ws, not my problem.
    weaponskill.close_and_reopen_window(target)               -- there was a ws and now it's ready for close

    if action.top_level_param ~= nil and action.top_level_param > 0 and action.top_level_param < 255  then
        if res.weapon_skills[action.top_level_param].en ~= nil and res.weapon_skills[action.top_level_param].en == user_settings.weaponskill.partner.weaponskill then
            weaponskill.can_skillchain_to_close = true
        else 
            weaponskill.can_skillchain_to_close = false
        end
    end
end

return weaponskill