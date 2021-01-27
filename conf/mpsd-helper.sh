#!/bin/sh
# mpsd için yardımcı işlevler

export TOP_PID=$$

hata_olustu(){
	if [ ! -z "$1" ];then 
		echo "$1"
		kill -9 $TOP_PID
		exit 1
	fi
}

BSDTAR="bsdtar"

bsdtar --version | grep "3.3"
[ $? -eq 0 ] && BSDTAR="bsdtar --acls --xattrs"

G_=${DERLEME_ISYER}/tmp/globals/

get_var(){
	[ -f ${G_}$1 ] && printf `cat ${G_}$1` || printf "-"
}

set_var(){
	[ -z $1 ] && hata_olustu "variable param not exists"
	[ -z $2 ] && hata_olustu "value param not exists"
	printf "$2" > ${G_}$1
}

_delete_work_dir() {
	if [ -z ${DERLEME_ISYER} ];then
		echo "DERLEME_ISYER tanımlı değil!"
		exit 1 
	elif [ "x${DERLEME_ISYER}" == "x/" ];then
		echo "DERLEME_ISYER / olamaz!"
		exit 1 
	else
		rm -rf ${DERLEME_ISYER}
	fi
}
_prepare_work_dir(){
	umask 022
	_delete_work_dir
	mkdir -p $SRC $PKG $PKG/${META} ${G_}
}

libgerek_bul(){
	# todo!!! ldd ile tüm gereklerin buldurulup libgerekler dosyasının
	# tek gezmede gerek tespitinin yapılması sağlanabilir mi araştıralacak.
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	echo "libgerek analizi"
	local templg=`mktemp`
	rm -f ${PKG}/libgerekler
	for libso in `find  $PKG -name *.so -type f`;do
		LC_ALL=C objdump -x $libso | grep NEEDED | awk '{print $2}' >> $templg
	done
	#for exec in `find $PKG -executable -type f`;do
	# sadece elf ikililerin dinamiklerini tespit etmek için
	for exec in `find $PKG -executable -type f | xargs -I {}  file {} | grep  ELF | cut -d':' -f1`;do
		LC_ALL=C objdump -x $exec | grep NEEDED | awk '{print $2}' >> $templg
		echo "$exec +"
	done
	awk '!/./ || !seen[$0]++' $templg > ${PKG}/${META}/libgerekler
	rm -f $templg
	cp -v ${PKG}/${META}/libgerekler $PWD/$isim.libgerekler
}

pktlib_bul(){
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	echo "pktlib analizi"
	local temppl=`mktemp`
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
	cp -v ${PKG}/${META}/pktlibler $PWD/$isim.pktlibler
}

compress_manpages() {
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	local FILE DIR TARGET
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
}

delete_non_req_files() {
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	pushd $PWD &>/dev/zero
	echo "istenmeyen dosya/dizinlerin silinmesi işlemi"
	cd $PKG
	# share/info/dir.gz
	local infodirgz=$(find . -type f -printf "%P\n" | grep share/info/dir.gz)
	[ ! -z $infodirgz ] && rm -rvf $infodirgz
	# todo!!!
	# DOC_SIL=1 ayarı değerlendirilecek 
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
	if [ -d usr/share ];then
		[ ! "$(ls -A usr/share)" ] && rm -rvf usr/share
	fi
	###
	# systemd dizin sil
	if [ -d usr/lib/systemd ];then
		rm -rvf usr/lib/systemd
	fi
	# var/run run dizini sistemle çakışıyor
	if [ -d var/run ];then
		rm -rvf var/run
	fi
	if [ -d run ];then
		rm -rvf run
	fi
	echo "-----------------------------------"
	popd &>/dev/zero
}

strip_files() {
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	local _strip_kl=`get_var "STRIP_KARALISTE"`
	if [ -f $PKG/.nostrip ];then
		echo "strip yok"
		STRIP="0"
	fi
	[ "${_strip_kl}" != "-" ] && STRIP_KARALISTE=${_strip_kl}
	if [ "$STRIP" = "1" ];then
		echo "strip(kırpma) işlemi"
		local FILE kara
		kara=""
		# strip_karaliste kontrol edilecek, listedeki dosyalar pas geçilecek
		# karaliste: "a b c" şeklinde gelmektedir.
		pushd $PWD &>/dev/zero
		cd $PKG
		find . -type f -printf "%P\n" | while read FILE; do
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
	else
		echo "strip(kırpma) işlemi iptal edildi"
	fi
}

kosuk_kopyala(){
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	pushd $PWD &>/dev/zero
	echo "kosuk kopyalama"
	local yeniad=""
	for _kosuk in kurkos.sh koskur.sh silkos.sh kossil.sh;do
		if [ -f ${TALIMAT_DIZIN}/${_kosuk} ];then
			yeniad=`printf ${_kosuk} | cut -d'.' -f1`
			cp -fv ${TALIMAT_DIZIN}/${_kosuk} $PKG/${META}/."${yeniad}"
			echo "${_kosuk} pakete eklendi."
		fi
	done
	popd &>/dev/zero
	echo "-----------------------------------"
}

paket_arsiv_bilgi_uret(){
	[ -z $1 ] && hata_olustu "mps paketi tanımlı değil!"
	[ ! -f $1 ] && hata_olustu "mps paketi bulunamadı!"
	echo "paket arşiv bilgisi"
	local pkt=$1
	local pakboyut=`boyut_hesapla $pkt`
	# paket boyutu kontrol edilerek paketin içeriği kontrol edilir
	# bir diğer yöntem de içinde dolu dizin barındırıyor mu ona bakılacak.
	# derleme aşamaları başarı mesajı üretebilir. her işlev kendisinden önceki başarı mesajını kontrol edebilir.
	if [ "$pakboyut" -lt "2000" ]; then
		echo "${urpkt}.mps.lz.bilgi -"
		rm -f $pkt
		hata_olustu "paket oluşturmada hata, yetersiz boyut. Pakur aşamasını kontrol ediniz!!!"	
	else
		# paket arşiv boyut hesaplama
		local kurboyut=`boyut_hesapla $PKG`
		local pakhash=`sha256sum $pkt | awk '{print $1}'`
		local mimari=`uname -m`
		echo "$isim $surum $devir $mimari $pakboyut $kurboyut $pakhash" > "${pkt}.bilgi"
		echo "${urpkt}.mps.lz.bilgi +"
	fi
	echo "-----------------------------------"
}

paket_ustbilgi_uret(){
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	local derzaman=`date +%s`
	local mimari=`uname -m`
	local boyut=`boyut_hesapla $PKG`
	
	libgerek_bul
	pktlib_bul
	rm -f ${META}/${USTBILGI}
	
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
}

paket_icerik_bilgi_uret(){
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	pushd $PWD &>/dev/zero
	cd $PKG
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
}

paket_arsivle(){
	[ ! -d $PKG ] && hata_olustu "paketleme dizini: $PKG bulunamadı!"
	local urpkt="${PAKETLEME_DIZIN}/${isim}#${surum}-${devir}-$(uname -m)"
	echo "paket arşivi"
	pushd $PWD &>/dev/zero
	cd $PKG
	set -x
	LANG=C \
	$BSDTAR --preserve-permissions \
	-cf ${urpkt}.mps * ${META} ${ICBILGI}
	rm -f ${urpkt}.mps.lz
	#xz -4 --threads=0 ${urpkt}
	set +x
	#mv ${urpkt}.xz ${urpkt}.mps
	lzip -9 ${urpkt}.mps
	popd &>/dev/zero
	echo "paket arşivi: ${urpkt}.mps.lz +"
	echo "-------------------------------"
	paket_arsiv_bilgi_uret "${urpkt}.mps.lz"
}

_generate_package(){
	# paket üretimden önce PKG/ altına atılmış dosya kontrolü
	cd $PKG
	if [ "`ls|wc -l`" == "0" ]; then
		hata_olustu "Boş paketleme dizini!!!"
	fi
	cd -
	echo "PAKET OLUŞTURMA = ${isim}#${surum}-${devir}" 
	echo "---------"
	time_start
	echo "======================================================="
	strip_files
	compress_manpages
	delete_non_req_files
	kosuk_kopyala
	paket_ustbilgi_uret
	paket_icerik_bilgi_uret
	paket_arsivle
	# paket sorunlu ise workdir silinmeyecek!!!!
	# echo "todo: paket sorunlu ise workdir silinmeyecek!!!!"
	_delete_work_dir
	# [ "$G_x" != "/x" ] && rm -rf G_
	echo "======================================================="
	time_finish
	echo "======================================================="
}

indir_git(){
	# girdi: git_kaynak_adres, klon_ismi//git://adresdeki dosya, klon konumu//$KAYNAKLAR_DEPO
	local _branch konum
	_branch=""
	[ ! -z $1 ] && local _gitadres=$1 || hata_olustu "git adresi tanımlı değil"
	[ ! -z $2 ] && local _isim=$2     || ad="`echo ${_gitadres} | sed 's|^.*://.*/||g'`"
	[ ! -z $3 ] && local konum=$3  || konum=${KAYNAKLAR_DEPO}
	
	#branch kontrolü
	_branch=`echo "${_gitadres}" |sed 's/#branch=/\n/g' | sed -n 2p`
	if [ ! -z ${_branch} ];then
	 _gitadres=`echo "${_gitadres}" |sed 's/#branch=/\n/g' | sed -n 1p`
	 _branch="-b ${_branch}"
	fi
	if [ ! -d ${konum}/${_isim}  ];then
		git clone ${_branch} ${_gitadres} ${konum}/${_isim}
	else
		cd ${konum}/${_isim} 
		git pull
		cd -
	fi
	cp -r ${konum}/${_isim} $SRC/
}


indir_wget(){
	# girdi: kaynak_adres, kayıt ismi//adresdeki dosya, kayıt konumu//$KAYNAKLAR_DEPO
	# ack: girdilere göre dosya wget ile önce .partial olarak iner başarılı tamamlanırsa
	# partial normal kayıt ismine aktarılır yoksa partial dosya üzerinden kısmi indirme devam eder.
	
	
	local hata
	local wget_sertifika_ayar=""
	[ ! -f /etc/ssl/certs/ca-certificates.crt ] && wget_sertifika_ayar="--no-check-certificate"
	
	[ ! -z $1 ] && local kaynak=$1 || hata_olustu "kaynak param eksik"
	[ ! -z $2 ] && local ad=$2     || ad="`echo $kaynak | sed 's|^.*://.*/||g'`"
	[ ! -z $3 ] && local konum=$3  || konum=${KAYNAKLAR_DEPO}
	
	local indirilen=${konum}/${ad}
	if [ -f ${konum}/${ad} ];then
		if [ ! -s ${konum}/${ad} ];then
			echo "boş kaynak dosyası"
			rm -rfv ${konum}/${ad}
			# eğer linkte bir hata varsa sürekli döngüye girebilir, hata atıyoruz.
			return 1
		else
			echo "${konum}/${ad} Dosya zaten mevcut"
			return
		fi
	fi
	# kaynak dosyası yoksa indirilecek
	# wget indirme aracnın kontrolü
	komut_kontrol wget
	local kismi_indirilen="${indirilen}.partial"
	local indirme_param="${wget_sertifika_ayar} --passive-ftp --no-directories \
						--tries=3 $wget_retry \
						-O $indirilen \
						--output-document=$kismi_indirilen \
						${WGET_GENEL_PARAM}"

	if [ -f "$kismi_indirilen" ];then
		echo "Kısmi indirme var,tamamlanmaya çalışılacak"
		kismi_indirme="-c"
	fi
	komut="wget ${kismi_indirme} ${indirme_param} $kaynak"
	#echo $komut
	
	hata=1
	
	if [ $hata != 0 ]; then
		while true; do
			wget ${kismi_indirme} ${indirme_param} $kaynak
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
		echo "İndiriliyor '$adres' başarısız."
		hata_olustu "indirilirken hata oluştu"	
	fi

	mv -f "${kismi_indirilen}" "${indirilen}"
		
}

_disari_cikar() {
	# girdi: kaynak_dosya, çıkarma_yeri
	# todo!!! gz(tarsız) uzantılı kaynaklara extract işlevi eklenecek
	local _arsiv _yer komut
	[ $1 ] && _arsiv=$1 || hata_olustu "_arsiv_gerekli"
	[ $2 ] && _yer=$2   || hata_olustu "_konum_gerekli"
	if [ ${TAR} = "tar" ];then
		komut_kontrol tar
		echo "gnu tar ile dışarı çıkarılacak"
		komut="tar xf ${_arsiv} -C ${_yer}"
	elif [ `basename ${TAR}` = "bsdtar" ];then
		komut_kontrol bsdtar
		komut="${TAR} -p -o -C ${_yer} -xf ${_arsiv}"
	else
		echo "farklı sıkıştırma aracı!!!"
		exit 1
	fi
	echo ${komut} 
	${komut}
}

kaynak_cikar() {
	# girdi: arsiv_listesi. kaynakların kayıt adlarının bulunduğu liste
	local arsiv_dosya
	local komut
	[ ! -z $1 ] && local arsiv_dosya=$1  || arsiv_dosya=${SRC}/arsiv.list
	[ ! -f ${arsiv_dosya} ] && return 1 # hata_olustu "arşiv liste dosyası bulunamadı!"
	
	for dosya in `cat ${arsiv_dosya}`; do
		unset komut
		case $dosya in
			*.tar|*.tar.gz|*.tar.Z|*.tgz|*.lz|*.tar.bz2|*.tbz2|*.tar.xz|*.txz|*.tar.lzma|*.zip|*.rpm)
				if [ ! "$CIKARMA_ATLA" -eq 1 ];then
					_disari_cikar ${KAYNAKLAR_DEPO}/$dosya $SRC
				else
					komut="cp ${KAYNAKLAR_DEPO}/$dosya $SRC"
				fi ;;
			*)
				if [ -f ${TALIMAT_DIZIN}/${dosya} ];then
					komut="cp ${TALIMAT_DIZIN}/$dosya $SRC"
				elif [ -f ${KAYNAKLAR_DEPO}/${dosya} ];then
					komut="cp ${KAYNAKLAR_DEPO}/$dosya $SRC"
				elif [ -d ${KAYNAKLAR_DEPO}/${dosya} ];then
					komut="cp -r ${KAYNAKLAR_DEPO}/$dosya $SRC"
				else
					hata_olustu "${dosya} dosya bulunamadı!"
				fi ;;
		esac
		
		if [ ! -z "$komut" ];then
			#echo "$komut"
			${komut}
		fi
	done
}

boyut_hesapla(){
	local dizin
	local boyut
	[ -z $1 ]       && hata_olustu "boyut hesaplama için dizin ismi gerekli"  || dizin=$1
	[ ! -s $dizin ] && hata_olustu "ilgili dizin boş veya tanımsız"
	boyut=`du -sb ${dizin} | awk '{print $1}'`
	printf $boyut
}

time_start(){
	echo "started: `date +%x\ %H:%M:%S`"	
}

time_finish(){
	echo "finished: `date +%x\ %H:%M:%S`"	
}

komut_kontrol() {
    [ -z $1 ] && hata_olustu "kontrol edilecek komut parametresi gerekli!"
    command -v $1 > /dev/null 2>&1
    [ ! $? -eq 0 ] && hata_olustu "$1 komutu gerekli"
}

# MODS
# mod tanımlanırsa aşağıdaki fonksiyonlar işletilecek
# yoksa rutin derleme adımları işletilir.

only_download_sources(){
	_prepare_work_dir;
	_download_copy;
	_hash_check
}

only_extract(){
	_prepare_work_dir;
	_download_copy;
	_hash_check;
	_extract
}

only_build(){
	_prepare_work_dir;
	_download_copy;
	_hash_check;
	_extract;
	#_install_bdeps;
	_build
}

re_build(){
	_build
}

re_generate(){
	_install;
	_generate_package
}

display_usage(){
	echo "valid parameters:"
	echo
	echo " --download     Only download sources"
	echo " --extract      download and extract sources"
	echo " --build        only build package"
	echo " --generate     generate package"
	echo
	echo "or just go without parameters, it builds routine steps"
}

run(){

# BUILD ROUTINE
#====================================================
arg="$1"
if [ -z $arg ] ; then
	# DEFAULT BUILD STEPS
	#==========================================
	rm -f ${BUILD_LOG}
	rm -f ${INSTALL_LOG}
	rm -f ${_LOG}
	_prepare_work_dir 2>&1 | tee ${_LOG}
	_download_copy    2>&1 | tee -a ${_LOG}
	_hash_check       2>&1 | tee -a ${_LOG}
	_extract          2>&1 | tee -a ${_LOG}
	#_install_bdeps    2>&1 | tee -a ${_LOG}
	_build  		  2>&1 | tee ${BUILD_LOG}
	_install 		  2>&1 | tee ${INSTALL_LOG}
	_generate_package 2>&1 | tee -a ${_LOG}
	#==========================================
else
  case $arg in
    --download)
      only_download_sources
      ;;
    --extract)
      only_extract
      ;;
    --build)
      only_build
      ;; 
    --rebuild)
      re_build
      ;; 
    --generate)
      re_generate
      ;; 
    *)
      echo "invalid parameter: ${arg}"
      display_usage
      exit 1
      ;;
  esac
fi
#====================================================
}
