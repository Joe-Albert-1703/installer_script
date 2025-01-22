
# Installation Script for Popular Development Tools

This script helps automate the installation and management of various programming languages and tools, including Python, Node.js, Go, Java, Rust, Docker, and Git. It checks for existing installations, fetches available versions dynamically, and allows you to update or downgrade to a specific version if necessary.

  

## Features

Checks for dependencies: Ensures required tools like ``curl`` are installed before proceeding.

Interactive version management: Prompts you to update, downgrade, or install new versions of tools.

Fetches available versions dynamically: It uses official sources to fetch available versions for each tool.

User-friendly interface: A simple, text-based menu guides you through the installation process.

  

## Supported Tools

Python - Install or manage versions of Python.

Node.js - Install or manage versions of Node.js.

Go - Install or manage versions of Golang.

Java - Install specific versions of Java (e.g., OpenJDK 11, 17, or 21).

Rust - Install the latest stable version of Rust.

Docker - Install or update Docker.

Git - Install or update Git.

  

## Requirements

Linux-based system (Ubuntu/Debian)

``sudo`` privileges for installing packages

Internet access for fetching installation packages and versions

  

## How to Use

Clone the repository:
``
git clone https://github.com/your-repo/dev-tool-installer.git
``
cd dev-tool-installer

Make the script executable:
``
chmod +x install_tools.sh
``
Run the script:
``
./install_tools.sh
``
Follow the prompts in the menu to choose a tool to install. The options are:

  

```
1: Python
2: Node.js
3: Golang
4: Java
5: Rust
6: Docker
7: Git
8: Exit
```

You will be prompted to either install, update, or downgrade the tool based on its current version.

  

## How It Works

Dependency Check: The script first checks for necessary dependencies like ``curl`` and ``wget``. If missing, it prompts the user to install them.

Version Management: For each tool, the script fetches available versions from official sources. It checks the currently installed version (if any), and provides an option to update, downgrade, or install a new version.

Installation: The script proceeds to install the selected tool, whether it's the latest version or a specific version chosen by the user.

Example Interaction
```
Select a programming language or tool to install and set up:

1) Python

2) Node.js

3) Golang

4) Java

5) Rust

6) Docker

7) Git

8) Exit

Enter your choice [1-8]: 1

Python is already installed. Current version: 3.8.10

Available versions:

1) 3.9.0

2) 3.8.10

3) Exit

Do you want to (u)pdate, (d)owngrade, or e(x)it? [u/d/x]: u

Newer versions available:

1) 3.9.0

Select a version to update to [1-1]: 1

Installing Python 3.9.0...

...
```
  

## Troubleshooting

Ensure that your system has ``curl`` and ``wget`` installed. The script will attempt to install them if they're missing.

If you encounter any issues with package installation, make sure your system's package list is up to date (``sudo apt update``).

The script works with Ubuntu/Debian-based distributions. For other Linux distributions, adjustments may be necessary.

## License

This script is open-source and unlicensed. Feel free to fork and modify it for your own purposes.