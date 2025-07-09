local cast = {}


--=====================================================================
-- MARK: Validation
--=====================================================================

--- Validate a resouce is actually a resource, and if the resource is ready to be used.
---@param spell table 
---@return boolean 
function cast.is_off_cooldown(action) 
    if not action then 
        print('Error: cast.spell being sent non-resource action: '..action)
        return false 
    end
    if type(action) == 'string' then
        print('Error: cast.spell being sent non-resource action: '..action)
        return false
    end
    if type(action) == 'function' then 
        print('Error: cast.spell being sent a function')
        return false
    end

    if action.prefix == '/weaponskill' then
        local player = windower.ffxi.get_player()
        if player.vitals.tp > 999 then return true end
        return false

    elseif action.prefix == '/jobability' or action.prefix == '/pet' then
        local recasts = windower.ffxi.get_ability_recasts()
        if recasts and recasts[action.recast_id] == 0 then return true end
        return false
        
    elseif action.prefix == '/magic' or action.prefix == '/ninjutsu' or action.prefix == '/song' then 
        local recasts = windower.ffxi.get_spell_recasts()
        if recasts and recasts[action.recast_id] == 0 then 
            return true 
        end
        return false
    else
        print('cooldown for action '..action.en..' not found')
        return false
    end
    print('unaccounted for condition during cooldown check for: '..action.en)
end


--=====================================================================
-- MARK: Casting
--=====================================================================

--- Cast a spell on a current targeted mob, or may swap to a new mob.
---@param spell table 
---@param mob table 
---@return int The delay for the job class to be added to check_interval for whatever job casting it.
function cast.spell(spell, mob)
    if not cast.is_off_cooldown(spell) then return 0 end 
    if mob == nil then return 0 end
    if not spell and spell.id and mob then return 0 end 
    local current_mob_target = windower.ffxi.get_mob_by_target()

    -- I'm not targeting the right mob, so swap
    if current_mob_target and current_mob_target.id and mob and mob.id and mob.id ~= current_mob_target.id then
        otto.assist.swap_target_and_cast(mob, spell.id)
        return spell.cast_time
    end

    if current_mob_target and current_mob_target.id and mob and mob.id and mob.id == current_mob_target.id then
        local command = 'input /ma "'..spell.en..'" <t>'
        windower.send_command(command)
        return spell.cast_time
    end

    if mob and mob.name and spell and spell.en then
        local command = 'input /ma "'..spell.en..'" '..mob.name
        windower.send_command(command)
        return spell.cast_time
    end
    return 0    
end

--- Cast a spell on a current targeted mob '<t>'.
---@param spell table 
---@param target table 
---@return int The delay for the job class to be added to check_interval
function cast.spell_no_check(spell, target)
    if not cast.is_off_cooldown(spell) then return 0 end 

    -- if actor:is_moving() then return 1 end
    -- if not actor:can_use(spell) then return 0 end
    local command = 'input /ma "'..spell.en..'" '..target
    windower.send_command(command)
    return spell.cast_time
end

--- Cast a job_ability on '<me>' or another player by string.
---@param job_ability table 
---@param target string 
---@return int The delay for the job class to be added to check_interval
function cast.job_ability(job_ability, target)
    if not cast.is_off_cooldown(job_ability) then return 0 end 

    -- if not actor:can_use(job_ability) then return 0 end
    
    local command = 'input /ja "'..job_ability.en..'" '..target
    windower.send_command(command)

    return 1
end

--- Cast a weapon_skill on a current targeted mob '<t>'.
---@param weapon_skill table 
---@param target string 
---@return int The delay for the job class to be added to check_interval
function cast.weapon_skill(weapon_skill, target)
    if not cast.is_off_cooldown(weapon_skill) then return 0 end 
    
    local command = 'input /ws "'..weapon_skill.en..'" <t>'
    windower.send_command(command)
    return 1
end


--- Cast a spell with a pre-action, or fail because of preconditions
---@param spell table 
---@param job_ability string 
---@param target table 
---@return int The delay for the job class to be added to check_interval
function cast.spell_with_pre_action(spell, job_ability, target)
    if not cast.is_off_cooldown(spell) then return 0 end 
    local delay = cast.job_ability(job_ability, '<me>')
    coroutine.sleep(delay)

    cast.spell(spell, target)
    return spell.cast_time
end

--=====================================================================
-- MARK: Targeting
--=====================================================================


--- Check if your target (always be of type from fight.my_target) has a damage over time spell on it.
---@param my_target table 
---@return boolean 
function cast.has_DoT(my_target)

    if my_target and my_target.debuffs then
        for debuff, _ in pairs(my_target.debuffs) do
            local mapped = res.buffs:with('en', debuff)
            if otto.event_statics.dot_debuffs:contains(mapped.id) then
                return true
            end
        end
    end
end

--- Get your partys current melee target. There may be more than one, this will return the first one.
---@return boolean 
function cast.party_target()
    for _, target in pairs(otto.fight.my_targets) do
        if target.engaged == 'fighting' then
            return target
        end
    end
end

--- Takes two mob.distance values and calculates the distance between them..
---@param one table {x = point.x, y = point.y, z = point.z}
---@param two table {x = point.x, y = point.y, z = point.z}
---@return boolean 
function cast.distance_between_points(one, two)
    if one and one.x and two and two.x then
        local x = one.x - two.x
        local y = one.y - two.y
        local z = one.z - two.z 

        local total = (x * x) + (y * y) + (z * z)
        return total:sqrt() 
    end
    return nil
end

--- A monster should be valid if it comes from otto.fights.my_targets. Use this to know if it's in range
---@param mob table 
---@param distance int in yalm range 
---@return boolean 
function cast.is_mob_valid_target(mob, distance)
    return mob and mob.distance and distance and mob.distance:sqrt() < distance
end

--- Check if a party member is a valid target
--- Developer notes allys distances are already in yalms from being put in the allys hash
---@param id int a players id
---@param distance int in yalm range 
---@return boolean 
function cast.is_ally_valid_target(id, distance)
    local ally = otto.fight.my_allies[id]
    return ally and ally.hpp > 0 and ally.distance < distance
end

--- Check if your party is in aoe_range of a spell. 
--- You can use this to wait until they are before casting
---@param spell table res.spell
---@return boolean 
function cast.aoe_range(spell)
    local player = windower.ffxi.get_player()

    for id, ally in pairs(otto.fight.my_allies) do
        if spell and spell.distance and ally and ally.zone == player.zone and cast.is_ally_valid_target(id, spell.distance) then
            return true
        end
    end

    return false
end

--- Check if your party is in aoe_range of a certain distance. 
--- You can use this to wait until they are before casting
---@param distance int in yalm range 
---@return boolean 
function cast.aoe_range(distance)
    local player = windower.ffxi.get_player()

    for id, ally in pairs(otto.fight.my_allies) do
        if ally and ally.zone == player.zone and cast.is_ally_valid_target(id, distance) then
            return false
        end
    end

    return true
end

return cast
