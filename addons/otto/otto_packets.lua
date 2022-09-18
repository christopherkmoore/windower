--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot packet handling functions
--]]
--==============================================================================
local otto_packets = { }
local messages_blacklist = _libs.lor.packets.messages_blacklist
local whitelist = L{ 'Gravity', 'Poison' }

local get_action_info = _libs.lor.packets.get_action_info
local parse_char_update = _libs.lor.packets.parse_char_update


--[[
    Analyze the data contained in incoming packets for useful info.
    :param int id: packet ID
    :param data: raw packet contents
--]]


function otto_packets.action_handler(raw_actionpacket)
    if not otto.active then return end

    local monitored_ids = otto.getMonitoredIds()

    local actionpacket = ActionPacket.new(raw_actionpacket)
    -- log('action packet')
    -- table.vprint(actionpacket)
    local category = actionpacket:get_category_string()
    
    local actor_id = actionpacket:get_id()
    local target = actionpacket:get_targets()()
    local targets = actionpacket:get_targets()-- actions can have multiple targets (for example, a bards song.) This is an iterator with those
    local action = target:get_actions()()
    local actions = target:get_actions()
    local add_effect = action:get_add_effect()
    -- local action_basic_info = action:get_basic_info()

    if category == 'spell_finish' then
        if messages_aspir:contains(action.message) then -- aspir seems to have message 228 
            otto.aspir.update_DB(target:get_name(), action.param) -- see maybe if this can get moved up to otto_packets. The messages are already being caught there.
        end
    end

    otto.weaponskill.action_handler(category, action, actor_id, add_effect, target)
    otto.magic_burst.action_handler(category, action, actor_id, add_effect, target)
    otto_packets.processAction(targets, actor_id, monitored_ids) 
end

ActionPacket.open_listener(otto_packets.action_handler)

function otto_packets.handle_incoming_chunk(id, data)


    if S{0x28,0x29}:contains(id) then 
        --Action / Action Message
        local monitored_ids = otto.getMonitoredIds()
        local action_info = get_action_info(id, data)
        actor:update_status(id, action_info)
        if id == 0x29 then
            otto_packets.processMessage(action_info, monitored_ids)
        end
    elseif (id == 0x037) then -- character update
        if (actor.indi ~= nil and actor.indi.info ~= nil) then actor.indi.info = parse_char_update(data) end   
    elseif (id == 0x0DD) then  --Party member update
        otto_packets.register_party_members_changed(data)
    elseif (id == 0x0DF) then -- Char Update
        otto_packets.character_update(data)
    end
end


--[[
    Process the information that was parsed from an action message packet
    :param action_info: parsed action info
    :param set monitored_ids: the IDs of PCs that are being monitored
--]]
function otto_packets.processMessage(action_info, monitored_ids)
    if monitored_ids[action_info.actor_id] or monitored_ids[action_info.target_id] then
        if not (messages_blacklist:contains(action_info.message_id)) then
            local target = windower.ffxi.get_mob_by_id(action_info.target_id)
            
            if otto.modes.showPacketInfo then
                local actor = windower.ffxi.get_mob_by_id(action_info.actor_id)
                local msg = res.action_messages[action_info.message_id] or {en='???'}
                local params = (', '):join(tostring(action_info.param_1), tostring(action_info.param_2), tostring(action_info.param_3))
                atcfs('[0x29]Message(%s): %s { %s } %s %s | %s', action_info.message_id, actor.name, params, rarr, target.name, msg.en)
            end
            
            if messages_wearOff:contains(action_info.message_id) then
                if enfeebling:contains(action_info.param_1) then
                    otto.buffs.register_debuff(target, res.buffs[action_info.param_1], false)
                else
                    otto.buffs.register_buff(target, res.buffs[action_info.param_1], false)
                end
            end
        end--/message ID not on blacklist
    end--/monitoring actor or target
end


--[[
    Process the information that was parsed from an action packet
    :param ai: parsed action info
    :param set monitored_ids: the IDs of PCs that are being monitored
--]]
function otto_packets.processAction(targets, actor_id, monitored_ids)
    for target in targets do
        if monitored_ids[actor_id] or monitored_ids[target.raw.id] then
            local a = windower.ffxi.get_mob_by_id(actor_id)
            local t = windower.ffxi.get_mob_by_id(target.raw.id)
            
            for _, action in pairs(target.raw.actions) do
                if not messages_blacklist:contains(action.message) then
                    if (action.message == 0) and (actor_id == actor.id) then
                        if indi_spell_ids:contains(action.param) then
                            actor.indi.latest = {spell = res.spells[action.param], landed = os.clock(), is_indi = true}
                            otto.buffs.register_buff(t, actor.indi.latest, true)
                        elseif geo_spell_ids:contains(action.param) then
                            actor.geo.latest = {spell = res.spells[action.param], landed = os.clock(), is_geo = true}
                            otto.buffs.register_buff(t, actor.geo.latest, true)
                        end
                    end

                    if otto.modes.showPacketInfo then
                        local msg = res.action_messages[action.message] or {en='???'}
                        atcfs('[0x28]Action(%s): %s { %s } %s %s { %s } | %s', action.message, actor.name, action.param, rarr, t.name, action.param, msg.en)
                    end
                    
                    otto_packets.registerEffect(action, a, t)
                end--/message ID not on blacklist
            end--/loop through targ's actions
        end--/monitoring actor or target
    end--/loop through action's targets
end


--[[
    Register the effects that were discovered in an action packet
    :param action_info: parsed action info
    :param tact: the subaction on a target
    :param actor: the PC/NPC initiating the action
    :param target: the PC/NPC that is the target of the action
    :param set monitored_ids: the IDs of PCs that are being monitored
--]]
function otto_packets.registerEffect(action, a, target)
    if target == nil then return end
    -- for registering new items.
        -- if action.param == 24 then
        --     log('action: ')
        --     table.vprint(action)
        --     log('actor: ')
        --     table.vprint(a)
        --     log('target: ')
        --     table.vprint(target)
        -- end

    local targ_is_enemy = (target.spawn_type == 16)
    if messages_magicDamage:contains(action.message) then      --action_info.param: spell; tact.param: damage
        local spell = res.spells[action.param]
        if S{230,231,232,233,234}:contains(action.param) then
            otto.buffs.register_debuff(target, 'Bio', true, spell)
        elseif S{23,24,25,26,27,33,34,35,36,37}:contains(action.param) then
            log('Message processing and registering debuff')
            otto.buffs.register_debuff(target, 'Dia', true, spell)
        end
    elseif messages_gainEffect:contains(action.message) then   --action_info.param: spell; tact.param: buff/debuff
        --{target} gains the effect of {buff} / {target} is {debuff}ed
        local cause = nil
        if msg_gain_abil:contains(action.message) then
            cause = res.job_abilities[action.param]
        elseif msg_gain_spell:contains(action.message) then
            cause = res.spells[action.param]
        elseif msg_gain_ws:contains(action.message) then
            cause = res.weapon_skills[action.param]
        end
        
        local buff = res.buffs[action.param]
        if enfeebling:contains(action.param) then
            otto.buffs.register_debuff(target, buff, true, cause)
        else
            otto.buffs.register_buff(target, buff, true, cause)
        end
    elseif messages_loseEffect:contains(action.message) then   --action_info.param: spell; tact.param: buff/debuff
        --{target}'s {buff} wore off
        local buff = res.buffs[action.param]
        if enfeebling:contains(action.param) then
            otto.buffs.register_debuff(target, buff, false)
        else
            otto.buffs.register_buff(target, buff, false)
        end
    elseif messages_noEffect:contains(action.message) then     --action_info.param: spell; tact.param: buff/debuff
        --Spell had no effect on {target}
        local spell = res.spells[action.param]
        if (spell ~= nil) then
            if spells_statusRemoval:contains(spell.id) then
                --The debuff must have worn off or have been removed already
                local debuffs = removal_map[spell.en]
                if (debuffs ~= nil) then
                    for _,debuff in pairs(debuffs) do
                        otto.buffs.register_debuff(target, debuff, false)
                    end
                end
            elseif spells_buffs:contains(spell.id) then
                --The buff must already be active, or there must be some debuff preventing the buff from landing
                local buff = otto.buffs.buff_for_action(spell)
                if (buff == nil) then
                    atc(123, 'ERROR: No buff found for spell: '..spell.en)
                else
                    otto.buffs.register_buff(target, buff, false)
                    if S{'Haste','Flurry'}:contains(buff.en) then
                        otto.buffs.register_debuff(target, 'slow', true)
                    end
                end
            elseif spell_debuff_idmap[spell.id] ~= nil and targ_is_enemy then
                --The debuff already landed from someone else
                local debuff_id = spell_debuff_idmap[spell.id]
                otto.buffs.register_debuff(target, debuff_id, true)
            end
        end
    elseif messages_specific_debuff_gain[action.message] ~= nil then
        local gained_debuffs = messages_specific_debuff_gain[action.message]
        for _,gained_debuff in pairs(gained_debuffs) do
            otto.buffs.register_debuff(target, gained_debuff, true)
        end
    elseif messages_specific_debuff_lose[action.message] ~= nil then
        local lost_debuffs = messages_specific_debuff_lose[action.message]
        for _,lost_debuff in pairs(lost_debuffs) do
            otto.buffs.register_debuff(target, lost_debuff, false)
        end
    elseif S{185}:contains(action.message) then    --${actor} uses ${weapon_skill}.${lb}${target} takes ${number} points of damage.
        local mabil = res.monster_abilities[action.param]
        if (mabil ~= nil) then
            if (otto.config.mabil_debuffs[mabil.en] ~= nil) then
                for dbf,_ in pairs(otto.config.mabil_debuffs[mabil.en]) do
                    otto.buffs.register_debuff(target, dbf, true)
                end
            end
        end
    elseif S{655}:contains(action.message) and targ_is_enemy then    --${actor} casts ${spell}.${lb}${target} completely resists the spell.
        offense.register_immunity(target, res.buffs[tact.param])
    elseif messages_paralyzed:contains(action.message) then
        otto.buffs.register_debuff(a, 'paralysis', true)
    end--/message ID checks
end

function otto_packets.character_update(data) 
    if otto.modes.showPacketInfo then
        local player = windower.ffxi.get_player()
        local parsed = packets.parse('incoming', data)
        if (player ~= nil) and (player.id ~= parsed.ID) then
            local person = windower.ffxi.get_mob_by_id(parsed.ID)
            atc('Caught char update packet for '..person.name)
        end
    end
end

function otto_packets.register_party_members_changed(data)
    local parsed = packets.parse('incoming', data)
    local pmName = parsed.Name
    local pmJobId = parsed['Main job']
    local pmSubJobId = parsed['Sub job']
    otto.partyMemberInfo[pmName] = otto.partyMemberInfo[pmName] or {}
    otto.partyMemberInfo[pmName].job = res.jobs[pmJobId].ens
    otto.partyMemberInfo[pmName].subjob = res.jobs[pmSubJobId].ens
    --atc('Caught party member update packet for '..parsed.Name..' | '..parsed.ID)
end


-----------------------------------------------------------------------------------------------------------
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of healBot nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-----------------------------------------------------------------------------------------------------------



return otto_packets