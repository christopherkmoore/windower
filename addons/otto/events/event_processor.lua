local event_processor = {}

local function update_resist_list(action, target)

    if S {655}:contains(action.message) then
        local target = windower.ffxi.get_mob_by_id(target.id)
        if action.top_level_param == 377 then
            otto.config.sleep_immunities[target.name] = true
            otto.config.sleep_immunities.save(otto.config.sleep_immunities)
        end
    end

    if messages_aspir:contains(action.message) then -- aspir seems to have message 228 
        otto.aspir.update_DB(target:get_name(), action.param)
    end
end

local function process_buff(action, target)
    local spell = res.spells:with('recast_id', action.top_level_param)
    -- is spell buff
    if spell and spell.status ~= nil and spell.duration and action.category == 'spell_finish'  then
        local buff = res.buffs[spell.status]

        local timestamp = os.time() + spell.duration

        if spell.targets.Enemy then
            -- otto.fight.update_ally_debuff(player_id, buff, timestamp)
        end

        spell.action_target = target
    end

    -- is ja buff
    local job_ability = res.job_abilities[action.top_level_param]
    if job_ability and job_ability.status ~= nil and job_ability.duration and action.category == 'job_ability' then
        local buff = res.buffs[job_ability.status]
        local timestamp = os.time() + job_ability.duration

        if job_ability.targets.Enemy then
            -- otto.fight.update_ally_debuff(player_id, buff, timestamp)
        end
    end
end

local function process_debuff(action, target)

    local spell = res.spells:with('recast_id', action.top_level_param)     --optional
    local job_ability = res.job_abilities[action.top_level_param]          --optional
    local monster_ability = res.monster_abilities[action.top_level_param]  --optional
    local monster_skill = res.monster_skills[action.top_level_param]       --optional
    local weapon_skills = res.weapon_skills[action.top_level_param]        --optional, not used
    
    -- TODO: somehow poison is getting through... and so are not my debuffs
    local is_debuff = otto.event_statics.enfeebling:contains(action.param)
    -- if spell and player_debuff and is_debuff and action.category == 'spell_finish' then
    --     local player_debuff = res.buffs[spell.status]

    --     if player_debuff and spell.targets.Self then
    --         local ids = otto.getMonitoredIds()
    --         local is_me = ids:contains(target.id)
    --         if is_me then
    --             -- otto.fight.update_ally_debuff(target.id, player_debuff)
    --             return
    --         end
    --     end
    -- end

    if spell and action.category == 'spell_finish' then
        local enemy_debuff = res.buffs[spell.status]

        if enemy_debuff and spell.targets.Enemy then
            local debuff = res.buffs[spell.status]
            otto.fight.update_target_debuff(target.id, enemy_debuff.en)
            return
        end
    end
    

    -- -- is job_ability
    -- if job_ability and job_ability and  otto.event_statics.enfeebling:contains(action.param) and action.category == 'job_ability' then
    --     if job_ability.targets.Self then
    --         -- print('in ja self')
    --         local ids = otto.getMonitoredIds()
    --         local is_me = ids:contains(target.id)
    --         if is_me then
    --             otto.fight.update_ally_debuff(target.id, debuff)
    --         end
    --     end

    --     if job_ability.targets.Enemy then
    --         -- otto.figth.update_targets_debuff
    --     end
    -- end

    -- -- is monster_ability
    -- if monster_ability and otto.event_statics.enfeebling:contains(action.param) then
    --     -- print('in monster_ability')

    --     if monster_ability.targets.Self then
    --         print('in monster_ability self')
    --         local ids = otto.getMonitoredIds()
    --         local is_me = ids:contains(target.id)
    --         if is_me then
    --             otto.fight.update_ally_debuff(target.id, debuff)
    --         end
    --     end

    --     if monster_ability.targets.Enemy then
    --         -- otto.figth.update_targets_debuff
    --     end
    -- end

    -- -- is monster_skill
    -- if monster_skill and otto.event_statics.enfeebling:contains(action.param) then
    --     local buff = res.buffs[monster_skill.status]
    --     -- print('in monster_skill')

    --     if monster_skill.targets.Self then
    --         -- print('in monster_skill self')
    --         local ids = otto.getMonitoredIds()
    --         local is_me = ids:contains(target.id)
    --         if is_me then
    --             otto.fight.update_ally_debuff(target.id, buff)-- target nil here
    --         end

    --     end

    --     if monster_skill.targets.Enemy then
    --         -- otto.figth.update_targets_debuff
    --     end
    -- end

end

function event_processor.process_buff(action, target)
    local immune = S {655, 656}:contains(action.message) -- ${actor} casts ${spell}.${lb}${target} completely resists the spell.
    local resisted = S{85,284,653,654}:contains(action.message)
    
    if immune then
        update_resist_list(action, target)
        return
    end

    if immune or resisted then return end 

    process_buff(action, target)
    process_debuff(action, target)
    
end

return event_processor
