# PPPwn++ ARM — GoldHEN automático para PS4

PPPwn++ (C++) compilado **estáticamente para ARMv7** — listo para usar en BeagleBone Black, Raspberry Pi y otras placas ARM.

No necesitas un PC — solo conecta tu placa ARM directamente a la PS4 por ethernet y GoldHEN se carga automáticamente.

## Por qué existe este repo

- El [PPPwn_cpp](https://github.com/xfangfang/PPPwn_cpp) oficial solo publica binarios x86_64
- La versión Python de PPPwn es demasiado lenta en ARM (falla el heap grooming)
- Compilar para ARM tiene sus trampas (versión de glibc, libpcap, compatibilidad del stage1)
- GoldHEN 2.4b18 crashea la PS4 al cargar si FTP/BinLoader están activos — este repo incluye el fix

---

# PPPwn++ ARM — PS4 GoldHEN Auto-Exploit

PPPwn++ (C++) compiled **statically for ARMv7** — ready to run on BeagleBone Black, Raspberry Pi, and other ARM boards.

No need for a PC — just connect your ARM board directly to the PS4 via ethernet and GoldHEN loads automatically.

## Why this exists

- The official [PPPwn_cpp](https://github.com/xfangfang/PPPwn_cpp) only publishes x86_64 binaries
- The Python version of PPPwn is too slow on ARM (heap grooming fails)
- Cross-compiling for ARM has pitfalls (glibc version, libpcap, stage1 compatibility)
- GoldHEN 2.4b18 crashes on load if FTP/BinLoader are enabled — this repo includes the fix

## Firmwares compatibles / Supported Firmware

| Firmware | Stage1 | Stage2 |
|----------|--------|--------|
| 7.0x | ✅ | ✅ |
| 8.0x | ✅ | ✅ |
| 9.00 | ✅ | ✅ |
| 10.50 | ✅ | ✅ |
| 10.70 | ✅ | ✅ |
| 10.71 | ✅ | ✅ |
| 11.00 | ✅ | ✅ |

## Requisitos de hardware / Hardware Requirements

- Placa ARM con ethernet (ver placas recomendadas abajo)
- Cable ethernet (conexión directa a la PS4 — **sin router/switch en medio**)
- Alimentación USB para la placa ARM
- Pendrive USB con `goldhen.bin` + `config.ini` conectado a la PS4

### Placas recomendadas / Recommended boards

| Placa / Board | Ethernet | Precio aprox. | Nota / Note |
|---------------|----------|-------------|-------------|
| **BeagleBone Black** ✅ | 100Mbps | ~35€ (2ª mano) | Probado y funcionando / Tested & working |
| Orange Pi One | 100Mbps | ~45€ | H3 quad-core, 1GB RAM |
| Orange Pi Zero | 100Mbps + WiFi | ~38€ | H2+, 512MB RAM, muy pequeña |
| Orange Pi Zero 3 | Gigabit + WiFi | ~25€ | H618 quad A53, best value |
| Raspberry Pi 3B+ | Gigabit | ~40€ (2ª mano) | Ampliamente disponible |

> 💡 Cualquier placa ARM con Linux + ethernet sirve. El BeagleBone Black es el más probado con este repo.
> 💡 Any ARM board with Linux + ethernet works. BeagleBone Black is the most tested with this repo.

> ⚠️ **La PS4 debe estar conectada directamente a la placa ARM.** Los routers/switches filtran los paquetes PPPoE discovery y el exploit no funcionará a través de ellos.
>
> ⚠️ **The PS4 must be connected directly to the ARM board.** Routers/switches filter PPPoE discovery packets and the exploit won't work through them.

## Guía rápida / Quick Start

### 1. Flashea tu placa ARM

Asegúrate de que tu placa tiene Debian/Ubuntu. Para BeagleBone Black, flashea la última imagen Debian IoT.

### 2. Copia los archivos

Copia el contenido de este repo a tu placa (por USB o SCP):

```
/home/debian/ps4/pppwn/
├── pppwn              # Binario ARM (estático)
├── stage1.bin          # Stage1 para tu firmware
├── stage2.bin          # Stage2 para tu firmware
├── goldhen.bin         # GoldHEN 2.4b18 payload
├── config.ini          # Config de GoldHEN (fix del crash)
├── run-pppwn.sh        # Script de auto-retry
└── pppwn.service       # Servicio systemd
```

### 3. Prepara el USB para la PS4

Formatea un pendrive USB como **FAT32** y copia en la raíz:

```
/goldhen.bin    # GoldHEN 2.4b18
/config.ini     # FTP y BinLoader desactivados (evita el crash)
```

> ⚠️ **El `config.ini` es crítico.** Sin él, GoldHEN 2.4b18 crashea la PS4 al cargar cuando FTP/BinLoader están activos. Ver [GoldHEN issue #209](https://github.com/GoldHEN/GoldHEN/issues/209).

### 4. Configura la PS4 (solo la primera vez)

1. **Ajustes → Red → Configurar conexión a Internet**
2. **Usar cable LAN → Personalizada**
3. Método IP: **PPPoE**
4. Nombre de usuario: `ppp` | Contraseña: `ppp`
5. Todo lo demás: **Automático**

### 5. Conecta y ejecuta

1. Conecta cable ethernet de la placa ARM directamente a la PS4
2. Alimenta la placa ARM (USB)
3. Conecta el pendrive USB a la PS4
4. Enciende la PS4 — ¡GoldHEN se carga automáticamente!

### 6. Después de cargar GoldHEN

Una vez GoldHEN está activo, puedes:
- **Desconectar el cable ethernet** de la PS4
- **Cambiar la PS4 a WiFi** para internet (GoldHEN sigue activo)
- **Instalar PKGs por USB** (carpeta `PKG` en la raíz del disco exFAT)
- **La placa ARM ya no es necesaria** hasta el próximo reinicio

## Servicio systemd

Instala el servicio para que PPPwn arranque automáticamente al encender la placa:

```bash
sudo cp pppwn.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable pppwn.service
```

El servicio:
- Reintenta automáticamente hasta que GoldHEN cargue
- Se detiene solo cuando tiene éxito
- Intenta apagar la placa tras 10 segundos

### Cambiar firmware

Edita `run-pppwn.sh` y cambia `--fw 1050` por tu firmware:

| Firmware | Valor `--fw` |
|----------|-------------|
| 7.0x | `700` |
| 8.0x | `800` |
| 9.00 | `900` |
| 10.50 | `1050` |
| 10.70 | `1070` |
| 10.71 | `1071` |
| 11.00 | `1100` |

## Archivos

### `pppwn` (binario ARM estático)

Compilado con cross-compilation desde Ubuntu x86_64:
```
arm-linux-gnueabihf-gcc / g++
cmake -DCMAKE_C_COMPILER=arm-linux-gnueabihf-gcc \
      -DCMAKE_CXX_COMPILER=arm-linux-gnueabihf-g++ \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_EXE_LINKER_FLAGS='-static' \
      -DUSE_SYSTEM_PCAP=OFF
```

Enlazado estáticamenteamente — sin dependencias, funciona en cualquier Linux ARMv7.

### `config.ini` (fix del crash de GoldHEN)

Desactiva el servidor FTP y BinLoader para evitar que la PS4 crashee/reinicie al cargar GoldHEN. Es un problema conocido de GoldHEN 2.4b18 ([GitHub issue #209](https://github.com/GoldHEN/GoldHEN/issues/209), [#224](https://github.com/GoldHEN/GoldHEN/issues/224), [#234](https://github.com/GoldHEN/GoldHEN/issues/234)).

### Archivos stage

Los binarios stage1 y stage2 deben coincidir con el firmware de tu PS4. Descárgalos de:
- [DrYenyen/Stage-files-for-pppwn](https://github.com/DrYenyen/Stage-files-for-pppwn) — pre-compilados para todos los firmwares
- [SiSTR0/PPPwn releases](https://github.com/SiSTR0/PPPwn/releases) — stage2 oficial

## Solución de problemas / Troubleshooting

| Problema | Solución |
|----------|----------|
| La PS4 crashea después de cargar GoldHEN | Asegúrate de que `config.ini` con `Enabled = 0` para FTP/BinLoader está en el USB |
| Se queda en "Waiting for PADR" | Estás pasando por un router — necesitas conexión directa |
| Se queda en "Waiting for IPCP configure ACK" | Solo debe haber un proceso PPPwn — mata los extras con `sudo killall pppwn` |
| eth0 no encontrado por PPPwn++ | Asigna una IP dummy: `sudo ip addr add 10.0.0.1/24 dev eth0` |
| Heap grooming falla al 6% | Usando PPPwn Python en ARM — cambia al binario C++ |
| `pppwn: not found` o error de glibc | Usa el binario estático de este repo |

## Créditos

- [TheOfficialFloW](https://github.com/TheOfficialFloW) — Exploit PPPwn
- [xfangfang](https://github.com/xfangfang/PPPwn_cpp) — Implementación PPPwn++ C++
- [SiSTR0](https://github.com/SiSTR0) — GoldHEN y stage2 de PPPwn
- [DrYenyen](https://github.com/DrYenyen) — Archivos stage pre-compilados
- [jason-eu](https://github.com/GoldHEN/GoldHEN/issues/209) — Fix del crash de GoldHEN (config.ini)

## Licencia

MIT — igual que PPPwn_cpp