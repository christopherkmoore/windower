local event_processor = {}

function event_processor.spell_finished(action, target)
    local spell = res.spells:with('recast_id', action.top_level_param)

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
            if otto.fight.my_targets[target.id] and otto.fight.my_targets[target.id]['debuffs'] then
                otto.fight.my_targets[target.id]['debuffs'][key] = expires_on
            end
        end
    
    end
end

return event_processor