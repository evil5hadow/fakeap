#Fake-AP Beta, Author @thelinuxchoice
trap 'stop;exit 1' 2

stop() {

printf "Killing all conections..\n" 
killall dnsmasq hostapd > /dev/null 2>&1
sleep 4
printf "Restarting Network-Manager..\n" 
service network-manager restart
sleep 5

}

start() {
interface=$(ifconfig -a | sed 's/[ \t].*//;/^$/d' | tr -d ':' > iface)



counter=1
for i in $(cat iface); do
printf "%s %s\n" $counter $i
let counter++
done

read -p 'interface to use:' use_interface
choosed_interface=$(sed ''$use_interface'q;d' iface)
read -p 'SSID to use:' use_ssid
read -p 'Channel to use:' use_channel
printf "Killing all conections..\n" 
sleep 2
#stop
killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
sleep 5
printf "interface=%s\n" $choosed_interface > hostapd.conf
printf "driver=nl80211\n" >> hostapd.conf
printf "ssid=%s\n" $use_ssid >> hostapd.conf
printf "hw_mode=g\n" >> hostapd.conf
printf "channel=%s\n" $use_channel >> hostapd.conf
printf "macaddr_acl=0\n" >> hostapd.conf
printf "auth_algs=1\n" >> hostapd.conf
printf "ignore_broadcast_ssid=0\n" >> hostapd.conf
printf "%s down\n" $choosed_interface 
ifconfig $choosed_interface down
sleep 4
printf "Setting %s to monitor mode\n" $choosed_interface
iwconfig $choosed_interface mode monitor
sleep 4
printf "%s Up\n" $choosed_interface 
ifconfig wlan0 up
sleep 5
hostapd hostapd.conf &
sleep 6
printf "interface=%s\n" $choosed_interface > dnsmasq.conf
printf "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h\n" >> dnsmasq.conf
printf "dhcp-option=3,192.168.1.1\n" >> dnsmasq.conf
printf "dhcp-option=6,192.168.1.1\n" >> dnsmasq.conf
printf "server=8.8.8.8\n" >> dnsmasq.conf
printf "log-queries\n" >> dnsmasq.conf
printf "log-dhcp\n" >> dnsmasq.conf
printf "listen-address=127.0.0.1\n" >> dnsmasq.conf
printf "address=/#/192.168.1.1\n" >> dnsmasq.conf
ifconfig wlan0 up 192.168.1.1 netmask 255.255.255.0
sleep 1
route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
sleep 1
dnsmasq -C dnsmasq.conf -d &

printf "To Stop: ./fakeap.sh --stop\n"
}

case "$1" in --stop) stop ;; *)
start
esac



