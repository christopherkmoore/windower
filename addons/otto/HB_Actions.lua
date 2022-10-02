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
	
    if (not user_settings.healer.disable.cure) then
		local cureq = otto.healer.get_cure_queue()
		while (not cureq:empty()) do
			local cact = cureq:pop()
            local_queue_insert(cact.action.en, cact.name)
			if (action.cure == nil) and actor:in_casting_range(cact.name) then
				action.cure = cact
			end
		end
	end

	if (not settings.disable.na) then
		local dbuffq = otto.buffs.getDebuffQueue()
		while (not dbuffq:empty()) do
			local dbact = dbuffq:pop()
            local_queue_insert(dbact.action.en, dbact.name)
			if (action.debuff == nil) and actor:in_casting_range(dbact.name) and actor:ready_to_use(dbact.action) then
				action.debuff = dbact
			end
		end
	end
    
	if (not settings.disable.buff) then
		local buffq = otto.buffs.getBuffQueue()
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
    otto.buffs.checkOwnBuffs()
    local_queue_reset()
    local action = actions.get_defensive_action()
    if (action ~= nil) then         --If there's a defensive action to perform
        --Record attempt time for buffs/debuffs
        otto.buffs.buffList[action.name] = otto.buffs.buffList[action.name] or {}
        if (action.type == 'buff') and (otto.buffs.buffList[action.name][action.buff]) then
            otto.buffs.buffList[action.name][action.buff].attempted = os.clock()
        elseif (action.type == 'debuff') then
            otto.buffs.debuffList[action.name][action.debuff.id].attempted = os.clock()
            if otto.buffs.debuffList[action.name][action.debuff.id].times_attempted and otto.buffs.debuffList[action.name][action.debuff.id].times_attempted > 0 then
                otto.buffs.debuffList[action.name][action.debuff.id].times_attempted = otto.buffs.debuffList[action.name][action.debuff.id].times_attempted + 1
            else
                otto.buffs.debuffList[action.name][action.debuff.id].times_attempted = 1
            end
        end
        
        actor:take_action(action)
    else     

        --Otherwise, there may be an offensive action
        local action = actions.get_offensive_action(player)
        if action == nil then return end

        local monitored_players = otto.getMonitoredPlayers()
        if (action.type == 'preaction' and monitored_players[action.name] ~= nil) or action.type == 'ability'  then
            if action.type == 'bubble' then
                actor:take_action(action, '<t>')
            end

            actor:take_action(action, action.name)
        end

        if user_settings.pull.enabled then 
            actor:take_action(action, '<t>')
        end

        local master = windower.ffxi.get_mob_by_name(user_settings.assist.master)
        if master == nil then return end

        local master_engaged = (master.status == 1)
        local matching_targets_with_master = player.target_index == master.target_index


        if master_engaged and (matching_targets_with_master or otto.assist.is_master) then 
            actor:take_action(action, '<t>')
            if action ~= nil and action.type == 'nuke_mob' then
                coroutine.schedule(actions.remove_offensive_action:prepare(action.action.id), action.action.cast_time)
            end
        end
        offense.cleanup()
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

    local job_queue = actions.check_job_actions()

    if job_queue ~= nil then
        while not job_queue:empty() do
            local preaction = job_queue:pop()
            local_queue_insert(preaction.action.en, preaction.name)
            if (action.preaction == nil) and actor:in_casting_range(preaction.name) and actor:ready_to_use(preaction.action) then
                action.preaction = preaction
            end
        end 
    end
    
    local nukeingQ = offense.getNukeQueue(target)
    while not nukeingQ:empty() do 
        local nukingAction = nukeingQ:pop()
        
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

    action.weaponskill = otto.weaponskill.action(target)

    local_queue_disp()
    if action.preaction ~= nil then 
        return action.preaction
    elseif action.nuke ~= nil then        
        return action.nuke
    elseif action.weaponskill ~= nil then
        return action.weaponskill
    elseif action.db ~= nil then
        return action.db
    end
    
    atcd('get_offensive_action: no offensive actions to perform')
	return nil
end

function actions.check_job_actions()
    if otto.geomancer then
        return otto.geomancer.geo_geomancy_queue()
    end
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
