#!/usr/bin/env lua
-- mps lua kodlaması

-- IMPORT --
local milispath=os.getenv("MILIS_PATH")
if not milispath then milispath="/usr/milis" end

local talimatname=os.getenv("TALIMATNAME")
if not talimatname then talimatname=milispath.."/".."talimatname" end

local mps_path=os.getenv("MPS_PATH")
if not mps_path then mps_path=milispath.."/".."mps" end

--package.cpath = package.cpath .. ";"..mps_path.."/lua/?.so"
-- genel lua kütüphanelerinden etkilenmemesi için önce mps yolunda olanlar kullanılacak.
package.cpath = mps_path.."/lua/?.so" ..     ";".. package.cpath
package.cpath = mps_path.."/lua/ext/?.so" .. ";".. package.cpath
package.path  = mps_path.."/lua/?.lua"    .. ";".. package.path
package.path  = mps_path.."/lua/ext/?.lua".. ";".. package.path
package.path  = mps_path.."/lang/?.lua"   .. ";".. package.path
package.path  = mps_path.."/conf/?.lua"   .. ";".. package.path

-- local socket = require("socket")
local argparse = require ("argparse")
local lfs = require("lfs")
local http = require("socket.http")
-- talimat ayrıştırıcı
local t=require ("talimat")
local util=require ("mps_helper")
local has_value=util.has_value
local find=util.find
local path_exists=util.path_exists
local shell=util.shell
local get_abspath=util.get_abspath
local get_basename=util.get_basename
local get_size=util.get_size
local get_content=util.get_content
local get_dirs=util.get_dirs
local has_line=util.has_line
local tprint=util.tprint
local hash_check=util.hash_check
local byte_convert=util.byte_convert


-- dil tespiti / sonra mps-helper den çağrılabilir.
local _langenv=os.getenv("LANG")
if not _langenv then _langenv="tr_TR" end
local _langvar,_=_langenv:match("(.*)_(.*)")
local messages = require ("lang_".. _langvar)
--------------------------------------------------

-- mps ile ilgili ayarların conf/conf.lua dan yüklenmesi
if not path_exists(mps_path.."/conf/conf.lua") then
	shell("cp "..mps_path.."/conf/conf.lua.sablon "..mps_path.."/conf/conf.lua")
	messages.default_configs_loaded:yaz(2)
	messages.relaunch_mps:yaz(2)
	os.exit()
end
local ayar= require ("conf")
-------------------------------------------------------

-- DIZIN OLUŞTURMA - KONTROL --

-- Paketleme dizini, yürürlük dosyasının oluşturulduğu konum
local paketleme_dizin=os.getenv("PAKETLEME_DIZIN")
if not paketleme_dizin then paketleme_dizin=lfs.currentdir() end

-- GLOBAL VARIABLES --

local arsivci="bsdtar"
local islem={}
islem.api={}

-- local talimatname="/usr/milis/talimatname"
local kokdizin=""

local paket_arsiv_pattern="([%a%d-_+]+)#([%d%a.]+)-([%d]+)" -- paket_isim#surum-devir-mimari : abc#1.2.3-1-x86_64
-- paket arşiv format -paket_isim#surum-devir-mimari.kur
local paf="%s#%s-%s.kur"
-- paket gösterim formatı
local pgf="%s#%s-%s"
-- paket depo link formatı - depo_adres/paket_isim#surum-devir-mimari.kur / paf kullan
local plf="%s/%s"

local rotator_sym={"\\","/"}

-- GLOBAL İŞLEVLER

-- genel parametre inceleme ve düzenlenmesi
function args_handler()
  -- parametrelere dönük özel işler yapılır.
  color_check()
  rootfs_check()
  --mps init kontrolü
  if args.ilk    then mps_init()   end
  if args.ilkds then mps_initfs() end
  
  local komut_islev={["in"]="indir",der="derle",kur="kur",
				sil="sil",gun="guncelle",ara="ara",
				sor="sorgu",bil="bilgi",kos="kos"}
  
  if args.command then
	local islev=komut_islev[args.command]
	if islev then
		if islem[islev] then
			islem[islev]["handler"](args)
		else
			print("not implemented yet")
		end
	--islem[args.command]["handler"](args)
	else
		print("not implemented yet")
	end
  end
end

-- root yetkili kontrolü
function authorised_check()
	if not os.getenv("MPS_NOROOT") then
		local me=os.getenv("USER")
		if me ~= "root" then
			messages.need_root:yaz(0)
		end
	end
end

-- parametre analiz/ color option check
function color_check()
	if args.renk == "0" then util.renkli=false end
	if args.renk == "1" then util.renkli=true end
end

-- parametre analiz/ package management root check
function rootfs_check()
	if args.kok:sub(-1) ~= "/" then args.kok=args.kok.."/" end
	kokdizin=args.kok
	-- kok dizin kontrolü yapıldıktan sonra alt dizin kontrolleri
	--[[
	-- milis dizini yoksa oluşturuyoruz.
	if path_exists(milispath) == false then
		shell("mkdir -p "..kokdizin..milispath)
	end

	-- talimat dizini yoksa oluşturuyoruz.
	if path_exists(talimatname) == false then
		shell("mkdir -p "..kokdizin..talimatname)
	end
	]]--
end

function mps_init()
	-- mps için gerekli dizinlerin oluşturulması
	-- /var/lib/mps/db
	local create_tmp=("mkdir -p %s"):format(kokdizin.."tmp")
	local create_db=("mkdir -p %s"):format(kokdizin..islem.paket.vt)
	local create_logs=("mkdir -p %s%s"):format(kokdizin,islem.paket.logdir)
	local create_log_k=("mkdir -p %s%s"):format(kokdizin,islem.kur.logdir)
	local create_log_s=("mkdir -p %s%s"):format(kokdizin,islem.sil.logdir)
	local create_cache=("mkdir -p %s%s"):format(kokdizin,islem.paket.cachedir)
	shell(create_tmp)
	shell(create_db)
	shell(create_logs)
	shell(create_log_k)
	shell(create_log_s);
	shell(create_cache);
	(messages.init_is_ok..kokdizin):yaz()
end


-- mps dosya sistemi ilkleme
function mps_initfs()
	-- Milis için gerekli dizinlerin oluşturulması
	local initfs_komut=("bash %s/conf/init_rootfs.sh %s"):format(mps_path,kokdizin)
	shell(initfs_komut);
	--print(initfs_komut);
	(messages.initfs_is_ok..kokdizin):yaz()
end

function sleep(n)
  -- waits for the passed time, letting the coroutine world spin
  local t0 = os.clock()
  while os.clock() - t0 <= n do
	coroutine.yield()
  end
end

-- Diyalog İşlemleri

islem.diyalog={}

function islem.diyalog.onay(mesaj)
	local answer="-"
	if mesaj == nil then mesaj="?(y/n)" end
	repeat
	io.write(mesaj)
	io.flush()
	answer=io.read()
	until answer=="y" or answer=="n" or answer=="e" or answer=="h"
	if answer=="y" or answer=="e" then return true
	else return false end
end

-- MPS İŞLEMLER

-- talimat bul
islem.talimat_bul={
	retkey="talimat_bul:",
}

function islem.talimat_bul.job(paket,hepsi)
	-- alfanumerik arama yapılır.
	-- 2.parametere tip=hepsi gönderilirse bütün arama sonuçları çevirilir.
	local komut=('find %s -name "%s#*" | sort -n | head -1'):format(talimatname,paket)

	if hepsi=="1" then
		komut=('find %s -name "*%s*" -type d | sort -n'):format(talimatname,paket)
	end
	--print(komut)
	local ret=shell(komut)
	if ret == "" then
		return false
	else
		return ret
	end
end

islem.ara={usage="",}

-- talimat bulma işlevi (mps bul talimat_isim)
function islem.ara.handler(input)
	local hepsi = input.hepsi
	local arlist={}
	
	-- konsoldan girilen paket girdi analiz
	if input.arama then
		for _,pk in ipairs(input.arama) do table.insert(arlist,pk) end
	end
	
	-- arama test işlevi
	if input.test then
		for _,pk in ipairs(arlist) do print("ar",pk) end
	end
		
	for _,arama in ipairs(arlist) do
		-- talimat araması ise
		if input.talimat then
			local ret=islem.talimat_bul.job(arama,hepsi)
			if ret then print(ret)
			else messages.talimat_not_found:yaz(0)
			end
		-- tanım araması ise
		elseif input.tanim then
			local kom='grep -r "^tanim*" %s |sed \'s/\\/talimat:tanim//\' | grep -i "%s"'
			--print(kom:format(talimatname,arama))
			local ret=shell(kom:format(talimatname,arama))
			if ret then print(ret) end
		-- parametre belirtilmediyse öntanımlı olarak paket araması uygulanır.
		else
			local kom=[[for vt in $(ls %s/paket.vt#*); do (printf '#';]]..
			[[echo "$vt"| cut -d'#' -f2);cat $vt | awk '{print $1,$2,$3}']].. 
			[[| grep  "%s" | column -t;done]]
			--print(kom:format(kokdizin..islem.paket.cachedir,arama))
			local ret=shell(kom:format(kokdizin..islem.paket.cachedir,arama))
			if ret then print(ret) end
		end
	end
end

--

-- Kaynak işlemleri
-- kaynak talimatın içerdiği kaynakları gösterecek
-- todo!!! bil altına alınacak
-- todo!!! talimat.lua ya göre güncel

islem.kaynak={
	usage="mps kaynak talimat_ismi",
	kontrol=false,
}

function islem.kaynak.handler(input)
	local liste={}
	if #input > 1 then
		-- 1 is talimat_bul işlemi
		local _islem=input[1]
		local girdi=input[2]
		local param=input[3]
		local dosya = girdi:match("^-%-dosya=(.*)$")

		if param and param:match("--kontrol") then islem.kaynak.kontrol=true end
		if dosya then
			if path_exists(dosya) then
				islem.kaynak.liste_dosyadan(dosya)
			else
				messages.file_not_found:format(dosya):yaz(0)
			end
		else
			-- girdi parametresi talimat olarak değerlendirelecek.
			local ret=islem.talimat_bul.job(girdi)
			if ret then
				-- kaynaklar kontrol edilecekse
				if islem.kaynak.kontrol then
					islem.kaynak.url_kontrol(islem.kaynak.liste(ret))
				-- kontrol yoksa sadece listeleme
				else
					tprint(islem.kaynak.liste(ret))
				end
			else
				messages.talimat_not_found:yaz(0)
			end
		end
	else
		(messages.usage..islem[_islem]["usage"]):yaz();
	end
end

-- talimata ait kaynakların listelenme işlevi
function islem.kaynak.liste(talimatd)
	assert(path_exists(talimatd),"talimat dizin not found!")
	local talimatf=talimatd.."/talimat"
	assert(path_exists(talimatf),talimatf.." file not found!")
	-- talimat dosyasından alınan kaynaklar bash ile yorumlanıp
	-- açık değerlerine çevirlecektir.
	local kliste={}
	local talimat=t.get(talimatd)
	local komut='url=%s && isim=%s && surum=%s && devir=%s && echo '
	komut=komut:format(talimat.paket.url,talimat.isim,talimat.surum,talimat.devir)
	for _,val in ipairs (t.kaynaklar(talimat)) do
		table.insert(kliste,shell(komut..val))
	end
	return kliste
end

-- dosyadaki talimata ait kaynakların listelenme işlevi
function islem.kaynak.liste_dosyadan(dosya)
	local ret=nil
	for pk in (get_content(dosya)):gmatch("[^\r\n]+") do
		ret=islem.talimat_bul.job(pk)
		if ret then
			-- kaynaklar kontrol edilecekse
			if islem.kaynak.kontrol then
				islem.kaynak.url_kontrol(islem.kaynak.liste(ret))
			-- kontrol yoksa sadece listeleme
			else
				tprint(islem.kaynak.liste(ret))
			end
		else
			messages.talimat_not_found:yaz(0)
		end
	end
end

-- talimata ait kaynakların url aktif kontrolü
function islem.kaynak.url_kontrol(kaynaklar)
	local komut="wget -q --spider %s && echo $?"
	local ret=""
	for _,kaynak in ipairs(kaynaklar) do
		if kaynak:match("http") or kaynak:match("https") then
			ret=shell(komut:format(kaynak))
			if ret == "0" then
				print(kaynak, "OK")
			else
				print(kaynak, "NOT")
			end
		else
			print(kaynak, "PASS")
		end
	end
end


-------

---------- Gerekler İşlemler ----------

islem.gerek={
	retkey="gerek:",
	usage="mps gerek paket_ismi tip",
	-- aktif gerek listesi
	liste={},
	-- aktif gereklerin eklenme kontrol listesi
	list={},
}

function islem.gerek.job(talimatd,tip)
	assert(talimatd,"talimatd is nil!")
	local talimat=t.load(talimatd.."/talimat",{"derle","pakur","kaynak"})
	--todo!!! sonsuz gerek döngüsü engellenecek.
	-- gereklerin toplanan listeye eklenmesi
	-- işlem yapıldığına dair imleç hareketi
	io.write(rotator_sym[ math.random( #rotator_sym) ].."\b")
    io.flush()
	
	local function ekle(talimatd)
		if islem.gerek.list[talimatd] == nil then
			islem.gerek.list[talimatd]=talimatd
			--print("e",talimatd)
			table.insert(islem.gerek.liste,talimatd)
		end
	end

	-- talimatın libgerekler dosyasının analiz edilmesi
	local function oto_rdeps(talimatd)
		if path_exists(talimatd.."/"..islem.shlib.dosya) then
			local sh_tal=""
			local shlibs=get_content(talimatd.."/"..islem.shlib.dosya)
				for sh in shlibs:gmatch("[^\r\n]+") do
					sh_tal=islem.shlib.bul(sh,"-t","ilk")
					if sh_tal and sh_tal ~= talimatd then
						--print("3",sh_tal)
						islem.gerek.job(sh_tal,"c")
					end
				end
		end
	end

	-- alt gereklerin dolaşılması
	local function gerek_dolas(dep,talimatd)
		local _td=islem.talimat_bul.job(dep)
		-- bir önceki paketin kurulabilir değeri iptal ediliyor
		local kurulabilir=false
		if _td then
			-- bir paketin depodaki bulunma durumuna göre
			-- derleme ve çalışma gereklerinin araştırılması yapılmaktadır.
			-- çalışma gerek araşırılmasında da aynı durum kontrol edilmektedir.
			-- todo!!! alt işleve alınacak alttaki operasyon
			tsd=get_basename(_td)
			for _,b in ipairs(islem.paket.pkvt_bilgi(dep)) do
				pksd=pgf:format(b.isim,b.surum,b.devir)
				if tsd == pksd then
					kurulabilir=b
					break
				end
			end
			if kurulabilir then
				tip="c"
			else
				tip="d"
			end

			islem.gerek.job(_td,tip)
		else
			(messages.talimat_not_found..talimatd..":"..dep):yaz(0)
		end
	end
	-- ikincil dolasma engelleme
	if islem.gerek.list[talimatd] == nil then
		-- talimatdaki gerek kısmının analiz edilmesi - ana iskelet
		if talimat["gerek"] then
			local rdeps=talimat["gerek"]["calisma"]
			local bdeps=talimat["gerek"]["derleme"]
			local kurulabilir=false
			if tip == "d" and bdeps then
				for dep in bdeps:gmatch('([^%s]+)') do
					gerek_dolas(dep,talimatd)
				end
			elseif rdeps then
				for dep in rdeps:gmatch('([^%s]+)') do
					gerek_dolas(dep,talimatd)
				end
			end
			oto_rdeps(talimatd)
			ekle(talimatd)
		else
			oto_rdeps(talimatd)
			ekle(talimatd)
		end
	end

end

islem.tgerek={comment=messages.comment_mps_rev_dep,}

function islem.tgerek.job(paket, tip)
	print("Ters gerekler:");
	print("-------------------")
	local local_paketler={}
	if tip == "d" then
		-- derleme
		local komut="grep -r ' *derleme *= *' %s | grep  ' %s$\\| %s \\|=%s$\\|=%s ' | cut -d':' -f1 | xargs -I {} dirname {} | xargs -I {} basename {} | cut -d'#' -f1"
		ret=shell(komut:format(talimatname,paket,paket,paket,paket))
		for line in ret:gmatch("[^\r\n]+") do
			table.insert(local_paketler, line)
		end
	else
		-- calistirma
		-- talimat dosyasindan
		local komut="grep -r ' *calisma *= *' %s | grep  ' %s$\\| %s \\|=%s$\\|=%s ' | cut -d':' -f1 | xargs -I {} dirname {} | xargs -I {} basename {} | cut -d'#' -f1"
		ret=shell(komut:format(talimatname,paket,paket,paket,paket))
		for line in ret:gmatch("[^\r\n]+") do
			table.insert(local_paketler, line)
		end
		-- libgerek dosyasindan
		local talimatd=islem.talimat_bul.job(paket)
		if path_exists(talimatd.."/".."pktlibler") then
			local sh_tal=""
			local shlibs=get_content(talimatd.."/".."pktlibler")
				for sh in shlibs:gmatch("[^\r\n]+") do
					local komut=("grep -ril --include=libgerekler '%s$' %s | xargs -I {} dirname {} | xargs -I {} basename {} | cut -d'#' -f1"):format(sh,talimatname)
					sh_tal=shell(komut)
					for line in sh_tal:gmatch("[^\r\n]+") do
						if not has_value(local_paketler, line) then
							table.insert(local_paketler, line)
						end
					end
				end
		end
	end
	tprint(local_paketler)
	print("-------------------")
end

------------------------------------------

-- Derle işlemi

islem.derle={
	retkey="derle:",
	usage="mps derle paket_ismi",
}

function islem.derle.handler(input)
	local derlist={}
	
	local hedefkur=false
	if input.kur then
		hedefkur=true
	end
	
	local function pk_analiz(talimat)
		local _durum=islem.talimat_bul.job(talimat)
		if _durum then
			table.insert(derlist,talimat)
		else
			(messages.talimat_not_found..talimat):yaz(0)
		end
	end
	
	-- konsoldan girilen paket girdi analiz
	if input.paket then
		for _,pk in ipairs(input.paket) do pk_analiz(pk) end
	end
	
	-- dosya parametresi içerik girdi analiz
	if input.dosya then
		if path_exists(input.dosya) then
			for pk in (get_content(input.dosya)):gmatch("[^\r\n]+") do 
				pk_analiz(pk)
			end
		else	
			messages.file_not_found:format(dosya):yaz(0)
		end
	end
	
	-- derle test işlevi
	if input.test then
		for _,pk in ipairs(derlist) do print("d",pk) end
	else
		-- test yoksa derle işlemi yapacak
		for _,dpaket in ipairs(derlist) do
			if input.tek then
				islem.derle.tek(dpaket)
			else
				islem.derle.job(dpaket,hedefkur)
			end
		end
	end
end

function islem.derle.job(paket,hedefkur)
	--talimatın konumu bulunarak gelecek handler den
	local ret=islem.talimat_bul.job(paket)
	local retq=nil
	-- pk   = paket isim
	-- pksd = ağdaki paket sürüm-devir
	-- tsd  = talimat sürüm-devir
	-- ksd  = kurulu sürüm-devir
	local pk,pksd,tsd,ksd=""
	local derlet=false
	local kurulabilir=false
	local eski_sil=false

	-- derleme işlemi
	-- todo!!! mpsd.lua lib olarak çağrılacak sonra, şu an shell
	-- 1. Derleme gerekleri bul.
	islem.gerek.job(ret,"d")
	--tprint(islem.gerek.liste)
	-- 2. Döngüde gerekler incelenir.
	for _,talimatd in ipairs(islem.gerek.liste) do
		-- her gerekte derletme ve kurulma durumları sıfırlanacak.
		derlet=false
		kurulabilir=false
		-- 2.1 kurulu kontrol
		tsd=get_basename(talimatd)
		pk,_=tsd:match("([%a%d-_+]+)#+")
		-- kurulu kontrol , link dizin dönüşü ile
		ksd=islem.paket.kurulu_kontrol(pk)
		-- 2.1.1 paket kurulu ise sürüm-devir uyum kontrolü yapılır.
		if ksd then
			-- ksd kurulu yol, sadece talimat isim formatı
			ksd=get_basename(ksd)
			if tsd ~= ksd then
				print("kurulu sürümd ile derlenmesi gereken sürümd farklı-derlenecek!")
				-- paket kurulu sd uyumsuzluğu var
				-- paketi sildir(onaylı?) ve derlet
				-- önemli !!!-eski paketi derleme başarılı olursa sildir.
				derlet=true
				eski_sil=true
			else
				messages.package_already_installed_and_uptodate:format(pk):yaz(2)
				goto continue
			end
		-- 2.1.2 paket kurulu değilse ağdan indirilip kurulacak
		end
		-- ağdaki paketin surumdeviri incelenecek
		-- tsd ile pksd karşılaştır
		-- paket.vt lerdeki paket sürüm-devir bilgileri taranacak.
		-- tsd e eşleşen bulunursa eşleşen! indirilecek yoksa derletilecek.
		-- pakete ait depolarda bulduğu pkvt bilgisini getirecek.
		for _,b in ipairs(islem.paket.pkvt_bilgi(pk)) do
			pksd=pgf:format(b.isim,b.surum,b.devir)
			if tsd == pksd then
				--print(pk,b.depo,"bulundu.")
				kurulabilir=b
				break
			end
		end
		-- kurulabilir nesnesine ağdaki paket bilgisi atılacak.
		if kurulabilir then
			-- paket önbellekte varsa
			-- shasum kontrolü yapılıp yerelden kurulma yapılacak.
			-- ağdan indirmeden önce önbellekte kontrol edecek
			local _pkt=paf:format(pk,kurulabilir.surum,kurulabilir.devir)
			local kur_onay=false
			local _indir=false
			local _pktyol=kokdizin..islem.paket.cachedir.."/".._pkt
			if path_exists(_pktyol) then
				if hash_check(_pktyol,kurulabilir.shasum) == false then
					--delete file
					shell("rm -f ".._pktyol)
					_indir=true
				end	
			else
			   -- önbellekte yoksa veya hash uyumsuzsa indirilecek
			   _indir=true
			end
			if _indir == true then
				islem.indir.handler({paket={pk}})
			end
			-- todo!!! paket önbellekte ise hash kontrolü yapılıyor - indikten sonra da yapılmalı.
			-- indirilememe veya herhangi bir nedenden paketin önbellekte hazır olmaması durumu
			if not path_exists(_pktyol) then
				messages.package_not_found:format(_pktyol):yaz(0)
			else
				-- ağdan inen veya önbellekteki paket kurulabilir
				-- ayrıca eski paket kurulu ise kaldırılacak.
				if eski_sil == true then
					print("eski sürüm paket tespit edildi, kaldırılacak")
					islem.sil.handler({paket={pk}})
				end
				--print(_pktyol,"kurulacak")
				islem.kur.yerelden(_pktyol)
				-- paket kurulduysa eğer eski sürümden dolayı onay verilen derletme
				-- işlemi iptal edilecektir.
				derlet=false
			end
		else
			derlet=true
		end

		-- 2.2 derleme
		if derlet == true then
			-- aktif oluşan paket arşiv
			local mimari=shell("uname -m")
			local pkarsiv=tsd..".kur"
			-- hedef paket isimleri
			local hpksd=get_basename(ret)
			local hdarsiv=hpksd..".kur"
			-- 2.2.1 talimat derle
			print(talimatd,"tl derlenecek")
			local komut="%s/bin/mpsd.lua %s 2>&1 | tee  %s.log"
			os.execute(komut:format(mps_path, talimatd, pk))
			-- 2.2.2 üretilen paketi kur
			-- hedef üretilmek istenen pakete gelindiğinde
			-- bu noktada derleme başarılı olup paket üretildiği
			-- kontrol edilerek eski sürüm paket kaldırılır.

			if pk == paket then
				-- mps derle paket --kur seçeneğine bakılacak.
				if hedefkur == true then
					-- hedef paket arşivi
					if path_exists(paketleme_dizin.."/"..hdarsiv) then
						if eski_sil then islem.sil.handler({paket={pk}}) end
						print(paket.." hedef paket de kurulacak.")
						islem.kur.yerelden(paketleme_dizin.."/"..hdarsiv)
					else
						messages.package_not_found:format(hdarsiv):yaz(0)
					end
				end
			else
				-- altgereklerin oluşan paketleri zorunlu kurulacak
				if path_exists(paketleme_dizin.."/"..pkarsiv) then
					if eski_sil then islem.sil.handler({paket={pk}}) end
					islem.kur.yerelden(paketleme_dizin.."/"..pkarsiv)
				else
					messages.package_not_found:format(pkarsiv):yaz(0)
				end
			end
		end
		::continue::
	-- for bitiş
	end
	--print(paket.." derleme bitti")
end

function islem.derle.tek(paket)
	--talimat konum bul
	ret=islem.talimat_bul.job(paket)
	if ret then
		print(ret.." derlenecek")
		local komut="%s/bin/mpsd.lua %s 2>&1 | tee  %s.log"
		os.execute(komut:format(mps_path, ret, paket))
	else
		(messages.talimat_not_found..paket):yaz(0)
	end
end

------------------------------

-- Paket Arşiv işlemleri
islem.arsiv={
	retkey="arşiv:",
}

-- Milis paketi ön kontrolleri
function islem.arsiv.kontrol(paket)
	-- kullanıcı hedefli de çıktı verilebilinir.
	assert(path_exists(paket),"islem.arsiv.kontrol : paket is not found")
	assert(paket:match("kur"),"islem.arsiv.kontrol : paket suffix is not kur")
	assert(get_size(paket) ~=0,"islem.arsiv.kontrol : paket size equals zero")

	local isd = get_basename(paket)
	local isim,surum,devir=isd:match(paket_arsiv_pattern)
	if not (isim and surum and devir) then
		print(messages.valid_format..paf:format(isim,surum,devir));
		(messages.package_name_format_not_valid..isd):yaz(0)
	end
	-- bir kontrol de tar ile içeriden paket bilgi dosyası çekilebilir
	-- bu kontrol extract den sonra yapılabilir, aynı işlemi tekrarlamamak için
	--("arşiv_kontrol:\tOK"):yaz();
	islem.debug.yaz(messages.package_archive_check_ok)
	return isim,surum,devir
end

function islem.arsiv.tempdir(paket)
	-- paket arşivinin açılacağı temp dizin ayarlanması
	assert(paket,"islem.arsiv.tempdir : paket is nil")
	local tempdir=kokdizin.."tmp/"..(get_basename(paket))..".tmpdir"
	assert(tempdir ~= "/tmp","islem.arsiv.tempdir : tempdir must not be /tmp")
	assert(tempdir ~= "/","islem.arsiv.tempdir : tempdir must not be /")
	-- paketin açılacağı tempdir oluşturma
	local tempdir_komut=("rm -rf %s && mkdir -p %s"):format(tempdir,tempdir)
	shell(tempdir_komut)
	return tempdir.."/"
end

-- Milis paketi dışarı çıkarma/extract
function islem.arsiv.cikar(paket)
	-- ön kontrollerin yapıldığı varsayılıyor/handler func ile ?
	-- extract komutu
	local tempdir=islem.arsiv.tempdir(paket)
	assert(tempdir,"islem.arsiv.cikar : tempdir is nil")
	-- paketin açılması
	local komut=("%s xf %s -C %s"):format(arsivci,paket,tempdir)
	ret=shell(komut);
	-- arşiv çıkarılması test edilecek!!!
	local log=messages.package_archive_extract_ok;
	islem.debug.yaz(log);
	islem.kur.logger:write(log.."\n")

	return tempdir
end
------------------------------

-- Shared Libs(Paylaşılan kütüphaneler) işlemleri

islem.shlib={
	retkey="shlib:",
	dosya="libgerekler",
}

--  -libbul
islem.api.libbul={
	usage="",
	comment="Bir .so dosyasını içeren paket veya talimatı bulur."
}
islem.api.libbul.job=function (params)
	local shlib=nil
	local param=params[2]
	if param == "-t" then
		shlib=params[3]
	else
		shlib=param
	end
	if shlib then
		print(islem.shlib.bul(shlib,param,"hepsi"))
	else
		messages.args_at_least_one:yaz(0)
	end
end


function islem.shlib.kontrol(tempdir)
	-- shlib kontrolü / altına kurulumlarda yapılabilir
	-- farklı bir kök altına kurulumlar için
	-- shlib dosya arama yoluyla olabilir.
	local log=""
	local ldconfig_bin="/usr/bin/ldconfig"
	if kokdizin == "/" and path_exists(ldconfig_bin) then
		assert(tempdir,"islem.shlib.kontrol : tempdir is nil")
		local shlibdos=tempdir..islem.paket.metadir..islem.shlib.dosya
		local pklibdos=tempdir..islem.paket.metadir..islem.paket.pktlib_dosya
		local iclib_kontrol=false
		if path_exists(pklibdos) then iclib_kontrol=true end
		if path_exists(shlibdos) and get_size(shlibdos) > 0 then
			local shlibs=get_content(shlibdos)
			for sh in shlibs:gmatch("[^\r\n]+") do
				if iclib_kontrol and has_line(pklibdos,sh) then
					log="shlib.kontrol\tOK";
				elseif not islem.shlib.exist(sh) then
					(messages.shlib_not_exits..sh):yaz(3)
				end
			end
		end
		log="shlib.kontrol\tOK";
		islem.debug.yaz(log);
		islem.kur.logger:write(log.."\n")
	else
		log="shlib.kontrol\tPASS";
		islem.debug.yaz(log);
		islem.kur.logger:write(log.."\n")
	end
end

function islem.shlib.exist(shlib)
	assert(shlib,"islem.shlib.exist : shlib is nil")
	local komut="ldconfig -p | grep "..shlib.." > /dev/null;echo $?"
	--local komut='ldconfig -p | grep '..shlib..' | awk \'{split($0,a,"=> "); print a[2]}\' | xargs -r ls > /dev/null 2>&1;echo $?'
	ret=shell(komut)
	assert(ret~="","islem.shlib.exist : ret is empty")
	--print (ret,komut)
	if ret == "0" then return true end
	return false
end

function islem.shlib.bul(shlib,param,show_opt)
	assert(shlib,"islem.shlib.bul : shlib is nil")
	local opt=" | head -n1"
	if show_opt=="hepsi" then
		opt=""
	end
	if param=="-t" then
		local komut=("grep -r -i -l --include=\\%s '%s$' %s | xargs -I {} dirname {} %s "):format(islem.paket.pktlib_dosya,shlib,talimatname,opt)
		ret=shell(komut)
		if ret ~= "" then
			return ret
		end
	else
		-- todo!!! kurulu paketler için yapılacak
		return nil
	end
end
------------------------------

-- İçbilgi(mtree) işlemleri

-- içbilgi içindeki dosyaları yazdırmak
islem.api.ib={
	usage="",
	comment="",
}

islem.api.ib.job=function (params)
	local paket=params[2]
	local ibdos=islem.icbilgi.dosyalar(kokdizin..islem.paket.vt..paket.."/")
	if ibdos then
		for _,dos in ipairs(ibdos) do
			print(dos)
		end
	end
end

islem.icbilgi={
	retkey="icbilgi:",
	dosya=".icbilgi",
}

function islem.icbilgi.dosyalar(tempdir)
	assert(tempdir,"islem.icbilgi.dosyalar : tempdir is nil")
	-- bu hata kullanıcı tanımlı olabilir.
	local icdosya=tempdir..islem.icbilgi.dosya
	assert(path_exists(icdosya),"islem.kur.dosya_kontrol : icbilgi is not found")
	assert(get_size(icdosya) > 0,"islem.kur.dosya_kontrol : icbilgi size equals zero")
	local tmpdos=shell("mktemp")
	local komut="zgrep -i './' "..icdosya.."| grep -v 'type=dir' | cut -d' ' -f1 > "..tmpdos
	shell(komut)
	local pdoslar=get_content(tmpdos)
	local dosyalar={}
	-- .icbilgi içindeki dosyalar döngüde tabloya eklenir.
	-- diğer dosyalar elenerek.
	for dos in pdoslar:gmatch("[^\r\n]+") do
		if dos:match(".ustbilgi")   then
		elseif dos:match("libgerekler") then
	    elseif dos:match("pktlibler")   then
	    elseif dos:match(".meta")   then
		else
			--print(dos:sub(3))
			table.insert(dosyalar,dos:sub(3))
		end
	end
	shell("rm "..tmpdos)
	return dosyalar
end

-- sha256digest eşitliğinden match edip değer karşılaştırma
function islem.icbilgi.hash_kontrol(dir,dosya)
	assert(dir,"islem.icbilgi.hash_kontrol : dir is nil")
	local icdosya=dir..islem.icbilgi.dosya
	local komut=("zgrep -i '%s ' %s | grep -v 'type=dir' | grep -v 'type=link'"):format(dosya,icdosya)
	local ret=shell(komut)
	local hash_pattern="sha256digest=(.*)"
	local ic_hash=ret:match(hash_pattern)
	local komut2=("sha256sum %s"):format(kokdizin..dosya)
	local ret2=shell(komut2)
	local d_hash=ret2:match("%S+")
	if ic_hash == d_hash then
		--print(dosya)
		--print(ic_hash,d_hash)
		return true
	end

	return false
end

------------------Paket ve Veritabanı İşlemleri-----------------------

islem.paket={
	retkey="paket:",
	vt="var/lib/mps/db/",
	logdir="var/log/mps/",
	--cachedir="tmp",
	cachedir="var/cache/mps/depo",
	pktlib_dosya="pktlibler",
	ustbildos=".ustbilgi",
	metadir=".meta/",
}

------------------Bilgi  İşlemleri-----------------------

islem.bilgi={retkey="bilgi:",}

function islem.bilgi.job(info)
	-- todo!!!  kurulu paket ve talimatnamedeki talimat özbilgileri ayrılacak
	-- parametrelerle ayrılacak...
	-- bu işlev yeniden değerlendirilecek
	-- önce kurulu kontrol yapılıp kurulu ise yerel vt den bilgi alınacak.
	local isim,surum,devir,tanim,paketci,url,grup,mimari,aboyut,kboyut,durum=""
	-- todo!!! diğer durumlarda incelenebilir talimat, paketvt den bilgi alımı?
	if info.durum == "kurulu" then
		local kpb=islem.paket.kurulum_bilgileri(info.paket)
		isim,surum,devir,tanim=kpb.isim,kpb.surum,kpb.devir,kpb.tanim
		url,paketci,grup,mimari=kpb.url,kpb.paketci,kpb.grup,kpb.mimari
		kboyut=byte_convert(kpb.boyut)
		aboyut=nil
		if info.talimatdir == false then info.durum= info.durum.." (talimatı yok)" end
		durum=info.durum
	else
		--talimat ayrıştırıcı kullanılarak talimat bilgileri alınır.
		local talimat_dir=shell("readlink -f "..info.talimatdir)
		local isd=shell("basename "..talimat_dir)
		local input=t.load(talimat_dir.."/talimat",{"derle","pakur","kaynak"})
		
		input.paket.isim=isd:split("#")[1]
		input.paket.surum=isd:split("#")[2]:split("-")[1]
		input.paket.devir=isd:split("#")[2]:split("-")[2]
		-- genel değişken atamaları
		isim=input.paket.isim
		tanim=input.paket.tanim
		grup=input.paket.grup
		url=input.paket.url
		paketci=input.paket.paketci
		-- kurulu değil ise paket.vt'den bilgileri al
		local pbs = islem.paket.pkvt_bilgi(isim)
		-- todo!!! nil değer gelmeme kontrol edilecek
		--paket.vt dosyasindaki gerekli girdileri al
		local pb = pbs[1]
		if pb == nil then
			surum=input.paket.surum
			devir=input.paket.devir
		else
			aboyut=byte_convert(pb.aboyut)
			kboyut=byte_convert(pb.kboyut)
			surum=pb.surum
			devir=pb.devir
			mimari=pb.mimari
		end
		durum=messages.not_installed
	end
	print(("%-13s : %s"):format(messages.package_info_name,isim))
	print(("%-13s : %s"):format(messages.package_info_desc,tanim))
	print(("%-13s : %s"):format(messages.package_info_group,grup))
	print(("%-13s : %s"):format(messages.package_info_url,url))
	print(("%-13s : %s"):format(messages.package_info_packager,paketci))
	print(("%-13s : %s"):format(messages.package_info_version,surum))
	print(("%-13s : %s"):format(messages.package_info_release,devir))
	print(("%-13s : %s"):format(messages.package_info_arch,mimari))
	print(("%-13s : %s"):format(messages.package_info_pack_size,aboyut))
	print(("%-13s : %s"):format(messages.package_info_inst_size,kboyut))
	print(("%-13s : %s"):format(messages.package_info_status,durum))
	print("-----------------------------------------")
end

function islem.bilgi.handler(input)
	local blist={}
	local durum=""
	-- todo!!! farklı bilgi parametreleri olacak
	local function pk_analiz(_paket)
		local path = islem.talimat_bul.job(_paket)
		
		if islem.paket.kurulu_kontrol(_paket) then
			blist[_paket]={durum="kurulu",talimatdir=path}
		elseif path then
			blist[_paket]={durum="talimat",talimatdir=path}
		else
			messages.package_not_found:format(_paket):yaz(0)
		end
	end
	
	local function status_print(tdir)
		local _pk,_=tdir:match("([%a%d-_+]+)#+")
		if islem.paket.kurulu_kontrol(_pk) then 
			print(("%-25s : %s"):format(get_basename(tdir),"+"))
		else
			print(("%-25s : %s"):format(get_basename(tdir),"-")) 
		end
	end
	
	-- konsoldan girilen paket girdi analiz
	if input.paket then
		for _,pk in ipairs(input.paket) do pk_analiz(pk) end
	end
	
	-- bilgi test işlevi
	if input.test then
		for pk,info in pairs(blist) do print(pk,info.durum,info.talimatdir) end
	else
		-- test olmadığı durumdaki işleyiş
		for paket,info in pairs(blist) do
			if input.gerek == "d" or input.gerek == "c"  then
				islem.gerek.job(info.talimatdir,input.gerek)
				print("-------")
				for _,tdir in ipairs(islem.gerek.liste) do 
					status_print(tdir)
				end 
			elseif input.gerek == "td" or input.gerek == "tc" then
				islem.tgerek.job(paket,input.gerek:sub(2))	
			-- bu api erişimleri tablodan sağlanacak
			elseif input.kk then
				islem.api.kk.job(paket)
			elseif input.kdl then
				print(islem.paket.kurulu_icerik(paket))
			elseif input.pl then
				print(islem.paket.pktlibler(paket,"-t"))
			elseif input.lg then
				print(islem.paket.libgerekler(paket,"-t"))
			elseif input.pkd then
				print(islem.paket.kurulum_dogrula(paket))	
			else
				info.paket=paket
				islem.bilgi.job(info)
			end
		end
	end
end

-- -kk kurulu kontrol
islem.api.kk={
	usage="",
	comment="bir paketin kurulu olma durumunu verir.",
}

islem.api.kk.job=function (pk)
	--- todo!!!! değerlere çıktı verilecek.
	-- nil   : tanımsız
	-- true  : kurulu
	-- false : kurulu değil
	if islem.paket.kurulu_kontrol(pk) then
		messages.installed:yaz(1)
	else
		messages.not_installed:yaz(3)
	end
end

-- -pkd paket kurulum doğrula
islem.api.pkd={
	usage="",
	comment="",
}

-----
function islem.paket.pktlibler(paket)
	-- kurulu olan bir paketin pktliblerini gösterir.(shlibs)
	-- önce kurulu kontrol edilir
	assert(paket,"paket param is nil")
	local icerik=""
	-- talimatnameden bakılması istenirse
	
	local _talimatd=islem.talimat_bul.job(paket)
	if _talimatd then
		if path_exists(_talimatd.."/"..islem.paket.pktlib_dosya) then
			icerik=get_content(_talimatd.."/"..islem.paket.pktlib_dosya)
		end
		print(icerik)
		print("-----------------------------")
	else
		(messages.talimat_not_found..paket):yaz(0)
	end
	-- paket kurulu ise onun da pl bilgisi gösterilecek
	if islem.paket.kurulu_kontrol(paket) then
		local _file=kokdizin..islem.paket.vt..paket.."/"..islem.paket.metadir..islem.paket.pktlib_dosya
		assert(path_exists(_file),"file not found "..islem.paket.pktlib_dosya)
		icerik=get_content(_file)
		print(icerik)
	end
	
end

function islem.paket.libgerekler(paket,param)
	-- kurulu olan bir paketin gerek duyduğu libleri gösterir.(needed shlibs)
	-- önce kurulu kontrol edilir
	assert(paket,"paket param is nil")
	local icerik=""
	-- talimatnameden bakılması istenirse
	
	local _talimatd=islem.talimat_bul.job(paket)
	if _talimatd then
		if path_exists(_talimatd.."/"..islem.shlib.dosya) then
			icerik=get_content(_talimatd.."/"..islem.shlib.dosya)
		end
		print(icerik)
		print("-----------------------------")
	else
		(messages.talimat_not_found..paket):yaz(0)
	end
	-- paket kurulu ise onun da lg bilgisi gösterilecek
	if islem.paket.kurulu_kontrol(paket) then
		local _file=kokdizin..islem.paket.vt..paket.."/"..islem.paket.metadir..islem.shlib.dosya
		assert(path_exists(_file),"file not found "..islem.shlib.dosya)
		icerik=get_content(_file)
		print(icerik)
	end
	
end

function islem.paket.pkvt_bilgi(paket)
	-- bir paket hakkında pkvt leri tarayarak bilgi toplar.
	local paketler={}
	local i=0
	-- isim,surum,devir,mimari,aboyut,kboyut,shasum içeriği olacak.
	local fields={"isim","surum","devir","mimari","aboyut","kboyut","shasum","depo"}
	local ret=""
	local komut='find %s -name "paket.vt#%s" -exec grep -i "^%s " {} \\; | sort -n'
	-- islem.paket.cachedir altında paketleri arayacak.
	-- {} /dev/null \; olursa eşleşen dosya ismi de gelir.
	-- en azından paket.vt#1 dosyası bulunmalıdır ki tarama yapılabilsin
	--if path_exists(islem.paket.cachedir.."/paket.vt#1") then

	for sira=1,#ayar.sunucu do
		if path_exists(kokdizin..islem.paket.cachedir.."/paket.vt#"..sira) then
			ret=shell(komut:format(kokdizin..islem.paket.cachedir,sira,paket))
			for satir in ret:gmatch("[^\r\n]+") do
				local _paket={}
				for bilgi in satir:gmatch("%S+") do
					i = i + 1
					_paket[fields[i]]=bilgi
				end
				-- depo bilgisi conf.lua dan alınıp eklenecek.
				_paket.depo=ayar.sunucu[sira]
				table.insert(paketler,_paket)
				i=0
			end
		else
			(sira..". "..messages.paketvt_not_found):yaz(0)
		end
	end
	if #ayar.sunucu == 0 then
		messages.package_server_not_defined:yaz(3)
	end
	return paketler
end

function islem.paket.kurulu_kontrol(paket)
	-- bir paketin kurulu olup olmadığını vt e bakarak kontrol eder
	-- /var/lib/mps/DB/paket_ismi dizin kontrol eder
	-- dönüş olarak kurulu değilse nil kurulu ise link dizini döndürür.
	assert(paket,"islem.paket.kurulu_kontrol : paket is nil")
	local ret=""
	local komut='find %s -name "%s#*" -type l'
	if path_exists(kokdizin..islem.paket.vt..paket.."/"..islem.kur.kurulandos) then
		ret=shell(komut:format(kokdizin..islem.paket.vt,paket))
		assert(ret,paket.." link dizini yok!")
		return ret
	end
	return nil
end

function islem.paket.kurulu_icerik(paket)
	-- kurulu olan bir paketin kurulum içeriğini gösterir
	-- önce kontrol edilir
	assert(paket,"islem.paket.kurulu_kontrol : paket is nil")
	if islem.paket.kurulu_kontrol(paket) then
		local _kurulan=kokdizin..islem.paket.vt..paket.."/"..islem.kur.kurulandos
		assert(path_exists(_kurulan),"islem.paket.kurulu_icerik : kurulan file not found")
		local icerik=get_content(_kurulan)
		print(icerik)
		-- clear screen
		--io.write("\27[2J")
	else
		messages.package_not_installed:format(paket):yaz(0)
	end
end

function islem.paket.kurulum_dogrula(paket)
	-- kurulu olan bir paketin dosyaları incelenerek kurulum doğrulaması yapılır
	-- mevcutluk ve hash kontrolü + izinler ! todo!!!
	assert(paket,"islem.paket.kurulum_dogrula : paket is nil")
	if islem.paket.kurulu_kontrol(paket) then
		-- paket dizin kaydı
		local pdk=kokdizin..islem.paket.vt..paket.."/"
		local dosyalar=islem.icbilgi.dosyalar(pdk)
		for _,dosya in ipairs(dosyalar) do
			-- 1. dosya mevcut kontrolü
			if not path_exists(kokdizin..dosya) then
				messages.file_not_found:format(kokdizin..dosya):yaz(3)
			end
			-- 2. hash kontrolü
			if lfs.symlinkattributes(kokdizin..dosya, "mode") ~= "directory" and
			lfs.symlinkattributes(kokdizin..dosya, "mode") ~= "link" then
				if not islem.icbilgi.hash_kontrol(pdk,dosya) then
					messages.hash_not_match:format(kokdizin..dosya):yaz(3)
				end
			end
		end

	else
		messages.package_not_installed:format(paket):yaz(0)
	end
end

function islem.paket.kurulum_bilgileri(paket)
	-- kurulu olan bir paketin üstbilgi dosyası incelenerek bilgiler döndürülür.
	assert(paket,"islem.paket.kurulum_bilgileri : paket is nil")
	local _pb={}
	local sahalar={"isim","surum","devir","tanim","url","paketci","grup","boyut","derzaman","thash","mimari"}
	local _file=kokdizin..islem.paket.vt..paket.."/"..islem.paket.metadir..islem.paket.ustbildos
	if path_exists(_file) then
		for line in (get_content(_file)):gmatch("[^\r\n]+") do 
			for _,saha in ipairs(sahalar) do
				val=line:match(saha.."=(.*)")
				if val then _pb[saha]=val end
			end
		end
	else	
		messages.file_not_found:format(_file):yaz(0)
	end
	return _pb
end

------------------------------

------------------Sorgu  İşlemleri-----------------------

islem.sorgu={retkey="sorgu:",}

function islem.sorgu.handler(input)
	-- todo!!! farklı sorgu parametreleri olacak
	
	-- sorgu test işlevi
	if input.test then
		print("sorgu işlevi testleri...")
	end
		
	-- kurulu paketlerin listesi
	if input.kpl then
		local komut="find %s -mindepth 1 -maxdepth 1 -type l -exec basename {} \\;"
		local pvt=kokdizin..islem.paket.vt
		--print(shell(komut:format(pvt)))
		cikti=shell(komut:format(pvt))
		local isim,surum,devir="","",""
		for line in cikti:gmatch("[^\r\n]+") do 
			isim,surum,devir=line:match("([%a%d-_+]+)#([%d%a.]+)-([%d]+)")
			print(("%-20s %-9s %-3s"):format(isim,surum,devir))
		end
	end
	
	-- depolardaki paketlerin listesi
	if input.dpl then
		local komut="cat %s/paket.vt#* | awk '{print $1,$2,$3}' | column -t"
		local pcd=kokdizin..islem.paket.cachedir
		print(shell(komut:format(pcd)))
	end
	
	-- temel paketlerin listesi
	if input.tpl then
		local komut="ls -d %s/1/*#* | xargs -I {} basename {} | cut -d'#' -f1"
		print(shell(komut:format(talimatname)))
	end
	
	-- arama girdisinin hangi pakette geçtiğini bulur
	if input.hp then
		local aranan=input.hp
		local komut="grep -rli %s %s*#*/kurulan | cut -d '/' -f6"
		local komut='find  %s \\( -name "kurulan" \\) -exec grep -H "%s" {} \\;'
		local pvt=kokdizin..islem.paket.vt
		print(shell(komut:format(pvt,aranan)))
	end

end

------------------İndirme İşlemleri-----------------------
-- handler parametre analiz ve linki hazırlayacak
-- job direk linki hash kontrollü indirecek

islem.indir={
	retkey="indir",
	usage="mps indir paket_ismi",
	comment=messages.comment_mps_download
}

function islem.indir.handler(input)
	-- paket bilgileri yer alacak
	local inlist={}
	-- öntanımlı 1.depodan çekmektedir.
	local sira=1
	-- girdi olarak varsa depo sırası güncellenecek
	if input.sira then sira=tonumber(input.sira) end
	
	local function pk_analiz(pkt)
		local ret=islem.paket.pkvt_bilgi(pkt)
		if ret then
			-- indir işlemi paket bilgi tablosunu kullanacak.
			if ret[sira] then
				table.insert(inlist,ret[sira])
			else
				messages.package_not_found_inrepo:format(pkt):yaz(0)
			end
		else
			print(pak,"depolarda bulunamadı")
		end
	end
	
	-- konsoldan girilen paket girdi analiz
	if input.paket then
		for _,pk in ipairs(input.paket) do pk_analiz(pk) end
	end
	
	-- dosya parametresi içerik girdi analiz
	if input.dosya then
		if path_exists(input.dosya) then
			for pk in (get_content(input.dosya)):gmatch("[^\r\n]+") do 
				pk_analiz(pk)
			end
		else	
			messages.file_not_found:format(dosya):yaz(0)
		end
	end
	
	-- indirme test işlevi
	if input.test then
		for _,pk in ipairs(inlist) do print("s",pk) end
	else
		-- test yoksa indirme işlemi yapacak
		for _,pb in ipairs(inlist) do
			islem.indir.job(pb)
		end
	end	
end

function islem.indir.job(pb)
	-- girdi olarak paket bilgi tablosu alır.
	-- Link ve paket arşiv formatlarına ayrıştırır.
	assert(pb,"paket bilgi tablosu nil")
	-- indirilecek link ve kayıt yolu+dosya ismiyle
	function _indir(link,kayit)
		local body, code = http.request(link)
		code=tostring(code)
		if code:match("connection refused") then
			messages.server_connection_refused:format(link):yaz(3)
		elseif code=="404" then
			messages.paketvt_not_found:yaz(3)
		elseif code == "200" then
			local f = assert(io.open(kayit, 'wb'))
			f:write(body)
			f:close();
			if path_exists(kayit) then
				(link):yaz(1);
			else
				messages.redownloading:format(kayit):yaz(2)
				_indir(link,kayit);
			end
		elseif not body then
			(link):yaz(3);
		else
			messages.unknown_error:format(link):yaz(0)
		end
	end

	-- arşiv formatında # , web için %23 olauyor.
	-- Bu nedenle global arşiv formatını kullanmıyoruz.
	local larsiv=("%s%%23%s-%s.kur"):format(pb.isim,pb.surum,pb.devir)
	local arsiv=paf:format(pb.isim,pb.surum,pb.devir)
	local indirilecek=true
	-- link oluşturulur
	local link=plf:format(pb.depo,larsiv)
	local kayit=kokdizin..islem.paket.cachedir.."/"..arsiv
	-- print(link,"indirilecek")
	-- indirme işlemi; indirme yöneticisine link ve kayıt yeri belirtilir.
	if path_exists(kayit) then
		-- eğer paket önbellekte var ise hash kontrolü yapılıp
		-- hatalı ise silinip tekrar indirilir.
		if hash_check(kayit,pb.shasum) then
			indirilecek=false;
			messages.package_incache:format(pb.isim):yaz(2)
			-- paketin zaten indirilmiş olduğu-doğrulanması, dönüş kayit yol.
			return kayit
		else
			messages.package_shasum_error:format(pb.isim):yaz(3)
			messages.package_redownloading:format(pb.isim):yaz(2)
			shell("rm -f "..kayit)
		end
	end

	if indirilecek then
		_indir(link,kayit)
		-- shasum kontrol; indirilen dosya mevcut ve hash kontrolü yapılır.
		if path_exists(kayit) then
			if hash_check(kayit,pb.shasum) then
				messages.package_downloaded:format(pb.isim):yaz(1)
				-- paketin indirilmesi-doğrulanması, dönüş kayit yol.
				return kayit
			else
				messages.package_shasum_error:format(pb.isim):yaz(0)
			end
		else
			messages.package_download_error:format(pb.isim):yaz(0)
		end
	end
	-- diğer durumlar için nil değerin döndürülmesi
	return nil
end
------------------------------------------------------------

-- Koşuk işlemleri - kurkos,koskur,silkos, kossil

islem.kosuk={
	retkey="kosuk:",
	predos=".koskur",
	postdos=".kurkos",
	postrm=".silkos",
	prerm=".kossil",
}

-- kurmadan önce çalıştırılacak kod
function islem.kosuk.koskur(tempdir)
	local log=""
	if islem.kur.koskur then
		assert(path_exists(tempdir),"islem.kosuk.koskur : tempdir is nil")
		local kos=tempdir..islem.paket.metadir..islem.kosuk.predos
		if path_exists(kos) then
			-- koskur u çalıştıma sonuçları logla
			-- koşuklara çalıştırma izni verme
			shell("chmod +x "..kos)
			os.execute(kos)
			log="kosuk.koskur:\tOK"
		else
			log="kosuk.koskur:\tPASS"
		end
	else
		log="kosuk.koskur:\tDISABLE"
	end
	islem.debug.yaz(log);
	islem.kur.logger:write(log.."\n")
end

-- kurmadan sonra çalıştırılacak kod
function islem.kosuk.kurkos(tempdir)
	local log=""
	if islem.kur.kurkos then
		assert(path_exists(tempdir),"islem.kosuk.kurkos : tempdir is nil")
		local kos=tempdir..islem.paket.metadir..islem.kosuk.postdos
		if path_exists(kos) then
			-- kurkos u çalıştıma sonuçları logla
			-- koşuklara çalıştırma izni verme
			shell("chmod +x "..kos)
			os.execute(kos)
			log="kosuk.kurkos:\tOK"
		else
			log="kosuk.kurkos:\tPASS"
		end
	else
		log="kosuk.kurkos:\tDISABLE"
	end
	islem.debug.yaz(log);
	islem.kur.logger:write(log.."\n")
end

-- kurulumda dosya-dizin tetiklemeli otomatik çalıştırılacak kod
function islem.kosuk.otokos_kur(tempdir)
	local log=""
	if islem.kur.otokos then
		assert(path_exists(tempdir),"islem.kosuk.otokos : tempdir is nil")
		local curdir=lfs.currentdir()
		lfs.chdir(tempdir)
		-- todo!!! değişkene atılacak
		kos=mps_path.."/conf/otokos.sh"
		if path_exists(kos) then
			-- kurkos u çalıştıma sonuçları logla
			-- koşuklara çalıştırma izni verme
			shell("chmod +x "..kos)
			shell(kos.." kur")
			log="kosuk.otokos_kur:\tOK"
		else
			log="kosuk.otokos_kur:\tPASS"
		end
		lfs.chdir(curdir)
	else
		log="kosuk.otokos_kur:\tDISABLE"
	end
	islem.debug.yaz(log);
	islem.kur.logger:write(log.."\n")
end

-- silmeden önce çalıştırılacak kod
function islem.kosuk.kossil(paket)
	assert(path_exists(kokdizin..islem.paket.vt..paket),"islem.kosuk.kossil : paketdir is nil")
	local _betik=kokdizin..islem.paket.vt..paket.."/"..islem.paket.metadir..islem.kosuk.prerm
	local log=""
	if path_exists(_betik) then
		-- kossil u çalıştıma sonuçları logla
		-- koşuklara çalıştırma izni verme
		shell("chmod +x ".._betik)
		os.execute(_betik)
		log="kosuk.kossil:\tOK"
	else
		log="kosuk.kossil:\tPASS"
	end
	islem.debug.yaz(log)
	islem.sil.logger:write(log.."\n")
end

-- sildikten sonra çalıştırılacak kod
function islem.kosuk.silkos(paket)
	assert(path_exists(kokdizin..islem.paket.vt..paket),"islem.kosuk.kossil : paketdir is nil")
	local _betik=kokdizin..islem.paket.vt..paket.."/"..islem.paket.metadir..islem.kosuk.postrm
	local log=""
	if path_exists(_betik) then
		-- silkos u çalıştıma sonuçları logla
		-- koşuklara çalıştırma izni verme
		shell("chmod +x ".._betik)
		os.execute(_betik)
		log="kosuk.silkos:\tOK"
	else
		log="kosuk.silkos:\tPASS"
	end
	islem.debug.yaz(log)
	islem.sil.logger:write(log.."\n")
end

------------------------------

-- Sil işlemleri

islem.sil={
	retkey="sil:",
	usage="mps sil paket_ismi",
	dlistfile="%stmp/%s.del.list",
	keeplist=".silme",
	logdir=islem.paket.logdir.."sil/",
	force_remove_dirs={"__pycache__"},
	logger=nil,
	silkos=true,
	kossil=true,
}

function islem.sil.handler(input)
	local remlist={}
	--for k,pk in pairs(input) do print(k,pk) end
	--print(input.paket)
	if input.silkos == "0" then islem.sil.silkos=false end
	if input.kossil == "0" then islem.sil.kossil=false end
	
	local function pk_analiz(_paket)
		local _durum=""
		-- paketin kurulu kontrolünün atlanması için
		if input.kksiz then
			_durum=true
		else
			_durum=islem.paket.kurulu_kontrol(_paket)
		end
		if _durum then
			if input.ona then
				table.insert(remlist,_paket)
			else
				if islem.diyalog.onay(messages.confirm_package_uninstallation:format(_paket)) then
					table.insert(remlist,_paket)
				end
			end
		else
			messages.package_not_installed:format(_paket):yaz(3)
		end
	end
	
	-- konsoldan girilen paket girdi analiz
	if input.paket then
		for _,pk in ipairs(input.paket) do pk_analiz(pk) end
	end
	
	-- dosya parametresi içerik girdi analiz
	if input.dosya then
		if path_exists(input.dosya) then
			for pk in (get_content(input.dosya)):gmatch("[^\r\n]+") do 
				pk_analiz(pk)
			end
		else	
			messages.file_not_found:format(dosya):yaz(0)
		end
	end
	
	-- silme test işlevi
	if input.test then
		for _,pk in ipairs(remlist) do print("s",pk) end
	else
		-- test yoksa bu işlem yapılacak
		for _,rpaket in ipairs(remlist) do
			-- todo!!! ters gereklerini kontrol et / silinecek pakete bağlı olan paketler
			islem.sil.job(rpaket)
		end
	end	
	-- silmesi onaylanmış paket sayı bilgisi
	-- sistem güncellemede kullanılacak.
	return #remlist	
end

function islem.sil.job(paket)
	-- tek bir paketi siler
	assert(paket,"islem.sil.paket : paket is nil")
	-- sed "s/^'/\/mnt/"  kurulan.s | sed "s/'//"
	-- sil adımları
	-- 0. logger set
	islem.sil.set_logger(paket)
	-- 1. silinecek dosya listesi hazırla
	islem.sil.prepare_list(paket)
	-- 2. silinecekleri filtrele(keeplist)
	islem.sil.filter_list(paket)
	-- 3. kos-sil betiğini kontrol et / çalıştır
	islem.kosuk.kossil(paket)
	-- 4. Dosyaları güvenli! sil ve logla
	islem.sil.uygula(paket)
	-- 5. sil-kos betiğini kontrol et / çalıştır
	islem.kosuk.silkos(paket)
	-- 6. paket veritabanı güncelle sil
	islem.sil.paket_vt(paket)
	-- silmeden sonra ld.so.cache güncellemesi için
	islem.kur.ld_update("sil");
	-- log dosyası kapatılır.
	islem.sil.logger:close();
	-- Silme işlemi sonuç kontrol
	islem.sil.bitis(paket)
end

function islem.sil.set_logger(paket)
	-- bu assert mps başına konulabilir
	assert(path_exists(kokdizin..islem.paket.logdir),"islem.sil.set_logger : islem.paket.logdir is not availables, needs mps --ilk")
	assert(path_exists(kokdizin..islem.sil.logdir),"islem.sil.set_logger : islem.sil.logdir is not availables, needs mps --ilk")
	local logfile=kokdizin..islem.sil.logdir..paket..".log"
	islem.sil.logger = assert(io.open(logfile, "w"),"islem.sil.set_logger logfile can not open")
	islem.sil.logger:write(paket.."\t"..os.date("%x %H:%M:%S").."\n");
	islem.sil.logger:write("--------------------------------------\n");
end

function islem.sil.bitis(paket)
	-- Silme adımlarının başarılı bir şekilde tamamlandığını log dosyası ile kontrol eder.
	local logfile=kokdizin..islem.sil.logdir..paket..".log"
	assert(path_exists(logfile),"islem.sil.bitis : logfile is not available")
	if not get_content(logfile):match("ERR@R") then
		messages.package_uninstalled:format(paket):yaz(1)
	else
		messages.package_uninstallation_failed:format(paket):yaz(0)
	end
end


function islem.sil.prepare_list(paket)
	local sildos=islem.sil.dlistfile:format(kokdizin,paket)
	local _kurulan=kokdizin..islem.paket.vt..paket.."/"..islem.kur.kurulandos
	-- todo!!! silinecek dosyaların başına kök diizn ekleyerek gerçek yollu silineceklerin oluşturulması
	--local komut='sed "s~^\'~%s~g"  %s | sed "s/\'//" > %s'

	-- silinecek dosyalardan ' karakterinin kaldirilmasi
	local komut="sed 's/'\\''//g' %s > %s"
	komut=komut:format(_kurulan,sildos)
	shell(komut)
	assert(get_size(sildos) > 0,"islem.sil.prepare_list : del.list is empty");
	local log="prepare_list:\tOK"
	islem.debug.yaz(log)
	islem.sil.logger:write(log.."\n")
end

function islem.sil.filter_list(paket)
	-- eğer paket dizin kaydında .silme isimli dosya varsa
	-- o dosya içindeki alt alta sıralı dosyalar silinecekler listesinden elenecektir.
	-- silinecekler başka dosya isimle içindekilerle karşılaştırılıp filtre edilenler silinir.
	local keeplistfile=kokdizin..islem.paket.vt..paket.."/"..islem.sil.keeplist
	local sildos=islem.sil.dlistfile:format(kokdizin,paket)
	local log=""
	if path_exists(keeplistfile) then
		local komut_k='sed "s~^~%s~g" %s > %s'
		komut_k=komut_k:format(kokdizin,keeplistfile,sildos..".keep")
		shell(komut)
		local komut_move="mv %s %s"
		shell(komut_move:format(sildos,sildos.."f"))
		local komut_f="sort %s %s |uniq -u > %s"
		komut_f=komut_f:format(sildos..".f",keeplistfile,sildos)
		shell(komut_f)
		log="filter_list:\tOK"
	else
		log="filter_list:\tPASS"
	end
	islem.debug.yaz(log)
	islem.sil.logger:write(log.."\n")
end

function islem.sil.uygula(paket)
	local sildos=islem.sil.dlistfile:format(kokdizin,paket)
	local sil_content=get_content(sildos);

	-- Once tum paket *dosya*lari silinecek
  -- Ardindan klasorler bos mu diye kontrol edilecek
  -- Bos olan klasorler kaldirilacak
	local exist=true
	local delete=true
	local log=""
	local sil_komut="rm -rf %s"
	local ret=nil
	islem.sil.logger:write("---------------\n")

	function smart_delete(file_list, no_check)
		-- smart delete bir doysa+dizin listesi alir
		-- Ilk olarak tum dosyalari kaldirir ve dizinleri arar
		-- Ardindan bos olan dizinler kaldirilir
		-- Son olarak bos olmayan dizinleri return eder

		-- file_list bir string arrayi olmali
		-- no_check bir boolean olmali

		-- eger no_check 1 ise, tum dizinler
		-- bos olup olmasina bakilmadan kalirilacak

		to_remove={
			files={},
			dirs={}
		}

		for dos in file_list:gmatch("[^\r\n]+") do
			file_attr = lfs.attributes(dos)
			if file_attr then
				if  file_attr.mode == "file" then
					table.insert(to_remove.files, dos)
				else
					_, count = dos:gsub('/', '/')
					table.insert(to_remove.dirs, {dos, count})
				end
			end
		end

		-- tabloyu dizin hiyerasisine gore sirala
		-- alttaki dizin tabloda uste gelir
		function compare(a,b)
			return a[2] > b[2]
		end
		table.sort(to_remove.dirs, compare)

		-- once tum dosyalari kaldir
		for _,v in pairs(to_remove.files) do
			local result, reason = os.remove(v)
      -- todo!!! dosya silinmemesine karsin error-check yap
			if result then
			else
			end
		end

		nonempty_dirs={}

		-- to_remove.dirs'i iterate et ve bos olan dizinleri kaldir
		-- todo !!! buranın yenilenmesi gerek lfs. linklerde sorunlu.
		for i=1, #to_remove.dirs do
			-- zorla siliniecek dizin kontrolü
			-- __pycache__ gibi, temel dizin adı ile kontrol edilmektedir.
			if has_value(islem.sil.force_remove_dirs,get_basename(to_remove.dirs[i][1])) then
				os.execute("rm -rf "..to_remove.dirs[i][1])
			else
				status, message, code = lfs.rmdir(to_remove.dirs[i][1])
			
				if status == nil then
					if code == 39 then
						if no_check then
							-- no_check set edilmisse, dizini recursive olarak kaldir
							deletedir(to_remove.dirs[i])
						else
							-- Dizin bos degil, silme!, nonempty_dirs'e ekle
							--if not has_value(islem.sil.force_remove_dirs,get_basename(to_remove.dirs[i][1])) then
							table.insert(nonempty_dirs, to_remove.dirs[i])
							--end
						end
					elseif code == 20 then
						-- bir dizinin linki durumundadır
						-- todo!!! link ise zorla silinecektir. farklı durumlar gözlemlenecek.
							os.execute("rm -f "..to_remove.dirs[i][1])
					else
						-- Hata yakala ve yazdir
						hata_msg="Klasör silinemedi!".."\n"..message..
						hata_msg:yaz(0)
					end
				end
			end
		end

    -- dizinleri recursive silmek icin yardimci function
		function deletedir(dir)
			for file in lfs.dir(dir) do
				local file_path = dir..'/'..file
				if file ~= "." and file ~= ".." then
					if lfs.attributes(file_path, 'mode') == 'file' then
						os.remove(file_path)
					elseif lfs.attributes(file_path, 'mode') == 'directory' then
						deletedir(file_path)
					end
				end
			end
			lfs.rmdir(dir)
		end

		return nonempty_dirs
	end

	-- sildos dosyasindaki entryleri smart_delete function'i ile sil
	protected_dirs = smart_delete(sil_content)

	-- Kullaniciya silinmeyen klasorleri goster
  -- todo!!! bu ozelligi tamamla
  -- kullanicidan input alip sil
	delete_list={}

	if #protected_dirs > 0  then
		messages.confirm_dir_removing_msg:format(sildos_by_user):yaz(3)

		sildos_by_user=islem.sil.dlistfile:format(kokdizin, paket)..".kor"
		sildos_file = io.open(sildos_by_user, "w")

		for i=1, #protected_dirs do
			-- eger protected_dirs te varsa ancak kullanicinin degistirdigi dosyada yoksa
      -- girdinin silinmesi gerekiyor
			local dir ={}
			dir.dir = protected_dirs[i][1]
			dir.level =protected_dirs[i][2]
			dir.children = {}

			for j=i-1, 1, -1 do
				if protected_dirs[j][2] == dir.level + 1 then
					table.insert(dir.children, protected_dirs[j][1])
				end
			end

			for file in lfs.dir(dir.dir) do
				if file ~= "." and file ~= ".." then
					file_path = dir.dir.."/"..file
					if find(dir.children, file_path) < 0 then
						sildos_file:write(file_path.."\n")
					end
				end
			end
		end
		sildos_file:close()

		messages.confirm_dir_removing_info:format(sildos_by_user):yaz(3)
		local entries_from_user = {}
		for line in io.lines(sildos_by_user) do
			print(line)
			table.insert(entries_from_user, line)
		end

	end
	----------
	islem.sil.logger:write("---------------\n")
	if exist and delete then
		log="sil.uygula:  \tOK";
		islem.debug.yaz(log);
		islem.sil.logger:write(log.."\n")
	else
		log="sil.uygula:\tERR@R";
		log:yaz(3);
		islem.sil.logger:write(log.."\n")
	end

end

function islem.sil.paket_vt(paket)
	local dizin=kokdizin..islem.paket.vt..paket
	assert(path_exists(dizin),"islem.sil.paket_vt : dizin is not available")
	local log=""
	local komut_vt="rm -rf %s"
	komut_vt=komut_vt:format(dizin)
	shell(komut_vt);
	-- linkin de silinmesi
	shell(komut_vt.."#*");
	if not path_exists(dizin) then
		log="sil.paket_vt:\tOK";
		islem.debug.yaz(log);
		islem.sil.logger:write(log.."\n")
	else
		log="sil.paket_vt:\tERR@R";
		log:yaz(3);
		islem.sil.logger:write(log.."\n")
	end
end

------------------------------

-- Kur işlemleri

islem.kur={
	retkey="kur:",
	kurulandos="kurulan",
	dizinler={"boot","etc","usr","opt","var","tools"}, -- paket içi desteklenen dizinler
	usage="mps kur paket_ismi | paket_yolu",
	logdir=islem.paket.logdir.."kur/",
	logger=nil,
	kurkos=true,
	koskur=true,
	otokos=true,
	zorla=false,
	comment=messages.comment_mps_install,
}

function islem.kur.agdan(paket)
	assert(paket,"islem.kur.agdan : paket is nil")
	-- 1.çalışma gerekleri tespit edilecek tablo=gerek paket c
	-- islem gerek listesi global olduğu için sıfırlanması gerekir.
	islem.gerek.liste={}
	islem.gerek.list={}
	islem.gerek.job(paket,"c")
	--print(paket,#islem.gerek.liste)
	-- 2.paketvt ler den döngüde paket#surum-devir
	local ret, pk=""
	local kurliste={}
	local pkpath=nil
	-- 3. gereklerin sıralı indirme
	
	function controller(tsd)
		-- gerekli paket kurulu kontrolü yapılıp indirilir
		local pk,_=tsd:match("([%a%d-_+]+)#+")
		-- paket kurulu ise atlanacak
		if islem.paket.kurulu_kontrol(pk) then
			(messages.package_already_installed..":"..pk):yaz(2);
		else
			ret=islem.paket.pkvt_bilgi(pk)[1]
			-- paket paket veritabanında bulunamaz ise, veritabanı güncellenmelidir.
			if ret == nil then messages.package_not_found_inpkvt:format(pk):yaz(0) end
			-- indirme işlemi
			-- kurliste ye inen/indirilmiş paketin yolunun kaydı
			pkpath=islem.indir.job(ret)
			if pkpath == nil then
				messages.package_dependency_dl_error:format(pk):yaz(3)
			else
				table.insert(kurliste,pkpath)
			end
		end
	end
	
	-- controller için görev tablosu
	local threads = {}
	
    function co_adder (tsd)
        -- create coroutine
        local co = coroutine.create(
            function ()
                controller(tsd)
            end)
        -- görev tablosuna işin(thread) eklenmesi
        table.insert(threads, co)
    end
	
	for _,tsd in ipairs(islem.gerek.liste) do
		-- 3.1 indirilecek size bilgi - kurulacak bilgi verilip onay ile
		-- eski kod için controller i aç dispatcher i kapat. 
		--controller(tsd)
		co_adder(tsd)
	end
	
	function dispatcher()
		while true do
			local n = #threads
			if n == 0 then break end -- no more threads to run
			for i=1,n do
				local status, res = coroutine.resume(threads[i])
				if not res then -- thread finished its task?
					table.remove(threads, i)
					break
				end
			end
		end
	end
	-- multithread kontrol ve indirme işlemi
	dispatcher()
	
	-- 4.gerekler kurulacak (yerelden kur ile cachedir den)
	for _,pkyol in ipairs(kurliste) do
		-- 4.1 indirilecek size bilgi - kurulacak bilgi verilip onay ile
		islem.kur.yerelden(pkyol)
	end
end

function islem.kur.yerelden(paket)
	--print (paket) -- belki bu mps.log a atılabilir/nereden talimatlandığına dair
	-- yerelden gelen paketin mevcut kontrolü
	-- gönderen işlevler yapamazsa
	if not paket then
		messages.package_not_found:format(paket):yaz(0)
	end
	assert(paket ~= "","islem.kur.yerelden : paket is empty string")
	-- print (paket,"yerelden")
	-- adımlar: loglanacak, her işlem adımı log dosyasına atacak
	-- önemli not: pcall ile işlemler uygulanacak, eğer break olursa sistem kaynaklı (ctrl+c vs)
	-- işlem adımı ve onu çağıran süreç job dosyası state kayıt edilecek.
	-- 0.  paket arşivi kontrol edilir
	local isim,surum,devir=islem.arsiv.kontrol(paket)
	-- 1. logger set
	islem.kur.set_logger(isim)
	-- 2.  paket kurulu kontrol yapılır
	islem.kur.kurulu_kontrol(isim)
	-- 3.  /tmp altında geçici bir dizine çıkarılır
	local tempdir=islem.arsiv.cikar(paket)
	-- 4.  libgerekler kontrol edilir- ldconfig sor
	islem.shlib.kontrol(tempdir) --/ kontrol altına eksik shlibleri içeren paketler kurulabilir.
	-- 5.  hedef kurulum dizininde çakışan/var olan dosya kontrolü
	islem.kur.dosya_kontrol(tempdir)
	-- 6.  koşkur varsa çalıştırılır 2.madde?
	islem.kosuk.koskur(tempdir)
	-- 7.  geçici dizinden hedef dizin altına kopyalanır
	islem.kur.kopyala(tempdir)
	-- 8.  kopyalanan dosyalar VT e yazılır, var/lib/mps/DB altına paketismi
	-- tempdir altında kurulan dosyası, .icbilgi, .ustbilgi, kosuklar, libgerekler, pktlibler
	islem.kur.vt_kayit(tempdir,isim,surum,devir)
	-- 9.  mtree ile karşılaştırma doğrulanır
	-- 10.  ldconfig güncellemesi
	islem.kur.ld_update_handler(tempdir)
	-- 11.  kurkos çalıştırılır
	islem.kosuk.kurkos(tempdir)
	-- 12.  otokos çalıştırılır
	islem.kosuk.otokos_kur(tempdir)
	-- 13. temizlik, başarı mesaj...
	islem.kur.clean_tempdir(tempdir)
	-- 14. log dosyası kapatılır.
	islem.kur.logger:close();
	-- 15. Paket kurulum sonucu
	islem.kur.bitis(isim)
end

function islem.kur.clean_tempdir(tempdir)
	-- kurma işlemleri bittikten sonra paket içeriğinin
	-- geçici çıkarıldığı tempdir silinir.
	local komut="rm -rf %s"
	komut=komut:format(tempdir)
	shell(komut)
end

function islem.kur.bitis(paket)
	-- Kurulum adımlarının başarılı bir şekilde tamamlandığını log dosyası ile kontrol eder.
	local logfile=kokdizin..islem.kur.logdir..paket..".log"
	assert(path_exists(logfile),"islem.kur.bitis : logfile is not available")
	if not get_content(logfile):match("ERR@R") then
		messages.package_installed:format(paket):yaz(1)
	else
		messages.package_installation_failed:format(paket):yaz(0)
	end
end

function islem.kur.set_logger(paket)
	-- bu assert mps başına konulabilir
	assert(path_exists(kokdizin..islem.paket.logdir),"islem.kur.set_logger : islem.paket.logdir is not available, needs mps --ilk")
	assert(path_exists(kokdizin..islem.kur.logdir),"islem.kur.set_logger : islem.kur.logdir is not availables, needs mps --ilk")
	local logfile=kokdizin..islem.kur.logdir..paket..".log"
	--print("-",logfile)
	islem.kur.logger = assert(io.open(logfile, "w"),"islem.kur.set_logger logfile can not open")
	islem.kur.logger:write(paket.."\t"..os.date("%x %H:%M:%S").."\n");
	islem.kur.logger:write("--------------------------------------\n");
end

function islem.kur.ld_update_handler(tempdir)
	local log=""
	if path_exists(tempdir..islem.paket.metadir..islem.paket.pktlib_dosya)
	or path_exists(tempdir..islem.paket.metadir..islem.shlib.dosya) then
		-- libgerek?(kurulu ise cache edilmiş olmalı), shlib varsa ldconfig edilecek.
		islem.kur.ld_update()
		log="ld_up_handler:\tOK";
		islem.kur.logger:write(log.."\n")
	else
		messages.ld_update_pass:yaz()
		log="ld_up_handler:\tPASS";
		islem.kur.logger:write(log.."\n")
	end
end

-- kura mahsus olmasın todo!!!
function islem.kur.ld_update(oper)
	-- hedef kök dizinde ldconfig varsa güncelleme olur.
	local log=""
	if path_exists(kokdizin.."usr/bin/ldconfig")
	or path_exists(kokdizin.."sbin/ldconfig") then
		--print("ldconfig update edilecek")
		local _cachedos="etc/ld.so.cache"
		local komut1=("rm -f %s%s"):format(kokdizin,_cachedos)
		--print(komut1)
		shell(komut1)
		local komut2=("ldconfig -r %s"):format(kokdizin)
		--print(komut2)
		shell(komut2)
	else
		(messages.ld_update_pass..kokdizin):yaz()
		log="ld_update:\tPASS";
		if oper then
			islem[oper].logger:write(log.."\n")
		else
			islem.kur.logger:write(log.."\n")
		end
	end
end

function islem.kur.kopyala(tempdir)
	-- geçici çıkarma dizininden sisteme kopyala işlemi
	-- geçerli dizinler kontrol edilerek kopyalama yapılır
	-- tempdir altındaki dizinleri islem.kur.dizinler ile karşılaştır.
	local dirs=get_dirs(tempdir)
	local kurulandos=tempdir..islem.kur.kurulandos
	assert(dirs,"islem.kur.kopyala : dirs is nil")
	--table.insert(dirs,"sbin")
	local log=""
	for _,dir in ipairs(dirs) do
		if not has_value(islem.kur.dizinler,dir) and dir.."/" ~= islem.paket.metadir then
			(messages.invalid_package_content..dir):yaz(3)
			islem.kur.logger:write(messages.invalid_package_content..dir.."\n")
		end
	end
	local komut=""
	for _,dizin in ipairs(islem.kur.dizinler) do
		if path_exists(tempdir..dizin) then
			komut='cp -v -aflr %s %s | awk \'{split($0,a,"-> "); print a[2]}\' | sed  \'s#%s#/#g\' >> %s'
			komut=komut:format(tempdir..dizin,kokdizin,kokdizin,kurulandos)
			shell(komut)
			log="kur.kopyala:\tOK";
			islem.debug.yaz(log)
			islem.kur.logger:write(log.."\n")
		end
	end
end

function islem.kur.vt_kayit(tempdir,isim,surum,devir)
	-- sisteme kopyalanan paketin paket veritabanı kaydının yapılması
	-- ve kurulum logunun oluşturulması (adımlar loglanacak)
	assert(isim,"islem.kur.vt_kayit : isim is nil")
	local log=""
	local paket_vt_dizin=kokdizin..islem.paket.vt..isim.."/"
	-- linkin oluşturulması - indeksleme için
	local paket_vt_dizin_link=kokdizin..islem.paket.vt..isim.."#"..surum.."-"..devir
	-- paket_vt dizin oluşturma
	local komut0=("rm -rf %s"):format(paket_vt_dizin)
	shell(komut0)
	local komut1=("mkdir -p %s"):format(paket_vt_dizin)
	local komut_link=("ln -s %s %s"):format(paket_vt_dizin,paket_vt_dizin_link)
	--print(komut1)
	shell(komut1)
	shell(komut_link)
	-- / altındakileri silme engeli
	assert(paket_vt_dizin ~= "/","islem.kur.vt_kayit : paket_vt_dizin must not be /")
	-- paket_vt dizin temizlik
	local komut2=("rm -rf %s*"):format(paket_vt_dizin)
	--print(komut2)
	shell(komut2)
	-- paket.vt içerik kopyalama (tek tek bilgi dosyaları yada file olan her obje)
	-- kurulan dosyası da eklenir, islem.kur içinde tanımlandığı için burda ekliyoruz.
	-- kurulan dosyanın oluşması beklenir, oluşmadıysa sisteme dosya ve dizin kopyalama olmamıştır.
	assert(path_exists(tempdir..islem.kur.kurulandos),"islem.kur.vt_kayit : kurulan file is not available -> no files, dirs copied!!!")
	-- kurulan dosyasının paket kayıt dizine kaydı
	shell(("cp -avf %s %s"):format(tempdir..islem.kur.kurulandos,paket_vt_dizin))
	-- .meta dizini kopyala
	shell(("cp -avf %s %s"):format(tempdir..islem.paket.metadir,paket_vt_dizin))
	-- icbilgi dosyası kopyala
	shell(("cp -avf %s %s"):format(tempdir..islem.icbilgi.dosya,paket_vt_dizin))
	log="kur.vt_kayit:\tOK";
	islem.debug.yaz(log)
	islem.kur.logger:write(log.."\n")
	-- vt_kayıt test edilecek!!!
end

function islem.kur.dosya_kontrol(tempdir)
	-- sisteme kopyalanacak paket içeriğinin sistemde çakışan karşılık kontrolü
	-- çakışanlar için strateji belirlenmeli: üzerine yaz, koru vs
	local dosyalar=islem.icbilgi.dosyalar(tempdir)
	assert(dosyalar,"islem.kur.dosya_kontrol : dosyalar is nil")
	local ret=true
	local log=""
	local conflict_files={}
	for _,dosya in ipairs(dosyalar) do
		if path_exists(kokdizin..dosya) then
			(messages.file_already_exists:format(kokdizin..dosya)):yaz(3)
			table.insert(conflict_files,kokdizin..dosya)
			ret=false
		end
	end
	-- handling already exist files
	if not ret and islem.kur.zorla == false then
		if islem.diyalog.onay(messages.confirm_files_removing) then
			-- conflict_files tablosundan dosyalar sıralı şekilde silinir
			for _,dosya in ipairs(conflict_files) do
				shell("rm -f "..dosya)
			end
			log="çakışan_dosya:\tOK";
		else
			-- tempdir i sil çıkış yap
			-- print("koskurdan sonra olmalı çakşm,log da silinmeli!!! not yet")
			-- islem.kur.clean_tempdir(tempdir)
			-- os.exit()
			log="çakışan_dosya:\tOVERRIDE";
		end
		islem.debug.yaz(log);
	else
		log="dosya_kontrol:\tOK";
		islem.debug.yaz(log);
	end
	islem.kur.logger:write(log.."\n")
end

function islem.kur.kurulu_kontrol(paket)
	-- sistemde kurulu paket kontrolü
	-- burada kurulu pakete uygulanacak seçenek sorulur
	-- sil/silme
	assert(paket,"islem.kur.kurulu_kontrol : paket is nil")
	local log=""
	if islem.paket.kurulu_kontrol(paket) then
		log=messages.package_already_installed;
		messages.package_already_installed:yaz(0);
	else
		log="kurulu_kontrol:\tOK";
	end
	islem.debug.yaz(log)
	islem.kur.logger:write(log.."\n")
end

function islem.kur.job(kur)
	-- dikkat ! sıralı kurmayabilir tablo şeklinde geliyor
	-- işlemlerin logu hazırlanacak.
	for tip,tablo in pairs(kur) do
		-- burası sıralı iş
		if kur[tip] then
			for _,job in ipairs(tablo) do
				islem.kur[tip](job)
			end
		end
	end
end

function islem.kur.handler(input)
	-- işlem isminden sonra en az bir parametre olmalıdır.
	if input.kurkos == "0" then islem.kur.kurkos=false end
	if input.koskur == "0" then islem.kur.koskur=false end
	if input.otokos == "0" then islem.kur.otokos=false end
	if input.zorla 	== true then islem.kur.zorla=true  end
	
	local jobs={
		agdan={},
		yerelden={}
	}
	
	-- paketin yerel/ağ kaynak tespiti ve ilgili listeye eklenmesi
	function pk_analiz(pkt)
		local _paket=""
		if pkt:match("kur") then 
			-- yerelden kurulacak listeye eklenir
			--print("yerelden kurulacak",pkt)
			table.insert(jobs.yerelden,get_abspath(pkt))
			_paket,_,_,_=pkt:match(paket_arsiv_pattern)
		else
			local _talimatd=islem.talimat_bul.job(pkt)
			if _talimatd then
				-- ağdan kurulacak listeye eklenir
				table.insert(jobs.agdan,_talimatd)
			else
				(messages.talimat_not_found..pkt):yaz(0)
			end
			_paket=pkt
		end
		-- tekrar parametresi verildiyse paketi silecek.
		if input.tekrar == true then
			islem.sil.handler({paket={_paket}})
		end
	end
	
	-- konsoldan girilen paket girdi analiz
	if input.paket then
		for _,pk in ipairs(input.paket) do pk_analiz(pk) end
	end
	
	-- dosya parametresi içerik girdi analiz
	if input.dosya then
		if path_exists(input.dosya) then
			for pk in (get_content(input.dosya)):gmatch("[^\r\n]+") do 
				pk_analiz(pk)
			end
		else	
			messages.file_not_found:format(dosya):yaz(0)
		end
	end
	
	-- handler işlevinin test işlemi
	if input.test then
		for _,v in ipairs(jobs.agdan) do print("a",v) end
		for _,v in ipairs(jobs.yerelden) do print("y",v) end
	else
		-- test yoksa bu işem yapılacak
		islem.kur.job(jobs);
	end		
	
	
	-- todo!!! işlemlerin logu okunacak
	-- ("işlemlerin logu okunacak"):yaz(2)
end
--------------------------------------------

--------Güncelleme İşlemleri-------------------

islem.guncelle={
	retkey="guncelle:",
	comment=messages.usage_updating_repos,
	usage="mps guncelle",
	betikdepo={isim="betikdepo",tnm="Betik",path=milispath},
	talimatdepo={isim="talimatdepo",tnm="Git",path=talimatname},
	paketlist={},
}
-- işlevler

function islem.guncelle.handler(input)
	local sira=tonumber(input.sira)
	-- mps güncelleme
	if input.mps then 
		islem.guncelle.mps() 
	end
	-- talimat depolarının güncelleme
	if input.git then 
		islem.guncelle.gitdepo(sira,islem.guncelle.talimatdepo) 
	end
	-- betik depolarının güncelleme
	if input.betik then
		islem.guncelle.gitdepo(sira,islem.guncelle.betikdepo)
	end
	-- paketvt depoları güncelleme
	if input.depo then 
		islem.guncelle.paketvt(sira)
	end
	-- sistem güncelleme
	if input.sistem then 
		islem.guncelle.sistem(input)
	end
	-- paket güncelleme
	if input.paket then 
		islem.guncelle.paket(input)
	end
	
	if not input.mps    and not input.git   and 
	   not input.betik  and not input.depo  and
	   not input.sistem and not input.paket then
		islem.guncelle.mps() 
		islem.guncelle.gitdepo(sira,islem.guncelle.talimatdepo)
		islem.guncelle.gitdepo(sira,islem.guncelle.betikdepo)
		islem.guncelle.paketvt(sira)
	end
end

function islem.guncelle.hesapla()

	local kkomut="find %s -type l | xargs -I {} basename {}"
	kkomut=kkomut:format(kokdizin..islem.paket.vt)
	local k_pak={}
	for line in shell(kkomut):gmatch("[^\r\n]+") do
		local paket,sd=line:match("(.*)#(.*)")
		k_pak[paket]=sd
	end
	
	--[=====[ 
	--local pkomut=[[cat %s/paket.vt#* | awk 'BEGIN{FS=" "} {print $1 "#" $2 "-" $3}']]
	pkomut=pkomut:format(kokdizin..islem.paket.cachedir)
	local p_pak={}
	for line in shell(pkomut):gmatch("[^\r\n]+") do
		local paket,sd=line:match("(.*)#(.*)")
		p_pak[paket]=sd
	end
	--]=====] 
	
	-- paket vtlerden ilk bulduğu eşleşen paket bilgisi değeri getirecek
	local pb,psd=""
	for paket,sd in pairs(k_pak) do
		pb=islem.paket.pkvt_bilgi(paket)[1]
		if pb == nil then psd=nil
		else psd=pb.surum.."-"..pb.devir end
		if psd ~= k_pak[paket] then
			islem.guncelle.paketlist[paket]={mevcut=k_pak[paket],guncel=pb}
		end
	end
	--[=====[ 
	for paket,sd in pairs(k_pak) do
		if p_pak[paket] ~= k_pak[paket] then
			islem.guncelle.paketlist[paket]={mevcut=k_pak[paket],guncel=p_pak[paket]}
		end
	end
	--]=====] 
end

function islem.guncelle.sistem(input)
	-- test aşamasında
	-- ilk önce talimatname ve paket depo eşitliğine bakılacak
	-- talimat ile paket sürümleri aynı olmak zorundadır yoksa derleyerek üretim gerekir.
	-- bu durum garantilendikten sonra ikili depodan güncelleme tespiti yapılıp sistem güncellenebilir.
	--local tkomut="find %s -name talimat | xargs -I {} dirname {} | xargs -I {} basename {}"
	--tkomut=tkomut:format(milispath)
	---local t_pak={}
	--for line in shell(tkomut):gmatch("[^\r\n]+") do
	--	table.insert(t_pak, line)
	--end
	-- find /usr/milis/talimatname/ -name talimat | xargs -I {} dirname {} | xargs -I {} basename {}
	-- kurulu paket list
	-- find /var/lib/mps/db -type l | xargs -I {} basename {}
	local esgeclist=input.esgec
	islem.guncelle.hesapla()
	local dppk=""
	for _paket,bilgi in pairs(islem.guncelle.paketlist) do
		if bilgi.guncel == nil then dppk="depoda olmayan paket"
		else dppk=bilgi.guncel.surum.."-"..bilgi.guncel.devir end
		if has_value(esgeclist,_paket) == true then
			print(_paket,"güncellemesi es geçildi.")
		else
			-- güncelleme işlemi - durum sorgulanacaksa işlem yaptırılmaz.
			if input.durum == true then
				-- güncelleme bilgisi
				print(string.format("%-15s %-10s -> %s",_paket,bilgi["mevcut"],dppk))
			else	
				islem.guncelle.paket({paket={_paket},ona=input.ona})
			end
		end
	end
	-- not islem.guncelle.paketlist key-value şeklinde # ile length alınamaz
end

function islem.guncelle.paket(input)
	-- 1 güncellenecek paket listesi için güncelleme hesaplanacak
	-- 2 guncellenecek paket listesinde yer alıyor mu 
	-- 3 paket depodan güncel paketi indir, doğrula
	-- 4 eski paketi kaldır. (geri kurtarma için eski paket depo?)
	-- 5 paketdepo inen yeni paketi kur.  
	-- -S ile guncellemeler hesaplanmış olabilir değilse hesaplanacak
	local paketgirdi=input.paket
	if next(islem.guncelle.paketlist) == nil then
		islem.guncelle.hesapla()
	end
	local pb,par,pyol=""
	-- silme onay değişkeni
	local s_onay=0
	-- döngü halinde paket listesindeki paketler güncellenecek.
	for _,paket in ipairs(paketgirdi) do
		if islem.guncelle.paketlist[paket] == nil then
			print(paket,"için güncelleme mevcut değil!")
		else
			pb=islem.guncelle.paketlist[paket]
			if pb.guncel == nil then
				print(paket,pb.mevcut,"depoda olmayan paket")
			else
				print(paket,pb.mevcut,pb.guncel.surum.."-"..pb.guncel.devir)
				islem.indir.handler({paket={paket}})
				par=paf:format(paket,pb.guncel.surum,pb.guncel.devir,pb.guncel.mimari)
				pyol=kokdizin..islem.paket.cachedir.."/"..par
				if path_exists(pyol) then
					s_onay=islem.sil.handler({paket={paket},ona=input.ona})
					if s_onay == 1 and islem.paket.kurulu_kontrol(paket) ~= true then 
						--islem.kur.yerelden(pyol)
						-- gerekler tekrar hesaplanacak
						islem.kur.agdan(islem.talimat_bul.job(paket))
					end
				else
					print(pyol,"güncellenecek paket yolu bulunamadı")
				end
			end
		end
		s_onay=0
	end
	--print("paket güncellemesi deneme kullanımındadır!")
end

function islem.guncelle.mps()
	-- todo!!! mps commit hash tutulacak oradan commit değer değişimi gösterilecek
	-- değişim yoksa güncelleme yok
	assert(path_exists(mps_path),"mps_path not exist")
	assert(path_exists(mps_path.."/.git"),"invalid git directory");
	("MPS güncelleniyor:"):yaz(2);
	("------------------------------------"):yaz(2);
	local komut="cd %s && git reset --hard HEAD && git pull ; chmod +x bin/mps*"
	local ret=shell(komut:format(mps_path));
	-- ret=shell(git_kont:format(repo,tmp,tmp))
	("------------------------------------"):yaz(2)
end

function islem.guncelle.paketvt(sira)
	-- todo!!! eskiden inen paketvt#x ler old a taşınacak
	-- başarılı indirmeler olunca silinecek şekilde ayarlanacak
	-- şu an bağlantı yoksa mevcutu da silimiş oluyor- bağlantı olmadan
	-- paket te inemez olarak kabul edildi.
	-- todo!!! bir önceki sürüm paketler için depo tahsisi ve güncellemelerde geri kurtarma deposu olarak kullanılması?
	local onbellek_depo=kokdizin..islem.paket.cachedir.."/"
	("Paket veritaban(lar)ı güncelleniyor:"):yaz(2);
	("------------------------------------"):yaz(2);
	-- paket önbellek depo yoksa oluşturulur.
	if not path_exists(kokdizin..islem.paket.cachedir) then
		local create_cache=("mkdir -p %s"):format(onbellek_depo)
		shell(create_cache)
	end
	-- Eski kalıntı paket.vt# dosyaları temizlenmesi
	local del_old_vts=("rm -f %s%s"):format(onbellek_depo,"paket.vt#*")
	shell(del_old_vts)
	
	sira=tonumber(sira)
	local pkvt="paket.vt"
	-- işlev içinde işlev paket.vt i indirmek için
	-- paket.vt.gz gibi sıkıştırılmış gerçekleme yapılacak. todo!!!
	function _indir(sunucu,sira)
		-- io.write(sunucu.."/"..pkvt.."\t")
		local link=sunucu.."/"..pkvt
		local body, code = http.request(link)
		code=tostring(code)
		if code:match("connection refused") then
			messages.server_connection_refused:format(sunucu):yaz(3)
		elseif code=="404" then
			messages.paketvt_not_found:yaz(3)
		elseif code == "200" then
			local kayit=onbellek_depo..pkvt.."#"..sira
			local f = assert(io.open(kayit, 'wb'))
			f:write(body)
			f:close();
			-- ("+"):yaz(1);
			--kayit:yaz(2);
			if path_exists(kayit) then
				(link):yaz(1);
			else
				messages.redownloading:format(kayit):yaz(2)
				_indir(sunucu,sira);
			end
		elseif not body then
			(link):yaz(3);
		else
			messages.unknown_error:format(link):yaz(0)
		end
	end

	-- eğer sadece bir paket sunucu güncellenmek istenirse
	if sira > 0 then
		-- sıra aşımlı paket vt güncellenmek istenirse
		if #ayar.sunucu < sira then
			messages.package_db_out_of_order:yaz(0)
		end
		if ayar.sunucu[sira]  then
			_indir(ayar.sunucu[sira],sira)
		end
	-- çoklu sunucu güncelleme - sıra 0 ve 0dan küçük ise
	else
		for _sira,sunucu in ipairs(ayar.sunucu) do
			_indir(sunucu,_sira)
		end
	end
	("------------------------------------"):yaz(2);
end

function islem.guncelle.gitdepo(sira,depo)
	-- tip=betikdepo, gitdepo
	-- depo={isim="betikdepo",tnm="Betik",path=milispath}
	-- depo={isim="gitdepo",tnm="Git",path=talimatname}
	-- bin, ayarlar lı betikdepo güncelleme yapılacak todo!!!
	assert(depo,"depo is nil!!!");
	(depo.tnm.." depoları güncelleniyor:"):yaz(2);
	("------------------------------------"):yaz(2);
	-- iç işlevler
	function do_clone(repo,path)
		local komut="git clone --depth 1 %s %s"
		local ret=shell(komut:format(repo,path))
	end

	function do_pull(path)
		assert(path_exists(path.."/.git"),"invalid git directory")
		local komut="cd %s && git pull"
		local ret=shell(komut:format(path))
	end

	function esitle(repoyol,altdizin,hedef)
		-- todo!!! eşitlenecek dizinden sadece talimat içeren
		-- dizinleri alarak eşitleme yap veya sonda silme
		local komut="cp -rf %s/%s/* %s/"
		if path_exists(repoyol.."/"..altdizin) then
			shell(("mkdir -p %s"):format(hedef))
			shell(komut:format(repoyol, altdizin ,hedef))
		else
			messages.git_repo_subdir_not_found:yaz(0)
		end
	end

	function yedekle(dizin)
		local komut="mv %s %s.ydk"
		assert(path_exists(dizin),dizin.." dizini yok!")
		shell(komut:format(dizin,dizin))
		-- dizin yedeklenerek yeni boş oluşturulur.
		assert(lfs.mkdir(dizin),dizin.." oluşturulamadı.")
	end
	
	-- yedeklenen dizin güncellenemediğinden geri yedeklenir.
	function geri_yedekle(dizin)
		local komut="mv %s.ydk %s"
		assert(path_exists(dizin..".ydk"),dizin..".ydk dizini yok!")
		shell(komut:format(dizin,dizin))
	end

	-- yedeklenen dizinin silinmesi
	function yedek_sil(dizin)
		local komut="rm -rf %s.ydk"
		assert(path_exists(dizin..".ydk"),dizin..".ydk dizini yok!")
		shell(komut:format(dizin,dizin))
	end

	local _repo=""
	local _repoyol=""
	local duzey=""
	local tmp=shell("mktemp")
	
	-- git repo mevcut kontrol komut
	local git_kont="git ls-remote -q %s > %s  2>&1;cat %s | head -n1 | awk '{print $1}'"
	-- !!! burası farklı ayar.betikdepo
	for bdepo,repolar in pairs(ayar[depo.isim]) do
		-- !!! burası farklı
		duzey=depo.path.."/"..bdepo
		-- her talimat-betik düzeyinde yedekleme-eşitleme-eskiyi silme yapılacak
		if path_exists(duzey) then
			yedekle(duzey)
		end
		for repo,dizin in pairs(repolar) do
			-- git repo mevcut kontrolü
			local ret=shell(git_kont:format(repo,tmp,tmp))
			io.write(bdepo," ",repo," ",dizin)
			if ret:match("fatal") then
				("\t-"):yaz(1)
			else
				-- Git işlemleri
				-- repo netde mevcut ise, yerelde yoksa clone varsa pull yapılacak.
				_repo=repo:gsub("https://", "")
				_repo=_repo:gsub("http://", "")
				_repo=_repo:gsub("/", ".")
				print("\t",_repo)
				_repoyol=kokdizin..ayar.repo_dizin.."/".._repo
				if path_exists(_repoyol) then
					do_pull(_repoyol)
				else
					do_clone(repo, _repoyol)
				end
				-- Eşitleme işlemleri
				esitle(_repoyol,dizin,duzey)
			end
		end
		-- sıra-talimat düzeyi işlemler bittikten sonra .ydk düzey silinir.
		if path_exists(duzey..".ydk") then
			if lfs.rmdir(duzey) == true then
				geri_yedekle(duzey)
			else
				yedek_sil(duzey)
			end
		end
	end
	shell(("rm -f %s"):format(tmp));
	("------------------------------------"):yaz(2);
end


-- Mps İşlemleri ----------------------------

-- -ayar öntanımlı ayarlar yükler/kopyalar

-- todo!!! mps kos altına alınacak
islem.ayarla={
	retkey="ayarla:",
	comment=messages.usage_configure,
	usage="mps ayarla",
}

function islem.ayarla.handler()
	-- mps için conf.lua yükleme komutu
	local komut="cp -f %s/conf/conf.lua.sablon %s/conf/conf.lua"
	shell(komut:format(mps_path,mps_path))
end


------------------------------------------------------------

-----------------------------------------

-- Debug işlemleri

islem.debug={
	retkey="debug",
}

function islem.debug.yaz(log)
	if args.debug then
		if log then
			log:yaz()
		else
			messages.empty_log:yaz(0)
		end
	end
end
-----------------------------------------

----------------------------------------

-- Yetkili çalıştırma kontrolü
authorised_check()


---PARAMETRE ANALİZ
-- komutlar
-- kur, sil, in, gun, der, bil, ara, sor, kos


local parser = argparse("mps", "Milis Linux Paket Yöneticisi") :require_command(false)

--seçili olan komutu tespit etmek için
parser:command_target("command")

-- genel seçenekler
parser:flag "-v" "--version" :description "Sürüm bilgisi gösterir"
   :action(function() print("MPS 2.1.1 - Milis Paket Sistemi milisarge@gmail.com") ;os.exit(0) end)

parser:option "--renk"  :default(1)  :description "Çıktının renkli olup olmama durumunu belirler"

parser:option "--kok"    :default "/" :description "Mps işlemleri için hedef kök dizini belirtir"

parser:option "--ilkds" :args(0)     :description "Milis dosya sistemi için hedef kök dizinde ilk yapılandırmaları yapar"

parser:option "--ilk"    :args(0)     :description "Mps nin hedef kök dizinde ilk yapılandırmaları yapar"

parser:flag   "--ona"    :description "Yapılacak mps işlemi için onay verir"

parser:flag   "--debug"  :description "Yapılan işlemlerin ayrıntılı çıktısını verir"

parser:flag   "--test"   :description "Yapılan işlemlerin sadece test işlevini çalıştırır"

-- komut parametreleri

local install = parser:command "kur" :description "paket kurma işlemi" -- :action(handler)
install:argument "paket" :args("*")  :description "yerel/ağ paket girdileri"
install:option "-d" "--dosya"	     :description "dosyadan paketleri kurar"
install:option "--kurkos"  :argname "<0/1>" :default "1" :description "paket kurulum sürecince kurkos betiklerinin çalıştırma durumunu belirler"
install:option "--koskur"  :argname "<0/1>"	:default "1" :description "paket kurulum sürecince kurkos betiklerinin çalıştırma durumunu belirler"
install:option "--otokos"  :argname "<0/1>" :default "1" :description "paket kurulum sürecince kurkos betiklerinin çalıştırma durumunu belirler"
install:option "--zorla"   :args(0)         :description "zorla kurulum durumunu belirler"
install:option "--tekrar"  :args(0) 		:description "paketin yeniden kurulur"

local delete = parser:command "sil" 	:description "paket silme işlemi"
delete:argument "paket" :args("*")      :description "paket girdileri (abc def ghi)"
delete:option   "-d" "--dosya"	    	:description "dosyadan paketleri siler"
delete:option   "--kksiz" :args(0) 		:description "kurulu kontrolü yapılmaz"

local update = parser:command "gun"     :description "güncelleme işlemleri"
update:option "-M" "--mps"     :args(0) :description "mps i günceller"
update:option "-G" "--git"     :args(0) :description "git depoları günceller"
update:option "-B" "--betik"   :args(0) :description "betik depoları günceller"
update:option "-P" "--depo"    :args(0) :description "paket depoları günceller"
update:option "-S" "--sistem"  :args(0) :description "sistemi günceller"
update:option "--sira"   :default "0" 	:description "depo sırasını belirtilir"
update:option "--paket"      :args("*") :description "ilgili paketi günceller"
update:option "--esgec" :args("*") :default "{}" :description "esgeçilecek paketleri belirtir"
update:option "--durum" :args(0)        :description "Güncelleme durum bilgisi verir. Güncelleme yapmaz."

local build = parser:command "der" 	    :description "paket derleme işlemi"
build:argument "paket" :args("*")		:description "paket girdileri (abc def ghi)"
build:option   "-d" "--dosya"	    	:description "dosyadan paketleri derler"
build:option   "--kur"    :args(0) 		:description "derledikten sonra kurar"
build:option   "-t --tek" :args(0) 		:description "gerek kontrolü yapılmadan tek paket derlenir"

local fetch = parser:command "in" 	    :description "paket indirme işlemi"
fetch:argument "paket"   :args("*")		:description "paket girdileri (abc def ghi)"
fetch:option   "-d" "--dosya"	    	:description "dosyadan paketleri indirir"
fetch:option   "--sira"  :default "1" 	:description "paketin indirileceği depo sırası belirtilir"

local search = parser:command "ara"   	:description "paket/talimat/tanım arama işlemi"
search:argument "arama"  :args("+")	    :description "arama girdisi"
search:option   "-t --talimat" :args(0) :description "talimat araması"
search:option   "-a --tanim"   :args(0) :description "tanım araması"
search:option   "--hepsi"  :default "1" :description "talimat aramada hepsinin getirilmesi"

local info = parser:command "bil"   	:description "paket bilgi işlemleri"
info:argument "paket"  :args("+")	    :description "paket girdileri"
info:option   "-g --gerek"              :description "gerek bilgileri -gc=çalışma -gd=derleme -gct=ters çalışma -gdt= ters derleme gereklerini verir"
info:option   "--kk"           :args(0) :description "paketin kurulu olma durumu"
info:option   "--kdl"          :args(0) :description "pakete ait kurulu dosya listesi"
info:option   "--pl"           :args(0) :description "pakete ait paylaşım kütüphane listesi"
info:option   "--lg"           :args(0) :description "paketin ihtiyaç duyduğu paylaşım kütüphane listesi"
info:option   "--pkd"          :args(0) :description "paketin kurulum doğrulaması yapılır"

local query = parser:command "sor"   	:description "genel sorgu işlemleri"
query:option "-L --kpl"        :args(0) :description "kurulu paket listesini verir"
query:option "--dpl"           :args(0) :description "depolardaki paket listesini verir"
query:option "--tpl"           :args(0) :description "temel paket listesini verir"
query:option "--hp" :argname "<aranan>" :args(1) :description "arama girdisinin kurulu hangi pakette olduğunu verir"

local script = parser:command "kos"   	:description "paket için kur/sil/servis koşuk işlemleri"
script:argument "paket"  :args("+")	    :description "paket girdileri"
script:option   "--baskur"              :description "başlama betiğini(servis) kurar"
script:option   "--bassil"              :description "başlama betiğini(servis) siler"
script:option   "--kurkos"              :description "kurulum sonrası betiklerini çalıştırır"
script:option   "--koskur"              :description "kurulum öncesi betiklerini çalıştırır"
script:option   "--silkos"              :description "silme sonrası betiklerini çalıştırır"
script:option   "--kossil"              :description "silme öncesi betiklerini çalıştırır"

-- parametrleri tabloya al
args=parser:parse()

args_handler()

-----------------------------------------
