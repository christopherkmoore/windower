require('luau')
local utilities = { }

utilities.assist = { active = false, engage = false}

-- Movement Handling
local lastlocation = 'fff'
lastlocation = lastlocation:pack(0,0,0)


function utilities.register_assistee(assistee_name)
    local pname = utilities.getPlayerName(assistee_name)
    if (pname ~= nil) then
        utilities.assist.name = pname
        utilities.assist.active = true
        windower.add_to_chat(123, 'Now assisting %s.', pname)
    else
        windower.add_to_chat(123,'Error: Invalid name provided as an assist target: %s', assistee_name)
    end

    return utilities.assist
end

function utilities.getPlayerName(name)
    local target = utilities.get_target(name)
    if target ~= nil then
        return target.name
    end
    return nil
end

function utilities.get_target(targ)
    log(targ)
    if targ == nil then
        return nil
    elseif istable(targ) then
        return targ
    elseif tonumber(targ) and (tonumber(targ) > 255) then
        return windower.ffxi.get_mob_by_id(tonumber(targ))
    elseif S{'<me>', 'me'}:contains(targ) then
        return windower.ffxi.get_mob_by_target('me')
    elseif targ == '<t>' then
        return windower.ffxi.get_mob_by_target()
    elseif isstr(targ) then
        local target = windower.ffxi.get_mob_by_name(targ)
        return target or windower.ffxi.get_mob_by_name(targ:ucfirst())
    end
    return nil
end

    --noinspection GlobalCreationOutsideO
    function isfunc(obj) return type(obj) == 'function' end
    --noinspection GlobalCreationOutsideO
    function isstr(obj) return type(obj) == 'string' end
    --noinspection GlobalCreationOutsideO
    function istable(obj) return type(obj) == 'table' end
    --noinspection GlobalCreationOutsideO
    function isnum(obj) return type(obj) == 'number' end
    --noinspection GlobalCreationOutsideO
    function isbool(obj) return type(obj) == 'boolean' end
    --noinspection GlobalCreationOutsideO
    function isnil(obj) return type(obj) == 'nil' end
    --noinspection GlobalCreationOutsideO
    function isuserdata(obj) return type(obj) == 'userdata' end
    --noinspection GlobalCreationOutsideO
    function isthread(obj) return type(obj) == 'thread' end
    --noinspection GlobalCreationOutsideO
    function class(obj)
        local m = getmetatable(obj)
        return m and (m.__class or m.__class__) or type(obj)
    end
    

return utilities