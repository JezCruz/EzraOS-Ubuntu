# EzraOS Ubuntu

**EzraOS Ubuntu** is an offline AI-powered development and learning environment built to run directly on Ubuntu Linux.

It provides a terminal-based interface with multiple specialized AI modes powered locally through llama.cpp.

## Installation

### Requirements

* Ubuntu Linux
* Internet connection for the initial installation and AI model download
* Git
* Python 3
* curl
* Sufficient storage for the selected AI model
* At least 4 GB of physical RAM recommended

### Install EzraOS

Open the Ubuntu terminal and run:

```bash
sudo apt update && sudo apt install -y git && \
git clone git@github.com:JezCruz/EzraOS-Ubuntu.git ~/EzraOS && \
cd ~/EzraOS && \
bash install.sh
```

Alternatively, clone using HTTPS:

```bash
git clone https://github.com/JezCruz/EzraOS-Ubuntu.git ~/EzraOS
cd ~/EzraOS
bash install.sh
```

After installation, start EzraOS with:

```bash
ezra
```

## First Launch

On the first launch, EzraOS will perform its initial setup and may download the required AI model.

The first AI launch may therefore take longer depending on your internet connection and hardware.

Once the model and required dependencies are installed, the core EzraOS AI features can run locally without an internet connection.

## Offline Usage

EzraOS is designed to run its AI locally through llama.cpp.

Internet access may still be required for:

* Initial installation
* AI model downloads
* Package installation and updates
* GitHub operations
* Downloading additional models or external resources

## Platform

This edition is designed for **Ubuntu Linux**.

It does not require Android or Termux.

EzraOS is an OS-like AI development environment that runs on top of Ubuntu. It does not replace Ubuntu or install a separate operating system.

## Status

**EzraOS Ubuntu v2.1.0 Alpha**

This is an alpha release. Bugs, hardware-specific issues, and compatibility problems may still occur.

## Developer

Developed by **JezCruz**

