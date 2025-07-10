
--[[
    The starting point for this code was drawn from 

    _addon.version = '0.0.7'
    _addon.name = 'attackwithme'
    _addon.author = 'yyoshisaur, modded by icy'
    _addon.commands = {'attackwithme','atkwm','awm'}

    and modified to suit my needs.
    -TC
]]

-- need to add a 'engager' who will move to the target, then the frontline slaves move to him
-- Commands related to targeting / engaging during battle
local assist = { _events = {} }

local function assign_roles() 
    -- roles
    -- tank, backline, frontline, puller
    local player = windower.ffxi.get_player()

    if player.main_job == "BRD" or player.main_job == "GEO" or player.main_job == "WHM" or 
    player.main_job == "BLM"  or player.main_job == "SMN"  or player.main_job == "SCH" then
        windower.send_command('otto assist role backline')
    -- elseif player.main_job == "RUN" or player.main_job == "PLD" then
    --     windower.send_command('otto assist role tank')
    else
        windower.send_command('otto assist role frontline')
    end  
end

function assist.init() 
    local defaults = { }
    defaults.enabled = true
    defaults.yalm_fight_range = 3.5
    defaults.role =  'frontline' --'frontline' | 'backline' (will close the distance to auto, or stay at range.)
    defaults.master = ''
    defaults.slaves = {  } -- { ['Slave'] = 'role' }
    defaults.should_engage = false -- controls if master will fight a new target when idle. TODO

    if user_settings.assist == nil then
        user_settings.assist = defaults
        user_settings:save()
    end

    if otto.assist._events['assist incoming chunk'] == nil or otto._events['assist outgoing chunk'] == nil then
        otto.assist._events['assist incoming chunk'] = windower.register_event('incoming chunk', assist.incoming_chunk_handler)
        otto.assist._events['assist outgoing chunk'] = windower.register_event('outgoing chunk', assist.outgoing_chunk_handler)
    end

    assign_roles()
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

function assist.is_master() 
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

---forces someone to target and try casting
---@param mob: T{mob}
---@param spell: param id
function assist.swap_target_and_cast(mob, spell)

    if not mob then
        return
    end

    local player = windower.ffxi.get_player()
    local elegy_recast = windower.ffxi.get_spell_recasts()[spell]

    if elegy_recast == 0 then

        local p = packets.new('incoming', 0x058, {
            ['Player'] = player.id,
            ['Target'] = mob.id,
            ['Player Index'] = player.index,
        })
    
        packets.inject(p)
        coroutine.sleep(1)

        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = mob.id,
            ["Target Index"] = mob.index,
            ["Category"] = 0x03, -- spell cast
            ["Param"] = spell
        })

        packets.inject(p)    
    end
end

---forces someone to target and try casting
---@param mob: T{mob}
---@param spell: param id
function assist.puller_target_and_cast(mob, spell)

    if not mob then
        return
    end

    local player = windower.ffxi.get_player()
    local elegy_recast = windower.ffxi.get_spell_recasts()[spell]

    if elegy_recast == 0 then
        local p = packets.new('outgoing', 0x01A, {
            ["Target"] = mob.id,
            ["Target Index"] = mob.index,
            ["Category"] = 0x03, -- spell cast
            ["Param"] = spell
        })

        packets.inject(p)

        coroutine.sleep(1)
        
        local p = packets.new('incoming', 0x058, {
            ['Player'] = player.id,
            ['Target'] = mob.id,
            ['Player Index'] = player.index,
        })
    
        packets.inject(p)
    
    end
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
		return 
	end

	windower.ffxi.turn(heading_to(mob.x, mob.y))
end


--- Will run towards 'master'. Start starts running towards master
--- when you're outside of start yalm range. Finish is when you're done moving
--- towards master.
---@param start int yalms  
---@param finish int yalms 
function assist.come_to_master(start, finish)
    if assist.already_coming then return end 
    local master = otto.fight.ally_lookup(user_settings.assist.master)
    if not master then return end

    local mobs_fighting = otto.fight.my_targets:keyset()
    if mobs_fighting == 0 then return end
    
    local master_mob = windower.ffxi.get_mob_by_id(master.id)
    

    local me = windower.ffxi.get_player()
    local me_mob = windower.ffxi.get_mob_by_id(me.id)
    if not master_mob and not me_mob then return end 
    
	local dist = math.sqrt(master_mob.distance)

    if dist > 3 then 
		closing_in = true
		log('Slave: Closing in ---> '..master_mob.name)
    else 
        face_target()
	end

    local me_coords = {x = me_mob.x, y = me_mob.y, z = me_mob.z}
    local master_coords = {x = master_mob.x, y = master_mob.y, z = master_mob.z}

    local distance_away_from_master = otto.cast.distance_between_points(me_coords, master_coords)

    if distance_away_from_master > start then
        assist.already_coming = true 
        while (master_mob and dist >= finish) do
            windower.ffxi.run(heading_to(master_mob.x, master_mob.y))
            coroutine.sleep(0.2)
            master_mob = windower.ffxi.get_mob_by_id(master.id)
    
            if master_mob then
                dist = math.sqrt(master_mob.distance)
            else
                master_mob = nil
            end
        end
    end

    assist.already_coming = false 
	windower.ffxi.run(false)
end

local function close_in(target_type) -- 't', 'bt'
    if locked_closing_in then face_target() return end

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

function assist.master_target_no_close_in(id)
    if not id then return end

    -- locked_closing_in = true 

    windower.send_ipc_message('master '..id)
end


-- TODO register handlers in otto
function assist.ipc_message_handler(message) 
    if not user_settings.assist.enabled then return end

    local msg = message:split(' ')

    if msg[1] == 'master' then
        locked_closing_in = true 
        if not assist.is_master() then return end

        local id = tonumber(msg[2])
        local player = windower.ffxi.get_player()

        while player.status == player_status["Idle"] do
            assist.attack_on(id)
            coroutine.sleep(1)

            player = windower.ffxi.get_player()
        end

        while player.status == player_status['Engaged'] do
            close_in()
            coroutine.sleep(.5)

            player = windower.ffxi.get_player()
        end
    end

    if not is_slave then
        return
    end

    local name = windower.ffxi.get_player().name
    local role = user_settings.assist.slaves[name]

    if msg[1] == 'attack' then
        if msg[2] == 'on' then
            log('Slave: Attacking!')
            local id = tonumber(msg[3])
            local target = windower.ffxi.get_mob_by_id(id)

            if not target then
                log('Slave: Target not found!')
                return
            end

            if math.sqrt(target.distance) > 20 then
                log('Slave: ['..target.name..']'..' found, but too far!')
                return
            end

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
        if role == 'frontline' then
            local retry_count = 0
            repeat
                switch_target(id)
                coroutine.sleep(2)
                player = windower.ffxi.get_player()
                retry_count = retry_count + 1
            until player.status == player_status['Engaged'] or retry_count > max_retry

			coroutine.sleep(1)
			while player.status == player_status['Engaged'] do
                assist.come_to_master(5, 0.2)

				-- if not closing_in and not locked_closing_in then
				-- 	-- close_in()
				-- end

                -- if locked_closing_in then
                --     face_target()
                -- end
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

    if not assist.is_master() then
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

    if not assist.is_master() then
        return
    end

    if id == 0x058 then -- -- Assist Response
        local p = packets.parse('incoming', original)
         send_ipc_message_delay:schedule(0.5, 'change '..tostring(p['Target']))
    end
end

windower.register_event('ipc message', assist.ipc_message_handler)

return assist