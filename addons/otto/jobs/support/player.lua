local player = {}
local static_me = windower.ffxi.get_player()

-- Is a player moving - used for checking before spell casting
player.is_moving = false
player.last_coords = string.pack('fff', 0, 0, 0)

-- Is a player casting? use for delays on job ticks
player.is_casting = false

-- the players currently selected target's index. Used for mob lookup get_mob_by_index(target_index)
player.target_index = 0

-- Used because targeting through packet injection can fail, so when I inject the packet
-- I need to look for a response in the incoming packets to see if the target was interacted with.
player.target_interacted = false                       

-- delay before the player can take an action again. Used in Job ticks.
player.delay = 1

function player.my_buffs()
    local player = windower.ffxi.get_player()
    return S(player.buffs)
end

function player.disabled()
    local buffs = player.my_buffs()
    if buffs:keyset() == 0 then
        return false
    end

    for _, disabled_id in pairs(otto.event_statics.disabled_states) do
        if buffs:contains(disabled_id) then
            return true
        end
    end

    return false
end

function player.mage_disabled()
    local buffs = player.my_buffs()
    if buffs:keyset() == 0 then
        return false
    end

    for _, disabled_id in pairs(otto.event_statics.mage_disabled_states) do
        if buffs:contains(disabled_id) then
            return true
        end
    end

    return false
end

function player.melee_disabled()
    local buffs = player.my_buffs()
    if buffs:keyset() == 0 then
        return false
    end

    local player = windower.ffxi.get_player()
    for _, disabled_id in pairs(otto.event_statics.melee_disabled_states) do
        if buffs:contains(disabled_id) then
            return true
        end
    end

    return false
end

-- Holds delay information for Jobs
function player.action_handler(category, action, actor_id)
    local categories = S {'job_ability', 'spell_finish', 'item_finish', 'casting_begin', 'item_begin'}

    local player = windower.ffxi.get_player()
    if actor_id ~= player.id or not categories:contains(category) then
        return
    end

    if category == 'job_ability' then
        otto.player.delay = 1.7
    end

    if category == 'casting_begin' then
        if action.top_level_param == 24931 then -- Begin Casting/WS/Item/Range

            local spell = res.spells[action.param]
            otto.player.is_casting = true
            otto.player.delay = spell.cast_time
            return
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            otto.player.is_casting = false
            otto.player.delay = 2.2
            return
        end
    end

    if category == 'item_begin' then
        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            otto.player.is_casting = false
            otto.player.delay = 2.2
            return
        end
        otto.player.is_casting = true
        otto.player.delay = 4.2

    end

    -- Casting finish
    if category == 'spell_finish' then
        otto.player.is_casting = false
        otto.player.delay = 3
    end

    if category == 'item_finish' then
        otto.player.is_casting = false
        otto.player.delay = 2.2
    end

end

return player
