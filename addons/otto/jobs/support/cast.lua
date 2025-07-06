local cast = {}

--- Cast a spell, or fail because of preconditions
-- @param parameters A spell from res.spells
-- @param parameters A targets name
-- @return The delay for the job class to be added to check_interval
function cast.spell(spell, target)
        
    local spell_recasts = windower.ffxi.get_spell_recasts()
    if actor:is_moving() then return 1 end
    if not actor:in_casting_range(target) then return 0 end
    if not actor:can_use(spell) then return 0 end

    windower.send_command(('input %s "%s" %s'):format(spell.prefix, spell.en, target))
    return spell.cast_time
end

--- Use a Job Ability, or fail because of preconditions
-- @param parameters A spell from res.job_abilities
-- @param parameters A targets name
-- @return The delay for the job class to be added to check_interval
function cast.job_ability(job_ability, target)
    if not actor:can_use(job_ability) then return 0 end

    local ability_recasts = windower.ffxi.get_ability_recasts()
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

return cast
