#!/bin/bash
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'
echo -e "${GREEN}Eğer ilk defa iso hazırlayacaksanız ${RED}1${NONE} ${GREEN}tuşuna basın, daha önce hazırladığınız dosyaları düzenleyecekseniz ${RED}2${NONE} ${GREEN}tuşuna basın...${NONE} "
select durum in ilk-defa Yeniden
do

if [ $durum = ilk-defa ]
then

export MSYS=/home/Aylinux-ISO 
export MPS_PATH=/opt/Aylinux-ISO 
export AYLINUX_PATH=$MSYS/usr/aylinux

rm -r $MPS_PATH
rm -r $MSYS
echo -e "${GREEN}Varsa önceden oluşmuş dosyalar silindi..${NONE}"
git clone https://github.com/oltulu/mps  $MPS_PATH
cd $MPS_PATH
bash derle.sh $MPS_PATH
cd bin
chmod +x ./mps
chmod +x ./mpsd
#chmod +x ./paket
./mps
./mps
./mps -v
./mps --ilkds --ilk --kok=$MSYS
./mps gun -GPB --kok=$MSYS
cp /etc/ld.so.conf $MSYS/etc/
echo -e "${RED}Temel paketler yükleniyor..${NONE}"
./mps kur --dosya=$MSYS/usr/aylinux/ayarlar/iso/ortam.order --kurkos=0 --koskur=0 --kok=$MSYS
#./mps kur temel-kur --kurkos=0 --koskur=0 --kok=$MSYS
cp -r $MPS_PATH $MSYS/usr/aylinux/mps
cp -f /etc/hosts $MSYS/etc/
chmod +x $MSYS/usr/aylinux/mps/bin/isoyap
chmod +x ./enter-chroot

cat > /tmp//isoyap2 << "EOf"
#!/bin/bash
export MSYS=/home/Aylinux-ISO 
export MPS_PATH=/opt/Aylinux-ISO 
export AYLINUX_PATH=$MSYS/usr/aylinux
rm -f $MSYS/root/.bash_history
cd /opt
git clone https://github.com/oltulu/Aylinux-isoyap
cd /opt/Aylinux-isoyap
bash iso_olustur.sh $MSYS
EOf
chmod +x /tmp//isoyap2
echo -e "${GREEN}Önce klavyeden ${RED}ctrl+c ${NONE}${GREEN}tuşlarına basarak mevcut dizine şıkış yapın...${NONE}"
echo -e "1- ${RED}$MPS_PATH/bin/enter-chroot /home/Aylinux-ISO${NONE}"
echo -e "${GREEN}Şimdi yeni sisteme geçmek için önce üsteki 1 nolu komutu yazıp enter tuşuna basın ve sonra  ${RED} isoyap  ${NONE} ${GREEN}yazarak  devam ediniz...${NONE} "


else
   echo "Bu dosyayı root olarak çalıştırmalısınız..."

#if [ "$(whoami)" == "root" ]
#then
#$masasecimi=(zenity --list --radiolist --text "<b>Lütfen</b> kurmak istediğiniz masaüstünü seçiniz" --hide-header --column "Buy" --column "Item" FALSE "xfce" FALSE "cinnamon" FALSE "mate" FALSE Quit)
# Dizinleri belirliyoruz
export MSYS=/home//Aylinux-ISO 
export MPS_PATH=/opt/Aylinux-ISO 
export AYLINUX_PATH=$MSYS/usr/aylinux

cd $MPS_PATH/bin
chmod +x ./mps
chmod +x ./mpsd
#chmod +x ./paket
chmod +x $MSYS/usr/aylinux/mps/bin/isoyap

cat > /tmp//isoyap2 << "EOf"
#!/bin/bash
export MSYS=/home//Aylinux-ISO 
export MPS_PATH=/opt/Aylinux-ISO 
export AYLINUX_PATH=$MSYS/usr/aylinux
rm -f $MSYS/root/.bash_history
cd /opt
git clone https://github.com/oltulu/Aylinux-isoyap
cd /opt/Aylinux-isoyap
bash iso_olustur.sh $MSYS
EOf
chmod +x /tmp//isoyap2
echo -e "${GREEN}Önce klavyeden ${RED}ctrl+c ${NONE}${GREEN}tuşlarına basarak mevcut dizine şıkış yapın...${NONE}"
echo "1- ${RED}$MPS_PATH/bin/enter-chroot /home/Aylinux-ISO${NONE}"
echo -e "${GREEN}Şimdi yeni sisteme geçmek için önce üsteki 1 nolu komutu yazıp enter tuşuna basın ve sonra  ${RED} isoyap  ${NONE} ${GREEN}yazarak  devam ediniz...${NONE} "
chmod +x ./enter-chroot

fi
done
#echo "Şimdi yeni sistemden çıtınız iso hazırlanacak..."
#rm -f $MSYS/root/.bash_history
#cd /opt/imaj-uretici
#bash iso_olustur.sh $MSYS
#------------------------------------------      
#else
 #   echo "Bu dosyayı root olarak çalıştırmalısınız..."
