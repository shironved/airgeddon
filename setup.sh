#!/usr/bin/env bash

set -e

show_usage() {
  echo "Usage: $(basename $0) takes exactly 1 argument (install | uninstall)"
}

if [ $# -ne 1 ]; then
  show_usage
  exit 1
fi

check_env() {
  if [[ -z "${RALPM_TMP_DIR}" ]]; then
    echo "RALPM_TMP_DIR is not set"
    exit 1

  elif [[ -z "${RALPM_PKG_INSTALL_DIR}" ]]; then
    echo "RALPM_PKG_INSTALL_DIR is not set"
    exit 1

  elif [[ -z "${RALPM_PKG_BIN_DIR}" ]]; then
    echo "RALPM_PKG_BIN_DIR is not set"
    exit 1
  fi
}

install() {
  echo "[*] Installing airgeddon..."

  if command -v git &>/dev/null; then
    echo "[*] Git found, using method 1..."
    git clone --depth 1 https://github.com/v1s1t0r1sh3r3/airgeddon.git "$RALPM_PKG_INSTALL_DIR/airgeddon"
  else
    echo "[*] Git not found, using method 2 (wget + unzip)..."
    wget https://github.com/v1s1t0r1sh3r3/airgeddon/archive/master.zip -O "$RALPM_TMP_DIR/airgeddon.zip"
    unzip "$RALPM_TMP_DIR/airgeddon.zip" -d "$RALPM_TMP_DIR/"
    mv "$RALPM_TMP_DIR/airgeddon-master" "$RALPM_PKG_INSTALL_DIR/airgeddon"
    rm "$RALPM_TMP_DIR/airgeddon.zip"
  fi

  chmod +x "$RALPM_PKG_INSTALL_DIR/airgeddon/airgeddon.sh"

  echo "[*] Creating launcher in $RALPM_PKG_BIN_DIR..."
  cat <<EOF > "$RALPM_PKG_BIN_DIR/airgeddon"
#!/usr/bin/env bash
exec bash "$RALPM_PKG_INSTALL_DIR/airgeddon/airgeddon.sh" "\$@"
EOF
  chmod +x "$RALPM_PKG_BIN_DIR/airgeddon"

  echo "[+] Installation complete. You can now run 'airgeddon'"
}

uninstall() {
  echo "[*] Uninstalling airgeddon..."
  rm -rf "$RALPM_PKG_BIN_DIR/airgeddon"
  rm -f "$RALPM_PKG_BIN_DIR/airgeddon"
  echo "[+] Uninstallation complete."
}

run() {
  if [[ "$1" == "install" ]]; then
    install
  elif [[ "$1" == "uninstall" ]]; then
    uninstall
  else
    show_usage
    exit 1
  fi
}

check_env
run "$1"
