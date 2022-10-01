-- Currently under construction.
-- TODO
-- I would like to add a new queue for geomancy since so many of the spells require actions. 
-- a geomancer should user the actors time at pos to know when it's a good idea to burn cooldowns.
-- loupan should almost always be fraily or malaise since the bonuses with coupled abilities are so good, and you're basically already at att cap with bard.

-- needs entrust, Queue, priority, q action triage based on priority, blow protection CDS on buffed loupan. Maybe send gs c ProtectLoupan  that locks certain gear in place while
-- a buffed loupan is active?


local geomancer = { }

function geomancer.init()
    local defaults = { }
    defaults.blow_cooldowns = false
	defaults.entrust = { }      -- entrust target and spell
   
    if user_settings.job.geomancer == nil then
        user_settings.job.geomancer = defaults
        user_settings:save()
    end
end

geomancer.indi = { latest = {}, info = {} }
geomancer.geo = { latest = {} }

function geomancer.check_buffs(bufflist)
    local geo = windower.ffxi.get_player()

    for player_name, flatten in pairs (bufflist) do

        for _, buff in pairs(flatten) do
            if buff and buff.is_geo and buff.action then
                local player = windower.ffxi.get_mob_by_name(player_name)
                local loupan = windower.ffxi.get_mob_by_target('pet')
                
                local should_recast_from_distance = geomancer.check_bubble_out_of_range(player, loupan) 

                if loupan == nil then
                    
                    otto.buffs.register_buff(player, geomancer.geo.latest, false)
                else
                    if should_recast_from_distance then
                        geomancer.use_full_circle()
                    end

                    otto.buffs.register_buff(player, geomancer.geo.latest, true)
                end
            elseif geo.name == player_name and buff and buff.is_indi and buff.action then
                local player = windower.ffxi.get_mob_by_name(player_name)

                otto.buffs.register_buff(player, geomancer.indi.latest, geomancer.indi.info.active)
            end
        end
    end
end

-- see if a bubble is far enough away that it should be full circle'd
-- param target_of_geo the ffxi.get_player of the spells target.
function geomancer.check_bubble_out_of_range(target_of_geo, loupan) 
    if not loupan then return true end
    local distance_between_bubble_and_target = math.abs(loupan.x - target_of_geo.x) -- this is not yalm perfect.

    -- if bubble target is further than 15 away
    if distance_between_bubble_and_target > 15 then
        return true
    end

    return false
end

function geomancer.use_full_circle() 

    -- fc
    --

end

return geomancer