
-- Weaponskills by TC

-- Notes
-- would be cool to add a user_settings property for step, which allows partners to wait until a certain step to ws.
-- ex step 1 something
-- ex step 2 something > Liquification
-- ex step 3 something > Light
-- skillchains addons has code for steps I believe.

-- min_hp not implemented. I don't think the partner.tp is either
local lor_res = _libs.lor.resources
local ffxi = _libs.lor.ffxi

local weaponskill = { }

function weaponskill.init()
    local defaults = { }
    defaults.enabled = true              -- top level enable toggle. on | off
	defaults.partner = 'none'            -- weaponskill partner to create skillchains with
	defaults.min_hp = 80                 -- Don't weaponskill below this hp%
	defaults.name = 'Savage Blade'       -- Weaponskill to use
   
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

    if os.time() > weaponskill.window_close then
        return true
    end

    return false
end

function weaponskill.should_weaponskill_to_close()

    local now = os.time() 
    local window_open = now < weaponskill.window_close and now > weaponskill.window_open
    if weaponskill.skillchain_active and weaponskill.can_skillchain and window_open and user_settings.weaponskill.partner.name and otto.fight.ally_lookup(user_settings.weaponskill.partner.name) then
        return true
    end

    return false
end

function weaponskill.should_weaponskill_to_open()
    local now = os.time() 
    if not weaponskill.skillchain_active and weaponskill.skillchain_start == 0 then
        return true
    end

    return false
end

function weaponskill.open_window(for_target) 
    weaponskill.skillchain_active = true
    weaponskill.skillchain_start = os.time() 
    weaponskill.window_open = weaponskill.skillchain_start + 3
    weaponskill.window_close = weaponskill.window_open + 7
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

    if os.time() > weaponskill.window_close then
        weaponskill.close_window()
    end
end

function weaponskill.action(target)
    if user_settings.weaponskill.enabled and (user_settings.weaponskill.name ~= nil) and actor:ready_to_use(lor_res.action_for(user_settings.weaponskill.name)) then

        -- local hp = user_settings.weaponskill.min_hp or 0
        -- local hp_ok = target.hpp >= hp
        local player = windower.ffxi.get_player().name
        local should_open_ws = (user_settings.weaponskill.partner == 'none' or user_settings.weaponskill.partner == '' or user_settings.weaponskill.partner.name == player)

        if weaponskill.should_weaponskill_to_close() then
            weaponskill.close_window()
            return {action=lor_res.action_for(user_settings.weaponskill.name),name='<t>'}
        end

        if weaponskill.should_weaponskill_to_open() then
            if user_settings.weaponskill.partner == 'none' then
                weaponskill.open_window()
                return {action=lor_res.action_for(user_settings.weaponskill.name),name='<t>'}
            else 
                weaponskill.open_window()
                return {action=lor_res.action_for(user_settings.weaponskill.partner.weaponskill),name='<t>'}
            end
        end

        weaponskill.check_should_window_close(target)
    end

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

    local ally = otto.fight.my_allies[actor]
    local mob = otto.fight.my_targets[target.id]
    if not otto.cast.is_mob_valid_target(mob) then return end    -- if the action was taken on a target that's not one of mine, don't care.
	if not ally then return end                              	 -- not my allys ws, not my problem.

    weaponskill.close_and_reopen_window(target.id)               -- there was a ws and now it's ready for close

    if action.top_level_param ~= nil and action.top_level_param > 0 and action.top_level_param < 255  then
        if res.weapon_skills[action.top_level_param].en ~= nil and res.weapon_skills[action.top_level_param].en == user_settings.weaponskill.partner.weaponskill then
            weaponskill.can_skillchain = true
        else 
            weaponskill.can_skillchain = false
        end
    end
end

return weaponskill