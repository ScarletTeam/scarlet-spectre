echo "ScarletSpectre" > /etc/hostname
apt-get install --yes --force-yes linux-image-amd64 live-boot systemd-sysv
apt-get install --yes --force-yes network-manager net-tools ntfs-3g python python-crypto
apt-get clean
apt-get autoclean
echo 'root:root' | chpasswd
ln -s /spectre/start.sh /etc/rc.local
exit
