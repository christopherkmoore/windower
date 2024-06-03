
-- otto bard by TC -- adapted from singer by Ivaar (thanks bro)



local bard = {}

bard.support = require('jobs/bard/support/support')
bard.song_timers = require('jobs/bard/support/timers')
bard.cast = require('jobs/bard/support/cast')

bard.check_interval = 0.4
bard.delay = 4
bard.counter = 0

bard.timers = {AoE={},buffs={}}
bard.party = bard.support.party()
bard.buffs = bard.support.buffs()
bard.times = {}
bard.debuffed = {}

function bard.init()
    local defaults = T{ 
        settings = T{
            enabled = false,
            build_playlist = true, -- will attempt to build a playlist from your pt.
            sleeps = true,         -- tries to use horde lullaby when there are multiple mobs.
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

    bard.support.start()
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

    if bard.counter >= bard.delay then
        bard.counter = 0
        bard.delay = bard.check_interval

        local play = windower.ffxi.get_player()
        if not play or play.main_job ~= 'BRD' or (play.status ~= 1 and play.status ~= 0) then return end
        if actor:is_moving() or bard.buffs.stun or bard.buffs.sleep or bard.buffs.charm or bard.buffs.terror or bard.buffs.petrification then return end

        local JA_WS_lock = bard.buffs.amnesia or bard.buffs.impairment

        if bard.buffs.silence or bard.buffs.mute or bard.buffs.omerta then return end

        otto.debug.create_log(bard.buffs, 'buffs')
        otto.debug.create_log(bard.times, 'buff_timers')
        -- check timers
        for k, v in pairs(bard.timers) do
            bard.song_timers.update(k)
        end

        -- check songs
        if not user_settings.job.bard.bard_settings.aoe.party or bard.support.aoe_range() then
            if bard.cast.check_song(user_settings.job.bard.songs, 'AoE', bard.buffs, JA_WS_lock) then
                return
            end
        end

        -- check song (pianissimo)
        if user_settings.job.bard.bard_settings.pianissimo then
            for targ, song in pairs(user_settings.job.bard.song) do
                local member = bard.support.party_member(targ)
                if member and bard.support.is_valid_target(member.mob, 20) then
                    if bard.cast.check_song(song, targ, bard.buffs, JA_WS_lock) then
                        return
                    end
                end
            end
        end

        -- check debuffs
        if user_settings.job.bard.bard_settings.debuffing then
            local targ = windower.ffxi.get_mob_by_target('bt')
            local spell_recasts = windower.ffxi.get_spell_recasts()

            if targ and targ.hpp > 0 and targ.valid_target and targ.distance:sqrt() < 20 then
                for song in user_settings.job.bard.debuffs:it() do
                    local effect
                    for k,v in pairs(bard.support.debuffs) do
                        if table.find(v, song) then
                            effect =  k
                            break
                        end
                    end

                    if effect and (not bard.debuffed[targ.id] or not bard.debuffed[targ.id][effect]) and spell_recasts[bard.support.song_by_name(song).id] == 0 then
                        bard.cast.MA(song,'<bt>')
                        break
                    end
                end
            end
        end

        -- check pulling
        if user_settings.pull.enabled then
            if #bard.debuffed <= otto.pull.pulling_until then 
                otto.pull.try_pulling()
            end
        end
                
        -- check sleeps
        if user_settings.job.bard.settings.sleeps then
            local mobs = windower.ffxi.get_mob_array() 
            local targets = {}
            local total_mob = 1

            -- build the entire aggro'd mob list
            for _, mob in pairs(mobs) do
                local ids = otto.getMonitoredIds()
                if mob.valid_target == true and mob.is_npc and ids:contains(mob.claim_id) then
                    targets[total_mob] = mob
                    total_mob = total_mob + 1

                end
            end
            -- table.vprint(bard.debuffed)

            -- build the slept mobs list
            -- for id, mob in pairs(bard.debuffed) do
            --     if targets[]
            -- end

            if total_mob >= 2 then 
                local random_index = math.random(1, #targets)
                local mob = targets[random_index]
                otto.assist.puller_target_and_cast(mob, 377)
                local effect = bard.song_timers.song_debuffs[2]
                bard.debuffed[mob.id] = bard.debuffed[mob.id] or {}
                bard.debuffed[mob.id][effect] = true
                otto.fight.add_target_effect(mob.id, effect)
            end
        end
    end
end


function bard.deinit() 
    utils.wipe_debufflist()
    utils.wipe_bufflist()
    user_settings.job.bard.settings.enabled = false

    windower.send_command('otto dispel off')
    windower.send_command('otto pull off')
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
        bard.delay = 5



        if bard.buffs.nightingale or bard.buffs.troubadour then 
            bard.delay = 2
        end

        local spell = bard.support.spell_by_id(action.top_level_param)
        if spell then
            bard.timers.buffs[spell.enl] = bard.timers.buffs[spell.enl] or {}
            bard.timers.buffs[spell.enl][target.name] = os.time() + spell.dur
            -- adds buff and buff duration on spell bard.cast
            return
        end

        local song = bard.support.song_name(action.top_level_param)

        if not song then return end
        local effect = target.raw.actions[1].param

        if bard.song_timers.song_buffs[effect] and not bard.buffs.pianissimo and (not user_settings.job.bard.bard_settings.aoe.party or bard.support.aoe_range()) then
            bard.song_timers.adjust(song, 'AoE', bard.buffs)
        end

        effect = target.raw.actions[1].param

        if bard.song_timers.song_buffs[effect] then
            bard.song_timers.adjust(song, windower.ffxi.get_mob_by_id(target.id).name, bard.buffs)
        elseif bard.song_timers.song_debuffs[effect] then
            effect = bard.song_timers.song_debuffs[effect]
            bard.debuffed[target.id] = bard.debuffed[target.id] or {}
            bard.debuffed[target.id][effect] = true
        end
    end

    if cateogry == 'item_finish' then 
        bard.delay = 2.2
    end

    if start_categories:contains(category) then 
        if param == 24931 then  -- Begin Casting/WS/Item/Range
            bard.delay = 4.2
            
            if bard.buffs.nightingale or bard.buffs.troubadour then 
                bard.delay = 2
            end
        end

        if param == 28787 then -- Failed Casting/WS/Item/Range
            bard.delay = 2.2
        end
    end

end

function addon_message(str)
    windower.add_to_chat(207, _addon.name..': '..str)
end

handled_commands = T{
    aoe = T{
        ['on'] = 'on',
        ['add'] = 'on',
        ['+'] = 'on',
        ['watch'] = 'on',
        ['off'] = 'off',
        ['remove'] = 'off',
        ['-'] = 'off',
        ['ignore'] = 'off',
    },
    recast = S{'buff','song'},
    clear = S{'remove','clear'},
}

short_commands = {
    ['p'] = 'pianissimo',
    ['n'] = 'nightingale',
    ['t'] = 'troubadour',
    ['play'] = 'playlist',
}

function resolve_song(commands)
    local x = tonumber(commands[#commands], 7)

    if x then commands[#commands] = {'I','II','III','IV','V','VI'}[x] end

    return bard.support.song_from_command(table.concat(commands, ' ',2))
end

function event_change()
    user_settings.job.bard.action = false
    bard.debuffed = {}
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

-- build playlist
-- sleeps
-- pulling
-- check equipment for horns?


