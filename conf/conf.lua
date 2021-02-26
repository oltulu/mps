#!/usr/bin/env lua

local mpsconf={
	repo_dizin="/sources",
	sunucu={
		--[1]="https://mls.akdeniz.edu.tr/paketler",
		--[1]="http://aylinux.kripto.com.tr/dosyalar/Aylinux-2021/depo",
		--[1]="http://localhost:9999",
		[2]="/home/cihan/Masaüstü/Aylinux-2021/depo",
	},
	talimatdepo={
		-- git repo adres, ilgili düzeye aktarılacak içerik
		-- tname düzeylere göre
		-- [1]={["https://mls.akdeniz.edu.tr/git/milislinux/milis19"]="talimatname/1"},
		-- [2]={["https://mls.akdeniz.edu.tr/git/milislinux/milis19"]="talimatname/2"},
		 [1]={["https://github.com/oltulu/Aylinux-2021"]="talimatlar"},
      --  [4]={["https://mls.akdeniz.edu.tr/git/milis-topluluk/mkd"]="talimatname/test"},
		 -- [3]={
		 --	["https://notabug.org/abc/milis"]="2/xorg",
		 -- ["https://notabug.org/def/milis"]="2/xfce4",
		 --},
		
	},
	betikdepo={
		-- ilgili repodan bin/ ayarlar/ gibi betik içeren dizinlerin alınması
		bin={["https://github.com/oltulu/mps"]="binn"},
		ayarlar={["https://github.com/oltulu/mps"]="ayarlar"},
		ayguci={["https://mls.akdeniz.edu.tr/git/milislinux/ayguci"]=""},
		mps={["https://github.com/oltulu/mps"]=""},
	},
}

return mpsconf
