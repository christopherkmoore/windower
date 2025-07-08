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

local pt_keys = {'party1_count', 'party2_count', 'party3_count'}
local pm_keys = {
    {'p0','p1','p2','p3','p4','p5'}, {'a10','a11','a12','a13','a14','a15'}, {'a20','a21','a22','a23','a24','a25'}
}

otto.events = require('otto_events')
otto.event_handler = require('events/event_handler')
otto.event_statics = require('events/event_statics')
otto.debug = require('debug/debug')

otto.assist = require('jobs/support/targeting/assist')
otto.cast = require('jobs/support/targeting/cast')
otto.pull = require('jobs/support/targeting/pull')
otto.fight = require('jobs/support/targeting/fight')

otto.weaponskill = require('jobs/support/weaponskill')
otto.aspir = require('jobs/support/aspir')
otto.magic_burst = require('jobs/support/magic_burst')
otto.dispel = require('jobs/support/dispel')
otto.buffs = require('jobs/support/magic/buffs')
otto.debuffs = require('jobs/support/magic/debuffs')
otto.player = require('jobs/support/player')
otto.draw = require('drawing/draw')
-- otto.follow = require('follow')


function otto.init()
    _G["actor"] = _libs.lor.actor.Actor.new() -- work to get rid of this i think.
    utils.load_configs()

    -- otto.follow.init()
    otto.magic_burst.init()
    otto.weaponskill.init()
    otto.pull.init()
    otto.assist.init()
    otto.dispel.init()
    otto.fight.init() 

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
    otto.draw.distances_from_master()
end)

otto._events['outgoing chunk'] = windower.register_event('addon command', otto.events.addon_command)
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

return otto