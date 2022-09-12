local aspir = T{ defaults = {}, immunities = {} }

require('luau')
require('actions')

function aspir.init()
    aspir.immunities = lor_settings.load('data/maspir_immunities.lua')
        
    aspir.defaults.tier = 3 -- the aspir tier to use.
    aspir.defaults.enabled = true -- wether or not aspir will be used.
    aspir.defaults.casting_mp = 80 -- the minimum mp at which to aspir
    aspir.defaults.casts_all = false  -- wether to cast all tiers of aspir or a single. // TODO: TC - add single, double, all
  
    return defaults
end

local spell = { 
    aspir  = {id=247,en="Aspir",ja="アスピル",cast_time=3,element=7,icon_id=238,icon_id_nq=15,levels={[4]=25,[8]=20,[20]=36,[21]=30},mp_cost=10,prefix="/magic",range=12,recast=60,recast_id=247,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir2 = {id=248,en="Aspir II",ja="アスピルII",cast_time=3,element=7,icon_id=239,icon_id_nq=15,levels={[4]=83,[8]=78,[20]=97,[21]=90},mp_cost=5,prefix="/magic",range=12,recast=11,recast_id=248,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir3 = {id=881,en="Aspir III",ja="アスピルIII",cast_time=3,element=7,icon_id=657,icon_id_nq=15,levels={[4]=550,[21]=550},mp_cost=2,prefix="/magic",range=12,recast=26,recast_id=881,requirements=0,skill=37,targets=32,type="BlackMagic"},
}

function aspir.should_cast()
    -- no target
    local player = windower.ffxi.get_player()
    if not player.target_index then return false end
   
    -- is claimed
    local mob = windower.ffxi.get_mob_by_index(player.target_index)
    if mob.claim_id == 0 then return false end
    
    -- mob has mp
    if aspir.immunities[mob.name] == false then return false end

    -- is casters mpp at threshold mpp?
    if user_settings.aspir.casting_mp < player.vitals.mpp then return false end

    -- is a valid target
    if mob.is_npc and mob.valid_target and mob.distance < 510 then 
        return true
    end
    return true
end


function aspir.check_aspir()
    if not aspir.should_cast() then return end 

	local target = windower.ffxi.get_mob_by_target()

    local aspir3_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir3.id]
    if aspir3_cooldown == 0 and (user_settings.aspir.tier == 3 or user_settings.aspir.casts_all) then
        if offense.nukes[spell.aspir3.id] == nil then
            offense.addToNukeingQueue(spell.aspir3, target)
        end
        return
    end

    local aspir2_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir2.id]
    if aspir2_cooldown == 0 and (user_settings.aspir.tier == 2 or user_settings.aspir.casts_all) then
        if offense.nukes[spell.aspir2.id] == nil then
            offense.addToNukeingQueue(spell.aspir2, target)
        end        return
    end

    local aspir_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir.id]
    if aspir_cooldown == 0 and (user_settings.aspir.tier == 1 or user_settings.aspir.casts_all) then
        if offense.nukes[spell.aspir] == nil then
            offense.addToNukeingQueue(spell.aspir, target)
        end        return
    end
end

function action_handler(raw_actionpacket)
    local actionpacket = ActionPacket.new(raw_actionpacket)
    
    if actionpacket:get_category_string() == 'spell_finish' then
        for target in actionpacket:get_targets() do -- target iterator
            for action in target:get_actions() do -- subaction iterator
                if action.message == 228 then -- aspir seems to have message 228 
                    aspir.update_DB(target:get_name(), action.param)
                end
            end
        end
    end
end

-- update the db with records of monsters who actually can be aspir'd.
function aspir.update_DB(actor, damage)
    if aspir.immunities[actor] ~= nil then return end

    local hasMP = damage ~= 0 
    aspir.immunities[actor] = hasMP

    user_settings.aspir.immunities.save(aspir.immunities)
end

ActionPacket.open_listener(action_handler)



return aspir