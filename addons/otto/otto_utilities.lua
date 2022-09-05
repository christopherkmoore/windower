require('luau')
local utilities = { }

-- Movement Handling
local lastlocation = 'fff'
lastlocation = lastlocation:pack(0,0,0)


function utilities.getPlayerName(name)
    local target = utilities.get_target(name)
    if target ~= nil then
        return target.name
    end
    return nil
end

function utilities.get_target(targ)
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

function utilities.assistee_and_target(settings)
    if settings.active and (settings.assistee ~= nil) then
        local partner = windower.ffxi.get_mob_by_name(settings.assistee)
        if partner then
            local targ = windower.ffxi.get_mob_by_index(partner.target_index)
            if (targ ~= nil) and targ.is_npc then
                return partner, targ
            end
        end
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