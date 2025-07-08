--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot buff handling functions
--]]

-- modifications made by TC
--==============================================================================

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


local function maintain_debuff(spell, maintain)
    local nspell = utils.normalize_action(spell, 'spells')
    if not nspell then
        atcfs(123, '[offense.maintain_debuff] Invalid spell: %s', spell)
        return
    end
    local debuff_id = spell_debuff_idmap[nspell.id]

    if debuff_id == nil then
        atcfs(123, 'Unable to find debuff for spell: %s', spell)
        return
    end
    local debuff = res.buffs[debuff_id]
    if maintain then
        buffs.debuff_list[nspell.name] = true
        otto.debug.create_log(buffs.debuff_list, 'debugger')
    else
        buffs.debuff_list[nspell.name] = nil
        otto.debug.create_log(buffs.debuff_list, 'debugger')
    end

    local msg = maintain and '' or 'no longer '
    atcf('Will %smaintain debuff on mobs: %s', msg, nspell.en)
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
    local arg_string = table.concat(args,' ')
    local spell = res.spells:with('name', arg_string)

    if (spell ~= nil) then
        if actor:can_use(spell) then
            maintain_debuff(spell, maintain)

        else
            atcfs(123,'Error: Unable to cast %s', spell.en)
        end
    else
        atcfs(123,'Error: Invalid spell name: %s', spell_name)
    end
end

local function register_new_buff_name(targetName, bname, toggle)
    local spell = res.spells:with('name', bname)

    if not spell then
        atc('Error: Unable to parse spell name')
        return
    end
    local target = windower.ffxi.get_mob_by_name(targetName)
    if not target then
        atc('Unable to find buff target: '..targetName)
        return
    end

    local action = buffs.getAction(spell.name, target)
    if not action then
        atc('Unable to cast or invalid: '..spell.name)
        return
    end
    
    buffs.buff_list[target.name] = buffs.buff_list[target.name] or {}
    local buff = buffs.buff_for_action(action)
    if (buff == nil) then
        atc('Unable to match the buff name to an actual buff: '..bname)
        return
    end
    
    if toggle then
        buffs.buff_list[target.name][action.en] = {['action']=action, ['maintain']=true, ['buff']=buff}
        if action.type == 'Geomancy' then
            if indi_spell_ids:contains(action.id) then
                buffs.buff_list[target.name][action.en].is_indi = true
            elseif geo_spell_ids:contains(action.id) then
                buffs.buff_list[target.name][action.en].is_geo = true
            end
        end
        atc('Will maintain buff: '..action.en..' '..rarr..' '..target.name)
    else
        buffs.buff_list[target.name][action.en] = nil
        atc('Will no longer maintain buff: '..action.en..' '..rarr..' '..target.name)
    end
end

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

    register_new_buff_name(targetName, arg_string, toggle)

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


function buffs.getAction(actionName, target)
    local me = windower.ffxi.get_player()
    local action = nil
    local spell = res.spells:with('en', actionName)
    if (spell ~= nil) and actor:can_use(spell) then
        action = spell
    elseif (target ~= nil) and (target.id == me.id) then
        local abil = res.job_abilities:with('en', actionName)
        if (abil ~= nil) and actor:can_use(abil) then
            action = abil
        end
    end
    return action
end

function buffs.buff_for_action(action)
    local action_str = action
    
    if (buff_map[action_str] ~= nil) then
        if isnum(buff_map[action_str]) then
            return res.buffs[buff_map[action_str]]
        else
            return res.buffs:with('en', buff_map[action_str])
        end
    elseif action_str:match('^Protectr?a?%s?I*V?$') then
        return res.buffs[40]
    elseif action_str:match('^Shellr?a?%s?I*V?$') then
        return res.buffs[41]
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

return buffs