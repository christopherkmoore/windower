-- Copyright © 2022, Twochix
-- All rights reserved.
-- want beef.

_addon.version = '1.0.0'
_addon.name = 'otto'
_addon.author = 'Twochix'
_addon.lastUpdate = '6/11/2020'
_addon.commands = { 'otto' }

require('luau')
require('actions')
local otto = {}

Settings = require('otto_settings')
State = require('otto_state')

otto.events = require('otto_events')
otto.settings = require('otto_settings')
otto.utilities = require('otto_utilities')
otto.utilities.settings = otto.settings

otto.events.settings = Settings
otto.events.state = State 

otto.aspir = require('aspir')
otto.magic_burst = require('magic_burst')

function otto.init()
    Settings.update(Settings, otto.aspir:New(Settings, State))
    Settings.update(Settings, otto.magic_burst:New(Settings, State))

    Settings:save()
    -- Settings.magic_burst:save()
    otto.events.settings = Settings
end

function otto.provide_state(...)
    if otto.events.should_update_settings then 
        Settings = otto.events.Update()
        Settings:save()
    end

    State = otto.events.Report()
    if otto.aspir:Update(Settings, State) then
        State.is_busy = otto.aspir.Report_state()
    end

    if otto.magic_burst:Update(Settings, State) then
        State.is_busy = otto.magic_burst.Report_state()
    end
end

otto.init()
windower.register_event('outgoing chunk', otto.events.outgoing_chuck)
windower.register_event('prerender', otto.events.prerender)
windower.register_event('prerender', otto.provide_state)
windower.register_event('addon command', otto.events.addon_command)



return otto