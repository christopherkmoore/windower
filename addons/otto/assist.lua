
--[[
    The starting point for this code was drawn from 

    _addon.version = '0.0.7'
    _addon.name = 'attackwithme'
    _addon.author = 'yyoshisaur, modded by icy'
    _addon.commands = {'attackwithme','atkwm','awm'}

    and modified to suit my needs.
    -TC

    -- todo test actor:is_acting to make sure mobs moving isn't dragging people all over the place
    -- add should_close_in() check to test that the master's yalm range is within a sensible distance to start running it down. 
    Otherwise you look like a fucking idiot running into narnia...

    -- maybe add retry to target master. in busy places i think the congestion drops injected packets.
]]

-- Commands related to targeting / engaging during battle
local assist = { _events = {} }

function assist.init() 
    local defaults = { }
    defaults.enabled = true
    defaults.yalm_fight_range = 3.5
    -- defaults.role = 'frontline' | 'backline' (will close the distance to auto, or stay at range.)
    defaults.master = ''
    defaults.slaves = {  } -- { ['Slave'] = 'role' }

    if user_settings.assist == nil then
        user_settings.assist = defaults
        user_settings:save()
    end

    if is_slave then 
        windower.send_command('input /autotarget off')
    end

end

local closing_in = false
local locked_closing_in = false

local player_status = {
    ['Idle'] = 0,
    ['Engaged'] = 1,
}

local max_retry = 5

local function is_slave() 
    local name = windower.ffxi.get_player().name
    local role = user_settings.assist.slaves[name]

    if role ~= nil then
        return true
    end

    return false
end

local function is_master() 
    local player = windower.ffxi.get_player().name
    
    if user_settings.assist.master == "" then return false end 

    return  player == user_settings.assist.master
end

function assist.attack_on(id)
    local target = windower.ffxi.get_mob_by_id(id)

    if not target then
        return
    end

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = target.id,
        ["Target Index"] = target.index,
        ["Category"] = 0x02 -- Engage Monster
    })
    packets.inject(p)

end


local function attack_off()
    local player = windower.ffxi.get_player()

    if not player then
        return
    end

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = player.id,
        ["Target Index"] = player.index,
        ["Category"] = 0x04 -- Disengage
    })

    packets.inject(p)

end

local function switch_target(id)
    local target = windower.ffxi.get_mob_by_id(id)

    if not target then
        return
    end

    local p = packets.new('outgoing', 0x01A, {
        ["Target"] = target.id,
        ["Target Index"] = target.index,
        ["Category"] = 0x0F -- Switch target
    })

    packets.inject(p)

end

local function target_master(player, id)
    if not player or not id then return end

    packets.inject(packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = id,
        ['Player Index'] = player.index,
    }))
end

function assist.all_target_master(id)

    if not id then
        return
    end

    local player = windower.ffxi.get_player()

    packets.inject(packets.new('incoming', 0x058, {
        ['Player'] = player.id,
        ['Target'] = id,
        ['Player Index'] = player.index,
    }))

end

local function target_lock_on()
    local player = windower.ffxi.get_player()
    if player and not player.target_locked then
        windower.send_command('input /lockon')
    end
end

local function heading_to(x, y)
	local p = windower.ffxi.get_mob_by_target('me')
	local x = x - p.x
	local y = y - p.y
	local h = math.atan2(x, y)
	return h - 1.5708
end

local function face_target(target_type) -- 't', 'bt'
	if not target_type then target_type = 't' end
	
	local mob = windower.ffxi.get_mob_by_target(target_type)
	if not mob then
		-- error
		return 
	end
	
	windower.ffxi.turn(heading_to(mob.x, mob.y))
end


local function close_in(target_type) -- 't', 'bt'
    if actor:is_acting() then return end

    local name = windower.ffxi.get_player().name
    local role = user_settings.assist.slaves[name]

    local closes_in = role == 'frontline'
    
	if not closes_in then return end
	if not target_type then target_type = 't' end
	
	local mob = windower.ffxi.get_mob_by_target('t')
	if not mob then
		-- error
		return
	end
	
	local dist = math.sqrt(mob.distance)

    if locked_closing_in then face_target() return end


    if dist > user_settings.assist.yalm_fight_range then 
		closing_in = true
		log('Slave: Closing in ---> '..mob.name)
    else 
        face_target()
	end
    
    
    if dist > 14 then return end -- don't close in on super far away mobs

	while (mob and dist > user_settings.assist.yalm_fight_range) do
		windower.ffxi.run(heading_to(mob.x, mob.y))
		coroutine.sleep(0.2)
		mob = windower.ffxi.get_mob_by_target('t')

		if mob then
			dist = math.sqrt(mob.distance)
		else
			mob = nil
		end
	end
	
	closing_in = false
	windower.ffxi.run(false)
end

function assist.targets()
    if not is_master then return end

    local target = windower.ffxi.get_mob_by_target('t')

    if not target then return end

    local player_target = windower.ffxi.get_mob_by_id(target.id)
		
    if not player_target then
		return
    end

    windower.send_ipc_message('target '..player_target.id)
end

-- targets something
-- player 
function assist.target(player)
    if not player then return end

    local target = windower.ffxi.get_mob_by_target('t')
    
    if not target then return end

    local player_target = windower.ffxi.get_mob_by_id(target.id)
		
    if not player_target then
		return
    end

    windower.send_ipc_message('target '..player_target.id..' '..player)
end

function assist.master_target_no_close_in(id)
    if not id then return end

    locked_closing_in = true 

    windower.send_ipc_message('master '..id)
end


-- TODO register handlers in otto
function assist.ipc_message_handler(message) 
    if not user_settings.assist.enabled then return end

    local msg = message:split(' ')

    if msg[1] == 'master' then
        locked_closing_in = true 
        if not is_master then return end

        local id = tonumber(msg[2])
        local player = windower.ffxi.get_player()

        assist.attack_on(id)

        target_lock_on:schedule(1)

        coroutine.sleep(1)

        while player.status == player_status['Engaged'] do
            face_target()
            coroutine.sleep(.5)
            player = windower.ffxi.get_player()
        end
    end

    if not is_slave then
        return
    end

    if msg[1] == 'attack' then
        if msg[2] == 'on' then
            log('Slave: Attacking!')
            local id = tonumber(msg[3])
            local target = windower.ffxi.get_mob_by_id(id)

            if not target then
                log('Slave: Target not found!')
                return
            end

            if math.sqrt(target.distance) > 29 then
                log('Slave: ['..target.name..']'..' found, but too far!')
                return
            end

            assist.attack_on(id)
            target_lock_on:schedule(1)
        elseif msg[2] == 'off' then
            local player = windower.ffxi.get_player()
            local role = user_settings.assist.slaves[player.name]
            
            if role ~= nil and role == 'frontline' then
                attack_off()
            end
        end
    elseif msg[1] == 'change' then
        local id = tonumber(msg[2])
        local target = windower.ffxi.get_mob_by_id(id)
        local player = windower.ffxi.get_player()

        if not target then
            log('Slave: Target not found!')
            return
        end

        local name = windower.ffxi.get_player().name
        local role = user_settings.assist.slaves[name]

		if role == 'frontline' then
            local retry_count = 0
            repeat
                switch_target(id)
                coroutine.sleep(2)
                player = windower.ffxi.get_player()
                retry_count = retry_count + 1
            until player.status == player_status['Engaged'] or retry_count > max_retry
    
            target_lock_on:schedule(1)
            
			coroutine.sleep(1)
			while player.status == player_status['Engaged'] do
				if not closing_in and not locked_closing_in then
					close_in()
				end
				coroutine.sleep(.5)
				player = windower.ffxi.get_player()
			end
        elseif role == 'backline' then
            target_master(player, id)
            return
        end
    elseif msg[1] == 'follow' then
        local id = msg[2]
        local mob = windower.ffxi.get_mob_by_id(id)
        if mob then
            local index = mob.index
            windower.ffxi.follow(index)
        end

    elseif msg[1] == 'target' then     
        local targetId = tonumber(msg[2])
        if msg[3] then
            local player = windower.ffxi.get_player()
            if player.name == msg[3] then
                target_master(player, targetId)   
                return
            end
            return
        end

        assist.all_target_master(targetId)
    end
end


function send_ipc_message_delay(msg)
    windower.send_ipc_message(msg)
end

function assist.outgoing_chunk_handler(id, original)
    if not user_settings.assist.enabled then return end

    if not is_master() then
        return
    end

    if id == 0x01A then
        local p = packets.parse('outgoing', original)
        if p['Category'] == 0x04 then -- Disengage
            windower.send_ipc_message('attack off')
        end
    end
end

function assist.incoming_chunk_handler(id, original)
    if not user_settings.assist.enabled then return end

    if not is_master() then
        return
    end

    if id == 0x058 then -- -- Assist Response
        local p = packets.parse('incoming', original)
         send_ipc_message_delay:schedule(0.5, 'change '..tostring(p['Target']))
    end
end

windower.register_event('incoming chunk', assist.incoming_chunk_handler)
windower.register_event('outgoing chunk', assist.outgoing_chunk_handler)
windower.register_event('ipc message', assist.ipc_message_handler)

return assist