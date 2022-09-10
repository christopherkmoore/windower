-- nearly all of this load / util / parse code pulled from Lorand. Thanks!

local files = require('files')
require('luau')
local settings = T{}

local global = gearswap and gearswap._G or _G
local no_quote_types = S{'number','boolean','nil'}
local valid_classes = S{'List','Set','Table'}
local converting = false


--[[
    Load the settings file with the given path (relative to the calling addon's
    directory), and an optional table of default values.  If the file doesn't
    exist, then it is created and populated with the default values.
--]]
function settings.load(filepath, defaults)
    if type(filepath) ~= 'string' then
        filepath, defaults = 'data/settings.lua', filepath
    end


    local loaded = nil
    local fcontents = files.read(filepath)
    
    if (fcontents ~= nil) then
        loaded = loadstring(fcontents)
        global.setfenv(loaded, _G)       --Allows loading of S{}, T{}, etc.
        loaded = loaded()
    end
    
    local do_save = false
    if loaded == nil then
        loaded = defaults or {}
        do_save = true
    end
    
    local d_meta = getmetatable(defaults) or _meta.T
    local m = getmetatable(loaded)
    if m == nil then
        m = {}
        setmetatable(loaded, m)
    end
    m.__settings_path = filepath
    m.__class = 'Settings'
    m.__index = function(t, k)
        if settings[k] ~= nil then
            return settings[k]
        end
        return d_meta.__index[k]
    end
    
    if do_save then
        settings.save(loaded)
    end
    return loaded
end


--[[
    Returns the class prefix for the given table, if supported
--]]
local function t_prefix(obj)
    local oclass = class(obj)
    if valid_classes:contains(oclass) then
        return oclass:match('^%u')
    end
    return ''
end


--[[
    Prepare the given table to be written to file.  Recursive for sub-tables.
    Returns a list of strings, where each entry is a line of output.
    
    Every key=value pair / entry is placed on a separate line.
    
    If all entries have numeric keys, the first key is 1, and those keys are in
    sequential order, then the table is treated like a list (i.e., no key value
    is stored).  Otherwise, entries are stored as [key] = value.  Strings are
    enclosed in quotation marks and escaped if necessary via the enquote()
    lor_strings method.
--]]
local function prepare(t, indent)
    local pair_fn = converting and pairs or opairs
    local res = {}
    local tlen = 0
    local is_ordered_list = true
    for k,_ in pairs(t) do
        tlen = tlen + 1
        if k ~= tlen then is_ordered_list = false end
    end
    local is_set = (class(t) == 'Set')
    
    local i = 1
    for _k,_v in pair_fn(t) do
        local k,v = '',_v
        if is_set then  --Values are stored as {key1=true,key2=true}, but the
            v = _k      --constructor is S{key1,key2}, so treat keys as values
        elseif not is_ordered_list then
            k = tostring(_k)
            if not no_quote_types:contains(type(_k)) then
                k = k:enquote()
            end
            k = ('[%s] = '):format(k)
        end
        
        if type(v) == 'table' then
            local class_prefix = t_prefix(v)
            local sub_table = prepare(v, indent)
            if #sub_table < 1 then
                res[#res+1] = ('%s%s{}'):format(k, class_prefix)
            else
                --Encorporate the subtable into the result, adding a level of indentation
                res[#res+1] = ('%s%s{'):format(k, class_prefix)
                for _,line in pair_fn(sub_table) do
                    res[#res+1] = ('%s%s'):format(indent, line)
                end
                res[#res+1] = '}'
            end
        else
            local val = tostring(v)
            if not no_quote_types:contains(type(v)) then
                val = val:enquote()
            end
            res[#res+1] = ('%s%s'):format(k, val)
        end
        
        if i < tlen then
            res[#res] = res[#res]..','
        end
        i = i + 1
    end
    return res
end

function string.enquote(s)
    return ('%q'):format(s)
end

function opairs(tbl)
    local i = 0
    local ordered = ordered_indices(tbl)
    return function()
        i = i + 1
        local key = ordered[i]
        return key, tbl[key]
    end
end

function table.keys(t)
    local r = {}
    for k,_ in pairs(t) do r[#r+1] = k end
    return r
end

function cmp(obj1, obj2)
    --Compare obj1 to obj2
    local t1, t2 = type(obj1), type(obj2)
    if t1 ~= t2 then
        --Type mismatch: compare types
        return t1 < t2
    --If not a type mismatch, t1 == t2, so only t1 will be used going forward
    elseif t1 == "boolean" then
        return obj1
    elseif any_eq(t1, "number", "string") then
        return obj1 < obj2
    else
        return tostring(obj1) < tostring(obj2)
    end
end

function any_eq(val, ...)
    --Returns true if one or more aguments are equal to val
    for _,arg in pairs({...}) do
        if arg == val then return true end
    end
    return false
end

function ordered_indices(t) local r = table.keys(t); table.sort(r, cmp); return r end


--[[
    Save the settings table to the path provided when it was loaded.
    quiet: (optional) boolean whether or not to hide the saved message
    indent: (optional) string or number of spaces to use (default: 4 spaces)
    line_end: (optional) newline character for each line (default: \n)
--]]
function settings.save(settings_tbl, quiet, indent, line_end)
    indent = (type(indent) == 'number') and (' '):rep(indent) or indent
    indent = (type(indent) == 'string') and indent or '    '
    line_end = (type(line_end) == 'string') and line_end or '\n'
    
    local m = getmetatable(settings_tbl)
    if m == nil then
        m = {}
        setmetatable(settings_tbl, m)
    end
    m.__settings_path = 'data/settings.lua'
    m.__class = 'Settings'

    if m == nil or m.__settings_path == nil then    
        error('Invalid argument passed to settings.save: '..tostring(settings_tbl))
        return
    end
    
    local prepared = prepare(settings_tbl, indent)
    if prepared == nil then
        error('Unexpected error occurred while preparing output')
        return
    end
    
    local filepath = os.path.join(windower.addon_path, m.__settings_path)
    os.path.mkdirs(windower.addon_path, os.path.parent(m.__settings_path))
    
    local f = io.open(filepath, 'wb')   --'w' -> \r\n; 'wb' -> \n
    f:write('return {', line_end)
    for _,line in pairs(prepared) do
        f:write(indent, line, line_end)
    end
    f:write('}', line_end)
    f:close()
    
    if not quiet then
        windower.add_to_chat(1, 'Saved settings to: '..filepath)
    end
end

os.path = {
    exists = function(path) return global.windower.file_exists(path) or global.windower.dir_exists(path) end,
    mkdir = global.windower.create_dir,
    join = function(root, ...)
        local result = root or '/'
        local subs = {...}
        for _,p in ipairs(subs) do
            local trailing = result:endswith('/')
            local leading = p:startswith('/')
            local s = (trailing or leading) and '' or '/'
            result = ('%s%s%s'):format(result, s, p)
        end
        return result
    end,
    split = function(path)
        local parts = path:psplit('[\\\\/]')
        local result = T{}
        for _,p in ipairs(parts) do
            if #p > 0 then
                result:append(p)
            end
        end
        return result
    end,
    mkdirs = function(root, path)
        local parts = os.path.split(path)
        local cwd = root
        for _,p in ipairs(parts) do
            cwd = os.path.join(cwd, p)
            if not global.windower.dir_exists(cwd) then
                os.path.mkdir(cwd)
            end
        end
    end,
    parent = function(path)
        local parts = os.path.split(path)
        parts[#parts] = nil
        return os.path.join(unpack(parts))
    end
}

return settings