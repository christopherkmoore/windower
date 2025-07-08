local debuffs = {}

function debuffs.cast() 
    if otto.fight.my_targets:keyset():empty() then return end

    for target, debuff_spell in pairs(otto.buffs.debuff_list) do
        local spell = res.spells:with('name', debuff_spell)
        local debuff = res.buffs[spell.status]
        local spell_recasts = windower.ffxi.get_spell_recasts()
    
        -- our debuff has a specific target, so use that.
        if target ~= '' then
            local mob = otto.fight.target_lookup(target, nil, nil)
            if mob then
                local mob_target = otto.fight.my_targets[mob.id]
                if mob_target then
                    local has_debuff = otto.fight.my_targets[mob.id].debuffs[debuff.en] or false
                    local has_debuff = mob.debuffs[debuff.en] or false
    
                    if spell and spell_recasts and spell_recasts[spell.id] == 0 and mob and not has_debuff then
                        local delay = otto.cast.spell(spell, '<t>')
                        return delay
                    end
                end
            end
        end
    
        -- no target, so just go ahead and debuff the rest.
        if target == '' or 'AoE' then
            for _, mob in pairs(otto.fight.my_targets) do
                if mob and otto.cast.is_mob_valid_target(mob, 20) then
        
                    local spell = res.spells:with('name', debuff_spell)
                    local debuff = res.buffs[spell.status]
                    local spell_recasts = windower.ffxi.get_spell_recasts()
                    local has_debuff = otto.fight.my_targets[mob.id].debuffs[debuff.en] or false
        
                    if spell and spell_recasts and spell_recasts[spell.id] == 0 and mob and not has_debuff then
                        local delay = otto.cast.spell(spell, '<t>')
                        return delay
                    end
                end
            end
        end
    end
end

return debuffs
