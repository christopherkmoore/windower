local weaponskill = { }

function weaponskill.init()
    local defaults = { }
    defaults.enable = true           -- top level enable toggle. on | off
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
weaponskill.window = 0
weaponskill.can_skillchain = false

function weaponskill.can_close_skillchain() 
    if not weaponskill.skillchain_active then return false end

    if os.clock() < weaponskill.window then
        return true
    end

    return false
end

function weaponskill.open_window(can_skillchain) 
    weaponskill.skillchain_active = true
    weaponskill.skillchain_start = os.clock() + 9
    weaponskill.window = os.clock() + 6

    if can_skillchain ~= nil then
        weaponskill.can_skillchain = true
    else 
        weaponskill.can_skillchain = false
    end
end

function weaponskill.close_window(force_close, can_skillchain)

    if force ~= nil and force then
        weaponskill.skillchain_active = false
        weaponskill.skillchain_start = 0
        weaponskill.window = 0
        weaponskill.skillchain = ''
        weaponskill.open_window(can_skillchain)
    end
end

function weaponskill.check_should_window_close() 
    if os.clock() > weaponskill.skillchain_start then
        weaponskill.skillchain_active = false
        weaponskill.skillchain_start = 0
        weaponskill.window = 0
        weaponskill.skillchain = ''
    end
end

function weaponskill.action(target)
    if user_settings.weaponskill.enable and (user_settings.weaponskill ~= nil) and actor:ready_to_use(lor_res.action_for(user_settings.weaponskill.name)) then

        local hp = user_settings.weaponskill.hp or 0
        local hp_ok = target.hpp >= user_settings.weaponskill.min_hp
        
        if user_settings.weaponskill.partner == 'none' then
            return {action=lor_res.action_for(user_settings.weaponskill.name),name='<t>'}
        end

        local partner_ok = true

        if (user_settings.weaponskill.partner ~= nil) then
            local pname = user_settings.weaponskill.partner.name
            local partner = ffxi.get_party_member(pname)
            if partner ~= nil then
                partner_ok = partner.tp >= user_settings.weaponskill.partner.tp
            else
                partner_ok = false
                atc(123,'Unable to locate weaponskill partner '..pname)
            end
        end
        
        if (hp_ok and partner_ok) then 
            if (weaponskill.can_skillchain and os.clock() <= weaponskill.window) then
                return {action=lor_res.action_for(user_settings.weaponskill.name),name='<t>'}
            end
        end
    end

    weaponskill.check_should_window_close()
end

function weaponskill.action_handler(category, action, actor, add_effect, target)

	if not user_settings.weaponskill.enabled then return end

	local categories = S{     
		'weaponskill_finish',
    	'mob_tp_finish',
    	'avatar_tp_finish',
	 }

    if not categories:contains(category) or action.param == 0 then
        return
    end

    skillchain.close_window(true)

    local is_partner_weaponskill = res[action.param].en == user_setings.weaponskill.name

    if is_partner_weaponskill then 
        skillchain.close_window(true, is_partner_weaponskill)
    else
        skillchain.close_window(true)
    end

end

return weaponskill