
local event_handler = {}
local event_processor = require('events/event_processor')

event_handler.buffs = { player = windower.ffxi.get_player().name, buffs= S{} }

function event_handler.prerender() 
end

function event_handler.postrender() 
end


function event_handler.action(raw) 

    local actionpacket = ActionPacket.new(raw)
    local monitored_ids = otto.getMonitoredIds()
    
    local category = actionpacket:get_category_string() -- ex: 'spell finish'
    local actor_id = actionpacket:get_id()              -- int which can be lookedup ffxi.get_mob_by_id()
    local target = actionpacket:get_targets()()         -- big payload, see debug json dumps
    local targets = actionpacket:get_targets()          -- actions can have multiple targets (for example, a bards song.) This is an iterator with those
    local action = target:get_actions()()
    local actions = target:get_actions()
    local add_effect = action:get_add_effect()
    local action_basic_info = action:get_basic_info()
    local get_spell = action:get_spell() -- returns an integer which needs to be looked up
    local message_id = action:get_message_id()

    local reaction_string = action:get_reaction_string()
    local get_animation_string = action:get_animation_string()

    if category == "melee" then 
        otto.fight.remove_monster_debuff(target.id, 'sleep')
    end
    -- see debugger/logs for action format
    if action.category == 1 then -- melee attack
    end  
    
    if action.category == 2 then end  -- finish ranged attack
    if action.category == 3 then end  -- finish weaponskill
    if action.category == 4 then      -- finish spell casting
    
        for t, action in targets do 
            -- otto.debug.create_log_once_json(action)
        end
    end  
    if action.category == 5 then end  -- finish item use
    if action.category == 6 then      -- use job ability 

    end
    if action.category == 7 then end  -- begin weaponskill or TP move
    if action.category == 8 then end  -- begin spell casting or interrupt casting
    if action.category == 9 then end  -- begin item use or interrupt casting
    if action.category == 10 then end -- unknown / unused
    if action.category == 11 then end -- finish TP move
    if action.category == 12 then end -- begin ranged attack
    if action.category == 13 then end -- pet completes ability or weaponskill
    if action.category == 14 then end -- unblinkable job ability
    if action.category == 15 then end -- some RUN JA

    event_processor.update_resist_list(action, target)
    if category == 'spell_finish' then
        for target in actionpacket:get_targets() do -- an action may have multiple targets, iterate over them
            for action in target:get_actions() do -- may also have multiple actions (but mostly just one)
                event_processor.spell_finished(action, target)
            end
        end
    end

    if category == 'mob_tp_finish' then

        if S{266, 280, 194}:contains(action.message) then -- target gains the effect of
            if otto.config.monster_ability_dispelables[action.top_level_param] then
                local dispellable = res.buffs[action.param]
                if dispellable and target.id and otto.fight.my_targets[target.id] and otto.fight.my_targets[target.id]['dispellables'] then
                    otto.fight.my_targets[target.id]['dispellables'][dispellable.enl] = true
                end
            end
        end

    end

    

    otto.weaponskill.action_handler(category, action, actor_id, add_effect, target)
    otto.dispel.action_handler(category, action, actor_id, target, monitored_ids, action_basic_info)
    otto.magic_burst.action_handler(category, action, actor_id, add_effect, target)

    if otto.bard ~= nil then
        otto.bard.action_handler(category, action, actor_id, add_effect, target)
    elseif otto.pld ~= nil then
        otto.pld.action_handler(category, action, actor_id, add_effect, target)
    end
end

function event_handler.action_message(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)
    local death_messages = {[6]=true,[20]=true,[113]=true,[406]=true,[605]=true,[646]=true}

    -- $ is asleep
    if death_messages[message_id] then
        otto.fight.remove_target(target_id)
    end 
end

function event_handler.gain_buff(raw) 
    local player = windower.ffxi.get_player().name
    local new = res.buffs[raw]
    event_handler.buffs.buffs[new.en] = raw 
    
    -- otto.debug.create_log(event_handler.buffs, 'gain_buff')
end

function event_handler.lose_buff(raw)
    local player = windower.ffxi.get_player().name
    local new = res.buffs[raw]
    event_handler.buffs.buffs[new.en] = nil 
    -- otto.debug.create_log(event_handler.buffs, 'lose_buff')

end

function event_handler.outgoing_chunk() 
end

function event_handler.incoming_chunk() 
end

function event_handler.job_change() 
end

function event_handler.target_change() 
end

function event_handler.ipc_message() 
end



return event_handler