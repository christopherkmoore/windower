local cast = {}

--=====================================================================
-- MARK: Casting
--=====================================================================

--- Cast a spell, or fail because of preconditions
-- @param parameters A spell from res.spells
-- @param parameters A mob
-- @return The delay for the job class to be added to check_interval
function cast.spell(spell, mob)
    
    local spell_recasts = windower.ffxi.get_spell_recasts()
    if actor:is_moving() then return 1 end
    if not actor:in_casting_range(mob) then return 0 end
    if not actor:can_use(spell) then return 0 end
    
    if mob and type(mob) == 'table' and mob.name and mob.id then
        local current_mob_target = windower.ffxi.get_mob_by_target('t')

        -- I'm not targeting the right mob, so swap
        if current_mob_target and otto.fight.my_targets[mob.id] and mob.id ~= current_mob_target.id then
            otto.assist.swap_target_and_cast(mob, spell.id)
            return spell.cast_time
        end

        local ally = otto.fight.my_allies[mob.id]

        -- I'm not targeting the right ally, so swap
        if ally and current_mob_target ~= ally.id then
            otto.assist.swap_target_and_cast(mob, spell.id)
            return spell.cast_time
        end
    end

    if type(mob) == 'string' then
        if mob == '<t>' then
            windower.send_command(('input %s "%s" <t>'):format("/ma", spell.en))
            return spell.cast_time
        elseif mob == '<me>' then
            windower.send_command(('input %s "%s" <me>'):format("/ma", spell.en))
            return spell.cast_time
        else
            print('cast.spell is being sent a mob name. This wont work with multiple mobs.')
            windower.send_command(('input %s "%s" %s'):format("/ma", spell.en, mob))
            return spell.cast_time
        end

        return spell.cast_time
    end

    windower.send_command(('input %s "%s" %s'):format("/ma", spell.en, mob.name))
    return spell.cast_time
end

--- Cast a spell, or fail because of preconditions
-- @param parameters A spell from res.spells
-- @return The delay for the job class to be added to check_interval
function cast.spell_no_check(spell, target)
    
    local spell_recasts = windower.ffxi.get_spell_recasts()
    if actor:is_moving() then return 1 end
    if not actor:can_use(spell) then return 0 end

    windower.send_command(('input %s "%s" %s'):format("/ma", spell.en, target))
    return spell.cast_time
end

--- Use a Job Ability, or fail because of preconditions
-- @param parameters A spell from res.job_abilities
-- @param parameters A targets name
-- @return The delay for the job class to be added to check_interval
function cast.job_ability(job_ability, target)
    if not job_ability then return end
    local ability_recasts = windower.ffxi.get_ability_recasts()[job_ability.recast_id]

    if not actor:can_use(job_ability) then return 0 end

    windower.send_command(('input %s "%s" %s'):format(job_ability.prefix, job_ability.en, target))

    return 1
end

--- Cast a spell with a pre-action, or fail because of preconditions
-- @param parameters A spell from res.spells
-- @param parameters A targets name
-- @return The delay for the job class to be added to check_interval
function cast.spell_with_pre_action(spell, job_ability, target)

    local delay = cast.job_ability(job_ability, '<me>')
    coroutine.sleep(delay)

    cast.spell(spell, target)
    return spell.cast_time
end

--=====================================================================
-- MARK: Targeting
--=====================================================================

--- Check if a monster is a valid target
-- @param parameters A mob SPECIFICALLY from otto.fight.my_targets, since so much validation is done there already. 
-- @param parameters The distance the monster should be within in yalms
-- @return A boolean if the target is valid or false if it's invalid
function cast.is_mob_valid_target(mob, distance)
    return mob.distance:sqrt() < distance
end

--- Check if a party member is a valid target
--- Developer notes allys distances are already in yalms from being put in the allys hash
-- @param parameters A player.id
-- @param parameters The distance the ally should be within in yalms
-- @return A boolean if the party member is valid or false if it's invalid
function cast.is_ally_valid_target(id, distance)
    local ally = otto.fight.my_allies[id]
    return ally and ally.hpp > 0 and ally.distance < distance
end

--- Check if your party is in aoe_range of a spell. 
--- You can use this to wait until they are before casting
-- @param parameters A spell from res.spells
-- @return A boolean if the party is included in the spells AoE range or false if it's not.
function cast.aoe_range(spell)
    local player = windower.ffxi.get_player()

    for id, ally in pairs(otto.fight.my_allies) do
        if ally and ally.zone == player.zone and cast.is_ally_valid_target(id, spell.distance) then
            return true
        end
    end

    return false
end

--- Check if your party is in aoe_range of a certain distance. 
--- You can use this to wait until they are before casting
-- @param parameters A spell from res.spells
-- @return A boolean if the party is included in the spells AoE range or false if it's not.
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
