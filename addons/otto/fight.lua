local fight = {}

local check_tick = 1

--- targets raw
fight.targets = {}

-- if you want to do a status update, do it on these because raw is constantly re-written
-- needs to be updated for AoE Actions (in packets)
fight.my_targets = {}

-- list of allies buffs and debuffs
fight.my_allies = {}


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
                    fight.my_targets[mob.id] = { engaged = "fighting" , id = mob.id, name = mob.name} 
                end
            end

            -- mobs that may be fighting me, but i'm not fighting back
            if mob.valid_target == true and mob.is_npc and (mob.status == 1 and mob.claim_id == 0) and mob.distance < 50 then 
                fight.targets[mob.id] = mob

                -- only add new mobs when they're new, otherwise you reset the statuses
                if not fight.my_targets[mob.id] then
                    fight.my_targets[mob.id] = { engaged = "agro" , id = mob.id, name = mob.name} 
                end
            end
        end
        -- otto.debug.create_log(fight.my_targets)
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

--- tested working.
function fight.remove_target(id)
    fight.targets[id] = nil
    fight.my_targets[id] = nil
end 

return fight