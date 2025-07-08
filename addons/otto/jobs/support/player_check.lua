local player_check = {}
local static_me = windower.ffxi.get_player()


function player_check.buff_active(id)
    local player = windower.ffxi.get_player()
    if T(windower.ffxi.get_player().buffs):contains(id) == true then
        return true
    end
    return false
end

function player_check.disabled() 
    for _, disabled_id in pairs(otto.event_statics.disabled_states) do
		if player_check.buff_active.buff_active(disabled_id) then
			return true
		end
	end
	
    return false
    
end

function player_check.my_buffs() 
    local player = windower.ffxi.get_player()
    return S(player.buffs)
end

function player_check.mage_disabled()
    for _, disabled_id in pairs(otto.event_statics.mage_disabled_states) do
		if player_check.buff_active.buff_active(disabled_id) then
			return true
		end
	end
	
    return false
end

function player_check.melee_disabled()
    local player = windower.ffxi.get_player()
	for _, disabled_id in pairs(otto.event_statics.melee_disabled_states) do
		if player_check.buff_active.buff_active(disabled_id) then
			return true
		end
	end
	
    return false
end



return player_check