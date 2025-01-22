#!/bin/bash

# Function to check and install missing dependencies
check_dependency() {
  local dep=$1
  if ! command -v $dep &> /dev/null; then
    echo "$dep is not installed."
    read -p "Do you want to install $dep? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
      sudo apt update && sudo apt install -y $dep
    else
      echo "$dep is required for this operation. Exiting..."
      exit 1
    fi
  fi
}

# Function to display a menu of tools/languages
show_menu() {
  echo "Select a programming language or tool to install and set up:"
  echo "1) Python"
  echo "2) Node.js"
  echo "3) Golang"
  echo "4) Java"
  echo "5) Rust"
  echo "6) Docker"
  echo "7) Git"
  echo "8) Exit"
  echo -n "Enter your choice [1-8]: "
}

# Fetch available versions dynamically
fetch_versions() {
  local tool=$1
  case $tool in
    "Python")
      curl -s https://www.python.org/ftp/python/ | grep -oP '(?<=href=")3\\.[0-9]+\\.[0-9]+(?=/)' | sort -V | uniq ;;
    "Node.js")
      curl -s https://nodejs.org/dist/ | grep -oP '(?<=v)[0-9]+\\.[0-9]+\\.[0-9]+' | sort -V | uniq ;;
    "Golang")
      curl -s https://go.dev/dl/ | grep -oP '(?<=go)[0-9]+\\.[0-9]+\\.[0-9]+(?=\\.linux-amd64\\.tar\\.gz)' | sort -V | uniq ;;
    "Java")
      echo -e "11\n17\n21" ;;
    "Rust")
      echo "latest stable" ;;
    "Docker")
      echo "latest stable" ;;
    "Git")
      echo "latest stable" ;;
  esac
}

# Check existing version and prompt for update/downgrade
handle_existing_version() {
  local tool=$1
  local current_version=$2
  local versions=($3)
  echo "$tool is already installed. Current version: $current_version"
  echo "Available versions:"
  for i in "${!versions[@]}"; do
    echo "$((i+1))) ${versions[i]}"
  done
  echo "$(( ${#versions[@]} + 1 ))) Exit"
  read -p "Do you want to (u)pdate, (d)owngrade, or e(x)it? [u/d/x]: " action
  case $action in
    u|U)
      local newer_versions=( $(printf "%s\n" "${versions[@]}" | awk -v cur="$current_version" '$1 > cur') )
      if [[ ${#newer_versions[@]} -eq 0 ]]; then
        echo "No newer versions available."
        return 1
      fi
      echo "Newer versions available:"
      for i in "${!newer_versions[@]}"; do
        echo "$((i+1))) ${newer_versions[i]}"
      done
      read -p "Select a version to update to [1-${#newer_versions[@]}]: " version_choice
      echo "${newer_versions[$((version_choice-1))]}" ;;
    d|D)
      local older_versions=( $(printf "%s\n" "${versions[@]}" | awk -v cur="$current_version" '$1 < cur') )
      if [[ ${#older_versions[@]} -eq 0 ]]; then
        echo "No older versions available."
        return 1
      fi
      echo "Older versions available:"
      for i in "${!older_versions[@]}"; do
        echo "$((i+1))) ${older_versions[i]}"
      done
      read -p "Select a version to downgrade to [1-${#older_versions[@]}]: " version_choice
      echo "${older_versions[$((version_choice-1))]}" ;;
    x|X)
      echo "Exiting..."
      exit 0 ;;
    *)
      echo "Invalid choice. Exiting..."
      exit 1 ;;
  esac
}

# Install Python
install_python() {
  local versions=( $(fetch_versions "Python") )
  if command -v python3 &> /dev/null; then
    local current_version=$(python3 --version | awk '{print $2}')
    local version=$(handle_existing_version "Python" "$current_version" "${versions[*]}") || return
  else
    local version=$(select_version "${versions[*]}")
  fi
  echo "Installing Python $version..."
  sudo apt update && sudo apt install -y python${version} python${version}-pip
  echo "Python installed. Version: $(python${version} --version)"
}

# Install Node.js
install_node() {
  local versions=( $(fetch_versions "Node.js") )
  if command -v node &> /dev/null; then
    local current_version=$(node --version | tr -d 'v')
    local version=$(handle_existing_version "Node.js" "$current_version" "${versions[*]}") || return
  else
    local version=$(select_version "${versions[*]}")
  fi
  echo "Installing Node.js $version..."
  check_dependency curl
  curl -fsSL https://deb.nodesource.com/setup_$version.x | sudo -E bash -
  sudo apt update && sudo apt install -y nodejs
  echo "Node.js installed. Version: $(node --version)"
}

# Install Go
install_golang() {
  local versions=( $(fetch_versions "Golang") )
  if command -v go &> /dev/null; then
    local current_version=$(go version | awk '{print $3}' | tr -d 'go')
    local version=$(handle_existing_version "Golang" "$current_version" "${versions[*]}") || return
  else
    local version=$(select_version "${versions[*]}")
  fi
  echo "Installing Go $version..."
  check_dependency wget
  wget https://go.dev/dl/go$version.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go$version.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  source ~/.bashrc
  echo "Go installed. Version: $(go version)"
}

# Install Java
install_java() {
  local versions=( $(fetch_versions "Java") )
  if command -v java &> /dev/null; then
    local current_version=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')
    local version=$(handle_existing_version "Java" "$current_version" "${versions[*]}") || return
  else
    local version=$(select_version "${versions[*]}")
  fi
  echo "Installing Java $version..."
  sudo apt update && sudo apt install -y openjdk-$version-jdk
  echo "Java installed. Version: $(java -version)"
}

# Install Rust
install_rust() {
  if command -v rustc &> /dev/null; then
    local current_version=$(rustc --version | awk '{print $2}')
    echo "Rust is already installed. Current version: $current_version"
    read -p "Do you want to update to the latest version? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
      echo "Skipping Rust update."
      return
    fi
  fi
  echo "Installing/Updating Rust to the latest stable version..."
  check_dependency curl
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
  echo "Rust installed. Version: $(rustc --version)"
}

# Install Docker
install_docker() {
  if command -v docker &> /dev/null; then
    local current_version=$(docker --version | awk '{print $3}' | tr -d ',')
    echo "Docker is already installed. Current version: $current_version"
    read -p "Do you want to update to the latest version? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
      echo "Skipping Docker update."
      return
    fi
  fi
  echo "Installing/Updating Docker to the latest stable version..."
  check_dependency curl
  check_dependency gpg
  sudo apt update && sudo apt install -y apt-transport-https ca-certificates software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update && sudo apt install -y docker-ce
  sudo usermod -aG docker $USER
  echo "Docker installed. Version: $(docker --version)"
}

# Install Git
install_git() {
  if command -v git &> /dev/null; then
    local current_version=$(git --version | awk '{print $3}')
    echo "Git is already installed. Current version: $current_version"
    read -p "Do you want to update to the latest version? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
      echo "Skipping Git update."
      return
    fi
  fi
  echo "Installing/Updating Git to the latest stable version..."
  sudo apt update && sudo apt install -y git
  echo "Git installed. Version: $(git --version)"
}

# Main script
while true; do
  show_menu
  read choice
  case $choice in
    1) install_python ;;
    2) install_node ;;
    3) install_golang ;;
    4) install_java ;;
    5) install_rust ;;
    6) install_docker ;;
    7) install_git ;;
    8) echo "Exiting..."; exit 0 ;;
    *) echo "Invalid choice. Please enter a number between 1 and 8." ;;
  esac
  echo
done
