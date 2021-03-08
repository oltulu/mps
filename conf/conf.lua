#!/usr/bin/env lua

local mpsconf={
	repo_dizin="/sources",
	sunucu={
		[1]="http://paketler.aylinux.org",
		--[2]="http://aylinux.kripto.com.tr/dosyalar/Aylinux-2021/depo",
		--[1]="http://localhost:9999",
	},
	talimatdepo={
		-- git repo adres, ilgili düzeye aktarılacak içerik
		-- tname düzeylere göre
		 [1]={["https://github.com/oltulu/Aylinux-2021"]="talimatlar"},
                --  [2]={["https://mls.akdeniz.edu.tr/git/milis-topluluk/mkd"]="talimatname/test"},
		 -- [3]={
		 --	["https://notabug.org/abc/aylinux"]="2/xorg",
		 -- ["https://notabug.org/def/aylinux"]="2/xfce4",
		 --},
		
	},
	betikdepo={
		-- ilgili repodan bin/ ayarlar/ gibi betik içeren dizinlerin alınması
		bin={["https://github.com/oltulu/mps"]="binn"},
		ayarlar={["https://github.com/oltulu/mps"]="ayarlar"},
		--ayguci={["https://mls.akdeniz.edu.tr/git/milislinux/ayguci"]=""},
		mps={["https://github.com/oltulu/mps"]=""},
	},
}

return mpsconf
