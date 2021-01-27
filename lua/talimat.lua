--[[
	Copyright (c) 2020 Milis Linux
--]]


-- check a variable in an array 
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

-- remove leading whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function ltrim(s)
  return (s:gsub("^%s*", ""))
end

-- remove trailing whitespace from string.
-- http://en.wikipedia.org/wiki/Trim_(programming)
function rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end

local talimat = {};

--- Returns a table containing all the data from the INI file.
--@param fileName The name of the INI file to parse. [string]
--@return The table containing all data from the INI file. [table]
function talimat.load(fileName,nested)
	assert(type(fileName) == 'string', 'Parameter "fileName" must be a string.');
	local file = assert(io.open(fileName, 'r'), 'Error loading file : ' .. fileName);
	local data = {};
	local section;
	local count =0;
	-- if nested param dont't push
	if nested == nil then
		nested={}
	end
	for line in file:lines() do
		local tempSection = line:match('^%[([^%[%]]+)%]$');
		if(tempSection)then
			section = tonumber(tempSection) and tonumber(tempSection) or tempSection;
			data[section] = data[section] or {};
		end
		local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$');
		if(param and value ~= nil)then
		
			if(tonumber(value))then
				value = tonumber(value);
			elseif(value == 'true')then
				value = true;
			elseif(value == 'false')then
				value = false;
			end
			if(tonumber(param))then
				param = tonumber(param);
			end
			
			-- value trim spaces not all just ltrim,rtrim
			-- this is for all,not suit for betik key -> value=value:gsub('%s+', '')
			if value ~= nil and type(value) ~= "number" then 
				value=ltrim(rtrim(value))
			end
			-- nested parametresiyle derle,pakur gibi kısımlar için
			-- indekslenerek array yapı olarak tutulması sağlanıyor.
			-- derle,pakur sıralı betik olmak zorundadır.
			if has_value(nested,section) then
				--count = count +1
				--data[section][count] = param .."@@"..value;
				table.insert(data[section],param .."@@"..value)
			else
				data[section][param] = value;
			end
		end
	end
	file:close();
	return data;
end



return talimat;
