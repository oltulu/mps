function formatter(fmt, ...)
    local args, order = {...}, {}

    fmt = fmt:gsub('%%(%d+)%$', function(i)
        table.insert(order, args[tonumber(i)])
        return '%'
    end)

    return string.format(fmt, table.unpack(order))
end

function file_content(filename)
	local f = assert(io.open(filename, "r"))
	local t = f:read('*all')
	f:close()
	return t
end

helper={}
helper.scripts={

	strip=[===[
PKG=%s
STRIP_KARALISTE=%s

pushd $PWD &>/dev/zero
cd $PKG
find . -type f -printf "%%P\n" | while read FILE; do
  if [ ! -z $STRIP_KARALISTE ];then
    kara=`echo "$STRIP_KARALISTE" | awk -v FILE="$FILE" '$1 ~ FILE  {print $1}'`
  fi
  if [ -z $kara ];then
    case $(file -b "$FILE") in
    *ELF*executable*not\ stripped)
      strip --strip-all "$FILE"
      echo "$FILE +"
      ;;
    *ELF*shared\ object*not\ stripped)
      strip --strip-unneeded "$FILE"
      echo "$FILE +"
      ;;
    current\ ar\ archive)
      strip --strip-debug "$FILE"
      echo "$FILE +"
    esac
  else
    echo "$FILE -"
  fi
done
popd &>/dev/zero
]===],

	delete_files=[===[
PKG=%s
[ -z $PKG ] && exit 1
[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
pushd $PWD &>/dev/zero
echo "istenmeyen dosya/dizinlerin silinmesi işlemi"
cd $PKG
# share/info/dir.gz
infodirgz=$(find . -type f -printf "%%P\n" | grep share/info/dir.gz)
[ ! -z $infodirgz ] && rm -rvf $infodirgz
[ -d usr/share/doc ] && rm -rvf usr/share/doc
[ -d usr/share/gtk-doc ] && rm -rvf usr/share/gtk-doc
# todo!!!
# INFO_SIL=1 ayarı değerlendirilecek 
[ -d usr/share/info ] && rm -rvf usr/share/info
# todo!!!
# LIBTOOL_SIL=1 ayarı değerlendirilecek 
# .la files deleting
[ -d usr/lib ] && find usr/lib -name "*.la" ! -path "usr/lib/ImageMagick*" -exec rm -fv {} \;
# perl gereksizleri
if [  -d usr/lib/perl5 ];then
  find $PKG -iname 'TODO*' -or \
  -iname 'Change*' -or \
  -iname 'README*' -or \
  -name '*.bs' -or \
  -name .packlist -or \
  -name perllocal.pod | xargs rm -v
fi
# sbin altındakileri bin altına taşıma
if [ -d $PKG/usr/sbin ] && [ ! -l $PKG/usr/sbin ];then
  mv -v $PKG/usr/sbin/* $PKG/usr/bin
  rm -rvf $PKG/usr/sbin
fi
if [ -d $PKG/sbin ]  && [ ! -l $PKG/sbin ];then
  mv -v $PKG/sbin/* $PKG/usr/bin
  rm -rvf $PKG/sbin
fi
if [ -d $PKG/bin ] && [ ! -l $PKG/bin ];then
  mv -v $PKG/bin/* $PKG/usr/bin
  rm -rvf $PKG/bin
fi
if [ -d $PKG/lib ] && [ ! -l  $PKG/lib ];then
  cp -rvf $PKG/lib/* $PKG/usr/lib/
  rm -rvf $PKG/lib
fi
# boş dizin sil
[ -d usr/share ] && [ ! "$(ls -A usr/share)" ] && rm -rvf usr/share
# systemd dizin sil
[ -d usr/lib/systemd ] && rm -rvf usr/lib/systemd
# var/run run dizini sistemle çakışıyor
[ -d var/run ] && rm -rvf var/run
[ -d run ] && rm -rvf run
popd &>/dev/zero
]===],

	copy_scripts=[===[
TALIMAT_DIZIN=%s
[ -z $TALIMAT_DIZIN ] && exit 1
PKG=%s
META=%s
[ -z $PKG ] && exit 1
pushd $PWD &>/dev/zero
echo "kosuk kopyalama"
yeniad=""
for _kosuk in kurkos.sh koskur.sh silkos.sh kossil.sh;do
  if [ -f ${TALIMAT_DIZIN}/${_kosuk} ];then
    yeniad=`printf ${_kosuk} | cut -d'.' -f1`
    cp -fv ${TALIMAT_DIZIN}/${_kosuk} $PKG/${META}/."${yeniad}"
    echo "${_kosuk} pakete eklendi."
  fi
done
# yururluk dosya kopyalama
yururluk_dosya="/tmp/$(basename ${TALIMAT_DIZIN}).yur"
[ -f ${yururluk_dosya} ] && cp ${yururluk_dosya} $PKG/${META}/
popd &>/dev/zero
]===],

	libdepends=[===[
PKG=%s
META=%s
if [ ! -d $PKG ];then
  echo "paketleme dizini: $PKG bulunamadı!"
  exit 1
fi
echo "libgerek analizi"
templg=`mktemp`
rm -f ${PKG}/libgerekler
for libso in `find  ${PKG} -name *.so -type f`;do
  LC_ALL=C objdump -x $libso | grep NEEDED | awk '{print $2}' >> $templg
done

for libso in `find  ${PKG} -name *.so.* -type f`;do
  LC_ALL=C objdump -x $libso | grep NEEDED | awk '{print $2}' >> $templg
done
# sadece elf ikililerin dinamiklerini tespit etmek için
for exec in `find $PKG -executable -type f | xargs -I {}  file {} | grep  ELF | cut -d':' -f1`;do
  LC_ALL=C objdump -x $exec | grep NEEDED | awk '{print $2}' >> $templg
  echo "$exec +"
done
awk '!/./ || !seen[$0]++' $templg > ${PKG}/${META}/libgerekler
rm -f $templg
cat ${PKG}/${META}/libgerekler | sort > $PWD/$isim.libgerekler
]===],

	pkglibs=[===[
echo "pktlib analizi"
temppl=`mktemp`
rm -f ${PKG}/pktlibler
for libso in `find $PKG -name *.so* -type f`;do
  # paket içerik so dosya isminin yazılması
  echo "`basename $libso`" >> $temppl
  echo "$libso +"
done
for libso in `find $PKG -name *.so* -type l`;do
  # paket içerik so dosya isminin yazılması
  echo "`basename $libso`" >> $temppl
  echo "$libso +"
done
# mükerrer kayıtların elenmesi.
awk '!/./ || !seen[$0]++' $temppl > ${PKG}/${META}/pktlibler
rm -f $temppl
cat ${PKG}/${META}/pktlibler | sort > $PWD/$isim.pktlibler
]===],
	
	compress_manpages=[===[
PKG=%s
[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"

pushd $PWD &>/dev/zero
cd $PKG
echo "manpages(arşivleme) işlemi"
find . -type f -path "*/share/man*/*" | while read FILE; do
  if [ "$FILE" = "${FILE%%.gz}" ]; then
    gzip -9 "$FILE"
  fi
done

find . -type l -path "*/share/man*/*" | while read FILE; do
  TARGET=`readlink -n "$FILE"`
  TARGET="${TARGET##*/}"
  TARGET="${TARGET%%.gz}.gz"
  rm -f "$FILE"
  FILE="${FILE%%.gz}.gz"
  DIR=`dirname "$FILE"`

  if [ -e "$DIR/$TARGET" ]; then
    ln -sf "$TARGET" "$FILE"
  fi
done
find . -type f -path "*/share/info/*" | while read FILE; do
  if [ "$FILE" = "${FILE%%.gz}" ]; then
    gzip -9 "$FILE"
  fi
done
find . -type l -path "*/share/info/*" | while read FILE; do
  TARGET=`readlink -n "$FILE"`
  TARGET="${TARGET##*/}"
  TARGET="${TARGET%%.gz}.gz"
  rm -f "$FILE"
  FILE="${FILE%%.gz}.gz"
  DIR=`dirname "$FILE"`

  if [ -e "$DIR/$TARGET" ]; then
    ln -sf "$TARGET" "$FILE"
  fi
done
popd &>/dev/zero
]===],
	
	meta_info=[===[
PKG=%s
META=%s
boyut=%s
thash=%s
USTBILGI=".ustbilgi"
mimari=`uname -m`
derzaman=`date +%%s`
rm -f ${PKG}/${META}/${USTBILGI}	
# meta bilgilerin oluşturulması
cat <<EOF > ${PKG}/${META}/${USTBILGI}
isim=$isim
surum=$surum
devir=$devir
tanim=$tanim
url=$url
paketci=$paketci					
derzaman=$derzaman
mimari=$mimari
grup=$grup
boyut=$boyut
thash=$thash
EOF
echo "paket üstbilgileri ${PKG}/${USTBILGI} dosyasına yazıldı."
]===],

	content_info=[===[
PKG=%s
BSDTAR=$(which bsdtar)
if [ ! -d $PKG ];then
  echo "paketleme dizini: $PKG bulunamadı!"
  exit 1
fi
pushd $PWD &>/dev/zero
cd $PKG
ICBILGI=".icbilgi"
rm -f ${ICBILGI}
# yöntem 1
#LANG=C  mtree -c -K sha256digest > ${ICBILGI}.k
# yöntem 2
LANG=C \
$BSDTAR --preserve-permissions --format=mtree \
--options='!all,use-set,type,uid,gid,mode,time,size,sha256,link' \
-czf - * ${META} > ${ICBILGI}

popd &>/dev/zero
echo "paket içbilgileri ${PKG}/${ICBILGI} dosyasına yazıldı."
]===],

	generate_package=[===[
PKG=%s
META=%s
BSDTAR=$(which bsdtar)
SUFFIX="mps.lz"
if [ ! -d $PKG ];then
  echo "paketleme dizini: $PKG bulunamadı!"
  exit 1
fi
urpkt="$PWD/${isim}#${surum}-${devir}"

ICBILGI=".icbilgi"
pushd $PWD &>/dev/zero
cd $PKG
set -x
LANG=C \
$BSDTAR --preserve-permissions \
-cf ${urpkt}.mps * ${META} ${ICBILGI}
rm -f ${urpkt}.kur
#xz -4 --threads=0 ${urpkt}
set +x
#mv ${urpkt}.xz ${urpkt}.mps
lzip -9 ${urpkt}.mps
mv ${urpkt}.mps.lz ${urpkt}.kur

echo "Paket arşivi: ${urpkt}.kur +"
echo "\n"
if [ -z ${urpkt} ];then
  echo "mps paketi tanımlı değil!"
  exit 1
fi
if [ ! -f ${urpkt}.kur ];then
  echo "mps paketi bulunamadı!"
  exit 1
fi

echo "paket arşiv bilgisi"
pakboyut=`du -sb ${urpkt}.kur | awk '{print $1}'`
if [ "$pakboyut" -lt "2000" ]; then
  echo "${urpkt}.kur.bilgi -"
  rm -f ${urpkt}
  echo "paket oluşturmada hata, yetersiz boyut. Pakur aşamasını kontrol ediniz!!!"	
  exit 1
else
  # paket arşiv boyut hesaplama
  kurboyut=`du -sb ${PKG}| awk '{print $1}'`
  pakhash=`sha256sum ${urpkt}.kur | awk '{print $1}'`
  mimari=`uname -m`
  echo "$isim $surum $devir $mimari $pakboyut $kurboyut $pakhash" > "${urpkt}.kur.bilgi"
  echo "${urpkt}.kur.bilgi +"
fi
#mv ${urpkt}.kur.bilgi ${urpkt}.kur.bilgi
popd &>/dev/zero
]===],

wget=[===[
kaynak=%s
indirilen=%s

wget_genel_param=" --progress=bar:force" 
wget_sertifika_ayar=""
indirme_iptal=0

[ ! -f /etc/ssl/certs/ca-certificates.crt ] && wget_sertifika_ayar="--no-check-certificate"
	
if [ -z $kaynak ];then
  echo "kaynak parametresi eksik"
  exit 1 
fi
if [ -z $indirilen ];then
  echo "indirilen parametresi eksik"
  exit 1 
fi

# kaynak var ise

if [ -f ${indirilen} ];then
  if [ ! -s ${indirilen} ];then
    echo "boş kaynak dosyası"
    rm -rfv ${indirilen}
    # eğer linkte bir hata varsa sürekli döngüye girebilir, hata atıyoruz.
    exit 1
  else
    echo "${indirilen} Dosya zaten mevcut"
    indirme_iptal=1
  fi
fi
# kaynak dosyası yoksa indirilecek
if [ $indirme_iptal -eq 0 ];then
  kismi_indirilen="${indirilen}.partial"
  indirme_param="${wget_sertifika_ayar} --passive-ftp --no-directories --tries=3 -O $indirilen --output-document=$kismi_indirilen ${wget_genel_param}"

  [ -f "$kismi_indirilen" ] && kismi_indirme="-c"
  komut="wget ${kismi_indirme} ${indirme_param} $kaynak"
  hata=1
	
  if [ $hata != 0 ]; then
  while true; do
    LC_ALL=C wget ${kismi_indirme} ${indirme_param} $kaynak
    hata=$?
    if [ $hata != 0 ] && [ "$kismi_indirme" ]; then
      echo "Kısmi indirme hata oluştu,tekrar başlatılıyor"
      rm -f "$kismi_indirilen"
      kismi_indirme=""
    else
      break
    fi
  done
  fi

  if [ $hata != 0 ]; then
    echo "İndiriliyor '$kaynak' başarısız."
    exit 1
  fi

  mv -f "${kismi_indirilen}" "${indirilen}"
fi
]===],

}

-- Rules of Talimat
rules={

dirs={
	-- don't forget last slash
	src     = "/tmp/work/src/",
	pkg     = "/tmp/work/pkg/",
	pkg_meta= ".meta",
	archive = "/sources/",
},

export={
	me = function(key,default,val) if val ~=nil then return 'export '..key..'="'..val..'"' else return 'export '..key..'="'..default..'"' end end,
	talimat=function (pmeta)
	  exports={}
	  for key,val in pairs(pmeta) do
		table.insert(exports,("export "..key.."="..'"'..val..'"'))
	  end
	  return exports
	end,
	dirs=function ()
	  exports={}
	  table.insert(exports,("export ".."PKG".."="..'"'..rules.dirs.pkg..'"'))
	  table.insert(exports,("export ".."SRC".."="..'"'..rules.dirs.src..'"'))
	  table.insert(exports,("export ".."META".."="..'"'..rules.dirs.pkg_meta..'"'))
	  table.insert(exports,("export ".."KAYNAK_DIZIN".."="..'"'..rules.dirs.archive..'"'))
	  return exports
	end,
	source_aliases=[===[
KERNEL_SITE="https://www.kernel.org/pub/linux/"
GNU_SITE="https://ftp.gnu.org/gnu/"
GNOME_SITE="https://download.gnome.org/sources"
PYPI_SITE="https://files.pythonhosted.org/packages/source"
XFCE4_SITE="https://archive.xfce.org/src"
CPAN_SITE="https://www.cpan.org/modules/by-module"
SOURCEFORGE_SITE="https://downloads.sourceforge.net/sourceforge"
FREEDESKTOP_SITE="https://www.freedesktop.org/software/"
DEBIAN_SITE="http://ftp.debian.org/debian/pool/"
KDE_SITE="https://download.kde.org/stable/"
XORG_SITE="https://www.x.org/releases/individual"
	]===],
},

make_dirs={
	src     = function() return "rm -rf "..rules.dirs.src..";mkdir -pv "..rules.dirs.src   end,
	pkg     = function() return "rm -rf "..rules.dirs.pkg..";mkdir -pv "..rules.dirs.pkg   end,
	pkg_meta= function() return "mkdir -pv "..rules.dirs.pkg..rules.dirs.pkg_meta  end,
	archive = function() return "mkdir -pv "..rules.dirs.archive   end,
},

package={
	archive="$isim-$surum"
},

source={
	gz     = function(t,v) return v.."/"..t.paket.isim.."-"..t.paket.surum..".tar.gz"   end,
	xz     = function(t,v) return v.."/"..t.paket.isim.."-"..t.paket.surum..".tar.xz"   end,
	bz2    = function(t,v) return v.."/"..t.paket.isim.."-"..t.paket.surum..".tar.bz2"  end,
	tgz    = function(t,v) return v.."/"..t.paket.isim.."-"..t.paket.surum..".tgz"      end,
    github = function(t,v) return "https://github.com/"..v.."/archive/v"..t.paket.surum..".tar.gz::"..t.paket.isim.."-"..t.paket.surum..".tar.gz" end
},

fetch={
	--url    = function(f) return rules.wget.bin..rules.wget.params..f.address.." -O "..f.store  end,
	url    = function(f) return helper.scripts.wget:format(f.address,f.store)  end,
	git    = function(f) 
				return ("([ -d %s ] && (cd %s;git pull) || git clone %s %s ) && cp -r %s %s")
				:format(f.store,f.store,f.address,f.store,f.store,rules.dirs.src)
			 end,
	svn    = function(f) 
				return ("([ -d %s ] && (cd %s;svn up) || svn co %s %s ) && cp -r %s %s")
				:format(f.store,f.store,f.address,f.store,f.store,rules.dirs.src)
			 end,
	--file   = function(f) return "cp  -f "..f.address.." "..rules.dirs.src..f.store  end,
	dir    = function(f) return "cp  -frv "..f.address.." "..f.store  end,
	file   = function(f) return "cp  -fv "..f.address.." "..f.store  end,
	check  = function(f) return ("[ -f %s ] && exit 0"):format(f.store)  end,
},

hash={
	sha256 = function(file,hash) return ('set -x;echo "%s %s" | sha256sum --check'):format(hash,file) end,
	sha512 = function(file,hash) return ('set -x;echo "%s %s" | sha512sum --check'):format(hash,file) end,
},

extract={
	bsdtar = function(dir,archive) return ("set -x;bsdtar -p -o -C %s -xf %s"):format(dir,archive) end,
},

build_type={
	gnu   = "./configure ${CONF_OPT} ${EXT_OPT} && make ${MAKEJOBS}",
	cmake = "mkdir -p build;cd build;cmake ${CMAKE_OPT} ${EXT_OPT} ../ && make ${MAKEJOBS}",
	py3   = "python3 setup.py build",
	py2   = "python2 setup.py build",
	perl  = "perl Makefile.PL INSTALLDIRS=vendor && make",
	meson = "[ -z $ARCHIVE_DIR ] && ARCHIVE_DIR=$isim-$surum ; cd $SRC && milis-meson $ARCHIVE_DIR build ${EXT_OPT}",
	ninja = "mkdir -p build && ninja -C build",
	waf   = "python3 waf configure --prefix=/usr ${EXT_OPT} && python3 waf build",
	qmake = "qmake-qt5 CONFIG+=release PREFIX=/usr ${EXT_OPT} && make ${MAKEJOBS}",
},

build_env={
	carch    = function(v) return rules.export.me("CARCH","x86_64",v) end,
	chost    = function(v) return rules.export.me("CHOST","x86_64-pc-linux-gnu",v) end,
    cppflags = function(v) return rules.export.me("CPPFLAGS","-D_FORTIFY_SOURCE=2",v) end,
    cflags   = function(v) return rules.export.me("CFLAGS","-march=x86-64 -mtune=generic -O2 -pipe -fno-plt",v) end,
    cxxflags = function(v) return rules.export.me("CXXFLAGS","-march=x86-64 -mtune=generic -O2 -pipe -fno-plt",v) end,
	ldflags  = function(v) return rules.export.me("LDFLAGS","-Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now",v) end,
	jobs     = function(v) if v == nil then return rules.export.me("MAKEJOBS","-j$((`nproc`+1))",nil) 
						   else return rules.export.me("MAKEJOBS","-j$((`nproc`+1))","-j"..tostring(v)) end
			   end,
	confopt  = function(v) return rules.export.me("CONF_OPT","--prefix=/usr --libdir=/usr/lib --libexecdir=/usr/lib --bindir=/usr/bin --sbindir=/usr/bin --sysconfdir=/etc --mandir=/usr/share/man --infodir=/usr/share/info --datadir=/usr/share --localstatedir=/var --disable-static",v) end,
    cmakeopt = function(v) return rules.export.me("CMAKE_OPT"," -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib -DCMAKE_INSTALL_LIBEXECDIR=/usr/lib ",v) end,
},	

build={	
	cd    = function(t,v) return rules.change.dir(rules.dir.src..v) end,
	tip   = function(t,v) return rules.build_type[v] end,
	betik = function(t,v) return v               end,
	dosya = function(t,v) return "set -e \n"..file_content(t.dir.."/"..v).."set +e \n" end,
	ekconf= function(t,v) return rules.export.me("EXT_OPT",nil,v) end,
	yama  = function(t,v) return "patch -Np1 -i $SRC/"..v end,
	yama0 = function(t,v) return "patch -Np0 -i $SRC/"..v end,
	bayrak= function(t,v) if v == "yok" or v == "0" then return "unset CPPFLAGS;unset CFLAGS;unset CXXFLAGS;unset LDFLAGS" end
			end,
},

install_type={
	gnu   = "make DESTDIR=$PKG install $EXT_OPT",
	cmake = "cd build;make DESTDIR=$PKG install",
	py3   = "python3 setup.py install --root=${PKG} --optimize=1 --skip-build $EXT_OPT",
	py2   = "python2 setup.py install --root=${PKG} --optimize=1 --skip-build $EXT_OPT",
	ninja = "DESTDIR=$PKG ninja -C build install",
	meson = "cd $SRC && DESTDIR=$PKG ninja -C build install",
	waf   = "python3 waf install --destdir=$PKG",
	qmake = [===[make INSTALL_ROOT=${PKG} install && [ -d $PKG/usr/lib ] \
	&& find $PKG/usr/lib -type f -name '*.prl' -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;]===],
},

install={
	cd      = function(t,v) return rules.change.dir(rules.dir.src..v) end,
	tip     = function(t,v) return rules.install_type[v] end,
	betik   = function(t,v) return v end,
	dosya   = function(t,v) return "set -e \n"..file_content(t.dir.."/"..v).."set +e \n" end,
	strip   = function(t,v) if v == "yok" or v == "0" then rules.strip.status=false end; end,
	nostrip = function(t,v) rules.strip.blacklist=v end,
	servis  = function(t,v) return ("cd /usr/milis/ayarlar/servisler\nmake DESTDIR=$PKG kur-%s\ncd -"):format(v) end,
},

strip={
	status    = true,
	blacklist = '""',
	files     = function(pkg,blacklist) return helper.scripts.strip:format(pkg,blacklist) end,
},

compress={
	man=function(pkg) return helper.scripts.compress_manpages:format(pkg) end,
},

delete={
	-- it will just files=
	files_un=function(path) return helper.scripts.delete_files:format(path) end,
	files=function(path,pattern,ignore) return 
	"find "..path..' -name "'..pattern..'" ! -path "'..ignore..'" -type f -exec rm -rfv {} + &>/dev/null' end,
	dir=function(path) return "rm -rf "..path end,
},

copy={
	-- it will just files=
	scripts=function(talimatdir,pkg,meta) return helper.scripts.copy_scripts:format(talimatdir,pkg,meta) end,
},

generate={
	meta_info=function(pkg,meta,size,thash) return helper.scripts.meta_info:format(pkg,meta,size,thash) end,
	content_info=function(pkg) return helper.scripts.content_info:format(pkg) end,
	package=function(pkg,meta) return helper.scripts.generate_package:format(pkg,meta) end,
},

calculate={
	size=function(path) return "`du -sb "..path.."| awk '{print $1}'`" end,
},

find={
	libdepends=function(pkg,meta) return helper.scripts.libdepends:format(pkg,meta) end,
	-- if they call one by one so pass parameters
	pkglibs=function() return helper.scripts.pkglibs end,
},

change={
	dir = function(dir) 
		local changedir="[ -d %s ] && cd %s"
		if dir then return changedir:format(dir,dir) end
	end,
}

}-- end of rules
return rules;
