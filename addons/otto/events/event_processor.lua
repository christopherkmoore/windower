local event_processor = {}

function event_processor.update_resist_list(message_id, target_id, param)
    local target = otto.fight.my_targets[target_id]

    if target then
        -- CKM TEST, mayne needs top_level_param in stead.
        local buff_immunity = res.buffs[param]
        if buff_immunity then 
            utils.register_immunity(target, buff_immunity)
        end

        if S {655, 656}:contains(message_id) then
            if action.top_level_param == 377 then -- make more robus by adding all sleeps
                otto.config.sleep_immunities[target.name] = true
                otto.config.sleep_immunities.save(otto.config.sleep_immunities)
            end
        end

        if otto.event_statics.aspir:contains(message_id) then -- aspir seems to have message 228 
            -- CKM TEST - this seems weird as hell after moving it here
            otto.aspir.update_DB(target.name, action.param) -- action.param is damage? seems weird
        end
    end
end

function event_processor.process_buff(action, target)
    local spell = res.spells:with('recast_id', action.top_level_param)     --optional
    local job_ability = res.job_abilities[action.top_level_param]          --optional
    local weapon_skills = res.weapon_skills[action.top_level_param]        --optional, not used
    
    local is_debuff = otto.event_statics.enfeebling:contains(action.param)

    if spell and action.category == 'spell_finish' then
        local enemy_debuff = res.buffs[spell.status]
    
        if enemy_debuff and spell.targets.Enemy then
            otto.fight.update_target_debuff(target.id, enemy_debuff.en)
        end

        local enemy_debuff = res.buffs[action.param]
        if enemy_debuff and spell.targets.Enemy and is_debuff and spell.en == enemy_debuff.en then
            otto.fight.update_target_debuff(target.id, enemy_debuff.en)
        end
    end
    

    -- is job_ability - most ja don't have debuffs except like light shot I think...
    if job_ability and action.category == 'job_ability' then        
        local enemy_debuff = res.buffs[job_ability.status]

        if enemy_debuff and job_ability.targets.Enemy then
            otto.fight.update_target_debuff(target.id, enemy_debuff.en)
        end

        local enemy_debuff = res.buffs[action.param]
        if enemy_debuff and spell.targets.Enemy and is_debuff and spell.en == enemy_debuff.en then
            otto.fight.update_target_debuff(target.id, enemy_debuff.en)
        end
    end
    
end

return event_processor
