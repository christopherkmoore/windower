local event_handler = {}
local event_processor = require('events/event_processor')

function event_handler.prerender()
end

function event_handler.postrender()
end

function event_handler.action(raw)

    local actionpacket = ActionPacket.new(raw)

    local category = actionpacket:get_category_string() -- ex: 'spell finish'
    local actor_id = actionpacket:get_id() -- int which can be lookedup ffxi.get_mob_by_id()
    local target = actionpacket:get_targets()() -- big payload, see debug json dumps
    local targets = actionpacket:get_targets() -- actions can have multiple targets (for example, a bards song.) This is an iterator with those
    local action = target:get_actions()()
    local actions = target:get_actions()
    local add_effect = action:get_add_effect()
    local action_basic_info = action:get_basic_info()
    local get_spell = action:get_spell() -- returns an integer which needs to be looked up
    local message_id = action:get_message_id()

    local reaction_string = action:get_reaction_string()
    local get_animation_string = action:get_animation_string()

    -- see debugger/logs for action format
    if action.category == 1 then -- melee attack
    end

    if action.category == 2 then
    end -- finish ranged attack
    if action.category == 3 then
    end -- finish weaponskill
    if action.category == 4 then
    end -- finish spell casting

    if action.category == 5 then
    end -- finish item use
    if action.category == 6 then -- use job ability 

    end
    if action.category == 7 then
    end -- begin weaponskill or TP move
    if action.category == 8 then
    end -- begin spell casting or interrupt casting
    if action.category == 9 then
    end -- begin item use or interrupt casting
    if action.category == 10 then
    end -- unknown / unused
    if action.category == 11 then
    end -- finish TP move
    if action.category == 12 then
    end -- begin ranged attack
    if action.category == 13 then
    end -- pet completes ability or weaponskill
    if action.category == 14 then
    end -- unblinkable job ability
    if action.category == 15 then
    end -- some RUN JA

    for target in actionpacket:get_targets() do -- an action may have multiple targets, iterate over them
        for action in target:get_actions() do -- may also have multiple actions (but mostly just one)
            event_processor.process_buff(action, target)
            if not otto.event_statics.messages_blacklist:contains(action.message) then
                if otto.geomancer then 
                    if indi_spell_ids:contains(action.param) then
                        otto.geomancer.indi.latest = {spell = res.spells[action.param], landed = os.time(), is_indi = true}
                    end
                end    
            end
        end
    end


    local immune = otto.event_statics.immune:contains(message_id) -- ${actor} casts ${spell}.${lb}${target} completely resists the spell.

    if immune then
        event_processor.update_resist_list(message_id, target.id, action)
    end

    -- setup custom action handlers who implement their own logic
    otto.player.action_handler(category, action, actor_id)
    otto.weaponskill.action_handler(category, action, actor_id, add_effect, target)
    otto.dispel.action_handler(category, action, actor_id, target, action_basic_info)
    otto.magic_burst.action_handler(category, action, actor_id, add_effect, target)
    otto.fight.action_handler(category, action, actor_id, target, action_basic_info)

    -- extremely useful for classes to manage delay with an action handler
    -- will result in the char being actually playable by a human
    if otto.bard ~= nil then
        otto.bard.action_handler(category, action, actor_id, add_effect, target)
    elseif otto.whitemage ~= nil then
        otto.whitemage.action_handler(category, action, actor_id, add_effect, target)
    end
end

function event_handler.outgoing_chunk(id, data, modified, injected, blocked)
    if id == 0x015 then
        local parsed = packets.parse('outgoing', data)
        otto.player.is_moving = otto.player.last_coords ~= modified:sub(5, 16)
        otto.player.last_coords = modified:sub(5, 16)
        otto.player.target_index = parsed['Target Index']
    end
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
    for k = 0, 4 do
        local id = data:unpack('I', k * 48 + 5)
        otto.fight.buffs[id] = {}

        if id ~= 0 then
            for i = 1, 32 do
                local buff = data:byte(k * 48 + 5 + 16 + i - 1) + 256 *
                                 (math.floor(data:byte(k * 48 + 5 + 8 + math.floor((i - 1) / 4)) / 4 ^ ((i - 1) % 4)) %
                                     4) -- Credit: Byrth, GearSwap
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
    if not otto.fight.buffs[player.id] then
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


    for i = 1, 32 do
        local buff_id = data:unpack('H', i * 2 + 7)
        local buff_ts = data:unpack('I', i * 4 + 69)
        local buff_name = res.buffs[buff_id]

        if otto.fight.buffs[player.id] and otto.fight.buffs[player.id][i] ~= buff_id and buff_id ~= 255 then
            otto.fight.buffs[player.id][buff_id] = buff_name.en
            otto.fight.buff_timers[player.id][buff_id] = math.floor(buff_ts / 60 + bufftime_offset)
        end


    end
end

local function register_party_members_changed(data)
    local parsed = packets.parse('incoming', data)
    local pmName = parsed.Name
    local pmJobId = parsed['Main job']
    local pmSubJobId = parsed['Sub job']
    otto.partyMemberInfo[pmName] = otto.partyMemberInfo[pmName] or {}
    otto.partyMemberInfo[pmName].job = res.jobs[pmJobId].ens
    otto.partyMemberInfo[pmName].subjob = res.jobs[pmSubJobId].ens
    --atc('Caught party member update packet for '..parsed.Name..' | '..parsed.ID)
end

local function parse_action_message(message_id, target_id, param_1)
    local resisted = otto.event_statics.resisted:contains(message_id)
    local debuff_expired = otto.event_statics.lose_effect:contains(message_id)
    local immune = otto.event_statics.immune:contains(message_id) -- ${actor} casts ${spell}.${lb}${target} completely resists the spell.

    -- Debuff expired
    if debuff_expired then
        local buff = res.buffs[param_1] -- CKM TEST for spells like dia, I may have to make the spell, then map the spell to the debuffs spell.status
        otto.fight.remove_target_debuff(target_id, buff.en)
    end

    if immune or resisted then
        return
    end

    -- mob died.
    if otto.event_statics.message_death:contains(message_id) then
        otto.fight.remove_target(target_id)
        otto.pull.targets[target_id] = nil
    end
end

local function parse_bard_timers(data)
    if otto.bard == nil then return end 
    if not user_settings.job.bard.settings.enabled then return end 
    -- appears # of copies are not checked anymore and times may only ever be used for afermath, I keep forgetting we dont getno party buff timers
    local set_buff = {}
    local set_time = {}
    
    local time = os.time()
    local vana_time = time - 1009810800
    local bufftime_offset = math.floor(time - (vana_time * 60 % 0x100000000) / 60)

    for n=1,32 do
        local buff_id = data:unpack('H', n*2+7)
        local buff_ts = data:unpack('I', n*4+69)

        if buff_ts == 0 then
            break
        elseif buff_id ~= 255 then
            local buff_en = res.buffs[buff_id].en:lower()

            set_buff[buff_en] = (set_buff[buff_en] or 0) + 1
            set_time[buff_en] = math.floor(buff_ts / 60 + bufftime_offset)
        end
    end
    otto.bard.buffs = set_buff
    otto.bard.times = set_time
end

local function parse_char_update(data)
    local indi_info = {}
    local indi_byte = data:byte(0x59)

    if ((indi_byte%128)/64) >= 1 then
        indi_info.active = true
        indi_info.element_id = indi_byte % 8
        indi_info.element = res.elements[indi_info.element_id].en
        indi_info.size = math.floor((indi_byte%64)/16) + 1      --Range: 1~4
        if ((indi_byte%16)/8) >= 1 then
            indi_info.target = 'Enemy'
        else
            indi_info.target = 'Ally'
        end
    else
        indi_info.active = false
    end
    return indi_info
end

function event_handler.incoming_chunk(id, data, modified, injected, blocked)

    if id == 0x63 and data:byte(5) == 9 then
        parse_bard_timers(data)
    end

    if id == 0x034 or id == 0x032 then
        otto.player.target_interacted = true
        coroutine.sleep(3)
        otto.player.target_interacted = false

    end

    if id == 0x076 then -- party buffs update
        parse_party_buffs_update(data)
    elseif id == 0x63 and data:byte(5) == 9 then -- my buffs update with timers
        parse_my_buffs_update(data)
    elseif id == 0x028 then -- action
    elseif id == 0x029 then -- action message
        local actor = data:unpack('I', 0x04+1)
        local target = data:unpack('I',0x08+1)
        local param = data:unpack('I',0x0C+1)
        local message = data:unpack('H',0x18+1) % 0x8000
        
        local buff_lost_messages = S{64,204,206,350,531} -- CKM TEST
        if otto.bard and actor == otto.bard.support.player_id and buff_lost_messages:contains(message)  then
            otto.bard.song_timers.buff_lost(target, param) 
        end

        local target_id = data:unpack('I', 0x09)
        local param_1 = data:unpack('I', 0x0D)
        local message_id = data:unpack('H', 0x19) % 32768
        parse_action_message(message_id, target_id, param_1)
    elseif id == 0x037 then -- character update
        if otto.geomancer then 
            otto.geomancer.indi.info = parse_char_update(data) 
        end   
    elseif id == 0x0DD then  --Party member update
        register_party_members_changed(data)

    else -- contains buff info with timestamps
        -- use this for basically keeping a duration for songs without having to do a bunch
        -- of number crunching to calc song dur and +song etc..
    -- elseif id == 0x0E2 then
    --     print('packet recieved')
    --     local packet = packets.parse('incoming', data)
    --     otto.debug.create_log(packet, 'debugger')
    end
end

return event_handler
