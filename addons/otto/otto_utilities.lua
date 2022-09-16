--==============================================================================
--[[
    Author: Ragnarok.Lorand
    HealBot utility functions that don't belong anywhere else
--]]
--==============================================================================
--          Input Handling Functions
--==============================================================================

utils = {normalize={}}
local lor_res = _libs.lor.resources
local lc_res = lor_res.lc_res
local ffxi = _libs.lor.ffxi


function utils.normalize_str(str)
    return str:lower():gsub(' ', '_'):gsub('%.', '')
end


function utils.normalize_action(action, action_type)
    --atcf('utils.normalize_action(%s, %s)', tostring(action), tostring(action_type))
    if istable(action) then return action end
    if action_type == nil then return nil end
    if isstr(action) then
        if tonumber(action) == nil then
            local naction = res[action_type]:with('en', action)
            if naction ~= nil then
                --atcf("res.%s[%s] found for %s", action_type, naction.id, action)
                return naction
            end
            --atcf("Searching resources for normalized name for %s [%s]", action, action_type)
            return res[action_type]:with('enn', utils.normalize_str(action))
        end
        action = tonumber(action) 
    end
    if isnum(action) then
        return res[action_type][action]
    end
    --atcf("Unable to normalize: '%s'[%s] (%s)", tostring(action), type(action), tostring(action_type))
    return nil
end


function utils.strip_roman_numerals(str)
    --return str:sub(1, str:find('I*V?X?I*V?I*$')):trim()
    return str:match('^%s*(.-)%s*I*V?X?I*V?I*$')
end


--[[
    Add an 'enn' (english, normalized) entry to each relevant resource
--]]
local function normalize_action_names()
    local categories = {'spells', 'job_abilities', 'weapon_skills', 'buffs'}
    for _,cat in pairs(categories) do
        for id,entry in pairs(res[cat]) do
            res[cat][id].enn = utils.normalize_str(entry.en)
            res[cat][id].ja = nil
            res[cat][id].jal = nil
        end
    end
end
normalize_action_names()


utils.txtbox_cmd_map = {
    moveinfo = 'moveInfo',          actioninfo = 'actionInfo',
    showq = 'actionQueue',          showqueue = 'actionQueue',
    queue = 'actionQueue',          monitored = 'montoredBox',
    showmonitored = 'montoredBox',
}


local function _get_player_id(player_name)
    local player_mob = windower.ffxi.get_mob_by_name(player_name)
    if player_mob then
        return player_mob.id
    end
    return nil
end
utils.get_player_id = _libs.lor.advutils.scached(_get_player_id)


function utils.register_offensive_debuff(args, cancel)
    local argstr = table.concat(args,' ')
    local spell_name = utils.formatActionName(argstr)
    local spell = lor_res.action_for(spell_name)

    if (spell ~= nil) then
        if actor:can_use(spell) then
            offense.maintain_debuff(spell, cancel)
        else
            atcfs(123,'Error: Unable to cast %s', spell.en)
        end
    else
        atcfs(123,'Error: Invalid spell name: %s', spell_name)
    end
end


function utils.register_spam_action(args)
    local argstr = table.concat(args,' ')
    local action_name = utils.formatActionName(argstr)
    local action = lor_res.action_for(action_name)
    if (action ~= nil) then
        if actor:can_use(action) then
            settings.spam.name = action.en
            atcfs('Will now spam %s', settings.spam.name)
        else
            atcfs(123,'Error: Unable to cast %s', action.en)
        end
    else
        atcfs(123,'Error: Invalid action name: %s', action_name)
    end
end


function utils.register_ws(args)
    local argstr = table.concat(args,' ')
    local wsname = utils.formatActionName(argstr)
    local ws = lor_res.action_for(wsname)
    if (ws ~= nil) then
        settings.ws.name = ws.en
        atcfs('Will now use %s', ws.en)
    else
        atcfs(123,'Error: Invalid weaponskill name: %s', wsname)
    end
end


function utils.apply_bufflist(args)
    local mj = windower.ffxi.get_player().main_job
    local sj = windower.ffxi.get_player().sub_job
    local job = ('%s/%s'):format(mj, sj)
    local bl_name = args[1]
    local bl_target = args[2]
    if bl_target == nil and bl_name == 'self' then
        bl_target = 'me'
    end
    local buff_list = table.get_nested_value(otto.config.buff_lists, {job, job:lower(), mj, mj:lower()}, bl_name)
    
    buff_list = buff_list or otto.config.buff_lists[bl_name]
    if buff_list ~= nil then
        for _,buff in pairs(buff_list) do
            buffs.registerNewBuff({bl_target, buff}, true)
        end
    else
        atc('Error: Invalid argument specified for BuffList: '..bl_name)
    end
end

function utils.wipe_bufflist()
    buffs.buffList = {}
end

function utils.wipe_debufflist()
    offense.debuffs = {}
end


function utils.posCommand(boxName, args)
    if (args[1] == nil) or (args[2] == nil) then return false end
    local cmd = args[1]:lower()
    if not S{'pos','posx','posy'}:contains(cmd) then
        return false
    end
    local x,y = tonumber(args[2]),tonumber(args[3])
    if (cmd == 'pos') then
        if (x == nil) or (y == nil) then return false end
        settings.textBoxes[boxName].x = x
        settings.textBoxes[boxName].y = y
    elseif (cmd == 'posx') then
        if (x == nil) then return false end
        settings.textBoxes[boxName].x = x
    elseif (cmd == 'posy') then
        if (y == nil) then return false end
        settings.textBoxes[boxName].y = y
    end
    return true
end

function utils.toggleVisible(boxName, cmd)
    cmd = cmd and cmd:lower() or (settings.textBoxes[boxName].visible and 'off' or 'on')
    if (cmd == 'on') then
        settings.textBoxes[boxName].visible = true
    elseif (cmd == 'off') then
        settings.textBoxes[boxName].visible = false
    else
        atc(123,'Invalid argument for changing text box settings: '..cmd)
    end
end

function utils.toggleX(tbl, field, cmd, msg, msgErr)
    if (tbl[field] == nil) then
        atcf(123, 'Error: Invalid mode to toggle: %s', field)
        return
    end
    cmd = cmd and cmd:lower() or (tbl[field] and 'off' or 'on')
    if (cmd == 'on') then
        tbl[field] = true
        atc(msg..' is now on.')
    elseif (cmd == 'off') then
        tbl[field] = false
        atc(msg..' is now off.')
    else
        atc(123,'Invalid argument for '..msgErr..': '..cmd)
    end
end

function toggleMode(mode, cmd, msg, msgErr)
    utils.toggleX(otto.modes, mode, cmd, msg, msgErr)
    _libs.lor.debug = otto.modes.debug
end

function utils.disableCommand(cmd, disable)
    local msg = ' is now '..(disable and 'disabled.' or 're-enabled.')
    if S{'cure','cures','curing'}:contains(cmd) then
        if (not disable) then
            if (settings.maxCureTier == 0) then
                settings.disable.cure = true
                atc(123,'Error: Unable to enable curing because you have no Cure spells available.')
                return
            end
        end
        settings.disable.cure = disable
        atc('Curing'..msg)
    elseif S{'curaga'}:contains(cmd) then
        settings.disable.curaga = disable
        atc('Curaga use'..msg)
    elseif S{'na','heal_debuff','cure_debuff'}:contains(cmd) then
        settings.disable.na = disable
        atc('Removal of status effects'..msg)
    elseif S{'buff','buffs','buffing'}:contains(cmd) then
        settings.disable.buff = disable
        atc('Buffing'..msg)
    elseif S{'debuff','debuffs','debuffing'}:contains(cmd) then
        settings.disable.debuff = disable
        atc('Debuffing'..msg)
    elseif S{'spam','nuke','nukes','nuking'}:contains(cmd) then
        settings.disable.spam = disable
        atc('Spamming'..msg)
    elseif S{'ws','weaponskill','weaponskills','weaponskilling'}:contains(cmd) then
        settings.disable.ws = disable
        atc('Weaponskilling'..msg)
    else
        atc(123,'Error: Invalid argument for disable/enable: '..cmd)
    end
end

function monitorCommand(cmd, pname)
    if (pname == nil) then
        atc('Error: No argument specified for '..cmd)
        return
    end
    local name = utils.getPlayerName(pname)
    if cmd == 'ignore' then
        if (not otto.ignoreList:contains(name)) then
            otto.ignoreList:add(name)
            atc('Will now ignore '..name)
            if otto.extraWatchList:contains(name) then
                otto.extraWatchList:remove(name)
            end
        else
            atc('Error: Already ignoring '..name)
        end
    elseif cmd == 'unignore' then
        if (otto.ignoreList:contains(name)) then
            otto.ignoreList:remove(name)
            atc('Will no longer ignore '..name)
        else
            atc('Error: Was not ignoring '..name)
        end
    elseif cmd == 'watch' then
        if (not otto.extraWatchList:contains(name)) then
            otto.extraWatchList:add(name)
            atc('Will now watch '..name)
            if otto.ignoreList:contains(name) then
                otto.ignoreList:remove(name)
            end
        else
            atc('Error: Already watching '..name)
        end
    elseif cmd == 'unwatch' then
        if (otto.extraWatchList:contains(name)) then
            otto.extraWatchList:remove(name)
            atc('Will no longer watch '..name)
        else
            atc('Error: Was not watching '..name)
        end
    end
end

function validate(args, numArgs, message)
    for i = 1, numArgs do
        if (args[i] == nil) then
            atc(message..' ('..i..')')
            return false
        end
    end
    return true
end

function utils.getPlayerName(name)
    local target = ffxi.get_target(name)
    if target ~= nil then
        return target.name
    end
    return nil
end

--==============================================================================
--          String Formatting Functions
--==============================================================================

function utils.formatActionName(text)
    if (type(text) ~= 'string') or (#text < 1) then return nil end
    
    local fromAlias = otto.config.aliases[text]
    if (fromAlias ~= nil) then
        return fromAlias
    end
    
    local spell_from_lc = lc_res.spells[text:lower()]
    if spell_from_lc ~= nil then
        return spell_from_lc.en
    end
    
    local parts = text:split(' ')
    if #parts >= 2 then
        local name = formatName(parts[1])
        for p = 2, #parts do
            local part = parts[p]
            local tier = toRomanNumeral(part) or part:upper()
            if (roman2dec[tier] == nil) then
                name = name..' '..formatName(part)
            else
                name = name..' '..tier
            end
        end
        return name
    else
        local name = formatName(text)
        local tier = text:sub(-1)
        local rnTier = toRomanNumeral(tier)
        if (rnTier ~= nil) then
            return name:sub(1, #name-1)..' '..rnTier
        else
            return name
        end
    end
end

function formatName(text)
    if (text ~= nil) and (type(text) == 'string') then
        return text:lower():ucfirst()
    end
    return text
end

function toRomanNumeral(val)
    if type(val) ~= 'number' then
        if type(val) == 'string' then
            val = tonumber(val)
        else
            return nil
        end
    end
    return dec2roman[val]
end


--==============================================================================
--          Initialization Functions
--==============================================================================

function utils.load_configs()
    local defaults = {
        textBoxes = {
            actionQueue={x=-125,y=300,font='Arial',size=10,visible=true},
            moveInfo={x=0,y=18,visible=false},
            actionInfo={x=0,y=0,visible=true},
            montoredBox={x=-150,y=600,font='Arial',size=10,visible=true}
        }
    }
    local loaded = lor_settings.load('data/settings.lua', defaults)
    local player = windower.ffxi.get_player()
    user_settings = lor_settings.load('data/'..player.name..'/user_settings.lua')

    utils.update_settings(loaded)
    utils.refresh_textBoxes()
    
    local cure_potency_defaults = {
        cure = {94,207,469,880,1110,1395},  curaga = {150,313,636,1125,1510},
        waltz = {157,325,581,887,1156},     waltzga = {160,521}
    }
    local buff_lists_defaults = {       self = {'Haste II','Refresh II'},
        whm = {self={'Haste','Refresh'}}, rdm = {self={'Haste II','Refresh II'}}
    }
    
    otto.config = {
        aliases = config.load('../shortcuts/data/aliases.xml'),
        mabil_debuffs = lor_settings.load('data/mabil_debuffs.lua'),
        buff_lists = lor_settings.load('data/buffLists.lua', buff_lists_defaults),
        priorities = lor_settings.load('data/priorities.lua'),
        cure_potency = lor_settings.load('data/cure_potency.lua', cure_potency_defaults),
        maspir_immunities = lor_settings.load('data/maspir_immunities.lua'),
        ipc_monitored_boxes = lor_settings.load('data/ipc_monitored_boxes.lua')
    }

    if otto.config.ipc_monitored_boxes:empty() or not otto.config.ipc_monitored_boxes:contains(player) then
        otto.config.ipc_monitored_boxes[player.name] = true
        otto.config.ipc_monitored_boxes:save()
    end

    otto.config.priorities.players =        otto.config.priorities.players or {}
    otto.config.priorities.jobs =           otto.config.priorities.jobs or {}
    otto.config.priorities.status_removal = otto.config.priorities.status_removal or {}
    otto.config.priorities.buffs =          otto.config.priorities.buffs or {}
    otto.config.priorities.debuffs =        otto.config.priorities.debuffs or {}
    otto.config.priorities.dispel =         otto.config.priorities.dispel or {}     --not implemented yet
    otto.config.priorities.default =        otto.config.priorities.default or 5
    --process_mabil_debuffs()
    local msg = otto.configs_loaded and 'Rel' or 'L'
    otto.configs_loaded = true
    atcc(262, msg..'oaded config files.')
end


function process_mabil_debuffs()
    local debuff_names = table.keys(otto.config.mabil_debuffs)
    for _,abil_raw in pairs(debuff_names) do
        local abil_fixed = abil_raw:gsub('_',' '):capitalize()
        otto.config.mabil_debuffs[abil_fixed] = S{}
        local debuffs = otto.config.mabil_debuffs[abil_raw]
        for _,debuff in pairs(debuffs) do
            otto.config.mabil_debuffs[abil_fixed]:add(debuff)
        end
        otto.config.mabil_debuffs[abil_raw] = nil
    end
    otto.config.mabil_debuffs:save()
end


function utils.update_settings(loaded)
    for key,val in pairs(loaded) do
        if istable(val) then
            settings[key] = settings[key] or {}
            for skey,sval in pairs(val) do
                settings[key][skey] = sval
            end
        else
            settings[key] = settings[key] or val
        end
    end
    table.update_if_not_set(settings, {
        disable = {},
        follow = {delay = 0.08, distance = 3},
        healing = {minCure = 3, minCuraga = 1, minWaltz = 2, minWaltzga = 1},
        spam = {}
    })
end

function utils.refresh_textBoxes()
    local boxes = {'actionQueue','moveInfo','actionInfo','montoredBox'}
    for _,box in pairs(boxes) do
        local bs = settings.textBoxes[box]
        local bst = {pos={x=bs.x, y=bs.y}}
        bst.flags = {right=(bs.x < 0), bottom=(bs.y < 0)}
        if (bs.font ~= nil) then
            bst.text = {font=bs.font}
        end
        if (bs.size ~= nil) then
            bst.text = bst.text or {}
            bst.text.size = bs.size
        end
        
        if (otto.txts[box] ~= nil) then
            otto.txts[box]:destroy()
        end
        otto.txts[box] = texts.new(bst)
    end
end

-- This ended up being some fucking jank. because each person has to hold their own state but know about updates
-- from the other boxes, I added a setting to save all the boxes otto runs on, then I can iterate and update
-- them all for changes and merge the tables for slaves together. That way a person using the CLI doesn't have to enter
-- in the same commands multiple times. I also just duplicated the loop too because someone in my monitored boxes group was 
-- empty after a single iteration.
function utils.unionSettings(secondIteration) 
    for player, _ in pairs(otto.config.ipc_monitored_boxes) do
        if not (player == windower.ffxi.get_player().name) then 

            local temp_settings = lor_settings.load('data/'..player..'/user_settings.lua')

            -- look for a value in my settings and apply it to theirs. If they don't match, take mine
            if temp_settings.assist.master == nil or temp_settings.assist.master == '' then
                if user_settings.assist.master ~= nil or user_settings.assist.master ~= ''  then
                    temp_settings.assist.master = user_settings.assist.master
                end
            elseif temp_settings.assist.master ~= user_settings.assist.master then
                temp_settings.assist.master = user_settings.assist.master
            end

            if temp_settings.assist.slaves ~= nil and user_settings.assist.slaves ~= nil then
                local new = merge(temp_settings.assist.slaves, user_settings.assist.slaves)
                temp_settings.assist.slaves = new
                user_settings.assist.slaves = new
                user_settings:save()
                temp_settings:save()
            end
        end
    end

    if secondIteration ~= nil and secondIteration then 
        windower.send_command('otto r')
        return 
    end

    utils.unionSettings(true)
end

function merge(a, b)
    local c = {}
    for k,v in pairs(a) do c[k] = v end
    for k,v in pairs(b) do c[k] = v end
    return c
end

--==============================================================================
--          Table Functions
--==============================================================================

function getPrintable(list, inverse)
    local qstring = ''
    for index,line in pairs(list) do
        local check = index
        local add = line
        if (inverse) then
            check = line
            add = index
        end
        if (tostring(check) ~= 'n') then
            if (#qstring > 1) then
                qstring = qstring..'\n'
            end
            qstring = qstring..add
        end
    end
    return qstring
end

--======================================================================================================================
--                      Misc.
--======================================================================================================================

function help_text()
    local t = '    '
    local ac,cc,dc = 262,263,1
    atcc(262,'HealBot Commands:')
    local cmds = {
        {'on | off','Activate / deactivate HealBot (does not affect follow)'},
        {'reload','Reload HealBot, resetting everything'},
        {'refresh','Reloads settings XMLs in addons/HealBot/data/'},
        {'fcmd','Sets a player to follow, the distance to maintain, or toggles being active with no argument'},
        {'buff <player> <spell>[, <spell>[, ...]]','Sets spell(s) to be maintained on the given player'},
        {'cancelbuff <player> <spell>[, <spell>[, ...]]','Un-sets spell(s) to be maintained on the given player'},
        {'blcmd','Sets the given list of spells to be maintained on the given player'},
        {'bufflists','Lists the currently configured spells/abilities in each bufflist'},
        {'spam [use <spell> | <bool>]','Sets the spell to be spammed on assist target\'s enemy, or toggles being active (default: Stone, off)'},
        {'dbcmd','Add/remove debuff spell to maintain on assist target\'s enemy, toggle on/off, or list current debuffs to maintain'},
        {'mincure <number>','Sets the minimum cure spell tier to cast (default: 3)'},
        {'disable <action type>','Disables actions of a given type (cure, buff, na)'},
        {'enable <action type>','Re-enables actions of a given type (cure, buff, na) if they were disabled'},
        {'reset [buffs | debuffs | both [on <player>]]','Resets the list of buffs/debuffs that have been detected, optionally for a single player'},
        {'ignore_debuff <player/always> <debuff>','Ignores when the given debuff is cast on the given player or everyone'},
        {'unignore_debuff <player/always> <debuff>','Stops ignoring the given debuff for the given player or everyone'},
        {'ignore <player>','Ignores the given player/npc so they will not be healed'},
        {'unignore <player>','Stops ignoring the given player/npc (=/= watch)'},
        {'watch <player>','Monitors the given player/npc so they will be healed'},
        {'unwatch <player>','Stops monitoring the given player/npc (=/= ignore)'},
        {'ignoretrusts <on/off>','Toggles whether or not Trust NPCs should be ignored (default: on)'},
        {'ascmd','Sets a player to assist, toggles whether or not to engage, or toggles being active with no argument'},
        {'wscmd1','Sets the weaponskill to use'},
        {'wscmd2','Sets when weaponskills should be used according to whether the mob HP is < or > the given amount'},
        {'wscmd3','Sets a weaponskill partner to open skillchains for, and the TP that they should have'},
        {'wscmd4','Removes a weaponskill partner so weaponskills will be performed independently'},
        {'queue [pos <x> <y> | on | off]','Moves action queue, or toggles display with no argument (default: on)'},
        {'actioninfo [pos <x> <y> | on | off]','Moves character status info, or toggles display with no argument (default: on)'},
        {'moveinfo [pos <x> <y> | on | off]','Moves movement status info, or toggles display with no argument (default: off)'},
        {'monitored [pos <x> <y> | on | off]','Moves monitored player list, or toggles display with no argument (default: on)'},
        {'help','Displays this help text'}
    }
    local acmds = {
        ['fcmd']=('f'):colorize(ac,cc)..'ollow [<player> | dist <distance> | off | resume]',
        ['ascmd']=('as'):colorize(ac,cc)..'sist [<player> | attack | off | resume]',
        ['wscmd1']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill use <ws name>',
        ['wscmd2']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill hp <sign> <mob hp%>',
        ['wscmd3']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill waitfor <player> <tp>',
        ['wscmd4']=('w'):colorize(ac,cc)..'eapon'..('s'):colorize(ac,cc)..'kill nopartner',
        ['dbcmd']=('d'):colorize(ac,cc)..'e'..('b'):colorize(ac,cc)..'uff [(use | rm) <spell> | on | off | ls]',
        ['blcmd']=('b'):colorize(ac,cc)..'uff'..('l'):colorize(ac,cc)..'ist <list name> (<player>)',
    }
    
    for _,tbl in pairs(cmds) do
        local cmd,desc = tbl[1],tbl[2]
        local txta = cmd
        if (acmds[cmd] ~= nil) then
            txta = acmds[cmd]
        else
            txta = txta:colorize(cc)
        end
        local txtb = desc:colorize(dc)
        atc(txta)
        atc(t..txtb)
    end
end

-- magic burst cast types
function utils.cast_types()
    return  T{'spell', 'helix', 'ga', 'ja', 'ra', 'jutsu', 'white', 'holy'}
end


--======================================================================================================================
--[[
Copyright © 2016, Lorand
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the
      following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
      following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of ffxiHealer nor the names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL Lorand BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
--]]
--======================================================================================================================
