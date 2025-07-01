
local event_handler = {}

function event_handler.prerender() 
end

function event_handler.postrender() 
end


function event_handler.action(action) 

    -- see debugger/logs for action format
    if action.category == 1 then end  -- melee attack
    if action.category == 2 then end  -- finish ranged attack
    if action.category == 3 then end  -- finish weaponskill
    if action.category == 4 then end  -- finish spell casting
    if action.category == 5 then end  -- finish item use
    if action.category == 6 then      -- use job ability 

    end
    if action.category == 7 then end  -- begin weaponskill or TP move
    if action.category == 8 then end  -- begin spell casting or interrupt casting
    if action.category == 9 then end  -- begin item use or interrupt casting
    if action.category == 10 then end -- unknown / unused
    if action.category == 11 then end -- finish TP move
    if action.category == 12 then end -- begin ranged attack
    if action.category == 13 then end -- pet completes ability or weaponskill
    if action.category == 14 then end -- unblinkable job ability
    if action.category == 15 then end -- some RUN JA
end

function event_handler.action_message(actor_id, target_id, actor_index, target_index, message_id, param_1, param_2, param_3) 
end

function event_handler.gain_buff() 
end

function event_handler.lose_buff() 
end

function event_handler.outgoing_chunk() 
end

function event_handler.incoming_chunk() 
end

function event_handler.job_change() 
end

function event_handler.target_change() 
end

function event_handler.ipc_message() 
end



return event_handler