-- TODO draw some useful stuff and not all this horseshit on my  .. (user_settings.magic_burst.change_target and 'enabled' or 'disabled') .. 
-- save casts and ja cast and show old
-- show current action.

local draw = {}

local function getPrintable(list, inverse)
    local qstring = ''
    for index,line in pairs(list) do
        local check = index
        local add = line
        if (inverse) then
            check = line
            add = index
        end
        if (tostring(check) ~= 'n') then
            if (#qstring > 1) then
                qstring = qstring..'\n'
            end
            qstring = qstring..add
        end
    end
    return qstring
end

function draw.distances_from_master()
    local targets = S{}
    if settings.textBoxes.moveInfo.visible then
        if user_settings.assist.master ~= nil and user_settings.assist.master ~= "" then
            local p = windower.ffxi.get_player()
            if p.name == user_settings.assist.master then 
                for player, _ in pairs(otto.config.ipc_monitored_boxes) do
                    local added = false
                    if player ~= user_settings.assist.master then 
                        local mbox = windower.ffxi.get_mob_by_name(player)
                        if mbox ~= nil then 
                            local distance = math.sqrt(mbox.distance)
                            local rounded = math.floor(distance)

                            if mbox.target_index ~= nil and mbox.target_index then
                                local target = windower.ffxi.get_mob_by_index(mbox.target_index)
                                if target ~= nil and target.valid_target and target.claim_id > 0 then
                                    targets[player..' -> '..rounded..' yalms | Fighting: '..target.name] = player
                                    added = true
                                elseif target ~= nil and target.valid_target and target.claim_id == 0 and not added then
                                    targets[player..' -> '..rounded..' yalms | target: '..target.name] = player
                                    added = true    
                                elseif target == nil and not added then
                                    targets[player..' -> '..rounded..' yalms'] = player        
                                    added = true
                                end

                            end
                        end

                    end
                    if not added and player ~= user_settings.assist.master then 
                        targets[player] = player
                    end
                end
            end
        end
    end

    targets = targets:sort()

    otto.txts.moveInfo:text(getPrintable(targets, false))
    otto.txts.moveInfo:visible(settings.textBoxes.moveInfo.visible)

end


function draw.isPerformingAction(moving)
    local status = ('is %s'):format((moving and 'moving' or 'idle'))
     
    if otto.player_check.disabled() then
        acting = true
        status = 'is disabled'
    end
    
    local player = windower.ffxi.get_player()
    if (player ~= nil) then
        local mpp = player.vitals.mpp
        if (mpp <= 10) then
            status = status..' | \\cs(255,0,0)LOW MP\\cr'
        end
    end
    
    local otto_status = otto.active and '\\cs(0,0,255)[ON]\\cr' or '\\cs(255,0,0)[OFF]\\cr'
    otto.txts.actionInfo:text((' %s %s %s'):format(otto_status, actor.name, status))
    otto.txts.actionInfo:visible(true)

    -- otto.txts.actionInfo:visible(settings.textBoxes.actionInfo.visible)
end


return draw