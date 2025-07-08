local player = {}
local static_me = windower.ffxi.get_player()


function player.buff_active(id)
    local player = windower.ffxi.get_player()
    if T(windower.ffxi.get_player().buffs):contains(id) == true then
        return true
    end
    return false
end

function player.disabled() 
    for _, disabled_id in pairs(otto.event_statics.disabled_states) do
		if player.buff_active(disabled_id) then
			return true
		end
	end
	
    return false
    
end

function player.my_buffs() 
    local player = windower.ffxi.get_player()
    return S(player.buffs)
end

function player.mage_disabled()
    for _, disabled_id in pairs(otto.event_statics.mage_disabled_states) do
		if player.buff_active(disabled_id) then
			return true
		end
	end
	
    return false
end

function melee_disabled()
    local player = windower.ffxi.get_player()
	for _, disabled_id in pairs(otto.event_statics.melee_disabled_states) do
		if player.buff_active(disabled_id) then
			return true
		end
	end
	
    return false
end





return player