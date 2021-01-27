#!/bin/env lua
-- mps için yardımcı işlevler

--importlar
local color = require ("ansicolors")
local helper={}
helper.renkli=true
helper.shell_log="/tmp/mps_helper-shell.log"

-- yaz = farklı tipte çıktıları ekrana renkli yazan işlev
-- codes: 0=error, 1=success, 2=info 3=warning
getmetatable("").__index.yaz = function(msg,code)
	--print("*",msg,code,color)
	tip={'%{red}','%{green}','%{blue}','%{lred}'}
	if code == nil then code=2 end
	if helper.renkli then
		--print(tip[code+1](msg))
		print(color(('%s%s'):format(tip[code+1],msg)))
	else
		print(msg)
	end
	if code == 0 then
		os.exit()
	end
end

--split string
function string:split(delimiter)
  local result = {}
  if delimiter == "." then  
    for i in string.gmatch(self, "[^%.]+") do
	  table.insert(result,i)
    end
  else
    local from  = 1
    local delim_from, delim_to = string.find( self, delimiter, from  )
    while delim_from do
      table.insert( result, string.sub( self, from , delim_from-1 ) )
      from  = delim_to + 1
      delim_from, delim_to = string.find( self, delimiter, from  )
    end
    table.insert( result, string.sub( self, from  ) )
  end
  return result
end

-- myassert, bir parametrenin nil, "", false olma durumlarını kontrol eder.
function helper._assert(param,msg)
	if msg == nil then
		msg = "error:"
	end
	if param == nil or param == false then
		msg:yaz(0)
	else
		return param
	end
end

-- check a variable in an array 
-- todo!!!  has_value kullanilan islevler find ile revize edilecek
function helper.has_value (tab, val)
    for _, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- get the index of an item in a table
function helper.find(tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return index
        end
    end

    return -1
end

-- print elements of a table-array
function helper.tprint(tablo)
    for _, value in ipairs(tablo) do
       print (value)
    end
end

-- bir dizin/dosya yolunun varlığını kontrol eder
function helper.path_exists(path)
	return lfs.attributes(path, "mode") ~= nil
end

-- bir dizin/dosya boyut
function helper.get_size(path)
	return lfs.attributes(path, "size")
end

function helper.shell(command)
	-- Open log file in append mode
	local logger = io.open(helper.shell_log, "a")
	logger:write(command.."\n");
	logger:close();
	local handle=io.popen(command)
	local result=handle:read('*all')
	handle:close()
	-- komut çıktısı sonu yeni satır karakterin silinmesi - en sondaki \n
	if result:sub(-1) == "\n" then
		--result=result:gsub("\n", "")
		result=result:sub(1,-2)
	end
	return result
end

function helper.get_abspath(path)
	local ret=helper.shell("readlink -f " .. path)
	return ret
end

function helper.get_basename(path)
	return helper.shell("basename " .. path)
end

function helper.get_dirname(path)
	return helper.shell("dirname " .. path)
end

-- get content of a file
function helper.get_content(filename)
	assert(helper.path_exists(filename),"helper.get_content : invalid path: "..filename)
	local f = assert(io.open(filename, "r"))
	local t = f:read('*all')
	f:close()
	return t
end

-- check a file has a line
function helper.has_line(filename,line)
	assert(helper.path_exists(filename),"helper.has_line : invalid path: "..filename)
	local cnt=helper.get_content(filename)
	for linein in cnt:gmatch("[^\r\n]+") do 
		if linein == line then
			return true
		end
	end
	return false
end

-- check sha256sum of a file
function helper.hash_check(filepath,hash_value)
	assert(helper.path_exists(filepath),"helper invalid path: "..filepath)
	local komut='echo "%s  %s" | sha256sum --check ;[ $? -eq 1 ] && printf "err@r"'
	local ret=helper.shell(komut:format(hash_value,filepath))
	if ret:match("err@r") then
		return false
	end
	return true
end

-- get dirs of a directory
function helper.get_dirs(directory)
	dirs={}
	for obj in lfs.dir(directory) do
		if lfs.attributes(directory..obj,"mode") == "directory" then 
			if obj ~="." and obj~=".." then
				table.insert(dirs,obj) 
			end
		end
	end
	return dirs
end

-- convert byte to kilobyte,megabyte
function helper.byte_convert(value)
	--test
	if value == "@test" then
		assert(helper.byte_convert(1023) == "1023 B")
		assert(helper.byte_convert(1025) == "1.0 KB")
		assert(helper.byte_convert(1024*1025) == "1.00 MB")
		assert(helper.byte_convert(1024*1025*1024) == "1.001 GB")
		return 1
	end
	
	local _kb=1024
	local _mb=1024*_kb
	local _gb=1024*_mb
	local result=""
	
	if type(value) == "string" then value=tonumber(value) end
	
	if     value > _gb then result=("%.3f GB"):format(value/_gb)
	elseif value > _mb then result=("%.2f MB"):format(value/_mb)
	elseif value > _kb then result=("%.1f KB"):format(value/_kb)
	else   result=("%.0f B"):format(value) end
	
	return result
end

return helper
