

require('actions')
json = require('json')

local debugger = { _events = T{} }

debugger.event_handler = require('event_handler')


function debugger.init() 

end


debugger._events['prerender'] = windower.register_event('prerender', function()
end)

debugger._events['postrender'] = windower.register_event('postrender', function()
end)

debugger._events['action'] = windower.register_event('action', debugger.event_handler.action)
debugger._events['action_message'] = windower.register_event('action message', debugger.handler_action_message)

debugger._events['load'] = windower.register_event('load', function()
    debugger.init()
end)
debugger._events['unload'] = windower.register_event('unload', function()
    for _,event in pairs(debugger._events) do
        windower.unregister_event(event)
    end
end)

debugger._events['logout'] = windower.register_event('logout', function()
    windower.send_command('lua unload debugger')
end)
ebugger._events['login'] = windower.register_event('login', function()
    windower.send_command('lua load debugger')
end)


debugger._events['gain_buff'] = windower.register_event('gain buff', function()
end)
debugger._events['lose buff'] = windower.register_event('lose buff', function()
end)

debugger._events['outgoing chunk'] = windower.register_event('addon command', debugger.events.addon_command)
debugger._events['incoming chunk'] = windower.register_event('incoming chunk', debugger.packets.handle_incoming_chunk)


debugger._events['job change'] = windower.register_event('job change', debugger.check_jobs)
debugger._events['target change'] = windower.register_event('target change', debugger.check_jobs)

debugger._events['ipc message'] = windower.register_event('ipc message', function()
end)

return debugger