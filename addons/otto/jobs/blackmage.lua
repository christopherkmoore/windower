-- otto blm by TC

local blackmage = { }
-- job check ticks
blackmage.check_interval = 0.4
blackmage.counter = 0

function blackmage.init()
    local defaults = { enabled = false }
    defaults.enabled = false
    defaults.cooldowns = true

    if user_settings.job.blackmage == nil then
        user_settings.job.blackmage = defaults
        user_settings:save()
    end
    if user_settings.aspir.enabled then
        otto.assist.init()
    end

    user_settings.job.blackmage.enable = true

    blackmage.check_blm:loop(blackmage.check_interval)
    otto.aspir.init()

end

function blackmage.deinit()
    user_settings.job.blackmage.enable = false
    otto.aspir.deinit()

end

function blackmage.should_drain()
    local should_drain = windower.ffxi.get_player().vitals.hpp < 80
    local target = otoo.cast.party_target()
    local drain = {id=245,en="Drain",ja="ドレイン",cast_time=3,element=7,icon_id=236,icon_id_nq=15,levels={[4]=12,[8]=10,[20]=21,[21]=15},mp_cost=21,prefix="/magic",range=12,recast=60,recast_id=245,requirements=2,skill=37,targets=32,type="BlackMagic"}
    local drain_cooldown = windower.ffxi.get_spell_recasts()[drain.id]

    if target and drain_cooldown == 0 and should_drain then
        otto.cast.spell(drain, target)
        return
    end
end

local function check_aspir()
    if otto.aspir.ready.target then
        otto.cast.spell(otto.aspir.ready.spell, otto.aspir.ready.target)
        return
    end
end

-- The BLM main function.
function blackmage.check_blm()
    if not user_settings.job.blackmage.enabled then return end
    if otto.player.is_moving or otto.player.mage_disabled() then return end

    blackmage.counter = blackmage.counter + blackmage.check_interval

    if blackmage.counter >= otto.player.delay then
        blackmage.counter = 0
        otto.player.delay = blackmage.check_interval

        if user_settings.aspir.enabled then
            check_aspir()
        end

        local buffs = otto.player.my_buffs()
        
        blackmage.should_drain()

        if player.vitals.hpp < 60 then
            local manawall = {id=254,en="Mana Wall",ja="マナウォール",duration=300,element=7,icon_id=388,mp_cost=0,prefix="/jobability",range=0,recast_id=39,status=437,targets=1,tp_cost=0,type="JobAbility"}
            local recast = otto.cast.is_off_cooldown(manawall)
            
            if manawall_recast == 0 and not buffs:contains(manawall.status) then 
                otto.cast.job_ability(manawall, '<me>')
                return
            end
        end

        if user_settings.job.blackmage.cooldowns then
            local cascade = {id=388,en="Cascade",ja="カスケード",duration=60,element=7,icon_id=661,mp_cost=0,prefix="/jobability",range=0,recast_id=12,status=598,targets=1,tp_cost=0,type="JobAbility"}
            local cascade_recast = windower.ffxi.get_ability_recasts()[cascade.recast_id]

            if player.vitals.tp >= 1000 and cascade_recast == 0 and not buffs:contains(cascade.status) then
                otto.cast.job_ability(cascade, '<me>')
                return
            end
        end

        -- Check if you need to come closer to the fight
        if user_settings.assist.fight_style == 'follow_master' then
            otto.assist.come_to_master(13, 14)
        end

    end
end    

return blackmage