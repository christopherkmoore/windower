-- dispels by TC

local dispel = { monster_ability_dispelables = {},}

function dispel.init()

    local defaults = { }
	defaults.enabled = false       -- top level enable toggle. on | off

    if user_settings.dispel == nil then
        user_settings.dispel = defaults
        user_settings:save()
    end

end

function dispel.should_dispel_new()
    local player = windower.ffxi.get_player()
    local can_dispel = otto.event_statics.dispel_jobs:contains(player.main_job)

    if user_settings.dispel.enabled and can_dispel then
        for _, mob in pairs(otto.fight.my_targets) do
            if mob.dispellables then
                for name, id in pairs(mob.dispellables) do
                    return mob
                end
            end
        end
    end
end

function dispel.action_handler(category, action, actor_id, target, basic_info)
	if not user_settings.dispel.enabled then return end

	local categories = S{
    	'mob_tp_finish',
        'spell_finish',
    	'avatar_tp_finish',
	 }

    if not categories:contains(category) or action.param == 0 then
        return
    end

	local mob = otto.fight.my_targets[target.id]
	if not mob then return end       -- not my mob, not my problem.                          
	if not otto.cast.is_mob_valid_target(mob, 20) then return end


    if mob and otto.event_statics.monster_buff_gained:contains(action.message) then
        -- otto.debug.create_2log_for_comparison(action, 'debugger', target, 'debugger2')
        for _, action in pairs(target.raw.actions) do
            local buff = res.buffs[action.param]
            if buff then
                otto.fight.update_target_dispellable(target.raw.id, buff.en)
            end

            -- stub a false dispel in the config. check later as dispel resovles if it can be saved as dispelable
            if otto.config.monster_ability_dispelables == nil or otto.config.monster_ability_dispelables[action.top_level_param] == nil then
                otto.config.monster_ability_dispelables[action.top_level_param] = false
                otto.config.monster_ability_dispelables.save(otto.config.monster_ability_dispelables)
            end

            -- immediately add for known dispelables
            if buff and otto.config.monster_ability_dispelables[action.top_level_param] == true then
                print('here')
                otto.fight.update_target_dispellable(target.raw.id, buff.en)
            end
        end
    end


    if otto.event_statics.dispel_spell_ids:contains(basic_info.spell_id) and otto.event_statics.dispel_message_successful:contains(action.message) then
        if otto.fight.my_targets[target.raw.id] then
            local dispellable = res.buffs[action.param]

            -- save new dispellable abilities
            if otto.config.monster_ability_dispelables[action.top_level_param] == false then
                otto.config.monster_ability_dispelables[action.top_level_param] = true
                otto.config.monster_ability_dispelables.save(otto.config.monster_ability_dispelables)
            end

            -- remove from lists
            otto.fight.my_targets[target.id]['dispellables'][dispellable.en] = nil
        end
    end
end

return dispel