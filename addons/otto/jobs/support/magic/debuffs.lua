local debuffs = {}

local function debuff_spell(spell, mob) 
    local debuff = res.buffs[spell.status]
    local spell_recasts = windower.ffxi.get_spell_recasts()
    local has_debuff = otto.fight.my_targets[mob.id].debuffs[debuff.en] or false

    if spell and spell_recasts and spell_recasts[spell.id] == 0 and mob and not has_debuff then
        local delay = otto.cast.spell(spell, mob)
        return delay
    end
end

function debuffs.cast() 
    if otto.fight.my_targets:keyset():empty() then return end

    for target, debuff_spells in pairs(otto.buffs.debuff_list) do
        -- no target, so just go ahead and debuff the rest.

        if target == '' or target == 'AoE' then
            for d_spell, _ in pairs(debuff_spells) do
                for _, mob in pairs(otto.fight.my_targets) do
                    if mob and otto.cast.is_mob_valid_target(mob, 20) then
                        local spell = res.spells:with('name', d_spell)
                        local debuff = res.buffs[spell.status]

                        if otto.event_statics.dot_debuffs:contains(debuff.id) and mob.engaged == 'fighting' then
                            -- Make sure spell isn't a dot. It will mess up sleeps otherwise.
                            debuff_spell(spell, mob) 
                        end

                        if otto.event_statics.dot_debuffs:contains(debuff.id) then
                            debuff_spell(spell, mob) 
                        end
                    end
                end
            end
        end
    
        -- our debuff has a specific target, so use that.
        if target ~= 'AoE' or target ~= '' then
            local mob = otto.fight.target_lookup(target, nil, nil)
            if mob then
                local mob_target = otto.fight.my_targets[mob.id]
                if mob_target then
                    for d_spell, _ in pairs(debuff_spells) do
                        local spell = res.spells:with('name', d_spell)
                        local debuff = res.buffs[spell.status]

                        if otto.event_statics.dot_debuffs:contains(debuff.id) and mob_target.engaged == 'fighting' then
                            -- Make sure spell isn't a dot. It will mess up sleeps otherwise.
                            debuff_spell(spell, mob_target) 
                        end

                        if otto.event_statics.dot_debuffs:contains(debuff.id) then
                            debuff_spell(spell, mob_target) 
                        end
                    end
                end
            end
        end
    
        
    end
end

return debuffs
