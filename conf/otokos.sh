#!/bin/sh
# Dosya ve dizin içeriklerine bağlı olarak
# paketlerin kurulum, silme ve güncelleme durumlarında tetiklenecek kodların yönetim kodu.

mod=$1
if [ -z $mod ];then
	echo "mod belirtiniz!"
	exit 1
fi

tname="/usr/milis/talimatname"

echo "paket kur otokoş işlemi"
# talimatnameden otokos.sh uzantılı betikleri bulup iç ederek
# kur işlevlerini çalıştırsın
for oto in $(find ${tname} -name 'otokos.sh');do
	. $oto
	if [ ${!mod} -eq 1 ];then
		# kontrol komut
		if [[ ! -z $kontrol ]];then
			$kontrol > /dev/null 2>&1
			if [ $? -eq 0 ];then
				if [[ ! -z $betik ]];then
					echo "$(dirname ${oto}) otokos" >> /tmp/mps_otokos.log
					$betik
				else
					echo "çalıştırma betigi bulunamadı! $oto" >&2
				fi
			fi
		else
			echo "kontrol betigi bulunamadı! $oto" >&2
		fi  
	fi
done
