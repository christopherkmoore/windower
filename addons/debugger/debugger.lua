
require('luau')
require('actions')
json = require('json')
files = require('files')


debugger = { _events = T{} }

debugger.event_handler = require('event_handler')
debugger.custom_logger = require('custom_logger')

function debugger.init() 

end


debugger._events['prerender'] = windower.register_event('prerender', debugger.event_handler.prerender)
debugger._events['postrender'] = windower.register_event('postrender', debugger.event_handler.postrender)
debugger._events['action'] = windower.register_event('action', debugger.event_handler.action)
debugger._events['action_message'] = windower.register_event('action message', debugger.event_handler.action_message)

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
debugger._events['login'] = windower.register_event('login', function()
    windower.send_command('lua load debugger')
end)


debugger._events['gain_buff'] = windower.register_event('gain buff', debugger.event_handler.gain_buff)
debugger._events['lose buff'] = windower.register_event('lose buff', debugger.event_handler.lose_buff)

debugger._events['outgoing chunk'] = windower.register_event('addon command', debugger.event_handler.outgoing_chunk)
debugger._events['incoming chunk'] = windower.register_event('incoming chunk', debugger.event_handler.incoming_chunk)


debugger._events['job change'] = windower.register_event('job change', debugger.event_handler.job_change)
debugger._events['target change'] = windower.register_event('target change', debugger.event_handler.target_change)

debugger._events['ipc message'] = windower.register_event('ipc message', debugger.event_handler.ipc_message)

return debugger