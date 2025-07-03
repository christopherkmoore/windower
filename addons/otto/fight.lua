local fight = {}

local check_tick = 1

--- targets raw
fight.targets = {}

-- if you want to do a status update, do it on these because raw is constantly re-written
-- needs to be updated for AoE Actions (in packets)
fight.my_targets = T { }

-- list of allies buffs and debuffs
fight.my_allies = T { }
fight.common = {}
fight.common.debuff_horn_multiplier = 1.53

function fight.init() 
    fight.update_targets:loop(check_tick)
end


-- tested working.
function fight.update_targets() 
    local mobs = windower.ffxi.get_mob_array() 

    -- build the entire aggro'd mob list
    for _, mob in pairs(mobs) do
        local ids = otto.getMonitoredIds()
        -- mobs i'm fighting
        if mob.valid_target == true and mob.is_npc and ids:contains(mob.claim_id) and mob.status == 1 then
            fight.targets[mob.id] = mob

            -- only add new mobs when they're new, otherwise you reset the statuses
            if not fight.my_targets[mob.id] then
                fight.my_targets[mob.id] = { engaged = "fighting" , id = mob.id, name = mob.name, index = mob.index, debuffs = {}, dispellables = {}} 
            end
        end

        -- mobs that may be fighting me, but i'm not fighting back
        if mob.valid_target == true and mob.is_npc and (mob.status == 1 and mob.claim_id == 0) and mob.distance < 50 and mob.race == 0 and mob.spawn_type ~= 2 then 
            fight.targets[mob.id] = mob

            -- only add new mobs when they're new, otherwise you reset the statuses
            -- bug this adds other peoples trusts
            if not fight.my_targets[mob.id] then
                fight.my_targets[mob.id] = { engaged = "agro" , id = mob.id, name = mob.name, index = mob.index, debuffs = {}, dispellables = {}} 
            end
        end

        -- for whatever reason, sometimes death message doesn't clear.
        -- go ahead and just do this to keep list fresh by removing mobs
        if fight.my_targets[mob.id] and mob.hpp == 0 then
            fight.my_targets[mob.id] = nil
        end
    end

    for _, mob in pairs(fight.my_targets) do 
        -- remove expired debuffs
        if mob.debuffs then 
            for key, expires in pairs(mob.debuffs) do
                local now = os.time()
                if now >= expires then
                    mob.debuffs[key] = nil
                end
            end
        end
    end

    otto.debug.create_log(fight.my_targets, 'my_targets')

end

function fight.add_target_effect(target_id, effect)
    local still_fighting = fight.targets[target_id] and fight.my_targets[target_id]

    if still_fighting then
        fight.my_targets[target_id][effect] = true
    end

end

function fight.remove_target_effect(target_id, effect)
    local should_remove_effect = (fight.targets[target_id] and fight.my_targets[target_id]) and fight.my_targets[target_id][effect]

    if should_remove_effect then
        fight.my_targets[target_id][effect] = nil
    end
end

function fight.remove_monster_debuff(target_id, effect)
    local should_remove = fight.my_targets[target_id] and fight.my_targets[target_id]['debuffs'][effect]

    if should_remove then
        fight.my_targets[target_id]['debuffs'][effect] = nil
    end
end


--- tested working.
function fight.remove_target(id)
    fight.targets[id] = nil
    fight.my_targets[id] = nil
end 

return fight