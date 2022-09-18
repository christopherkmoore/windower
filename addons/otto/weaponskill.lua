
-- Notes
-- actor is stoping ws from happening during movement...
-- the action function should be returning more than once. but it seems like only once?

local lor_res = _libs.lor.resources
local ffxi = _libs.lor.ffxi

local weaponskill = { }

function weaponskill.init()
    local defaults = { }
    defaults.enabled = true           -- top level enable toggle. on | off
	defaults.partner = 'none'            -- weaponskill partner to create skillchains with
	defaults.min_hp = 80             -- Don't weaponskill below this hp%
	defaults.name = 'Savage Blade'   -- Weaponskill to use
   
    if user_settings.weaponskill == nil then
        user_settings.weaponskill = defaults
        user_settings:save()
    end
end

weaponskill.skillchain_active = false
weaponskill.skillchain_start = 0
weaponskill.window_open = 0
weaponskill.window_close = 0
weaponskill.can_skillchain = false
weaponskill.target = nil

function weaponskill.can_close_skillchain() 
    if not weaponskill.skillchain_active then return false end

    if os.clock() > weaponskill.window_close then
        return true
    end

    return false
end

function weaponskill.should_weaponskill_to_close()
    if not weaponskill.skillchain_active then return false end
    if not weaponskill.can_skillchain then return false end

    local now = os.clock() 
    if now < weaponskill.window_close and now > weaponskill.window_open then
        return true
    end

    return false
end

function weaponskill.open_window(for_target) 
    weaponskill.skillchain_active = true
    weaponskill.skillchain_start = os.clock() 
    weaponskill.window_open = weaponskill.skillchain_start + 3
    weaponskill.window_close = weaponskill.window_open + 6
    weaponskill.target = for_target
end

function weaponskill.close_window()
    weaponskill.skillchain_active = false
    weaponskill.skillchain_start = 0
    weaponskill.window_open = 0
    weaponskill.window_close = 0
    weaponskill.targetId = nil
end

function weaponskill.close_and_reopen_window(target)
    weaponskill.skillchain_active = false
    weaponskill.skillchain_start = 0
    weaponskill.window_open = 0
    weaponskill.window_close = 0
    weaponskill.targetId = nil
    weaponskill.open_window(target)
end

function weaponskill.check_should_window_close(target) 
    if weaponskill.window_close == 0 or weaponskill.window_close == nil then 
        return 
    end

    if target.id ~= weaponskill.target then
        weaponskill.close_window()
    end

    if os.clock() > weaponskill.window_close then
        weaponskill.close_window()
    end
end

function weaponskill.action(target)
    if user_settings.weaponskill.enabled and (user_settings.weaponskill.name ~= nil) and actor:ready_to_use(lor_res.action_for(user_settings.weaponskill.name)) then

        local hp = user_settings.weaponskill.min_hp or 0
        local hp_ok = target.hpp >= hp

        if user_settings.weaponskill.partner == 'none' then
            return {action=lor_res.action_for(user_settings.weaponskill.name),name='<t>'}
        end
        
        if (weaponskill.should_weaponskill_to_close()) then
            log('in skillchain here')
            return {action=lor_res.action_for(user_settings.weaponskill.name),name='<t>'}
        end
    end
    weaponskill.check_should_window_close(target)

    return nil
end

function weaponskill.action_handler(category, action, actor, add_effect, target)
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

    weaponskill.close_and_reopen_window(target.id)
    local ids = otto.getMonitoredIds()
    local ws_is_from_teammate = ids:contains(actor)

    if action.top_level_param ~= nil and action.top_level_param > 0 and action.top_level_param < 255 and ws_is_from_teammate then
        if res.weapon_skills[action.top_level_param].en ~= nil and res.weapon_skills[action.top_level_param].en == user_settings.weaponskill.partner.weaponskill then
            log('can ws')
            weaponskill.can_skillchain = true
        else 
            weaponskill.can_skillchain = false
        end
    end
end

return weaponskill