local debug = {}

local default = {}
debug.snapshot = {}
local json_custom = require('debug/lib/JSON')

function debug.init()

  if user_settings.debug == nil then
      local debug = {
        enabled = false
       }

      user_settings.debug = debug
      user_settings:save()
  end

end


function debug.create_log(log, newfile)
  local filename = newfile or 'debug_test'
  local newLog = log or {}
  if user_settings.debug.enabled then
    if type(log) == "table" then
      table.save(newLog, "C:/Users/chris/Desktop/Windower/addons/otto/debug/logs/"..filename..".txt")
    elseif  type(log) == "string" or type(log) == "number" then
      print('saved string')
      local file = io.open('C:/Users/chris/Desktop/Windower/addons/otto/debug/logs/'..filename..'.txt', "a")
      file:write(log..'\n')
      file:close()
    end
    return
  end 

end

function debug.create_log_once(log, newfile)

    if not next(debug.snapshot)  then 
      local filename = newfile or 'snapshot'
      debug.snapshot = file
      table.save(log, "C:/Users/chris/Desktop/Windower/addons/otto/debug/logs/"..filename..".txt")
      print(filename..' created!')
    end

end

function debug.create_2log_for_comparison(log, newfile, log2, newfile2)
  local filename = newfile or 'snapshot'
  local filename2 = newfile2 or 'snapshot'
  if not next(debug.snapshot) then
    debug.snapshot = filename

    table.save(log, "C:/Users/chris/Desktop/Windower/addons/otto/debug/logs/"..filename..".txt")
    table.save(log2, "C:/Users/chris/Desktop/Windower/addons/otto/debug/logs/"..filename2..".txt")
    print(filename..' and '..filename2..' created!')
  end
end

function debug.create_log_once_json(log, newfile)


  if not next(debug.snapshot) then 
    debug.snapshot = log
    local filename = newfile or 'snapshot'

    local result = json_custom:encode_pretty(log)

    local file = io.open('C:/Users/chris/Desktop/Windower/addons/otto/debug/logs/'..filename..'.json', "a")
    file:write(result..'\n')
    file:close()
    print(filename..' created!')
  end
end

function debug.save_table(log, newfile)
  local filename = newfile or 'debug_test'
  local newLog = log or {}
  if user_settings.debug.enabled then
    if type(log) == "table" then
      table.save(newLog, "C:/Users/chris/Desktop/Windower/addons/otto/"..filename..".lua")
    end 
      -- error
  end 
end
















local function exportstring( s )
    s = string.format( "%q",s )
    -- to replace
    s = string.gsub( s,"\\\n","\\n" )
    s = string.gsub( s,"\r","\\r" )
    s = string.gsub( s,string.char(26),"\"..string.char(26)..\"" )
    return s
  end
--// The Save Function
function table.save(  tbl,filename )
  local charS,charE = "   ","\n"
  local file,err
  -- create a pseudo file that writes to a string and return the string
  if not filename then
    file =  { write = function( self,newstr ) self.str = self.str..newstr end, str = "" }
    charS,charE = "",""
  -- write table to tmpfile
  elseif filename == true or filename == 1 then
    charS,charE,file = "","",io.tmpfile()
  -- write table to file
  -- use io.open here rather than io.output, since in windows when clicking on a file opened with io.output will create an error
  else
    file,err = io.open( filename, "w" )
    if err then return _,err end
  end
  -- initiate variables for save procedure
  local tables,lookup = { tbl },{ [tbl] = 1 }

  file:write( "return {"..charE )
  for idx,t in ipairs( tables ) do
    if filename and filename ~= true and filename ~= 1 then
      file:write( "-- Table: {"..idx.."}"..charE )
    end
    file:write( "{"..charE )
    local thandled = {}
    for i,v in ipairs( t ) do
      thandled[i] = true
      -- escape functions and userdata
      if type( v ) ~= "userdata" then
        -- only handle value
        if type( v ) == "table" then
          if not lookup[v] then
            table.insert( tables, v )
            lookup[v] = #tables
          end
          file:write( charS.."{"..lookup[v].."},"..charE )
        elseif type( v ) == "function" then
          file:write( charS.."loadstring("..exportstring(string.dump( v )).."),"..charE )
        else
          local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
          file:write(  charS..value..","..charE )
        end
      end
    end
    for i,v in pairs( t ) do
      -- escape functions and userdata
      if (not thandled[i]) and type( v ) ~= "userdata" then
        -- handle index
        if type( i ) == "table" then
          if not lookup[i] then
            table.insert( tables,i )
            lookup[i] = #tables
          end
          file:write( charS.."[{"..lookup[i].."}]=" )
        else
          local index = ( type( i ) == "string" and "["..exportstring( i ).."]" ) or string.format( "[%d]",i )
          file:write( charS..index.."=" )
        end
        -- handle value
        if type( v ) == "table" then
          if not lookup[v] then
            table.insert( tables,v )
            lookup[v] = #tables
          end
          file:write( "{"..lookup[v].."},"..charE )
        elseif type( v ) == "function" then
          file:write( "loadstring("..exportstring(string.dump( v )).."),"..charE )
        else
          local value =  ( type( v ) == "string" and exportstring( v ) ) or tostring( v )
          file:write( value..","..charE )
        end
      end
    end
    file:write( "},"..charE )
  end
  file:write( "}" )
  -- Return Values
  -- return stringtable from string
  if not filename then
    -- set marker for stringtable
    return file.str.."--|"
  -- return stringttable from file
  elseif filename == true or filename == 1 then
    file:seek ( "set" )
    -- no need to close file, it gets closed and removed automatically
    -- set marker for stringtable
    return file:read( "*a" ).."--|"
  -- close file and return 1
  else
    file:close()
    return 1
  end
end


return debug