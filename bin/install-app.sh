#!/usr/bin/env bash
set -e
#set -x

APP="${1:-"consul"}"
VERSION="${2:-"$(curl -s https://releases.hashicorp.com/${APP}/ | grep href | grep "${APP}" | grep -v "rc" | grep -v "beta" | head -1 | cut -d"/" -f 3)"}"
ZIP="${3:-"${APP}_${VERSION}_linux_amd64.zip"}"
URL="https://releases.hashicorp.com/${APP}/${VERSION}/${ZIP}"
CONFIG_DIR="/etc/${APP}.d"
DATA_DIR="/opt/${APP}"

if [[ ! -f $(which unzip) ]]; then
  echo "--> Installing unzip"
  sudo apt-get install -y unzip
fi

if [[ ! -f $(which jq) ]]; then
  echo "--> Installing jq"
  sudo apt-get install -y jq
fi

if [[ -f /vagrant/zips/${ZIP} ]]; then
  echo "--> Found /vagrant/zips/${ZIP}"
  cp -f /vagrant/zips/${ZIP} /tmp/${ZIP}
else
  echo "--> Attempting download of ${APP} ${VERSION} to /tmp/${ZIP}"
  pushd /tmp > /dev/null
  if curl -O ${URL}; then
    echo "--> Downloaded ${ZIP}"
    popd > /dev/null
  else
    echo "--> Unable to download ${ZIP}"
    popd > /dev/null
    exit 1
  fi
fi

echo "--> Installing ${APP}"
sudo unzip -q -o /tmp/${ZIP} -d /usr/local/bin/
sudo chmod 755 /usr/local/bin/${APP}
sudo mkdir -p ${CONFIG_DIR} && sudo chmod 755 ${CONFIG_DIR}
sudo mkdir -p ${DATA_DIR} && sudo chmod 755 ${DATA_DIR}

if [[ -f /vagrant/etc/systemd/system/${APP}.service ]]; then
  echo "--> Installing systemd ${APP}.service"
  sudo cp /vagrant/etc/systemd/system/${APP}.service /etc/systemd/system/${APP}.service
fi
