local event_processor = {}

function event_processor.spell_finished(action, target)
    local spell = res.spells:with('recast_id', action.top_level_param)
    local resist = S{655}:contains(action.message) --${actor} casts ${spell}.${lb}${target} completely resists the spell.

    if spell and spell.type == "BardSong" then 
        -- duration is affected by +10% per +song
        -- so my ghorn is giving this +40% duration
        
        if spells_debuffs:contains(action.top_level_param) then
            local duration = (spell.duration or 0) * otto.fight.common.debuff_horn_multiplier
            local expires_on = (os.time() + duration or 0) 
            local key = spell.enn
            if sleep_spells:contains(spell.enn) then 
                key = 'sleep'
            end

            if otto.fight.my_targets[target.id] and otto.fight.my_targets[target.id]['debuffs'] and not resist then
                otto.fight.my_targets[target.id]['debuffs'][key] = expires_on
            end
        end
    
    end
end

function event_processor.update_resist_list(action, target)
    
    if S{655}:contains(action.message) then
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

return event_processor