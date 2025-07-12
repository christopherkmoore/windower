local event_processor = {}

function event_processor.update_resist_list(message_id, target_id, action)
    local target = otto.fight.my_targets[target_id]

    if target then
        -- CKM TEST, mayne needs top_level_param in stead.
        local buff_immunity = res.buffs[action.param]
        if buff_immunity and not message_id == 228 then -- 228 is for aspir, so ignore that one.
            utils.immunities[target.name] = S(utils.immunities[target.name]) or S{}
            utils.immunities[target.name]:add(buff_immunity.id)
            utils.immunities:save()
        end

        if otto.event_statics.sleep_spell_ids:contains(action.top_level_param) and  otto.config.sleep_immunities then 
            local mob = windower.ffxi.get_mob_by_id(target.id)
            otto.config.sleep_immunities[target.name] = true
            otto.config.sleep_immunities.save(otto.config.sleep_immunities)
        end

        if message_id == 228 then
            if otto.config.maspir_immunities[target.name] ~= nil then return end
            if otto.config.maspir_immunities == nil then
                otto.config.maspir_immunities = {}
            end
            -- update the db with records of monsters who actually can be aspir'd.
            local hasMP = action.param ~= 0               
            otto.config.maspir_immunities[target.name] = hasMP
        
            otto.config.maspir_immunities.save(otto.config.maspir_immunities)
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
