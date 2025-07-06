--[[
    If you have somehow stumbled upon this and begun using it, please for the love of god don't message me
    in game about it. Create a github issue or find me on disc. If you cannot figure out 
    Thank you to Lorand for a huge amount of the code from Healbot, which was adapted for otto. 
    The thing that sets healbot above other addons is the queues, which is something I wanted in 
    every addon I used outside of healbot... So I made it.
--]]
_addon.version = '1.0.0'
_addon.name = 'otto'
_addon.author = 'TC'
_addon.lastUpdate = '10/02/22'
_addon.commands = { 'otto' }

require('luau')
require('actions')
require('lor/lor_utils')
_libs.req('queues')

_libs.lor.req('all')
lor_settings = _libs.lor.settings
serialua = _libs.lor.serialization

otto = { 
    active = false, configs_loaded = false, partyMemberInfo = {}, ignoreList = S{}, extraWatchList = S{},
    modes = {['showPacketInfo'] = false, ['debug'] = false, ['mob_debug'] = false, ['independent'] = false},
    _events = {}, txts = {}, config = {}, 
 }

settings = {}
user_settings = T{}

res = require('resources')
config = require('config')
texts = require('texts')
packets = require('packets')
files = require('files')

require('otto_utilities')
require('HealBot_statics')
offense = require('HB_Offense')
actions = require('HB_Actions')
require('HealBot_queues')

local can_act_statuses = S{0, 1, 5, 85}    --0/1/5/85 = idle/engaged/chocobo/other_mount
local dead_statuses = S{2, 3}
local pt_keys = {'party1_count', 'party2_count', 'party3_count'}
local pm_keys = {
    {'p0','p1','p2','p3','p4','p5'}, {'a10','a11','a12','a13','a14','a15'}, {'a20','a21','a22','a23','a24','a25'}
}

otto.events = require('otto_events')
otto.packets = require('otto_packets')
otto.event_handler = require('events/event_handler')
otto.event_statics = require('events/event_statics')
otto.debug = require('debug/debug')

otto.assist = require('assist')
otto.aspir = require('jobs/support/aspir')
otto.magic_burst = require('jobs/support/magic_burst')
otto.dispel = require('jobs/support/dispel')
otto.cast = require('jobs/support/cast')
otto.follow = require('follow')
otto.healer = require('healer')
otto.buffs = require('buffs')
otto.weaponskill = require('weaponskill')
otto.pull = require('pull')
otto.fight = require('fight')


function otto.init()
    _G["actor"] = _libs.lor.actor.Actor.new()
    utils.load_configs()

    otto.aspir.init()
    otto.follow.init()
    otto.magic_burst.init()
    otto.healer.init()
    otto.weaponskill.init()
    otto.pull.init()
    otto.assist.init()
    otto.dispel.init()
    otto.fight.init() 
    otto.debug.init()

    otto.check_jobs()
    otto.active = true
end

function otto.check_jobs()
    local player = windower.ffxi.get_player()

    if user_settings.job == nil then
        user_settings.job = {}
        user_settings:save()
    end

    if player.main_job == "GEO" then
        otto.geomancer = require('jobs/geomancer')
    elseif player.main_job == "BLM" then
        otto.blackmage = require('jobs/blackmage')
    elseif player.main_job == "PLD" then 
        otto.paladin = require('jobs/paladin')
    elseif player.main_job == "BRD" then
        otto.bard = require('jobs/bard/bard')
    elseif player.main_job == "WHM" then
        otto.whitemage = require('jobs/whitemage')
    end

end

otto._events['action'] = windower.register_event('action', otto.event_handler.action)

otto._events['render'] = windower.register_event('prerender', function()
    if not otto.configs_loaded then return end
    local now = os.clock()

    otto.distances_from_master()
    local acting = otto.isPerformingAction(moving)
    local player = windower.ffxi.get_player()
    actor.name = player and player.name or 'Player'

    if (player ~= nil) and can_act_statuses:contains(player.status) then
        local partner, targ = offense.assistee_and_target()
        
        if user_settings.follow.enabled then
            otto.follow.prerender()
        end

        if otto.active and not (moving or acting) then

            if actor:action_delay_passed() then
                actor.last_action = now   

                actions.take_action(player, partner, targ)

                if user_settings.aspir.enabled then
                    otto.aspir.prerender()
                end
                
                if targ ~= nil and targ.id and user_settings.dispel.enabled then
                    otto.dispel.should_dispel(targ.id)
                end
                -- TODO CKM added for now
            end
        end
    end
end)


otto._events['outgoing chunk'] = windower.register_event('addon command', otto.events.addon_command)
otto._events['inc'] = windower.register_event('incoming chunk', otto.packets.handle_incoming_chunk)
otto._events['event handler inc'] = windower.register_event('incoming chunk', otto.event_handler.incoming_chunk)

otto._events['job change'] = windower.register_event('job change', otto.check_jobs)

otto._events['load'] = windower.register_event('load', function()
    if not _libs.lor then
        local err_msg = 'otto ERROR: Missing core requirement: https://github.com/lorand-ffxi/lor_libs'
        windower.add_to_chat(123, err_msg)
        error(err_msg)
    end
    -- I can't for the life of me figure out where in gearswap this is being rebound...
    -- if you're not me and don't have or want this script, just delete this next line.
    windower.send_command('bind ^t exec targetnpc')
    otto.init()
end)


otto._events['unload'] = windower.register_event('unload', function()
    for _,event in pairs(otto._events) do
        windower.unregister_event(event)
    end
end)


otto._events['logout'] = windower.register_event('logout', function()
    windower.send_command('lua unload otto')
end)

function otto.distances_from_master()
    local targets = S{}
    if settings.textBoxes.moveInfo.visible then
        if user_settings.assist.master ~= nil and user_settings.assist.master ~= "" then
            local p = windower.ffxi.get_player()
            if p.name == user_settings.assist.master then 
                for player, _ in pairs(otto.config.ipc_monitored_boxes) do
                    local added = false
                    if player ~= user_settings.assist.master then 
                        local mbox = windower.ffxi.get_mob_by_name(player)
                        if mbox ~= nil then 
                            local distance = math.sqrt(mbox.distance)
                            local rounded = math.floor(distance)

                            if mbox.target_index ~= nil and mbox.target_index then
                                local target = windower.ffxi.get_mob_by_index(mbox.target_index)
                                if target ~= nil and target.valid_target and target.claim_id > 0 then
                                    targets[player..' -> '..rounded..' yalms | Fighting: '..target.name] = player
                                    added = true
                                elseif target ~= nil and target.valid_target and target.claim_id == 0 and not added then
                                    targets[player..' -> '..rounded..' yalms | target: '..target.name] = player
                                    added = true    
                                elseif target == nil and not added then
                                    targets[player..' -> '..rounded..' yalms'] = player        
                                    added = true
                                end

                            end
                        end

                    end
                    if not added and player ~= user_settings.assist.master then 
                        targets[player] = player
                    end
                end
            end
        end
    end

    targets = targets:sort()

    otto.txts.moveInfo:text(getPrintable(targets, false))
    otto.txts.moveInfo:visible(settings.textBoxes.moveInfo.visible)

end

function otto.addPlayer(list, player)
    if (player == nil) or list:contains(player.name) or otto.ignoreList:contains(player.name) then return end
    local is_trust = player.mob and player.mob.spawn_type == 14 or false    --13 = players; 14 = Trust NPC
    if is_trust and (not otto.extraWatchList:contains(player.name)) then return end
    local status = player.mob and player.mob.status or player.status
    if dead_statuses:contains(status) or (player.hpp <= 0) then
        --Player is dead.  Reset their buff/debuff lists and don't include them in monitored list
        otto.buffs.resetDebuffTimers(player.name)
        otto.buffs.resetBuffTimers(player.name)
    else
        player.trust = is_trust
        list[player.name] = player
    end
end

local function _getMonitoredPlayers()
    local pt = windower.ffxi.get_party()
    local my_zone = pt.p0.zone
    local targets = S{}
    for p = 1, #pt_keys do
        for m = 1, pt[pt_keys[p]] do
            local pt_member = pt[pm_keys[p][m]]
            if pt_member and my_zone == pt_member.zone then
                if p == 1 or otto.extraWatchList:contains(pt_member.name) then
                    otto.addPlayer(targets, pt_member)
                end
            end
        end
    end

    for extraName,_ in pairs(otto.extraWatchList) do
        otto.addPlayer(targets, windower.ffxi.get_mob_by_name(extraName))
    end
    return targets
end
otto.getMonitoredPlayers = _libs.lor.advutils.tcached(1, _getMonitoredPlayers)


local function _getMonitoredIds()
    local ids = S{}
    for name, player in pairs(otto.getMonitoredPlayers()) do
        local id = player.mob and player.mob.id or player.id or utils.get_player_id[name]
        if id ~= nil then
            ids[id] = true
        end
    end
    return ids
end

otto.getMonitoredIds = _libs.lor.advutils.tcached(1, _getMonitoredIds)

function otto.isPerformingAction(moving)
    local acting = actor:is_acting()
    local status = ('is %s'):format(acting and 'performing an action' or (moving and 'moving' or 'idle'))
    
    if (os.clock() - actor.zone_enter) < 25 then
        acting = true
        status = 'zoned recently'
        actor.zone_wait = true
    elseif actor.zone_wait then
        actor.zone_wait = false
        otto.buffs.resetBuffTimers('ALL', S{'Protect V', 'Shell V'})
    elseif actor:buff_active('Sleep','Petrification','Charm','Terror','Lullaby','Stun','Silence','Mute') then
        acting = true
        status = 'is disabled'
    end
    
    local player = windower.ffxi.get_player()
    if (player ~= nil) then
        local mpp = player.vitals.mpp
        if (mpp <= 10) then
            status = status..' | \\cs(255,0,0)LOW MP\\cr'
        end
    end
    
    local otto_status = otto.active and '\\cs(0,0,255)[ON]\\cr' or '\\cs(255,0,0)[OFF]\\cr'
    otto.txts.actionInfo:text((' %s %s %s'):format(otto_status, actor.name, status))
    otto.txts.actionInfo:visible(settings.textBoxes.actionInfo.visible)
    return acting
end

return otto