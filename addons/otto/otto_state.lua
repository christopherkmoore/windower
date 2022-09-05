require('pack')

local state = {}

-- Movement Handling
local lastlocation = 'fff'
lastlocation = lastlocation:pack(0,0,0)
state.moving = false

state.is_busy = 0
state.last_check_time = os.clock()

function state.determine_movement(id, data, modified, is_injected, is_blocked)
    if id == 0x015 then
        local update = lastlocation ~= modified:sub(5, 16) 
        state.moving = update
        lastlocation = modified:sub(5, 16)
    end
end

function state.determine_is_busy()
	local time = os.clock()
	local delta_time = time - state.last_check_time

	state.last_check_time = time

	if (state.is_busy > 0) then
		state.is_busy = (state.is_busy - delta_time) < 0 and 0 or (state.is_busy - delta_time)
	end
end

return state