# iptables management program
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![GitHub go.mod Go version](https://img.shields.io/github/go-mod/go-version/pretty66/iptables-web)](https://github.com/pretty66/iptables-web/blob/master/go.mod)
### iptables-web is a lightweight iptables web management interface program that supports binary file direct operation and docker fast deployment and installation; the entire program is packaged as only one binary file, which is suitable for daily operation and maintenance.
![web](./docs/iptables-web.png)

## Directory
- [Installation](#Installation)
- [License](#License)

## Installation
### Docker deployment installation (recommended)
When deploying in docker, please note that you need to add two parameters `--privileged=true` and `--net=host` to run in privileged mode, which can manage the host iptables rules
```shell
docker run -d \
--name iptables-web \
--privileged=true \
--net=host \
-e "IPT_WEB_USERNAME=admin" \
-e "IPT_WEB_PASSWORD=admin" \
-e "IPT_WEB_ADDRESS=:10001" \
-p 10001:10001 \
pretty66/iptables-web:1.1.1
```
- `IPT_WEB_USERNAME`: Web authentication username, default: admin
- `IPT_WEB_PASSWORD`: Web authentication password, default: admin
- `IPT_WEB_ADDRESS`: Program listening address, default: 10001

### Direct installation
```shell
git clone https://github.com/pretty66/iptables-web.git
cd iptables-web
make
# Direct operation
./iptables-server -a :10001 -u admin -p admin
# Background operation
nohup ./iptables-server -a :10001 -u admin -p admin > /dev/null 2>&1 &
```

### License

iptables-web is under the Apache 2.0 license. See the [LICENSE](./LICENSE) directory for details.