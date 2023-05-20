-- otto blm by TC

local paladin = { }

function paladin.init()
    local defaults = { enabled = false }
    defaults.enabled = false
    defaults.cooldowns = true

    if user_settings.job.paladin == nil then
        user_settings.job.paladin = defaults
        user_settings:save()
    end
end

-- The BLM main function.
function paladin.check_pld()
    if not user_settings.job.paladin.enabled then return end

end

function paladin.should_drain()
    
end

-- -- not used for now. under construction
-- function paladin.pld_queue()
--     if not user_settings.job.paladin.enabled then return end

--     local blm_queue = ActionQueue.new()
--     local player = windower.ffxi.get_player()
--     local buffs = S(player.buffs)
    
--     if player.vitals.hpp < 60 then
--         local manawall = {id=254,en="Mana Wall",ja="マナウォール",duration=300,element=7,icon_id=388,mp_cost=0,prefix="/jobability",range=0,recast_id=39,status=437,targets=1,tp_cost=0,type="JobAbility"}
--         local manawall_recast = windower.ffxi.get_ability_recasts()[manawall.recast_id]

--         if manawall_recast == 0 and not buffs:contains(manawall.status) then 
--             blm_queue:enqueue('ability', manawall, player.name)
--         end
--     end

--     if user_settings.job.paladin.cooldowns then

--         local cascade = {id=388,en="Cascade",ja="カスケード",duration=60,element=7,icon_id=661,mp_cost=0,prefix="/jobability",range=0,recast_id=12,status=598,targets=1,tp_cost=0,type="JobAbility"}
--         local cascade_recast = windower.ffxi.get_ability_recasts()[cascade.recast_id]

--         if player.vitals.tp >= 1000 and cascade_recast == 0 and not buffs:contains(cascade.status) then
--             blm_queue:enqueue_preaction('ability', cascade, player.name)
--         end
--     end

--     return blm_queue:getQueue()
-- end

return paladin