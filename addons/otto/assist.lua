
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
    -- when set as backline i don't want them to lock target or engage 
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
    assist.toggle_register_windower_events()
end


local closing_in = false

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
    return  player == user_settings.assist.master
end

local function attack_on(id)
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
	local h = math.atan(x, y)
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
	
	local mob = windower.ffxi.get_mob_by_target(target_type)
	if not mob then
		-- error
		return
	end
	
	local dist = math.sqrt(mob.distance)
	if dist > user_settings.assist.yalm_fight_range then 
		closing_in = true
		log('Slave: Closing in ---> '..mob.name)
	else
		face_target()
	end
	
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


-- TODO register handlers in otto
function assist.ipc_message_handler(message) 
    log("in ipc handler, message: "..message)
    if not user_settings.assist.enabled then return end

    local msg = message:split(' ')

    log(msg)


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

            attack_on(id)
            target_lock_on:schedule(1)
        elseif msg[2] == 'off' then
            attack_off()
        end
    elseif msg[1] == 'change' then
        local id = tonumber(msg[2])
        local target = windower.ffxi.get_mob_by_id(id)
        local player = windower.ffxi.get_player()

        if not target then
            log('Slave: Target not found!')
            return
        end

        local retry_count = 0
        repeat
            switch_target(id)
            coroutine.sleep(2)
            player = windower.ffxi.get_player()
            retry_count = retry_count + 1
        until player.status == player_status['Engaged'] or retry_count > max_retry

        target_lock_on:schedule(1)
		
        local name = windower.ffxi.get_player().name
        local role = user_settings.assist.slaves[name]

		if role == 'frontline' then
			coroutine.sleep(1)
			while player.status == player_status['Engaged'] do
				if not closing_in then
					close_in()
				end
				coroutine.sleep(.5)
				player = windower.ffxi.get_player()
			end
		end
		
    elseif msg[1] == 'follow' then
        local id = msg[2]
        local mob = windower.ffxi.get_mob_by_id(id)
        if mob then
            local index = mob.index
            windower.ffxi.follow(index)
        end
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
        if p['Category'] == 0x02 then
            -- send_ipc_message_delay:schedule(1, 'attack on '..tostring(p['Target']))
            -- log('Master: Attack On')
        elseif p['Category'] == 0x04 then
            windower.send_ipc_message('attack off')
            log('Master: Attack Off')
        end
    end
end

function assist.incoming_chunk_handler(id, original)
    if not user_settings.assist.enabled then return end

    if not is_master() then
        return
    end

    if id == 0x058 then
        local p = packets.parse('incoming', original)
        send_ipc_message_delay:schedule(0.5, 'change '..tostring(p['Target']))
    end
end

function assist.toggle_register_windower_events()
    local name = windower.ffxi.get_player().name
    local role = user_settings.assist.slaves[name]

    if user_settings.assist.yalm_fight_range ~= nil or (role ~= nil or user_settings.assist.master ~= nil) then 
    
        if user_settings.assist.enabled then 
            assist._events['incoming chunk'] = windower.register_event('incoming chunk', assist.incoming_chunk_handler)
            assist._events['outgoing chunk'] = windower.register_event('outgoing chunk', assist.outgoing_chunk_handler)
            assist._events['ipc message'] = windower.register_event('ipc message', assist.ipc_message_handler)
            return
        end

        if not user_settings.assist.enabled then 
            for _,event in pairs(assist._events) do
                windower.unregister_event(event)
            end
            return
        end
    end

    if role == nil then
        error('To use assist, you need to configure yourself as either a slave, or master. If you are a slave, assign a role\n Assist is disabling itself you bufoon')
    end

    user_settings.assist.enabled = false
end

return assist