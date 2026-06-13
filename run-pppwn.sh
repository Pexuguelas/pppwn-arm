#!/bin/bash
# PS4 GoldHEN PPPwn++ — ARM Auto-Exploit
# Change --fw to match your PS4 firmware (700, 800, 900, 1050, 1070, 1071, 1100)

cd /home/debian/ps4/pppwn

# Assign dummy IP so pcap detects eth0
echo temppwd | sudo -S ip link set eth0 up 2>/dev/null
echo temppwd | sudo -S ip addr add 10.0.0.1/24 dev eth0 2>/dev/null

echo '=== PPPwn++ ARM started ==='
echo 'Waiting for PS4...'

# Run PPPwn++ with auto-retry
echo temppwd | sudo -S /home/debian/ps4/pppwn/pppwn --interface eth0 --fw 1050 --stage1 /home/debian/ps4/pppwn/stage1.bin --stage2 /home/debian/ps4/pppwn/stage2.bin --auto-retry --timeout 120 --no-wait-padi
RESULT=$?

if [ $RESULT -eq 0 ]; then
    echo '=== GoldHEN loaded. Shutting down in 10s ==='
    nohup bash -c 'sleep 10 && shutdown -h now' &
    echo temppwd | sudo -S systemctl stop pppwn
else
    echo '=== PPPwn failed (code $RESULT) ==='
    exit 1
fi