#!/usr/bin/env lua

local mpsconf={
	repo_dizin="/sources",
	sunucu={
		--[1]="https://mls.akdeniz.edu.tr/paketler",
		[1]="http://aylinux.kripto.com.tr/dosyalar/Aylinux-2021/depo",
		--[1]="http://localhost:9999",
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
		bin={["https://github.com/oltulu/Aylinux-2021"]="mps/bin"},
		ayarlar={["https://github.com/oltulu/Aylinux-2021"]="mps/ayarlar"},
		ayguci={["https://github.com/oltulu/Aylinux-2021"]="mps/ayguci"},
		mps={["https://github.com/oltulu/Aylinux-2021"]="mps/mps"},
	},
}

return mpsconf
