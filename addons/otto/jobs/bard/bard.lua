
-- otto bard by TC -- adapted from singer by Ivaar (thanks bro)

local bard = {}

bard.support = require('jobs/bard/support/support')
bard.song_timers = require('jobs/bard/support/timers')
bard.cast = require('jobs/bard/support/cast')

bard.check_interval = 0.4
bard.counter = 0

bard.timers = {AoE={},buffs={}}
bard.party = bard.support.party()
bard.buffs = bard.support.buffs()
bard.times = {}


--- Notes for construction
-- ideas: auto playlist creation (look at jobs), adapt to conditions (mages MP Low, swap to 2 ballads?) Etudes?

function bard.init()
    local defaults = T{ 
        settings = T{
            enabled = false,
            sleeps = true,     -- tries to use horde lullaby when there are multiple mobs.
            dispels = true,
            fight_type = 'xp'  -- xp, boss, savetimers (will basically change the bard_settings to appropriate categories.)
        },
        debuffs = {"Carnage Elegy","Light Threnody II",},
        dummy = {"Knight's Minne"},
        songs = {"Valor Minuet IV","Valor Minuet V","Victory March",},
        song = T{["Chixslave"] = L{"Mage's Ballad III",}},
        playlist = T{
            clear = L{}
        },
        bard_settings = {
            marcato=false,
            soul_voice=false,
            clarion=false,
            pianissimo=true,
            nightingale=true,
            troubadour=true,
            debuffing=true,
            recast=20,
            aoe={['party']=true, ['p1'] = true,['p2'] = true,['p3'] = true,['p4'] = true,['p5'] = true},
        }
    }
    
    if user_settings.job.bard == nil then
        user_settings.job.bard = defaults
        print('defaults saved')
        user_settings:save()
    end

    otto.assist.init()
    bard.support.start()
    user_settings.job.bard.settings.enabled = true
    bard.check_bard:loop(bard.check_interval)
end

function bard.check_fight_type() 
    local type = user_settings.job.bard.settings.fight_type
    if type == 'xp' then
        user_settings.job.bard.bard_settings.soul_voice = true 
        user_settings.job.bard.bard_settings.marcato = true
        user_settings.job.bard.bard_settings.clarion = true
        user_settings.job.bard.bard_settings.pianissimo = true
        user_settings.job.bard.bard_settings.nightingale = true
        user_settings.job.bard.bard_settings.troubadour = true
        user_settings.job.bard.bard_settings.debuffing = true
    elseif type == 'boss' then 
        user_settings.job.bard.bard_settings.soul_voice = true
        user_settings.job.bard.bard_settings.marcato = true
        user_settings.job.bard.bard_settings.clarion = true
        user_settings.job.bard.bard_settings.pianissimo = true
        user_settings.job.bard.bard_settings.nightingale = true
        user_settings.job.bard.bard_settings.troubadour = true
        user_settings.job.bard.bard_settings.debuffing = true
    elseif type == 'savetimers' then
        user_settings.job.bard.bard_settings.soul_voice = false
        user_settings.job.bard.bard_settings.marcato = false
        user_settings.job.bard.bard_settings.clarion = false
        user_settings.job.bard.bard_settings.pianissimo = true
        user_settings.job.bard.bard_settings.nightingale = false
        user_settings.job.bard.bard_settings.troubadour = false
        user_settings.job.bard.bard_settings.debuffing = false
    elseif type == 'normal' then
        user_settings.job.bard.bard_settings.soul_voice = false
        user_settings.job.bard.bard_settings.marcato = false
        user_settings.job.bard.bard_settings.clarion = false
        user_settings.job.bard.bard_settings.pianissimo = true
        user_settings.job.bard.bard_settings.nightingale = true
        user_settings.job.bard.bard_settings.troubadour = true
        user_settings.job.bard.bard_settings.debuffing = true
    end
end

function bard.check_bard()
    if not user_settings.job.bard.settings.enabled then return end
    bard.party = bard.support.party()

    bard.counter = bard.counter + bard.check_interval

    if bard.counter >= otto.player.delay then
        bard.counter = 0
        otto.player.delay = bard.check_interval

        if otto.player.is_moving or otto.player.mage_disabled() then return end

        local JA_WS_lock = bard.buffs.amnesia or bard.buffs.impairment

        if bard.buffs.silence or bard.buffs.mute or bard.buffs.omerta then return end
        
        local total_mob = 0        -- all the below should add up to total mobs, needs_sleep should be 0
        local total_sleeps = 0
        local fighting_targets = 1 -- you're always at least fighting on mob, so reduce the needs sleep
        local unsleepable_targets = 0
        local not_sleeping = T{ }

        -- check timers
        for k, v in pairs(bard.timers) do
            bard.song_timers.update(k)
        end

        -- check sleeps
        if user_settings.job.bard.settings.sleeps and otto.fight.my_targets ~= {} then
            -- update this to look at the 'fighting status'
            for index, mob in pairs(otto.fight.my_targets) do 
                total_mob = total_mob + 1

                local unsleepable = otto.config.sleep_immunities[mob.name] or false
                if unsleepable or otto.cast.has_DoT(mob) then --CKM TEST
                    unsleepable_targets = unsleepable_targets + 1
                end

                if mob.debuffs['sleep'] then
                    total_sleeps = total_sleeps + 1
                elseif not unsleepable then
                    if mob.engaged == 'agro' and not otto.cast.has_DoT(mob) then --CKM TEST
                        not_sleeping[mob.id] = true
                    end
                end
            end

            local needs_sleep = (total_mob - total_sleeps) - (fighting_targets - unsleepable_targets)
            -- count the total amount of mobs vs the amount slept
            -- if there needs to be a sleep spell, target a random, nonslept mob
            if needs_sleep >= 1 then 
                local random = math.random(1, needs_sleep)
                local counter = 1
                for mob_id, _ in pairs(not_sleeping) do
                    local mob = otto.fight.my_targets[mob_id]
                    if counter == random and otto.cast.is_mob_valid_target(mob, 19) then
                        -- eventually need to work on this to be swap target
                        -- assist needs to be expanded to start targeting my_targets
                        otto.assist.puller_target_and_cast(mob, 377) 
                        return
    
                    end
                    counter = counter + 1
                end
            end
        end

        -- check pulling
        if user_settings.pull.enabled then
            otto.pull.try_pulling()
        end

        -- dispel
        local magic_finale = res.spells[462]
        otto.dispel.should_dispel(magic_finale)

        -- check songs
        if not user_settings.job.bard.bard_settings.aoe.party or bard.support.aoe_range() then
            if bard.cast.check_song(user_settings.job.bard.songs, 'AoE', bard.buffs, JA_WS_lock) then
                return
            end
        end
        
        -- check song (pianissimo) 
        -- note: order does matter, pianissimo should come after check normal songs
        if user_settings.job.bard.bard_settings.pianissimo then
            for targ, song in pairs(user_settings.job.bard.song) do
                local member = bard.support.party_member(targ)
        
                if member and member.mob and bard.support.is_valid_target(member.mob, 20) then
                    if bard.cast.check_song(song, targ, bard.buffs, JA_WS_lock) then
                        return
                    end
                end
            end
        end

        -- Check if you need to come closer to the fight
        if user_settings.assist.fight_style == 'follow_master' then
            otto.assist.come_to_master(8, 5)
        end

        -- check debuffs 
        otto.debuffs.cast()
        -- if user_settings.job.bard.bard_settings.debuffing then
        --     for _, mob in pairs(otto.fight.my_targets) do
        --         if mob and otto.cast.is_mob_valid_target(mob, 20) then
        --             for song in user_settings.job.bard.debuffs:it() do
        --                 local spell = res.spells:with('name', song)
        --                 local debuff = res.buffs[spell.status]
        --                 local spell_recasts = windower.ffxi.get_spell_recasts()
        --                 local has_debuff = mob['debuffs'][debuff.en] or false

        --                 if spell and spell_recasts and spell_recasts[spell.id] == 0 and mob and not has_debuff then
        --                     otto.cast.spell(spell, mob)
        --                     return
        --                 end
        --             end
        --         end
        --     end
        -- end
    end
end


function bard.deinit() 
    user_settings.job.bard.settings.enabled = false
    windower.send_command('otto dispel off')
    windower.send_command('otto pull off')
    windower.send_command('otto bard debuff clear')
end

function bard.action_handler(category, action, actor_id, add_effect, target)
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

    if actor_id ~= bard.support.player_id then return end

    -- Casting finish
    if category == 'spell_finish' then
        local song = bard.support.song_name(action.top_level_param)

        if not song then return end
        local effect = target.raw.actions[1].param

        if bard.song_timers.song_buffs[effect] and not bard.buffs.pianissimo and (not user_settings.job.bard.bard_settings.aoe.party or bard.support.aoe_range()) then
            bard.song_timers.adjust(song, 'AoE', bard.buffs)
        end

        effect = target.raw.actions[1].param

        if bard.song_timers.song_buffs[effect] then
            bard.song_timers.adjust(song, windower.ffxi.get_mob_by_id(target.id).name, bard.buffs)
        end
    end
end

function event_change()
    user_settings.job.bard.action = false
    bard.song_timers.reset()
end

function status_change(new,old)
    if new == 2 or new == 3 then
        event_change()
    end
end

windower.register_event('unload', bard.song_timers.reset)
windower.register_event('status change', status_change)
windower.register_event('zone change','job change','logout', event_change)

return bard
