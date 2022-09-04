-- Copyright © 2022, Twochix
-- All rights reserved.
-- want beef.

_addon.version = '0.0.1'
_addon.name = 'otto'
_addon.author = 'Twochix'
_addon.lastUpdate = '6/11/2020'
_addon.commands = { 'otto' }

require('luau')

local otto = {}

otto.defaults = T{}
otto.defaults.tier = 0
otto.defaults.enabled = true

otto.events = require('otto_windower_events')
otto.logging = require('otto_logging')
otto.events.logger = otto.logging
otto.events.settings = settings

local magic_tiers = {
	[1] = {suffix=''},
	[2] = {suffix='II'},
	[3] = {suffix='III'},
	[4] = {suffix='IV'},
	[5] = {suffix='V'},
	[6] = {suffix='VI'}
}


settings = config.load(defaults)

local spell = { 
    aspir  = {id=247,en="Aspir",ja="アスピル",cast_time=3,element=7,icon_id=238,icon_id_nq=15,levels={[4]=25,[8]=20,[20]=36,[21]=30},mp_cost=10,prefix="/magic",range=12,recast=60,recast_id=247,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir2 = {id=248,en="Aspir II",ja="アスピルII",cast_time=3,element=7,icon_id=239,icon_id_nq=15,levels={[4]=83,[8]=78,[20]=97,[21]=90},mp_cost=5,prefix="/magic",range=12,recast=11,recast_id=248,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir3 = {id=881,en="Aspir III",ja="アスピルIII",cast_time=3,element=7,icon_id=657,icon_id_nq=15,levels={[4]=550,[21]=550},mp_cost=2,prefix="/magic",range=12,recast=26,recast_id=881,requirements=0,skill=37,targets=32,type="BlackMagic"},
}


-- Movement Handling
lastlocation = 'fff'
lastlocation = lastlocation:pack(0,0,0)
moving = false
wasmoving = false


windower.register_event('outgoing chunk', function(id,data,modified,is_injected,is_blocked)
    if id == 0x015 then
        local update = lastlocation ~= modified:sub(5, 16) 
        moving = update

        lastlocation = modified:sub(5, 16)
		wasmoving = moving
    end

end)


function otto.cast_spell(spell)
    local parsed = otto.parse_spell(spell)
    windower.send_command('input /ma "'..parsed..'" <t>')
end

function otto.parse_spell(spell) 
    
    if settings.tier > 1 then
        return spell..' '..magic_tiers[settings.tier].suffix
    end

    return spell
end

function otto.should_cast() 
    local player = windower.ffxi.get_player()
    if not player.target_index then return false end
    otto.logging.log(moving)
    local mob = windower.ffxi.get_mob_by_index(player.target_index)

    if otto.events.is_busy > 0 then return false end
    if otto.events.moving then return false end
    
    if mob.is_npc and mob.valid_target then 
        return true
    end

    -- walking
    -- is casting
    -- has target
    -- mp < 80 %

    return true
end


function otto.check_aspir()

    if not otto.should_cast() then return end 

    local aspir_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir.id]
    local aspir2_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir2.id]
    local aspir3_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir3.id]

    if aspir_cooldown == 0 and settings.tier == 1 then
        otto.cast_spell('Aspir')
        otto.events.is_busy = spell.aspir.cast_time
    end

    if aspir2_cooldown == 0 and settings.tier == 2 then
        otto.cast_spell('Aspir')
        otto.events.is_busy = spell.aspir.cast_time
    end

    if aspir3_cooldown == 0 and settings.tier == 3 then
        otto.cast_spell('Aspir')
        otto.events.is_busy = spell.aspir.cast_time
    end


end


windower.register_event('prerender', function(...)
    if settings.enabled then otto.check_aspir() end 
end)

windower.register_event('prerender', otto.events.prerender)

windower.register_event('addon command', otto.events.addon_command)



return otto
-- function event_action(act)
--     action = Action(act) -- constructor

--     -- print out all melee hits to the console
--     if actionpacket:get_category_string() == 'melee' then
--         for target in actionpacket:get_targets() do -- target iterator
--             for action in target:get_actions() do -- subaction iterator
--                 if action.message == 1 then -- 1 is the code for messages
--                     print(string.format("%s hit %s for %d damage",
--                         actionpacket:get_actor_name(), target:get_name(), action.param))
--                 end
--             end
--         end
--     end
-- end

-- windower.register_event('action message', event_action(args...)

-- )























-- local offense = {
--     immunities=config.load('data/mob_immunities.lua'),
--     assist={active = false, engage = false},
--     debuffs={}, ignored={}, mobs={}, dispel={},
--     debuffing_active = true
-- }

-- function offense.assistee_and_target()
--     if offense.assist.active and (offense.assist.name ~= nil) then
--         local partner = windower.ffxi.get_mob_by_name(offense.assist.name)
--         if partner then
--             local targ = windower.ffxi.get_mob_by_index(partner.target_index)
--             if (targ ~= nil) and targ.is_npc then
--                 return partner, targ
--             end
--         end
--     end
--     return nil
-- end

-- function offense.cleanup()
--     local mob_ids = table.keys(offense.mobs)
--     if mob_ids then
--         for _,id in pairs(mob_ids) do
--             local mob = windower.ffxi.get_mob_by_id(id)
--             if mob == nil or mob.hpp == 0 then
--                 offense.mobs[id] = nil
--             end
--         end
--     end
-- end


-- function offense.registerMob(mob, forget)
--     mob = offense.normalized_mob(mob)
--     if not mob then return end

--     if forget then
--         offense.mobs[mob.id] = nil
--         atcd(('Forgetting mob: %s [%s]'):format(mob.name, mob.id))
--     else
--         if offense.mobs[mob.id] ~= nil then
--             atcd(('Attempted to register already known mob: %s[%s]'):format(mob.name, mob.id))
--         else
--             atcd(('Registering new mob: %s[%s]'):format(mob.name, mob.id))
--         end
--         offense.mobs[mob.id] = offense.mobs[mob.id] or {}
--     end
-- end


-- function offense.normalized_mob(mob)
--     if istable(mob) then
--         return mob
--     elseif isnum(mob) then
--         return windower.ffxi.get_mob_by_id(mob)
--     end
--     return mob
-- end

-- function offense.register_immunity(mob, debuff)
--     offense.immunities[mob.name] = S(offense.immunities[mob.name]) or S{}
--     offense.immunities[mob.name]:add(debuff.id)
--     offense.immunities:save()
-- end

-- local settings = config.load(defaults)
