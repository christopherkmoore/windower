
local buffs = {
    debuff_list = {},
    buff_list = {},
    ignored_debuffs = {},
    action_buff_map = lor_settings.load('data/action_buff_map.lua')
}
local lc_res = _libs.lor.resources.lc_res


--==============================================================================
--          Input Handling Functions
--==============================================================================


function buffs.wipe_bufflist()
    buffs.buff_list = {}
end

function buffs.wipe_debufflist()
    buffs.debuff_list = {}
end


local function maintain_debuff(spell, maintain, targetName)

    buffs.debuff_list[targetName] = buffs.debuff_list[targetName] or {}

    if maintain then
        buffs.debuff_list[targetName][spell.en] = true
    else
        buffs.debuff_list[targetName][spell.en] = nil
    end

    local msg = maintain and '' or 'no longer '
    if targetName == 'AoE' then
        atcf('Will %smaintain debuff on mobs: %s', msg, spell.en)
    else
        atcf('Will %smaintain debuff on %s: %s', msg, targetName, spell.en)

    end
end

function buffs.register_offensive_debuff(args)
    local maintain = args[#args] 

    if maintain == 'on' then 
        maintain = true
    elseif maintain == 'off' then
        maintain = false
    else
        error('Could not determine buff on | off value in command. Please make sure the last word corresponds to on | off ')
    end
    table.remove(args, #args) -- pop the toggle off the table

--  pop pop                                   pop
--  otto debuff word two three buff two three on;
    local spell = {}
    local spell_guess = ''
    local count = 0
    local pop_count = 0
    for i=0, #args-1 do
        count = count + 1
        local spell_attempt = {}
        if i == 0 then
            spell_guess = args[#args - i]

            spell_attempt = res.spells:with('name', spell_guess)
        else
            spell_guess = args[#args - i]..' '..spell_guess
            spell_attempt = res.spells:with('name', spell_guess)    
        end

        if spell_attempt and spell_attempt.name then
            spell = spell_attempt
            pop_count = pop_count + 1
        end
    end -- do this horseshit because the command can get pretty complicated: EX
    -- otto debuff Stormride Surfer II Dia II on
    
    if not actor:can_use(spell) then
        atcfs(123,'Error: Unable to cast %s', arg_string)
    end

    -- finally pop off the spell (hopefully)
    for i=0, pop_count do
        table.remove(args, #args)
    end

    local arg_string = table.concat(args,' ')
    
    local targetName = ''
    
    if arg_string == nil or arg_string == '' then
        targetName = 'AoE'
    else
        targetName = arg_string
    end
    maintain_debuff(spell, maintain, targetName)
end

local function register_new_buff_name(targetName, bname, toggle)
    local target = windower.ffxi.get_mob_by_name(targetName)
    
    if not target then
        atc('Unable to find buff target: '..targetName)
        return
    end

    local spell = res.spells:with('name', bname)
    local job_ability = utils.get_job_ability(bname)
    
    buffs.buff_list[target.name] = buffs.buff_list[target.name] or {}

    if spell and actor:can_use(spell) then
        if toggle then
            buffs.buff_list[target.name][spell.en] = true 
            atc('Will maintain buff: '..spell.en..' on '..target.name)
        else
            buffs.buff_list[target.name][spell.en] = nil
            atc('Will no longer maintain buff: '..spell.en..' on '..target.name)
        end
    elseif job_ability and actor:can_use(job_ability) then
        if toggle then
            buffs.buff_list[target.name][job_ability.en] = 
            atc('Will maintain buff: '..job_ability.en..' on '..target.name)
        else
            buffs.buff_list[target.name][job_ability.en] = nil
            atc('Will no longer maintain buff: '..job_ability.en..' on '..target.name)
        end
    end
    
end

--  otto buff Chixslave Boost-STR on;
function buffs.register_new_buff(args)
    local toggle = args[#args] 

    if toggle == 'on' then 
        toggle = true
    elseif toggle == 'off' then
        toggle = false
    else
        error('Could not determine buff on | off value in command. Please make sure the last word corresponds to on | off ')
    end

    local targetName = args[1] and args[1] or ''
    table.remove(args, 1)
    table.remove(args, #args)
    local arg_string = table.concat(args,' ')
    local spell_name = arg_string:ucfirst()
    register_new_buff_name(targetName, spell_name, toggle)

end


function buffs.register_ignore_debuff(args, ignore)
    local targetName = args[1] and args[1] or ''
    table.remove(args, 1)
    local arg_string = table.concat(args,' ')
    
    local msg = ignore and 'ignore' or 'stop ignoring'
    
    local dbname = debuff_casemap[arg_string:lower()]
    if (dbname ~= nil) then
        if S{'always','everyone','all'}:contains(targetName) then
            buffs.ignored_debuffs[dbname] = {['all']=ignore}
            atc('Will now '..msg..' '..dbname..' on everyone.')
        else
            if (targetName ~= nil) then
                buffs.ignored_debuffs[dbname] = buffs.ignored_debuffs[dbname] or {['all']=false}
                if (buffs.ignored_debuffs[dbname].all == ignore) then
                    local msg2 = ignore and 'ignoring' or 'stopped ignoring'
                    atc('Ignore debuff settings unchanged. Already '..msg2..' '..dbname..' on everyone.')
                else
                    buffs.ignored_debuffs[dbname][targetName] = ignore
                    atc('Will now '..msg..' '..dbname..' on '..targetName)
                end
            else
                atc(123,'Error: Invalid target for ignore debuff: '..targetName)
            end
        end
    else
        atc(123,'Error: Invalid debuff name to '..msg..': '..arg_string)
    end
end

function buffs.buff_for_action(action)
    local action_str = action
    
    if (buff_map[action_str] ~= nil) then
        if isnum(buff_map[action_str]) then
            return res.buffs[buff_map[action_str]]
        else
            return res.buffs:with('en', buff_map[action_str])
        end
    else
        local buff = res.buffs:with('en', action_str)
        if buff ~= nil then
            return buff
        end
        buff = utils.normalize_action(action_str, 'buffs')
        if buff ~= nil then
            return buff
        end
        local buffName = action_str
        local spLoc = action_str:find(' ')
        if (spLoc ~= nil) then
            buffName = action_str:sub(1, spLoc-1)
        end
        return res.buffs:with('en', buffName)
    end
end

--==============================================================================
--    Call this for buffing
--==============================================================================


-- The main function for if you want to cast buffs
function buffs.cast()
    for target, buffs in pairs(otto.buffs.buff_list) do
        for buff, _ in pairs(buffs) do 
            local spell = res.spells:with('name', buff)
            if spell then
                local buff = res.buffs[spell.status]
                local spell_recasts = windower.ffxi.get_spell_recasts()
                local ally = otto.fight.ally_lookup(target, nil, nil)
                local has_buff = ally.buffs[buff.id] or false
                if spell and spell_recasts and spell_recasts[spell.id] == 0 and ally and not has_buff then
                    local delay = otto.cast.spell(spell, ally)
                    return delay
                end
            end

            local ja_ability = utils.get_job_ability(buff)
            if ja_ability then
                local is_ready = otto.cast.is_off_cooldown(ja_ability)
                local ally = otto.fight.ally_lookup(target, nil, nil)
                local buff = res.buffs[spell.status]
                local has_buff = ally.buffs[buff.id] or false
                
                if ja_ability and is_ready and ally and not has_buff then
                    local delay = otto.cast.job_ability(ja_ability, ally)
                    return delay
                end
            end
        end
    end
end

return buffs