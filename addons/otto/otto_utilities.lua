
local utilities = { }

utilities.assist = { name = nil, active = false, engage = false}

-- Movement Handling
local lastlocation = 'fff'
lastlocation = lastlocation:pack(0,0,0)


function utilities.register_assistee(assistee_name)
    local pname = utils.getPlayerName(assistee_name)
    if (pname ~= nil) then
        offense.assist.name = pname
        offense.assist.active = true
        atcf('Now assisting %s.', pname)
    else
        atcf(123,'Error: Invalid name provided as an assist target: %s', assistee_name)
    end
end

return utilities