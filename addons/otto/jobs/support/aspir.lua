-- aspir by TC

local aspir = T{ ready = {}}

local aspirs = { 
    aspir3 = {id=881,en="Aspir III",ja="アスピルIII",cast_time=3,element=7,icon_id=657,icon_id_nq=15,levels={[4]=550,[21]=550},mp_cost=2,prefix="/magic",range=12,recast=26,recast_id=881,requirements=0,skill=37,targets=32,type="BlackMagic"},
    aspir2 = {id=248,en="Aspir II",ja="アスピルII",cast_time=3,element=7,icon_id=239,icon_id_nq=15,levels={[4]=83,[8]=78,[20]=97,[21]=90},mp_cost=5,prefix="/magic",range=12,recast=11,recast_id=248,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir  = {id=247,en="Aspir",ja="アスピル",cast_time=3,element=7,icon_id=238,icon_id_nq=15,levels={[4]=25,[8]=20,[20]=36,[21]=30},mp_cost=10,prefix="/magic",range=12,recast=60,recast_id=247,requirements=2,skill=37,targets=32,type="BlackMagic"},
}

-- genearl check ticks
aspir.check_interval = 1.5

aspir.ready.target = nil
aspir.ready.spell = nil

function aspir.init()

    local defaults = { }
	defaults.enabled = true       -- top level enable toggle. on | off
	defaults.casting_mp = 80      -- stop bursting below this amount of mp%.
	defaults.casts_all = true     -- cast single or all available aspirs
    defaults.tier = 3             -- Aspir tier
   
    if user_settings.aspir == nil then
        user_settings.aspir = defaults
        user_settings:save()
    end

    aspir.check_loop:loop(aspir.check_interval)

end

function aspir.deinit()
    -- find a way to remove check_loop ( since it still runs)
    -- otto.aspir = nil
    -- coroutine.schedule(burst_window_close:prepare(), 9)

end


function aspir.can_cast()
    -- check if a target is set and if it's alive still 
    if aspir.ready.target and otto.fight.my_targets[aspir.ready.target.id] then return end

    for _, mob in pairs(otto.fight.my_targets) do 
        if otto.config.maspir_immunities[mob.name] == nil or otto.config.maspir_immunities[mob.name] == true then
            print('target set')
            local valid_target = otto.cast.is_mob_valid_target(mob, aspirs.aspir.range)
            if valid_target then
                aspir.ready.target = mob
                return
            end
        end
    end
end

function aspir.set_aspir() 
    if not aspir.ready.target then return end

    local spells_learned = windower.ffxi.get_spells()
    local cooldowns = windower.ffxi.get_spell_recasts()
    local tier_trying = 3
    for id, spell in pairs(aspirs) do
        local learned = spells_learned[spell.id] 
        local cooldown = cooldowns[spell.id]

        if learned and cooldown == 0 and (user_settings.aspir.tier == tier_trying or user_settings.aspir.casts_all) then
            aspir.ready.spell = spell 
            print('spell set')
            return
        end
        tier_trying = tier_trying - 1
    end
end

function aspir.check_loop()
    if not user_settings.aspir.enabled then return end
    aspir.set_aspir()

    if aspir.ready.target and otto.fight.my_targets[aspir.ready.target.id] == nil then 
        print('cleared target')
        aspir.ready.target = nil
    end
    local player = windower.ffxi.get_player()

    if player.vitals.mpp < user_settings.aspir.casting_mp then
        aspir.can_cast()
        print('here logggg')
        local log = {target = aspir.ready.target, spell = aspir.ready.spell}
        otto.debug.create_log(log, 'debugger')
    end

end

-- update the db with records of monsters who actually can be aspir'd.
function aspir.update_DB(actor, damage)
    if otto.config.maspir_immunities[actor] ~= nil then return end

    local hasMP = damage ~= 0 
    otto.config.maspir_immunities[actor] = hasMP

    otto.config.maspir_immunities.save(otto.config.maspir_immunities)
end
       
function aspir.action_handler(category, action, actor_id, add_effect, target)
	local categories = S{     
        'spell_finish',
	 }

     local start_categories = S{ 'casting_begin', 'item_begin'}

    if not categories:contains(category) or action.param == 0 then
        return
    end

    if otto.event_statics.aspir:contains(message_id) then -- aspir seems to have message 228 
        -- CKM TEST - this seems weird as hell after moving it here
        otto.aspir.update_DB(target.name, action.param) -- action.param is damage? seems weird
    end
end

return aspir