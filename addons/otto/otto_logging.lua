local logging = {}

--- @param message any
function logging.log(message)
    local prefix = 'Otto logger: '

    if not message then
        windower.add_to_chat(123, "value is nil")
        return
    end

    if type(message) == 'table' then
        table.print(message)
    elseif type(message) == 'boolean' then 
        if message == true then
            windower.add_to_chat(color, prefix .. tostring(true))
        else
            windower.add_to_chat(color, prefix .. tostring(false))
        end
    else
        windower.add_to_chat(color, prefix .. message)
    end
end

--- @param title string
--- @param message any 
function logging.log_with_title(title, message)
    local prefix = 'Otto logger: '

    if title then  
        prefix = prefix .. title .. ' - '
    end

    if not message then
        windower.add_to_chat(123, "value is nil")
        return
    end

    if type(message) == 'table' then
        table.print(message)
    else
        windower.add_to_chat(color, prefix .. message)
    end
end

return logging