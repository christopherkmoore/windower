local aspir = T{ immunities = {}, _events = {} }

require('luau')
require('actions')

local spell = { 
    aspir  = {id=247,en="Aspir",ja="アスピル",cast_time=3,element=7,icon_id=238,icon_id_nq=15,levels={[4]=25,[8]=20,[20]=36,[21]=30},mp_cost=10,prefix="/magic",range=12,recast=60,recast_id=247,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir2 = {id=248,en="Aspir II",ja="アスピルII",cast_time=3,element=7,icon_id=239,icon_id_nq=15,levels={[4]=83,[8]=78,[20]=97,[21]=90},mp_cost=5,prefix="/magic",range=12,recast=11,recast_id=248,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir3 = {id=881,en="Aspir III",ja="アスピルIII",cast_time=3,element=7,icon_id=657,icon_id_nq=15,levels={[4]=550,[21]=550},mp_cost=2,prefix="/magic",range=12,recast=26,recast_id=881,requirements=0,skill=37,targets=32,type="BlackMagic"},
}


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

end

function aspir.should_cast()
    -- no target
    local player = windower.ffxi.get_player()
    if not player.target_index then return false end
   
    -- is claimed
    local mob = windower.ffxi.get_mob_by_index(player.target_index)
    if mob.claim_id == 0 then return false end
    
    -- mob has mp
    if otto.config.maspir_immunities[mob.name] == false then return false end

    -- is casters mpp at threshold mpp?
    if user_settings.aspir.casting_mp < player.vitals.mpp then return false end

    -- is a valid target
    if mob.is_npc and mob.valid_target and mob.distance < 510 then 
        return true
    end
    return true
end

-- Prerender entry point. Steps through with early returns for if aspir should be added to the
-- offensive nuking queue.
function aspir.prerender()
    if not aspir.should_cast() then return end 

    local aspir3_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir3.id]
    if aspir3_cooldown == 0 and (user_settings.aspir.tier == 3 or user_settings.aspir.casts_all) and not offense.checkNukingQueueFor(spell.aspir3) then
        if offense.nukes[spell.aspir3.id] == nil then
            offense.addToNukeingQueue(spell.aspir3)
            return
        end
    end

    local aspir2_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir2.id]
    if aspir2_cooldown == 0 and (user_settings.aspir.tier == 2 or user_settings.aspir.casts_all) and not offense.checkNukingQueueFor(spell.aspir2) then
        if offense.nukes[spell.aspir2.id] == nil then
            offense.addToNukeingQueue(spell.aspir2)
            return
        end        
    end

    local aspir_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir.id]
    if aspir_cooldown == 0 and (user_settings.aspir.tier == 1 or user_settings.aspir.casts_all) and not offense.checkNukingQueueFor(spell.aspir3) then
        if offense.nukes[spell.aspir] == nil then
            offense.addToNukeingQueue(spell.aspir)
            return
        end        
    end
end

-- update the db with records of monsters who actually can be aspir'd.
local function update_DB(actor, damage)
    if otto.config.maspir_immunities[actor] ~= nil then return end

    local hasMP = damage ~= 0 
    otto.config.maspir_immunities[actor] = hasMP

    otto.config.maspir_immunities.save(otto.config.maspir_immunities)
end

function aspir.action_handler(raw_actionpacket)
    local actionpacket = ActionPacket.new(raw_actionpacket)
    
    if actionpacket:get_category_string() == 'spell_finish' then
        for target in actionpacket:get_targets() do -- target iterator
            for action in target:get_actions() do -- subaction iterator
                if messages_aspir:contains(action.message) then -- aspir seems to have message 228 
                    update_DB(target:get_name(), action.param)
                end
            end
        end
    end
end

aspir._events['prerender'] = windower.register_event('prerender', aspir.prerender)

return aspir