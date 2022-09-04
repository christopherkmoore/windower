-- Copyright © 2022, Twochix
-- All rights reserved.
-- want beef.

_addon.version = '1.0.0'
_addon.name = 'otto'
_addon.author = 'Twochix'
_addon.lastUpdate = '6/11/2020'
_addon.commands = { 'otto' }

require('luau')
require('actions')
local otto = {}

otto.defaults = T{}
otto.defaults.tier = 0
otto.defaults.enabled = true
otto.defaults.casting_mp = 100
otto.defaults.casts_all = false 

otto.events = require('otto_windower_events')
otto.settings = require('otto_settings')
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

local immunities = otto.settings.load('data/mob_immunities.lua')

local spell = { 
    aspir  = {id=247,en="Aspir",ja="アスピル",cast_time=3,element=7,icon_id=238,icon_id_nq=15,levels={[4]=25,[8]=20,[20]=36,[21]=30},mp_cost=10,prefix="/magic",range=12,recast=60,recast_id=247,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir2 = {id=248,en="Aspir II",ja="アスピルII",cast_time=3,element=7,icon_id=239,icon_id_nq=15,levels={[4]=83,[8]=78,[20]=97,[21]=90},mp_cost=5,prefix="/magic",range=12,recast=11,recast_id=248,requirements=2,skill=37,targets=32,type="BlackMagic"},
    aspir3 = {id=881,en="Aspir III",ja="アスピルIII",cast_time=3,element=7,icon_id=657,icon_id_nq=15,levels={[4]=550,[21]=550},mp_cost=2,prefix="/magic",range=12,recast=26,recast_id=881,requirements=0,skill=37,targets=32,type="BlackMagic"},
}


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
    -- is moving
    if otto.events.moving then return false end

    local player = windower.ffxi.get_player()
    -- no target
    if not player.target_index then return false end

    local mob = windower.ffxi.get_mob_by_index(player.target_index)
    -- is already casting
    if otto.events.is_busy > 0 then return false end
    
    -- is claimed
    if mob.claim_id == 0 then return false end
    
    -- mob has mp
    if immunities[mob.name] == false then return false end

    -- is a valid target
    if mob.is_npc and mob.valid_target and mob.distance < 510 and settings.casting_mp < player.vitals.mpp then 
        return true
    end

    return true
end


function otto.check_aspir()

    if not otto.should_cast() then return end 

    local aspir_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir.id]
    local aspir2_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir2.id]
    local aspir3_cooldown = windower.ffxi.get_spell_recasts()[spell.aspir3.id]

    if aspir_cooldown == 0 and (settings.tier == 1 or settings.casts_all) then
        otto.cast_spell('Aspir')
        otto.events.is_busy = spell.aspir.cast_time
    end

    if aspir2_cooldown == 0 and (settings.tier == 2 or settings.casts_all) then
        otto.cast_spell('Aspir')
        otto.events.is_busy = spell.aspir.cast_time
    end

    if aspir3_cooldown == 0 and (settings.tier == 3 or settings.casts_all) then
        otto.cast_spell('Aspir')
        otto.events.is_busy = spell.aspir.cast_time
    end



end

function action_handler(raw_actionpacket)
    local actionpacket = ActionPacket.new(raw_actionpacket)
    
    if actionpacket:get_category_string() == 'spell_finish' then
        for target in actionpacket:get_targets() do -- target iterator
            for action in target:get_actions() do -- subaction iterator
                if action.message == 228 then -- aspir seems to have message 228 
                    update_DB(target:get_name(), action.param)
                end
            end
        end
    end
end

-- update the db with records of monsters who actually can be aspir'd.
function update_DB(actor, damage)
    if immunities[actor] ~= nil then return end

    local hasMP = damage ~= 0 
    immunities[actor] = hasMP

    otto.settings.save(immunities)

end

ActionPacket.open_listener(action_handler)

windower.register_event('prerender', function(...)
    if settings.enabled then otto.check_aspir() end 
end)




windower.register_event('outgoing chunk', otto.events.determine_movement)
windower.register_event('prerender', otto.events.prerender)

windower.register_event('addon command', otto.events.addon_command)



return otto