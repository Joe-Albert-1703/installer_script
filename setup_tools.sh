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

# Install Python
install_python() {
  echo "Installing Python..."
  sudo apt update && sudo apt install -y python3 python3-pip
  echo "Python installed. Version: $(python3 --version)"
  echo "Pip Version: $(pip3 --version)"
}

# Install Node.js
install_node() {
  echo "Installing Node.js..."
  check_dependency curl
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt update && sudo apt install -y nodejs
  echo "Node.js installed. Version: $(node --version)"
  echo "NPM Version: $(npm --version)"
}

# Install Go
install_golang() {
  echo "Installing Go..."
  check_dependency wget
  wget https://go.dev/dl/go1.21.3.linux-amd64.tar.gz
  sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.21.3.linux-amd64.tar.gz
  echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
  source ~/.bashrc
  echo "Go installed. Version: $(go version)"
}

# Install Java
install_java() {
  echo "Installing Java..."
  sudo apt update && sudo apt install -y openjdk-17-jdk
  echo "Java installed. Version: $(java -version)"
}

# Install Rust
install_rust() {
  echo "Installing Rust..."
  check_dependency curl
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
  echo "Rust installed. Version: $(rustc --version)"
}

# Install Docker
install_docker() {
  echo "Installing Docker..."
  check_dependency curl
  check_dependency gpg
  sudo apt update && sudo apt install -y apt-transport-https ca-certificates software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update && sudo apt install -y docker-ce
  sudo usermod -aG docker $USER
  echo "Docker installed. Version: $(docker --version)"
}

# Install Git
install_git() {
  echo "Installing Git..."
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

