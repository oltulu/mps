#!/usr/bin/lua

local mps_path=os.getenv("MPS_PATH")
if not mps_path then mps_path="/usr/milis/mps" end

--package.cpath = package.cpath .. ";"..mps_path.."/lua/?.so"
-- genel lua kütüphanelerinden etkilenmemesi için önce mps yolunda olanlar kullanılacak.
package.cpath = mps_path.."/lua/?.so" ..     ";".. package.cpath
package.cpath = mps_path.."/lua/ext/?.so" .. ";".. package.cpath
package.path  = mps_path.."/lua/?.lua"    .. ";".. package.path
package.path  = mps_path.."/lua/ext/?.lua".. ";".. package.path
package.path  = mps_path.."/lang/?.lua"   .. ";".. package.path
package.path  = mps_path.."/conf/?.lua"   .. ";".. package.path

local talimatci= require("talimat")
local rules= require("rules")

-- Variables 
local talimat_file="talimat"
local noexec=false
local talimat_dir=""
local isd=""
local talimat_path=""
local thash=""
local start_task_no=1

local _signs={[0]="+",[1]="-",[2]="!",[8]="Server issued an error response.(wget)"}

local task_queue={
	"talimat_meta",
	"dirs_create" ,
	"fetch_sources" ,
	"check_sources" ,
	"extract_sources" ,
	"build_package",
	"install_package",
	"strip_files",
	"compress_manpages",
	"delete_files",
	"copy_scripts",
	"generate_meta",
	"generate_content",
	"generate_package",
	"dirs_delete"
}


-- Helper functions
function _error(msg)
	print(msg)
	os.exit()
end

function shell(command)
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

--- Check if a file or directory exists in this path
function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

function string:addline(line)
	return self..line.."\n"
end

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

-- check a variable in an array 
function table.has(tab,val)
    for index, value in ipairs(tab) do
        if value == val then return true end
    end
    return false
end


function create_talimat(tdir)
	local template=[===[
[paket]
tanim   = %s paketi
paketci = milisarge
grup    = kütüphane
url     = https://mls.akdeniz.edu.tr

[gerek]
derleme = 
calisma =

[kaynak]
1       = kaynak_adresi

[sha256]
1       = 

[derle]
tip     = gnu

[pakur]
tip     = gnu
	]===]
	local isim  =tdir:split("#")[1]
	local surum =tdir:split("#")[2]:split("-")[1]
	local devir =tdir:split("#")[2]:split("-")[2]
	if isim and surum and devir then
		shell("mkdir -pv "..tdir)
	end
	local file = io.open(tdir.."/talimat", "w")
	io.output(file)
	io.write(template:format(isim))
	io.close(file)
	print(tdir.." için şablon talimat oluşturuldu")
end

-------------------------------------------------- ---

-- talimat metalarını export olarak çıktı almak için

function talimat_meta()
	local t=""
	t=t:addline("##### talimat vars #####")	
	for _,cmd in ipairs(rules.export.talimat(talimat.paket)) do
		t=t:addline(cmd)
	end
	return t
end

function dirs_create() 
	local t=""
	t=t:addline("##### create dirs #####")	
	t=t:addline(rules.make_dirs.archive())
	t=t:addline(rules.make_dirs.pkg())
	t=t:addline(rules.make_dirs.src())
	t=t:addline(rules.make_dirs.pkg_meta())
	return t
end

function prepare_sources() 
	-- create srcobj, address store_name  
	local t={}
	local key, address, store, place
	for _,val in ipairs(talimat.kaynak) do
		key=val:split("@@")[1]
		val=val:split("@@")[2]
		if rules.source[key] ~= nil then
		    --apply rule
		    val=rules.source[key](talimat,val) 
		end
		--parse applied source string
		address=val:split("::")[1]
		store=val:split("::")[2]
		if store == nil then 
			store=val:split("/")[#val:split("/")]
		end
		place="url"
		extract=true
		if key == "git" then place="git" end
		if key == "svn" then place="svn" end
		if key == "dosya" or key == "file"	then place="file" end
		if key == "dizin" or key == "dir"	then place="dir" end
		
		if  place == "url" or place == "git" or place == "svn" 
		then store=rules.dirs.archive..store end
		if  place == "file" then 
			address=talimat_dir.."/"..address 
			store=rules.dirs.src.."/"..store
		end 
		if  place == "dir" then  
			store=rules.dirs.src.."/"..store
		end
		-- check if it has no extract option
		if store:sub(-1) == "!" then
			extract=false
			store=store:split("!")[1]
			address=address:split("!")[1]
		end
	    -- add sources table
		table.insert(t,{fetch=place,address=address,store=store,extract=extract})
	end
	return t
	-- print(srcobj.fetch,srcobj.address,srcobj.store)
end

function fetch_sources()
	local t=""
	local sources=prepare_sources()
	t=t:addline("##### fetch sources #####")
	t=t:addline(talimat_meta())
	t=t:addline(rules.export.source_aliases)
	if sources == {} then
		_error("source list is not ready")
	end
	local afetch
	for _,srcobj in ipairs(sources) do
		--if  srcobj.fetch == "url"  then srcobj.store=rules.dirs.archive..srcobj.store end
		--if  srcobj.fetch == "file" then 
		--	srcobj.address=talimat_dir.."/"..srcobj.address 
		--	srcobj.store=rules.dirs.src.."/"..srcobj.store
		--end 
		if rules.fetch[srcobj.fetch] ~= nil then
			--t=t:addline(rules.fetch.check(srcobj))
			--apply rule
		    afetch=rules.fetch[srcobj.fetch](srcobj) 
		else
			_error("unknown fetch way:"..srcobj.fetch)
		end
		t=t:addline(afetch)
	end
	return t
end

function check_sources()
	local t=""
	-- apply talimat variables
	t=t:addline(talimat_meta())
	local sources=prepare_sources()
	t=t:addline("##### check sources #####")
	if sources == {} then
		_error("source list is not ready")
	end
	local achk
	local hashes={"sha256","sha512"}
	for _,hasht in ipairs(hashes) do 
		if talimat[hasht] ~= nil then
			for index,_hash in ipairs(talimat[hasht]) do
				if sources[index] ~= nil then
					--if  sources[index]["fetch"] == "file" then sources[index]["store"]=rules.dirs.src.."/"..sources[index]["store"] end 
					--if  sources[index]["fetch"] == "url"  then sources[index]["store"]=rules.dirs.archive..sources[index]["store"] end
					achk=rules.hash[hasht](sources[index]["store"],_hash)
					t=t:addline(achk)
				end
			end
		end
	end
	return t
end

function extract_sources()
	local t=""
	-- apply talimat variables
	t=t:addline(talimat_meta())
	local sources=prepare_sources()
	t=t:addline("##### extract sources #####")
	if sources == {} then
		_error("source list is not ready")
	end
	local aext, suffix
	local archive_suffix={"gz","xz","lz","bz2","tgz","zip","tar"}
	-- archive file type only todo!!!
	for _,srcobj in ipairs(sources) do
		-- detect file type from suffix (todo!!! magic, mime type)
		if srcobj.extract then
			suffix=srcobj.store:split(".")[#srcobj.store:split(".")]
			-- extract dir, store name
			if table.has(archive_suffix,suffix) then
				aext=rules.extract.bsdtar(rules.dirs.src,srcobj.store)
				t=t:addline(aext)
			end
		else
			t=t:addline('echo "'..srcobj.store..' : no extract"')
		end
	end
	return t
end

function build_package() 
	local t=""
	t=t:addline("##### build sources #####")
	-- apply global env
	-- need(export_dir-make_dir)
	-- need(talimat_export)
	t=t:addline("set -x")
	for _,cmd in ipairs(rules.export.dirs()) do
		t=t:addline(cmd)
	end 
	-- apply talimat variables
	t=t:addline(talimat_meta())
	-- apply build environments
	for key,_ in pairs(rules.build_env) do
		--print("----",export)
		t=t:addline(rules.build_env[key]())
	end
	-- default enter source directory
	t=t:addline(rules.change.dir(rules.dirs.src))
	if talimat.paket.arsiv then
		t=t:addline(rules.export.me("ARCHIVE_DIR",rules.dirs.src..talimat.paket.arsiv))
		t=t:addline(rules.change.dir(rules.dirs.src..talimat.paket.arsiv))
	else
		t=t:addline(rules.change.dir(rules.package.archive))
		
	end
	-- create srcobj, address store_name  
	local key
	-- traverse orderly
	for _,val in ipairs(talimat.derle) do
		key=val:split("@@")[1]
		val=val:split("@@")[2]
		if rules.build[key] ~= nil then
		    --apply rule
		    val=rules.build[key](talimat,val) 
		end
		if rules.build_env[key] ~= nil then
		    --apply rule
		    val=rules.build_env[key](val)
		end
		t=t:addline(val)
	end
	--t=t:addline("set +x")
	return t
end

function install_package() 
	local t=""
	t=t:addline("##### install package #####")
	t=t:addline("set -x")
	-- apply global env
	for _,cmd in ipairs(rules.export.dirs()) do
		t=t:addline(cmd)
	end 
	-- apply talimat variables
	t=t:addline(talimat_meta())
	-- apply build environments
	for key,_ in pairs(rules.build_env) do
		--print("----",export)
		t=t:addline(rules.build_env[key]())
	end
	-- default enter source directory
	t=t:addline(rules.change.dir(rules.dirs.src))
	if talimat.paket.arsiv then
		t=t:addline(rules.export.me("ARCHIVE_DIR",rules.dirs.src..talimat.paket.arsiv))
		t=t:addline(rules.change.dir(rules.dirs.src..talimat.paket.arsiv))
	else
		t=t:addline(rules.change.dir(rules.package.archive))
	end
	-- create srcobj, address store_name  
	local key
	for _,val in ipairs(talimat.pakur) do
		key=val:split("@@")[1]
		val=val:split("@@")[2]
		if rules.install[key] ~= nil then
		    --apply rule
		    val=rules.install[key](talimat,val)
		end
		-- strip, nostrip return anything
		if val ~= nil then 
			t=t:addline(val) 
		end
	end
	--t=t:addline("set +x")
	return t
end

function strip_files() 
	local t=""
	t=t:addline("##### strip files #####")
	if rules.strip.status then
		t=t:addline(rules.strip.files(rules.dirs.pkg,rules.strip.blacklist))
	end
	return t
end

function compress_manpages() 
	local t=""
	t=t:addline("##### compress manpages #####")
	t=t:addline(rules.compress.man(rules.dirs.pkg))
	return t
end

function delete_files() 
	local t=""
	t=t:addline("##### delete files #####")
	t=t:addline(rules.delete.files_un(rules.dirs.pkg))
	return t
end

function copy_scripts() 
	local t=""
	t=t:addline("##### copy scripts #####")
	t=t:addline(rules.copy.scripts(talimat.dir,rules.dirs.pkg,rules.dirs.pkg_meta))
	return t
end

function generate_meta() 
	local t=""
	t=t:addline("##### generate meta #####")
	t=t:addline(talimat_meta())
	t=t:addline(rules.find.libdepends(rules.dirs.pkg,rules.dirs.pkg_meta))
	t=t:addline(rules.find.pkglibs())
	local size=rules.calculate.size(rules.dirs.pkg)
	t=t:addline(rules.generate.meta_info(rules.dirs.pkg,rules.dirs.pkg_meta,size,thash))
	return t
end

function generate_content() 
	local t=""
	t=t:addline("##### generate content #####")
	t=t:addline(rules.generate.content_info(rules.dirs.pkg))
	return t
end

function generate_package() 
	local t=""
	t=t:addline("##### generate package #####")
	t=t:addline(talimat_meta())
	t=t:addline(rules.generate.package(rules.dirs.pkg,rules.dirs.pkg_meta))
	return t
end

function dirs_delete() 
	local t=""
	t=t:addline("##### delete dirs #####")
	t=t:addline(rules.delete.dir(rules.dirs.pkg))
	t=t:addline(rules.delete.dir(rules.dirs.src))
	return t
end

function create_yur()
	local file = io.open(("/tmp/%s.yur"):format(isd), "w")
	io.output(file)
	local operf="Operation file generated by MPSD 2.0 [%s]\n"
	operf=operf:format(os.date())
	for _,task in ipairs(task_queue) do
		operf=operf.."\n".._G[task]()
	end
	io.write(operf)	
	io.close(file)
end


function run()

	--create yururluk file
	create_yur()
	
	local totalsec=0

	for taskno,task in ipairs(task_queue) do
		local task_cmd=""
		task_cmd=_G[task]()
		if start_task_no <= taskno then
			if noexec then 
				print(task_cmd)	
				print("##### ----------- #####")
			else 
				local stime=os.time()
				print("--------------")
				print(task:upper())
				print("---------------------------------------------------")
				print("start time",os.date())
				print()
				local a,b,c,exno=pcall(os.execute,task_cmd)
				--print(a,b,c,exno)
				print()
				print("finish time",os.date())
				totalsec=totalsec+(os.time()-stime)
				print("STATUS:",_signs[exno],exno,"sn: "..tostring(os.time()-stime))
				print("---------------------------------------------------")
				if exno ~= 0  then 
					break 
				end
			end
			print()
		end
	end
	print("Total min:",math.floor(totalsec/60*100)/100)
end
-- logging mpsd.lua talimatdir | tee /tmp/package.log



-------------- main start ---------------

talimat_dir=arg[1]
if talimat_dir == nil then _error("talimat dizini belirtilmedi!") end



if #arg > 1 then
	for i = 2,#arg do
		if arg[i] == "--print"  or  arg[i] == "-p" then 
			noexec=true 
		elseif arg[i] == "--create" or  arg[i] == "-c" then 
			create_talimat(talimat_dir) 
			os.exit() 
		elseif arg[i] == "--generate" or  arg[i] == "-g" then 
			-- resume since instal_package task
			start_task_no=7
		end
	end
	
end


if exists(talimat_dir) == nil then _error("geçersiz talimat dizini!")     end

talimat_dir=shell("readlink -f "..talimat_dir)
isd=shell("basename "..talimat_dir)
talimat_path=talimat_dir.."/"..talimat_file
thash=shell("sha256sum "..talimat_path.." | awk '{print $1}'")

if exists(talimat_path) == nil then _error("talimat dosyası bulunmadı!")  end

talimat=talimatci.load(talimat_path,{"derle","pakur","kaynak"})

talimat.dir=talimat_dir
talimat.paket.isim=isd:split("#")[1]
talimat.paket.surum=isd:split("#")[2]:split("-")[1]
talimat.paket.devir=isd:split("#")[2]:split("-")[2]

-- start to process tasks 
run()

