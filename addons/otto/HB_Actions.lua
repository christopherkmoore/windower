--==============================================================================
--[[
	Author: Ragnarok.Lorand
	HealBot action handling functions
--]]
--==============================================================================

local actions = {queue=L()}
local lor_res = _libs.lor.resources
local ffxi = _libs.lor.ffxi

--[[
    All queues feed into the actions queue, but queues are sorted and priortizied before being added.
    Hook for feeding into main occur from the 'defensive' actions and 'offensive' actions.
    defensive actions are priortized higher than offensive ones
--]]
local function local_queue_reset()
    actions.queue = L()
end

local function local_queue_insert(action, target)
    actions.queue:append(tostring(action)..' → '..tostring(target))
end

local function local_queue_disp()
    otto.txts.actionQueue:text(getPrintable(actions.queue))
    otto.txts.actionQueue:visible(settings.textBoxes.actionQueue.visible)
end


--[[
	Builds an action queue for defensive actions.  Returns the action deemed most important at the time.
--]]
function actions.get_defensive_action()
	local action = {}
	
	if (not settings.disable.cure) then
		local cureq = CureUtils.get_cure_queue()
		while (not cureq:empty()) do
			local cact = cureq:pop()
            local_queue_insert(cact.action.en, cact.name)
			if (action.cure == nil) and actor:in_casting_range(cact.name) then
				action.cure = cact
			end
		end
	end
	if (not settings.disable.na) then
		local dbuffq = buffs.getDebuffQueue()
		while (not dbuffq:empty()) do
			local dbact = dbuffq:pop()
            local_queue_insert(dbact.action.en, dbact.name)
			if (action.debuff == nil) and actor:in_casting_range(dbact.name) and actor:ready_to_use(dbact.action) then
				action.debuff = dbact
			end
		end
	end
	if (not settings.disable.buff) then
		local buffq = buffs.getBuffQueue()
		while (not buffq:empty()) do
			local bact = buffq:pop()
            if (bact.action ~= nil ) then 
                local_queue_insert(bact.action.en, bact.name)
                if (action.buff == nil) and actor:in_casting_range(bact.name) and actor:ready_to_use(bact.action) then
                    action.buff = bact
                end
            end
		end
	end
	
	local_queue_disp()
	
	if (action.cure ~= nil) then
		if (action.debuff ~= nil) and (action.debuff.action.en == 'Paralyna') and (action.debuff.name == actor.name) then
			return action.debuff
		elseif (action.debuff ~= nil) and ((action.debuff.prio + 2) < action.cure.prio) then
			return action.debuff
		elseif (action.buff ~= nil) and ((action.buff.prio + 2) < action.cure.prio) then
			return action.buff
		end
		return action.cure
	elseif (action.debuff ~= nil) then
		if (action.buff ~= nil) and (action.buff.prio < action.debuff.prio) then
			return action.buff
		end
		return action.debuff
	elseif (action.buff ~= nil) then
		return action.buff
	end
	return nil
end


function actions.take_action(player, partner, targ)
    buffs.checkOwnBuffs()
    local_queue_reset()
    local action = actions.get_defensive_action()
    if (action ~= nil) then         --If there's a defensive action to perform
        --Record attempt time for buffs/debuffs
        buffs.buffList[action.name] = buffs.buffList[action.name] or {}
        if (action.type == 'buff') and (buffs.buffList[action.name][action.buff]) then
            buffs.buffList[action.name][action.buff].attempted = os.clock()
        elseif (action.type == 'debuff') then
            buffs.debuffList[action.name][action.debuff.id].attempted = os.clock()
        end
        actor:take_action(action)
    else                        --Otherwise, there may be an offensive action
        if (targ ~= nil) or otto.modes.independent then
            local self_engaged = (player.status == 1)
            if (targ ~= nil) then
                local partner_engaged = (partner.status == 1)
                if (player.target_index == partner.target_index) then
                    if offense.assist.engage and partner_engaged and (not self_engaged) then
                        actor:send_cmd('input /attack on')
                    else
                        local action = actions.get_offensive_action(player)
                        actor:take_action(action, '<t>')

                        if action ~= nil and action.type == 'nuke_mob' then
                            coroutine.schedule(actions.remove_offensive_action:prepare(action.action.id), action.action.cast_time)
                        end
                    end
                else                            --Different targets
                    if partner_engaged and (not self_engaged) then
                        actor:send_cmd('input /as '..offense.assist.name)
                    end
                end
            elseif self_engaged and otto.modes.independent then
                local action = actions.get_offensive_action(player)
                actor:take_action(action, '<t>')

                if action ~= nil and action.type == 'nuke_mob' then
                    coroutine.schedule(actions.remove_offensive_action:prepare(action.action.id), action.action.cast_time)
                end
            end
            offense.cleanup()
        end
    end
end


--[[
	Builds an action queue for offensive actions.
    Returns the action deemed most important at the time.
--]]
function actions.get_offensive_action(player)
	player = player or windower.ffxi.get_player()
	local target = windower.ffxi.get_mob_by_target()
    if target == nil then return nil end
    local action = {}
    
    local nukeingQ = offense.getNukeQueue(target)
    while not nukeingQ:empty() do 
        local nukingAction = nukeingQ:pop()
        
        -- offense.nukes[nukingAction.action.id] = nil
        local_queue_insert(nukingAction.action.en, nukingAction.name)
        if (action.nuke == nil) and actor:in_casting_range(target) and actor:ready_to_use(nukingAction.action) then
            action.nuke = nukingAction
        end
    end

    --Prioritize debuffs over nukes/ws
    local dbuffq = offense.getDebuffQueue(player, target)
    while not dbuffq:empty() do
        local dbact = dbuffq:pop()
        local_queue_insert(dbact.action.en, target.name)
        if (action.db == nil) and actor:in_casting_range(target) and actor:ready_to_use(dbact.action) then
            action.db = dbact
        end
    end

    local_queue_disp()
    if action.nuke ~= nil then        
        return action.nuke
    elseif action.db ~= nil then
        return action.db
    end
    

    if (not settings.disable.ws) and (settings.ws ~= nil) and actor:ready_to_use(lor_res.action_for(settings.ws.name)) then
        local sign = settings.ws.sign or '>'
        local hp = settings.ws.hp or 0
        local hp_ok = ((sign == '<') and (target.hpp <= hp)) or ((sign == '>') and (target.hpp >= hp))
        
        local partner_ok = true
        if (settings.ws.partner ~= nil) then
            local pname = settings.ws.partner.name
            local partner = ffxi.get_party_member(pname)
            if partner ~= nil then
                partner_ok = partner.tp >= settings.ws.partner.tp
                --partner_ok = partner.tp <= 500
            else
                partner_ok = false
                atc(123,'Unable to locate weaponskill partner '..pname)
            end
        end
        
        if (hp_ok and partner_ok) then
            return {action=lor_res.action_for(settings.ws.name),name='<t>'}
        end
    elseif (not settings.disable.spam) and settings.spam.active and (settings.spam.name ~= nil) then
        local spam_action = lor_res.action_for(settings.spam.name)
        if (target.hpp > 0) and actor:ready_to_use(spam_action) and actor:in_casting_range('<t>') then
            local _p_ok = (player.vitals.mp >= spam_action.mp_cost)
            if spam_action.tp_cost ~= nil then
                _p_ok = (_p_ok and (player.vitals.tp >= spam_action.tp_cost))
            end
            if _p_ok then
                return {action=spam_action,name='<t>'}
            else
                atcd('MP/TP not ok for '..settings.spam.name)
            end
        end
    end
    
    atcd('get_offensive_action: no offensive actions to perform')
	return nil
end


-- Utility methods for managing the nukeing queue. The nuking queue is made as things are added and removed
-- from offense.nukes. If you want to add something to the nuking queue, you add it to there, and then it pulls 
-- everything from there and builds the queue.
function actions.has_bursting_spells() 
    if offense.nukes:length() == 0 then return false end

    for index, nuke in pairs(offense.nukes) do
        if spells_damage:contains(index) then
            return true
        end
    end

    return false
end

function actions.remove_bursting_spells()

    if next(offense.nukes) == nil then return end

    for index, nukes in pairs(offense.nukes) do
        spells_damage:contains(index)
        offense.nukes[index] = nil
    end

end

function actions.remove_offensive_action(id)
    if next(offense.nukes) == nil then return end

    offense.nukes[id] = nil
end

return actions

--==============================================================================
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiactor nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
--==============================================================================