-- aspir by TC

local aspir = T{ immunities = {}, _events = {} }

local spell = { 
    aspir3 = {id=881,en="Aspir III",ja="アスピルIII",cast_time=3,element=7,icon_id=657,icon_id_nq=15,levels={[4]=550,[21]=550},mp_cost=2,prefix="/magic",range=12,recast=26,recast_id=881,requirements=0,skill=37,targets=32,type="BlackMagic"},
    aspir2 = {id=248,en="Aspir II",ja="アスピルII",cast_time=3,element=7,icon_id=239,icon_id_nq=15,levels={[4]=83,[8]=78,[20]=97,[21]=90},mp_cost=5,prefix="/magic",range=12,recast=11,recast_id=248,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir  = {id=247,en="Aspir",ja="アスピル",cast_time=3,element=7,icon_id=238,icon_id_nq=15,levels={[4]=25,[8]=20,[20]=36,[21]=30},mp_cost=10,prefix="/magic",range=12,recast=60,recast_id=247,requirements=2,skill=37,targets=32,type="BlackMagic"},
}

-- genearl check ticks
aspir.check_interval = 0.4
aspir.delay = 4
aspir.counter = 0

aspir.aspirable_target = nil
aspir.should_use_spell = nil

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

local tick_delay = os.clock()

local function can_cast()
    -- check if a target is set and if it's alive still 
    if aspir.aspirable_target and otto.fight.my_targets[aspir.aspirable_target.id] then return end

    local player = windower.ffxi.get_player()
    for target_id, mob in pairs(otto.fight.my_targets) do
        local aspirable = otto.config.maspir_immunities[mob.name] == false
        local valid_target = otto.cast.is_mob_valid_target(mob, spell.aspir.range)
        local at_mp_threshhold = user_settings.aspir.casting_mp < player.vitals.mpp

        if aspirable and valid_target and at_mp_threshhold then 
            aspir.aspirable_target= mob
            return true
        end
    end

    aspir.aspirable_target = T{}
    return false
end

local function set_aspir() 
    if not aspir.aspirable_target then return end

    local spells_learned = windower.ffxi.get_spells()
    local cooldowns = windower.ffxi.get_spell_recasts()
    local tier_trying = 3

    for aspir in spell:it() do
        local learned = spells_learned[aspir.id] 
        local cooldown = cooldowns[aspir.id]

        if learned and cooldown == 0 and (user_settings.aspir.tier == tier_trying or user_settings.aspir.casts_all) then
            aspir.should_use_spell = aspir
            return
        end
        tier_trying = tier_trying - 1
    end
end

function aspir.check_loop()
    if not user_settings.aspir.enabled then return end
    if not otto.fight.my_targets and not aspir.aspirable_target then return end 

    aspir.counter = aspir.counter + aspir.check_interval

    if aspir.counter >= aspir.delay then
        aspir.counter = 0
        aspir.delay = aspir.check_interval

        if not can_cast() then return end 
        set_aspir() 
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
    	'job_ability',
    	'casting_begin',
        'spell_finish',
        'item_finish',
        'item_begin'
	 }

     local start_categories = S{ 'casting_begin', 'item_begin'}

    if not categories:contains(category) or action.param == 0 then
        return
    end
    
    local player = windower.ffxi.get_player()
    if actor_id ~= player.id then return end

    -- Casting finish
    if category == 'spell_finish' then
        aspir.delay = 5
    end

    if category == 'item_finish' then 
        aspir.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            aspir.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            aspir.delay = 2.2
        end
    end

end

return aspir