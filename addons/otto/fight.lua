local fight = {}

local check_tick = 1

--- targets raw
fight.targets = {}

-- raw buffs
fight.buffs = {}

-- if you want to do a status update, do it on these because raw is constantly re-written
-- needs to be updated for AoE Actions (in packets)
fight.my_targets = T { }

-- list of allies buffs and debuffs
fight.my_allies = T { }
fight.common = {}
fight.common.debuff_horn_multiplier = 1.53

function fight.init() 
    fight.update_targets:loop(check_tick)
    fight.update_allies:loop(check_tick)
end

function fight.update_allies()
    local party = windower.ffxi.get_party()
    if not next(fight.my_allies)  then 
        local p0 = { name = party.p0.mob.name, id = party.p0.mob.id, index = party.p0.mob.index, distance = party.p0.mob.distance, target_index = party.p0.mob.target_index, claim_id = party.p0.mob.claim_id, tp = party.p0.tp, zone = party.p0.zone, mpp = party.p0.mpp, mp = party.p0.mp, hp = party.p0.hp, hpp = party.p0.hpp, buffs = {}, debuffs = {} }
        local p1 = { name = party.p1.mob.name, id = party.p1.mob.id, index = party.p1.mob.index, distance = party.p1.mob.distance, target_index = party.p1.mob.target_index, claim_id = party.p1.mob.claim_id, tp = party.p1.tp, zone = party.p1.zone, mpp = party.p1.mpp, mp = party.p1.mp, hp = party.p1.hp, hpp = party.p1.hpp, buffs = {}, debuffs = {} }
        local p2 = { name = party.p2.mob.name, id = party.p2.mob.id, index = party.p2.mob.index, distance = party.p2.mob.distance, target_index = party.p2.mob.target_index, claim_id = party.p2.mob.claim_id, tp = party.p2.tp, zone = party.p2.zone, mpp = party.p2.mpp, mp = party.p2.mp, hp = party.p2.hp, hpp = party.p2.hpp, buffs = {}, debuffs = {} }
        local p3 = { name = party.p3.mob.name,id = party.p3.mob.id, index = party.p3.mob.index, distance = party.p3.mob.distance, target_index = party.p3.mob.target_index, claim_id = party.p3.mob.claim_id, tp = party.p3.tp, zone = party.p3.zone, mpp = party.p3.mpp, mp = party.p3.mp, hp = party.p3.hp, hpp = party.p3.hpp, buffs = {}, debuffs = {} }
        local p4 = { name = party.p4.mob.name,  id = party.p4.mob.id, index = party.p4.mob.index, distance = party.p4.mob.distance, target_index = party.p4.mob.target_index, claim_id = party.p4.mob.claim_id, tp = party.p4.tp, zone = party.p4.zone, mpp = party.p4.mpp, mp = party.p4.mp, hp = party.p4.hp, hpp = party.p4.hpp, buffs = {}, debuffs = {} }
        local p5 = { name = party.p5.mob.name, id = party.p5.mob.id, index = party.p5.mob.index, distance = party.p5.mob.distance, target_index = party.p5.mob.target_index, claim_id = party.p5.mob.claim_id, tp = party.p5.tp, zone = party.p5.zone, mpp = party.p5.mpp, mp = party.p5.mp, hp = party.p5.hp, hpp = party.p5.hpp, buffs = {}, debuffs = {} }


        -- fight.my_allies = T{ ['p0'] = p0, ['p1'] = p1, ['p2'] = p2, ['p3'] = p3, ['p4'] = p4, ['p5'] = p5 }
        fight.my_allies[party.p0.mob.id] = p0
        fight.my_allies[party.p1.mob.id] = p1
        fight.my_allies[party.p2.mob.id] = p2
        fight.my_allies[party.p3.mob.id] = p3
        fight.my_allies[party.p4.mob.id] = p4
        fight.my_allies[party.p5.mob.id] = p5
        return
    end

    local p0_target = fight.target_lookup(nil, nil, party.p0.mob.target_index) or ''
    local p1_target = fight.target_lookup(nil, nil, party.p1.mob.target_index) or ''
    local p2_target = fight.target_lookup(nil, nil, party.p2.mob.target_index) or ''
    local p3_target = fight.target_lookup(nil, nil, party.p3.mob.target_index) or ''
    local p4_target = fight.target_lookup(nil, nil, party.p4.mob.target_index) or ''
    local p5_target = fight.target_lookup(nil, nil, party.p5.mob.target_index) or ''

    local p0 = { name = party.p0.mob.name, id = party.p0.mob.id, index = party.p0.mob.index, distance = math.sqrt(party.p0.mob.distance), target_index = party.p0.mob.target_index, target_name = p0_target, claim_id = party.p0.mob.claim_id, tp = party.p0.tp, zone = party.p0.zone, mpp = party.p0.mpp, mp = party.p0.mp, hp = party.p0.hp, hpp = party.p0.hpp, buffs = fight.my_allies[party.p0.mob.id].buffs, debuffs = fight.my_allies[party.p0.mob.id].debuffs }
    local p1 = { name = party.p1.mob.name,  id = party.p1.mob.id, index = party.p1.mob.index, distance = math.sqrt(party.p1.mob.distance), target_index = party.p1.mob.target_index, target_name = p1_target, claim_id = party.p1.mob.claim_id, tp = party.p1.tp, zone = party.p1.zone, mpp = party.p1.mpp, mp = party.p1.mp, hp = party.p1.hp, hpp = party.p1.hpp, buffs = fight.my_allies[party.p1.mob.id].buffs, debuffs = fight.my_allies[party.p1.mob.id].debuffs }
    local p2 = { name = party.p2.mob.name, id = party.p2.mob.id, index = party.p2.mob.index, distance = math.sqrt(party.p2.mob.distance), target_index = party.p2.mob.target_index, target_name = p2_target, claim_id = party.p2.mob.claim_id, tp = party.p2.tp, zone = party.p2.zone, mpp = party.p2.mpp, mp = party.p2.mp, hp = party.p2.hp, hpp = party.p2.hpp, buffs = fight.my_allies[party.p2.mob.id].buffs, debuffs = fight.my_allies[party.p2.mob.id].debuffs }
    local p3 = { name = party.p3.mob.name, id = party.p3.mob.id, index = party.p3.mob.index, distance = math.sqrt(party.p3.mob.distance), target_index = party.p3.mob.target_index, target_name = p3_target, claim_id = party.p3.mob.claim_id, tp = party.p3.tp, zone = party.p3.zone, mpp = party.p3.mpp, mp = party.p3.mp, hp = party.p3.hp, hpp = party.p3.hpp, buffs = fight.my_allies[party.p3.mob.id].buffs, debuffs = fight.my_allies[party.p3.mob.id].debuffs }
    local p4 = { name = party.p4.mob.name, id = party.p4.mob.id, index = party.p4.mob.index, distance = math.sqrt(party.p4.mob.distance), target_index = party.p4.mob.target_index, target_name = p4_target, claim_id = party.p4.mob.claim_id, tp = party.p4.tp, zone = party.p4.zone, mpp = party.p4.mpp, mp = party.p4.mp, hp = party.p4.hp, hpp = party.p4.hpp, buffs = fight.my_allies[party.p4.mob.id].buffs, debuffs = fight.my_allies[party.p4.mob.id].debuffs }
    local p5 = { name = party.p5.mob.name,  id = party.p5.mob.id, index = party.p5.mob.index, distance = math.sqrt(party.p5.mob.distance), target_index = party.p5.mob.target_index, target_name = p5_target, claim_id = party.p5.mob.claim_id, tp = party.p5.tp, zone = party.p5.zone, mpp = party.p5.mpp, mp = party.p5.mp, hp = party.p5.hp, hpp = party.p5.hpp, buffs = fight.my_allies[party.p5.mob.id].buffs, debuffs = fight.my_allies[party.p5.mob.id].debuffs }    
    fight.my_allies[party.p0.mob.id] = p0
    fight.my_allies[party.p1.mob.id] = p1
    fight.my_allies[party.p2.mob.id] = p2
    fight.my_allies[party.p3.mob.id] = p3
    fight.my_allies[party.p4.mob.id] = p4
    fight.my_allies[party.p5.mob.id] = p5

    for player_id, ally in pairs(fight.my_allies) do 
        if fight.buffs then
            local player_buffs = fight.buffs[player_id] 
            local debuffs = {}
            local buffs = {}
            if player_buffs then 
                for buff_id, buff in pairs(player_buffs) do 
                    if otto.event_statics.enfeebling:contains(buff_id) then
                        debuffs[buff_id] = buff
                    else
                        buffs[buff_id] = buff
                    end
                end
                otto.debug.create_log(debuffs, 'debugger')


                fight.my_allies[player_id].buffs = buffs
                fight.my_allies[player_id].debuffs = debuffs
            end
        end
    end
    otto.debug.create_log(fight.my_allies, 'my_allies')
end

function fight.update_ally_buffs(player_id, buff, timestamp)
    for key, ally in pairs(fight.my_allies) do
        if ally.id == player_id then 
            ally.buffs[buff.en] = timestamp
            -- ally.buffs[buff.id] = timestamp
            return
        end
    end
end

function fight.remove_ally_buffs(player_id, buff, timestamp)
    for key, ally in pairs(fight.my_allies) do
        for key, buff in pairs(ally.buffs) do
            if key == buff then
                ally.buffs[buff.en] = nil
                ally.buffs[buff.id] = nil
                return
            end
        end
    end
end

function fight.update_ally_debuff(player_id, debuff)
    for key, ally in pairs(fight.my_allies) do
        if ally.id == player_id then 
            ally.debuffs[debuff.en] = player_id
            return
        end
    end

end

function fight.ally_lookup(name, id, index) 
    for k, v in pairs(fight.my_allies) do
        if name and v.name:lower() == name:lower() then
            return T { v, v.mob }
        end

        if id and v.mob.id == id then
            return T { v, v.mob }
        end

        if index and v.mob.index == index then
            return T { v, v.mob }
        end
    end
end



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
                fight.my_targets[mob.id] = { engaged = "fighting" , id = mob.id, distance = mob.distance, name = mob.name, index = mob.index, debuffs = {}, dispellables = {}} 
            end
        end

        -- mobs that may be fighting me, but i'm not fighting back
        if mob.valid_target == true and mob.is_npc and (mob.status == 1 and mob.claim_id == 0) and mob.distance < 50 and mob.race == 0 and mob.spawn_type ~= 2 then 
            fight.targets[mob.id] = mob

            -- only add new mobs when they're new, otherwise you reset the statuses
            -- bug this adds other peoples trusts
            if not fight.my_targets[mob.id] then
                fight.my_targets[mob.id] = { engaged = "agro" , id = mob.id, distance = mob.distance, name = mob.name, index = mob.index, debuffs = {}, dispellables = {}} 
            end
        end

        -- for whatever reason, sometimes death message doesn't clear.
        -- go ahead and just do this to keep list fresh by removing mobs
        if fight.my_targets[mob.id] and mob.hpp == 0 then
            fight.my_targets[mob.id] = nil
        end
    end

    otto.debug.create_log(fight.my_targets, 'my_targets')
end

function fight.target_lookup(name, id, index)
    for k, v in pairs(fight.my_targets) do
        if name and v.name:lower() == name:lower() then
            return v
        end

        if id and v.id == id then 
            return v
        end

        if index and v.index == index then 
            return v.name
        end
    end
end 

function fight.update_target_debuff(target_id, effect)
    local still_fighting = fight.targets[target_id] and fight.my_targets[target_id]

    if still_fighting then
        fight.my_targets[target_id]['debuffs'][effect] = true
    end
end

-- dupe but should use this one
-- function fight.remove_target_debuff(target_id, effect)
--     local should_remove = fight.my_targets[target_id] and fight.my_targets[target_id]['debuffs'][effect]

--     if should_remove then
--         fight.my_targets[target_id]['debuffs'][effect] = nil
--     end
-- end

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