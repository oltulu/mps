#!/usr/bin/env lua5.3
--[[
	Milis Linux Talimat Hazırlama Destek Betiği
	Void Linux template[1] yapısını Milis Linux 2.0 talimat yapısına çevirir.
	milisarge@gmail.com 2019
	
	[1] https://github.com/void-linux/void-packages/tree/master/srcpkgs
]]--

-- Gerekler
-- luarocks paketi   -> mps kur luarocks
-- luasec lua paketi -> luarocks install luasec
-- oto tanım çevirici için ceviri awk betiği lazım -https://github.com/soimort/translate-shell
-- Milis1 de hazır geliyor.
-- milis2 : mps kur luasec luafilesystem

-- Kullanım
-- ./vo2ml.lua paket_ismi

local http = require("socket.http")
https = require("ssl.https")
lfs = require("lfs")

local talimat={
	isim="",
	surum="",
	devir=1,
	paketci="milisarge",
	grup="kütüphane",
	url="",
	sha256="",
	gerek="",
	tanim="",
	ekconf="",
	dptip="",
	kaynak="",
	derle="",
	pakur="",
}

function _indir(link,kayit)
	local body, code = https.request(link)
	if body == nil then
		body, code = http.request(link)
	end
	code=tostring(code)
	if code:match("connection refused") then
		print(code)
	elseif code=="404" then
		print("not found")
	elseif code == "200" then
		local f = assert(io.open(kayit, 'wb'))
		f:write(body)
		f:close();
		if lfs.attributes(kayit, "mode") ~= nil then
			print("kaynak: "..link)
			return true
		else
			print("redown..")
			_indir(link,kayit);
		end
	elseif not body then
		print("sorunlu link")
	else
		print("unknw err",code)
	end
	return false
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function tprint(tablo)
    for key, value in pairs(tablo) do
       print (key.. " = "..value)
    end
end

function parse(template)
	if not file_exists(template) then return {} end   
    for line in io.lines(template) do 
		v,i=line:gsub("^hostmakedepends=", ""); if i ==1 then talimat.gerek=talimat.gerek.." "..v:gsub('%"',"");sonakt="gerek" end
		v,i=line:gsub("^makedepends=", ""); if i ==1 then talimat.gerek=talimat.gerek.." "..v:gsub('%"',"");sonakt="gerek" end
		v,i=line:gsub("^depends=", ""); if i ==1 then talimat.gerek=talimat.gerek.." "..v:gsub('%"',"");sonakt="gerek"  end
		v,i=line:gsub("pkgname=", ""); if i ==1 then talimat.isim=v end
		v,i=line:gsub("version=", ""); if i ==1 then talimat.surum=v end
		v,i=line:gsub("build_wrksrc=", ""); if i ==1 then talimat.arsiv=v end
		v,i=line:gsub("wrksrc=", ""); if i ==1 then talimat.arsiv=v end
		v,i=line:gsub("homepage=", ""); if i ==1 then talimat.url=v:gsub('%"',"") end
		v,i=line:gsub("short_desc=", ""); if i ==1 then talimat.tanim=v:gsub('%"',"") end
		v,i=line:gsub("checksum=", ""); if i ==1 then talimat.sha256=v:gsub('%"',"");;sonakt="sha256" end
		v,i=line:gsub("make_build_args=", ""); if i ==1 then talimat.ekconf=v:gsub('%"',"") end
		v,i=line:gsub("configure_args=", ""); if i ==1 then talimat.ekconf=v:gsub('%"',"");sonakt="ekconf" end
		v,i=line:gsub("build_style=", ""); if i ==1 then talimat.dptip=v end
		v,i=line:gsub("distfiles=", ""); if i ==1 then talimat.kaynak=v:gsub('%"',"");;sonakt="kaynak" end
		
		for k,v in line:gmatch("(pre_configure).+") do preconfigure=1;sonakt="" end
		if preconfigure==1 and line ~= '}' then talimat.derle=talimat.derle..line.."\n" end
		if line == '}' and preconfigure==1 then preconfigure=0;talimat.derle=talimat.derle:gsub("pre_configure%(%)%s%{","") end
		
		for k,v in line:gmatch("(pre_build).+") do prebuild=1;sonakt="" end
		if prebuild==1 and line ~= '}' then talimat.derle=talimat.derle..line.."\n" end
		if line == '}' and prebuild==1 then prebuild=0;talimat.derle=talimat.derle:gsub("pre_build%(%)%s%{","") end
		
		for k,v in line:gmatch("(do_build).+") do dobuild=1;sonakt="" end
		if dobuild==1 and line ~= '}' then talimat.derle=talimat.derle..line.."\n" end
		if line == '}' and dobuild==1 then dobuild=0;talimat.derle=talimat.derle:gsub("do_build%(%)%s%{","") end
		
		for k,v in line:gmatch("(do_install).+") do doinstall=1;sonakt="" end
		if doinstall==1 and line ~= '}' then talimat.pakur=talimat.pakur..line.."\n"  end
		if line == '}' and doinstall==1 then doinstall=0;talimat.pakur=talimat.pakur:gsub("do_install%(%)%s%{","") end
		
		for k,v in line:gmatch("(post_install).+") do postinstall=1;sonakt="" end
		if postinstall==1 and line ~= '}' then talimat.pakur=talimat.pakur..line.."\n"  end
		if line == '}' and postinstall==1 then postinstall=0;talimat.pakur=talimat.pakur:gsub("post_install%(%)%s%{","") end
		
		-- boşlukla başlayan satır yakalanması
		if line:match('^%s(.*)') then 
			if sonakt == "gerek" then
				talimat[sonakt]=talimat[sonakt].." "..line:gsub('%"',"")
			elseif sonakt == "kaynak" or sonakt == "sha256" then
				talimat[sonakt]=talimat[sonakt]..line.."\n"
			elseif sonakt == "ekconf" then
				talimat[sonakt]=talimat[sonakt]..line.."\n"
			end
			sonakt=""
		end
		
    end
    -- son temizlikler ve değişiklikler
    talimat.gerek=talimat.gerek:gsub("-devel","")
    talimat.gerek=talimat.gerek:lower()
    talimat.kaynak=talimat.kaynak:gsub("homepage","url")
    -- eşleştirme
    talimat.dptip=talimat.dptip:gsub("gnu%-makefile","gnu")
    talimat.dptip=talimat.dptip:gsub("gnu%-configure","gnu")
    talimat.kaynak=talimat.kaynak:gsub("pkgname","isim")
    talimat.kaynak=talimat.kaynak:gsub("version","surum")
    if talimat.arsiv then
		talimat.arsiv=talimat.arsiv:gsub("pkgname","isim")
		talimat.arsiv=talimat.arsiv:gsub("version","surum")
    end
    talimat.pakur=talimat.pakur:gsub("${DESTDIR}","${PKG}")
    talimat.pakur=talimat.pakur:gsub("${FILESDIR}","${SRC}")
end

--local link="https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/xfdesktop/template"
--local link="http://localhost:9999/paket.vt"
--local kayit="denem2e2.template"
local void_template="https://raw.githubusercontent.com/void-linux/void-packages/master/srcpkgs/%s/template"
local paket=arg[1]
local link=void_template:format(paket)
local kayit="/tmp/"..paket..".template"
if _indir(link,kayit) then
	parse(kayit)
end
--print("--")
--tprint(talimat)
print("-------------------------")

-- tanımın Türkçe'ye oto çevirisi
command="ceviri en:tr '%s' | awk 'NR==3' " .. ' | sed -r "s/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" '
local handle = io.popen(command:format(talimat.tanim))
local result = handle:read("*a")
handle:close()
if result ~= "" then talimat.tanim=result:gsub("\n","") end

-- talimat dosyasının üretilmesi
talimatd=("/tmp/%s#%s-1"):format(talimat.isim:lower(),talimat.surum)
os.execute(("mkdir -p %s"):format(talimatd))
file = io.open(talimatd.."/talimat", "w")

function fprint(data)
	if data == nil then data="" end
	file:write(data.."\n")
end

fprint("[paket]")
fprint(("tanim   = %s"):format(talimat.tanim))
fprint(("paketci = %s"):format(talimat.paketci))
fprint(("grup    = %s"):format(talimat.grup))
fprint(("url     = %s"):format(talimat.url))
if talimat.arsiv then 
	fprint(("arsiv   = %s"):format(talimat.arsiv))
end 
fprint()
fprint("[gerek]")
fprint(("derleme = %s"):format(talimat.gerek:gsub("^%s", "")))
fprint("calisma =")
fprint()
fprint("[kaynak]")
for s in talimat.kaynak:gmatch("[^\r\n]+") do
	fprint(("1       = %s"):format(s))
end
fprint()
fprint("[sha256]")
for s in talimat.sha256:gmatch("[^\r\n]+") do
	fprint(("1       = %s"):format(s))
end
fprint()
fprint("[derle]")
for s in talimat.derle:gmatch("[^\r\n]+") do
    fprint("betik   = "..s:gsub("^%s", ""))
end
if talimat.ekconf ~= "" then fprint(("ekconf     = %s"):format(talimat.ekconf)) end
fprint(("tip     = %s"):format(talimat.dptip))
fprint()
fprint("[pakur]")
fprint(("tip     = %s"):format(talimat.dptip))
for s in talimat.pakur:gmatch("[^\r\n]+") do
    fprint("betik   = "..s:gsub("^%s", ""))
end
-------------------------------------------------------
print("kayıt: "..talimatd.."/talimat")
