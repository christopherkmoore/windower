-- otto blm by TC

local blackmage = { }
-- job check ticks
blackmage.check_interval = 0.4
blackmage.delay = 4
blackmage.counter = 0

function blackmage.init()
    local defaults = { enabled = false }
    defaults.enabled = false
    defaults.cooldowns = true

    if user_settings.job.blackmage == nil then
        user_settings.job.blackmage = defaults
        user_settings:save()
    end

    
    blackmage.check_blm:loop(blackmage.check_interval)
end

function blackmage.deinit()
    -- empty for now but for clearing debuffs
end

function blackmage.should_drain()
    local should_drain = windower.ffxi.get_player().vitals.hpp < 80

    local drain = {id=245,en="Drain",ja="ドレイン",cast_time=3,element=7,icon_id=236,icon_id_nq=15,levels={[4]=12,[8]=10,[20]=21,[21]=15},mp_cost=21,prefix="/magic",range=12,recast=60,recast_id=245,requirements=2,skill=37,targets=32,type="BlackMagic"}
    local drain_cooldown = windower.ffxi.get_spell_recasts()[drain.id]

    if drain_cooldown == 0 and should_drain and not offense.checkNukingQueueFor(drain) then
        offense.addToNukeingQueue(drain)
    end
end

-- The BLM main function.
function blackmage.check_blm()
    if not user_settings.job.blackmage.enabled then return end

    local player = windower.ffxi.get_player()
    local buffs = S(player.buffs)
    
    blackmage.should_drain()

    if player.vitals.hpp < 60 then
        local manawall = {id=254,en="Mana Wall",ja="マナウォール",duration=300,element=7,icon_id=388,mp_cost=0,prefix="/jobability",range=0,recast_id=39,status=437,targets=1,tp_cost=0,type="JobAbility"}
        local manawall_recast = windower.ffxi.get_ability_recasts()[manawall.recast_id]

        if manawall_recast == 0 and not buffs:contains(manawall.status) then 
            local delay = otto.cast.job_ability(manawall, '<me>')
            blackmage.delay = delay
            return
        end
    end

    if user_settings.job.blackmage.cooldowns then
        local cascade = {id=388,en="Cascade",ja="カスケード",duration=60,element=7,icon_id=661,mp_cost=0,prefix="/jobability",range=0,recast_id=12,status=598,targets=1,tp_cost=0,type="JobAbility"}
        local cascade_recast = windower.ffxi.get_ability_recasts()[cascade.recast_id]

        if player.vitals.tp >= 1000 and cascade_recast == 0 and not buffs:contains(cascade.status) then
            local delay = otto.cast.job_ability(cascade, '<me>')
            blackmage.delay = delay
            return
        end
    end

    return blm_queue:getQueue()
end

        
function blackmage.action_handler(category, action, actor_id, add_effect, target)
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

    if actor_id ~= player.id then return end

    -- Casting finish
    if category == 'spell_finish' then
        blackmage.delay = 5
    end

    if category == 'item_finish' then 
        blackmage.delay = 2.2
    end

    if start_categories:contains(category) then 
        if action.top_level_param == 24931 then  -- Begin Casting/WS/Item/Range
            blackmage.delay = 4.2
        end

        if action.top_level_param == 28787 then -- Failed Casting/WS/Item/Range
            blackmage.delay = 2.2
        end
    end

end


return blackmage