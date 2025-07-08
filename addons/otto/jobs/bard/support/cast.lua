local cast = {}


function cast.check_song(song_list,targ,buffs,JA_WS_lock)
    local maxsongs = otto.bard.support.maxsongs(targ,buffs)
    local currsongs = otto.bard.timers[targ] and table.length(otto.bard.timers[targ]) or 0
    local basesongs = otto.bard.support.base_songs
    local min_recast = user_settings.job.bard.bard_settings.recast
    local ta = targ == 'AoE' and '<me>' or targ

    local spell_recasts = windower.ffxi.get_spell_recasts()
    local ability_recasts = windower.ffxi.get_ability_recasts()

    if actor:is_moving() then return false end
    if basesongs > 2 and currsongs < maxsongs and #song_list > currsongs then
        for i = 1, #user_settings.job.bard.dummy do
            local song = user_settings.job.bard.dummy[i]

            if basesongs - i >= 0 and currsongs == maxsongs - i and spell_recasts[otto.bard.support.song_by_name(song).id] <= 0 then
                windower.send_command(('input /ma "%s" %s'):format(song,ta))
                otto.bard.delay = 3
            end
        end
    end

    for i = 1, math.min(#song_list, maxsongs) do
        local song = otto.bard.support.song_by_name(song_list[i])

        if song and spell_recasts[song.id] <= 0 and
            (not otto.bard.timers[targ] or not otto.bard.timers[targ][song.enl] or
            os.time() - otto.bard.timers[targ][song.enl].ts + min_recast > 0 or
            (buffs.troubadour and not otto.bard.timers[targ][song.enl].nt) or
            (buffs['soul voice'] and not otto.bard.timers[targ][song.enl].sv)) then

            -- do soul voice, marcato or clarion call
            if not JA_WS_lock and user_settings.job.bard.bard_settings.soul_voice and not buffs['soul voice'] and ability_recasts[0] <= 0 then
                for targ, songs in pairs(otto.bard.timers) do
                    for song in pairs(songs) do
                        otto.bard.timers[targ][song].sv = false
                    end
                end
                windower.send_command('input /ja "Soul Voice" <me>')
                otto.bard.delay = 1.2
            end

            if not JA_WS_lock and user_settings.job.bard.bard_settings.clarion and not buffs['clarion call'] and ability_recasts[254] <= 0 then
                windower.send_command('input /ja "Clarion Call" <me>')
                otto.bard.delay = 1.2
            end


            if ta == '<me>' and user_settings.job.bard.bard_settings.nightingale and not JA_WS_lock and not buffs.nightingale and ability_recasts[109] <= 0 and ability_recasts[110] <= 0 then
                windower.send_command('input /ja "Nightingale" <me>')
                otto.bard.delay = 1.2
            elseif ta == '<me>' and user_settings.job.bard.bard_settings.troubadour and not JA_WS_lock and not buffs.troubadour and ability_recasts[110] <= 0 then
                for targ, songs in pairs(otto.bard.timers) do
                    for song in pairs(songs) do
                        otto.bard.timers[targ][song].nt = false
                    end
                end
                windower.send_command('input /ja "Troubadour" <me>')
                otto.bard.delay = 1.2
            elseif ta ~= '<me>' and not buffs.pianissimo then 
                if not JA_WS_lock and ability_recasts[112] <= 0 then
                    windower.send_command('input /ja "Pianissimo" <me>')
                    otto.bard.delay = 1.2
                end
            else
                windower.send_command(('input /ma "%s" %s'):format(song.enl,ta))
                otto.bard.delay = 3
            end
            return true
        end
    end
end

return cast
