
local event_handler = {}
local event_processor = require('events/event_processor')

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
        otto.fight.remove_target_debuff(target.id, 'sleep')
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
    

    for target in actionpacket:get_targets() do -- an action may have multiple targets, iterate over them
        for action in target:get_actions() do -- may also have multiple actions (but mostly just one)
            event_processor.process_buff(action, target)
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
    elseif otto.paladin ~= nil then
        otto.paladin.action_handler(category, action, actor_id, add_effect, target)
    end
end

function event_handler.action_message(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3)

    if otto.event_statics.message_death:contains(message_id) then
        otto.fight.remove_target(target_id)
    end 
end

function event_handler.gain_buff(raw) 

    -- local player = windower.ffxi.get_player()
    -- if not otto.fight.buffs[player.id] then
    --     otto.fight.buffs[player.id] = {}
    -- end
    -- local buff = res.buffs[raw]
    -- otto.fight.buffs[player.id][raw] = buff.en
end

function event_handler.lose_buff(raw)
    -- local player = windower.ffxi.get_player()
    -- local buff = res.buffs[raw]
    
    -- if not otto.fight.buffs[player.id] then
    --     return
    -- end

    -- otto.fight.buffs[player.id][raw] = nil
end

function event_handler.outgoing_chunk() 
end


function event_handler.job_change() 
end

function event_handler.target_change() 
end

function event_handler.ipc_message() 
end

local function parse_party_buffs_update(data)
    -- only gets the buffs for the parties, so fight buffs need to be built
    -- from the 'gain/lose buff' handlers as well (that on is the pt member)
    -- left out here
    for  k = 0, 4 do
        local id = data:unpack('I', k*48+5)
        otto.fight.buffs[id] = {}

        if id ~= 0 then
            for i = 1, 32 do
                local buff = data:byte(k*48+5+16+i-1) + 256*( math.floor( data:byte(k*48+5+8+ math.floor((i-1)/4)) / 4^((i-1)%4) )%4) -- Credit: Byrth, GearSwap
                if otto.fight.buffs[id][i] ~= buff and buff ~= 255 then
                    local buff_name = res.buffs[buff]
                    otto.fight.buffs[id][buff] = buff_name.en
                end
            end
        end
    end
end

local function parse_my_buffs_update(data)
    local player = windower.ffxi.get_player()
    if not otto.fight.buffs[player.id]  then
        otto.fight.buffs[player.id] = {}
    end

    if not otto.fight.buff_timers[player.id] then
        otto.fight.buff_timers[player.id] = {}
    end

    -- appears # of copies are not checked anymore and times may only ever be used for afermath, I keep forgetting we dont getno party buff timers
    local set_time = {}
    
    local time = os.time()
    local vana_time = time - 1009810800
    local bufftime_offset = math.floor(time - (vana_time * 60 % 0x100000000) / 60)

    otto.fight.buffs[player.id] = {}
    otto.fight.buff_timers[player.id] = {}

    for i=1,32 do
        local buff_id = data:unpack('H', i*2+7)
        local buff_ts = data:unpack('I', i*4+69)
        local buff_name = res.buffs[buff_id]

        if otto.fight.buffs[player.id] and otto.fight.buffs[player.id][i] ~= buff_id and buff_id ~= 255 then
            otto.fight.buffs[player.id][buff_id] = buff_name.en
            otto.fight.buff_timers[player.id][buff_id] = math.floor(buff_ts / 60 + bufftime_offset)
        end
    end

end    

function event_handler.incoming_chunk(id, data, modified, injected, blocked)
    
    if id == 0x076 then -- party buffs update
        parse_party_buffs_update(data)
    elseif id == 0x63 and data:byte(5) == 9 then
        parse_my_buffs_update(data)
    end 
end

return event_handler