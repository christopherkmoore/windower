--[[
    Alot of this code is simply consolidated from other places. What I wanted to build together was an entire job setup (with queues and 
    prorities) rather than depending on 3 or 9 different addons doing different things and not using shared state or communicating with each other.
    I have made changes / updates / modifications for my own playstyle.
    Original credit for a huge portion of this codebase is thanks to Lorand and healbot -- it is by far the best and most sophisticated 
    at doing everything from all addons I use.

    - libs/lor + queues + actions + Actor + so much stuff -- thank you!

    - Aspir - TC
    - Magic Burst - Ekrividus
    - Follow - pulled from HB
--]]
_addon.version = '1.0.0'
_addon.name = 'otto'
_addon.author = 'Twochix'
_addon.lastUpdate = '6/11/2020'
_addon.commands = { 'otto' }

require('luau')
require('actions')
require('lor/lor_utils')
_libs.req('queues')

_libs.lor.req('all')
lor_settings = _libs.lor.settings
serialua = _libs.lor.serialization

otto = { 
    active = true, configs_loaded = false, partyMemberInfo = {}, ignoreList = S{}, extraWatchList = S{},
    modes = {['showPacketInfo'] = false, ['debug'] = false, ['mob_debug'] = false, ['independent'] = false},
    _events = {}, txts = {}, config = {}, 
 }

action = T{}
settings = {}
user_settings = T{}

res = require('resources')
config = require('config')
texts = require('texts')
packets = require('packets')
files = require('files')

require('otto_utilities')
require('HealBot_statics')
CureUtils = require('HB_CureUtils')
offense = require('HB_Offense')
actions = require('HB_Actions')
buffs = require('HealBot_buffHandling')
require('HealBot_packetHandling')
require('HealBot_queues')
require('HealBot_packetHandling')

local can_act_statuses = S{0, 1, 5, 85}    --0/1/5/85 = idle/engaged/chocobo/other_mount
local dead_statuses = S{2, 3}
local pt_keys = {'party1_count', 'party2_count', 'party3_count'}
local pm_keys = {
    {'p0','p1','p2','p3','p4','p5'}, {'a10','a11','a12','a13','a14','a15'}, {'a20','a21','a22','a23','a24','a25'}
}

otto.events = require('otto_events')
otto.aspir = require('aspir')
otto.magic_burst = require('magic_burst')
otto.follow = require('follow')
otto.assist = require('assist')

function otto.init()
    _G["actor"] = _libs.lor.actor.Actor.new()
    utils.load_configs()

    if otto.active then
        otto.activate()
    end

    otto.follow.init()
    otto.assist.init()
end

function otto.provide_state(...)
end


otto._events['render'] = windower.register_event('prerender', function()
    if not otto.configs_loaded then return end

    local now = os.clock()
    local moving = otto.isMoving()
    local acting = otto.isPerformingAction(moving)
    local player = windower.ffxi.get_player()
    actor.name = player and player.name or 'Player'

    if (player ~= nil) and can_act_statuses:contains(player.status) then
        local partner, targ = offense.assistee_and_target()
        
        otto.follow.prerender()
        otto.aspir.prerender()

        if otto.active and not (moving or acting) then
            --otto.active = false    --Quick stop when debugging
            if actor:action_delay_passed() then
                actor.last_action = now                    --Refresh stored action check time
                actions.take_action(player, partner, targ)

                -- TODO CKM added for now
            end
        end
        
        -- if otto.active and ((now - actor.last_ipc_sent) > actor.ipc_delay) then
        --     windower.send_ipc_message(ipc_req)
        --     actor.last_ipc_sent = now
        -- end
    end
end)

otto._events['aspir_action_listener'] = ActionPacket.open_listener(otto.aspir.action_handler)
otto._events['magic_burst_action_listener'] = ActionPacket.open_listener(otto.magic_burst.action_handler)



otto._events['outgoing chunk'] = windower.register_event('addon command', otto.events.addon_command)

otto._events['load'] = windower.register_event('load', function()
    if not _libs.lor then
        local err_msg = 'otto ERROR: Missing core requirement: https://github.com/lorand-ffxi/lor_libs'
        windower.add_to_chat(123, err_msg)
        error(err_msg)
    end

    otto.init()
    CureUtils.init_cure_potencies()
end)


otto._events['unload'] = windower.register_event('unload', function()
    for _,event in pairs(otto._events) do
        windower.unregister_event(event)
    end
end)


otto._events['logout'] = windower.register_event('logout', function()
    windower.send_command('lua unload otto')
end)

function otto.activate()
    local player = windower.ffxi.get_player()
    if player ~= nil then

        if player.main_job ~= 'WHM' then
            utils.disableCommand('cure', true)
        end

        settings.healing.max = {}
        for _,cure_type in pairs(CureUtils.cure_types) do
            settings.healing.max[cure_type] = CureUtils.highest_tier(cure_type)
        end
        if (settings.healing.max.cure == 0) then
            if settings.healing.max.waltz > 0 then
                settings.healing.mode = 'waltz'
                settings.healing.modega = 'waltzga'
            else
                utils.disableCommand('cure', false)
            end
        else
            settings.healing.mode = 'cure'
            settings.healing.modega = 'curaga'
        end
        otto.active = true
    end

    utils.printStatus()
end


function otto.addPlayer(list, player)
    if (player == nil) or list:contains(player.name) or otto.ignoreList:contains(player.name) then return end
    local is_trust = player.mob and player.mob.spawn_type == 14 or false    --13 = players; 14 = Trust NPC
    if (settings.ignoreTrusts and is_trust and (not otto.extraWatchList:contains(player.name))) then return end
    local status = player.mob and player.mob.status or player.status
    if dead_statuses:contains(status) or (player.hpp <= 0) then
        --Player is dead.  Reset their buff/debuff lists and don't include them in monitored list
        buffs.resetDebuffTimers(player.name)
        buffs.resetBuffTimers(player.name)
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
            if my_zone == pt_member.zone then
                if p == 1 or otto.extraWatchList:contains(pt_member.name) then
                    otto.addPlayer(targets, pt_member)
                end
            end
        end
    end
    for extraName,_ in pairs(otto.extraWatchList) do
        otto.addPlayer(targets, windower.ffxi.get_mob_by_name(extraName))
    end
    otto.txts.montoredBox:text(getPrintable(targets, true))
    otto.txts.montoredBox:visible(settings.textBoxes.montoredBox.visible)
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

function otto.isMoving()
    local timeAtPos = actor:time_at_pos()
    if timeAtPos == nil then
        otto.txts.moveInfo:hide()
        return true
    end
    local moving = actor:is_moving()
    otto.txts.moveInfo:text(('Time @ %s: %.1fs'):format(tostring(actor:pos()), timeAtPos))
    otto.txts.moveInfo:visible(settings.textBoxes.moveInfo.visible)
    return moving
end


function otto.isPerformingAction(moving)
    local acting = actor:is_acting()
    local status = ('is %s'):format(acting and 'performing an action' or (moving and 'moving' or 'idle'))
    
    if (os.clock() - actor.zone_enter) < 25 then
        acting = true
        status = 'zoned recently'
        actor.zone_wait = true
    elseif actor.zone_wait then
        actor.zone_wait = false
        buffs.resetBuffTimers('ALL', S{'Protect V', 'Shell V'})
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