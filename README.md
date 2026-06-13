# PPPwn++ ARM — PS4 GoldHEN Auto-Exploit

PPPwn++ (C++) compiled **statically for ARMv7** — ready to run on BeagleBone Black, Raspberry Pi, and other ARM boards.

No need for a PC — just connect your ARM board directly to the PS4 via ethernet and GoldHEN loads automatically.

## Why this exists

- The official [PPPwn_cpp](https://github.com/xfangfang/PPPwn_cpp) only publishes x86_64 binaries
- The Python version of PPPwn is too slow on ARM (heap grooming fails)
- Cross-compiling for ARM has pitfalls (glibc version, libpcap, stage1 compatibility)
- GoldHEN 2.4b18 crashes on load if FTP/BinLoader are enabled — this repo includes the fix

## Supported Firmware

| Firmware | Stage1 | Stage2 |
|----------|--------|--------|
| 7.0x | ✅ | ✅ |
| 8.0x | ✅ | ✅ |
| 9.00 | ✅ | ✅ |
| 10.50 | ✅ | ✅ |
| 10.70 | ✅ | ✅ |
| 10.71 | ✅ | ✅ |
| 11.00 | ✅ | ✅ |

## Hardware Requirements

- ARM board with ethernet (BeagleBone Black, Raspberry Pi, etc.)
- Ethernet cable (direct connection to PS4 — **no router/switch in between**)
- USB power for the ARM board
- USB pendrive with `goldhen.bin` + `config.ini` plugged into the PS4

> ⚠️ **The PS4 must be connected directly to the ARM board.** Routers/switches filter PPPoE discovery packets and the exploit won't work through them.

## Quick Start

### 1. Flash your ARM board

Make sure your board runs Debian/Ubuntu. For BeagleBone Black, flash the latest Debian IoT image.

### 2. Copy files

Copy the contents of this repo to your board (e.g. via USB or SCP):

```
/home/debian/ps4/pppwn/
├── pppwn              # ARM binary (static)
├── stage1.bin          # Stage1 for your firmware
├── stage2.bin          # Stage2 for your firmware
├── goldhen.bin         # GoldHEN 2.4b18 payload
├── config.ini          # GoldHEN config (crash fix)
├── run-pppwn.sh        # Auto-retry script
└── pppwn.service       # systemd service
```

### 3. Prepare USB for PS4

Format a USB pendrive as **FAT32** and copy to the root:

```
/goldhen.bin    # GoldHEN 2.4b18
/config.ini     # FTP & BinLoader disabled (prevents crash)
```

> ⚠️ **The `config.ini` is critical.** Without it, GoldHEN 2.4b18 crashes the PS4 on load when FTP/BinLoader are enabled. See [GoldHEN issue #209](https://github.com/GoldHEN/GoldHEN/issues/209).

### 4. Configure PS4 (first time only)

1. **Settings → Network → Set Up Internet Connection**
2. **Use LAN Cable → Custom**
3. IP Method: **PPPoE**
4. Username: `ppp` | Password: `ppp`
5. Everything else: **Automatic**

### 5. Connect and run

1. Connect ethernet cable from ARM board directly to PS4
2. Power the ARM board (USB)
3. Plug the USB pendrive into the PS4
4. Turn on the PS4 — GoldHEN loads automatically!

### 6. After GoldHEN loads

Once GoldHEN is active, you can:
- **Disconnect the ethernet cable** from the PS4
- **Switch PS4 to WiFi** for internet access (GoldHEN stays active)
- **Install PKGs via USB** (M.2 enclosure with exFAT, `PKG` folder at root)
- **The ARM board is no longer needed** until next reboot

## systemd Service

Install the service so PPPwn starts automatically when the board boots:

```bash
sudo cp pppwn.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pppwn.service
```

The service will:
- Auto-retry until GoldHEN loads
- Stop itself when successful
- Attempt to shut down the board after 10 seconds

### Changing firmware

Edit `run-pppwn.sh` and change `--fw 1050` to your firmware version:

| Firmware | `--fw` value |
|----------|-------------|
| 7.0x | `700` |
| 8.0x | `800` |
| 9.00 | `900` |
| 10.50 | `1050` |
| 10.70 | `1070` |
| 10.71 | `1071` |
| 11.00 | `1100` |

## Files

### `pppwn` (ARM static binary)

Cross-compiled from x86_64 Ubuntu with:
```
arm-linux-gnueabihf-gcc / g++
cmake -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
      -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_EXE_LINKER_FLAGS='-static' \
      -DUSE_SYSTEM_PCAP=OFF
```

Statically linked — no dependencies required, works on any ARMv7 Linux.

### `config.ini` (GoldHEN crash fix)

Disables FTP server and BinLoader to prevent PS4 crash/reboot on GoldHEN load. This is a known issue with GoldHEN 2.4b18 ([GitHub issue #209](https://github.com/GoldHEN/GoldHEN/issues/209), [#224](https://github.com/GoldHEN/GoldHEN/issues/224), [#234](https://github.com/GoldHEN/GoldHEN/issues/234)).

### Stage files

Stage1 and stage2 binaries must match your PS4 firmware. Download from:
- [DrYenyen/Stage-files-for-pppwn](https://github.com/DrYenyen/Stage-files-for-pppwn) — pre-compiled for all firmwares
- [SiSTR0/PPPwn releases](https://github.com/SiSTR0/PPPwn/releases) — official stage2

## Troubleshooting

| Problem | Solution |
|---------|----------|
| PS4 crashes after GoldHEN loads | Make sure `config.ini` with `Enabled = 0` for FTP/BinLoader is on the USB |
| Stuck on "Waiting for PADR" | You're going through a router — need direct connection |
| Stuck on "Waiting for IPCP configure ACK" | Only one PPPwn process should be running — kill extras with `sudo killall pppwn` |
| eth0 not found by PPPwn++ | Assign a dummy IP: `sudo ip addr add 10.0.0.1/24 dev eth0` |
| Heap grooming fails at 6% | Using Python PPPwn on ARM — switch to C++ binary |
| `pppwn: not found` or glibc error | Use the static binary from this repo |

## Credits

- [TheOfficialFloW](https://github.com/TheOfficialFloW) — PPPwn exploit
- [xfangfang](https://github.com/xfangfang/PPPwn_cpp) — PPPwn++ C++ implementation
- [SiSTR0](https://github.com/SiSTR0) — GoldHEN and PPPwn stage2
- [DrYenyen](https://github.com/DrYenyen) — Pre-compiled stage files
- [jason-eu](https://github.com/GoldHEN/GoldHEN/issues/209) — GoldHEN crash fix (config.ini)

## License

MIT — same as PPPwn_cpp