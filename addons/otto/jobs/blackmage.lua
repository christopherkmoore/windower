-- otto blm by TC

local blackmage = { }

function blackmage.init()
    local defaults = { enabled = false }
    defaults.enabled = false
    defaults.cooldowns = true

    if user_settings.job.blackmage == nil then
        user_settings.job.blackmage = defaults
        user_settings:save()
    end
end

-- The BLM main function.
function blackmage.check_blm()
    if not user_settings.job.blackmage.enabled then return end
    blackmage.should_drain()

end

function blackmage.should_drain()
    local should_drain = windower.ffxi.get_player().vitals.hpp < 80

    local drain = {id=245,en="Drain",ja="ドレイン",cast_time=3,element=7,icon_id=236,icon_id_nq=15,levels={[4]=12,[8]=10,[20]=21,[21]=15},mp_cost=21,prefix="/magic",range=12,recast=60,recast_id=245,requirements=2,skill=37,targets=32,type="BlackMagic"}
    local drain_cooldown = windower.ffxi.get_spell_recasts()[drain.id]

    if drain_cooldown == 0 and should_drain and not offense.checkNukingQueueFor(drain) then
        offense.addToNukeingQueue(drain)
    end
end

-- not used for now. under construction
function blackmage.blm_queue()
    if not user_settings.job.blackmage.enabled then return end

    local blm_queue = ActionQueue.new()
    local player = windower.ffxi.get_player()
    local buffs = S(player.buffs)
    
    if player.vitals.hpp < 60 then
        local manawall = {id=254,en="Mana Wall",ja="マナウォール",duration=300,element=7,icon_id=388,mp_cost=0,prefix="/jobability",range=0,recast_id=39,status=437,targets=1,tp_cost=0,type="JobAbility"}
        local manawall_recast = windower.ffxi.get_ability_recasts()[manawall.recast_id]

        if manawall_recast == 0 and not buffs:contains(manawall.status) then 
            blm_queue:enqueue('ability', manawall, player.name)
        end
    end

    if user_settings.job.blackmage.cooldowns then

        local cascade = {id=388,en="Cascade",ja="カスケード",duration=60,element=7,icon_id=661,mp_cost=0,prefix="/jobability",range=0,recast_id=12,status=598,targets=1,tp_cost=0,type="JobAbility"}
        local cascade_recast = windower.ffxi.get_ability_recasts()[cascade.recast_id]

        if player.vitals.tp >= 1000 and cascade_recast == 0 and not buffs:contains(cascade.status) then
            blm_queue:enqueue_preaction('ability', cascade, player.name)
        end
    end

    return blm_queue:getQueue()
end

return blackmage