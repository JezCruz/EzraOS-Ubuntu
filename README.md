# EzraOS Ubuntu

**EzraOS Ubuntu** is a terminal-based, offline AI development and learning environment for Ubuntu Linux.

It runs a local AI model using **llama.cpp**, allowing the core AI features to work without an internet connection after the initial setup.

EzraOS includes multiple specialized modes for programming, Linux, Git, Bible study, and general conversations.

> **Alpha Release:** EzraOS Ubuntu is currently under active development. Bugs and compatibility issues may still occur.

---

## Features

* Offline local AI powered by llama.cpp
* Terminal-based EzraOS interface
* Automatic first-time setup
* Automatic llama.cpp / llama-server setup
* Automatic AI model download on first use
* Streaming AI responses
* Persistent user name
* Separate conversation history for each mode
* Automatic conversation history trimming
* Notes system
* Project repository scanner
* System information
* Background AI server management

### AI Modes

1. General Chat
2. Java Programming
3. Python Programming
4. SQL Learning
5. Linux and Ubuntu
6. Git and GitHub
7. Bible Study

---

# Requirements

Before installing EzraOS, you need:

* Ubuntu Linux
* Internet connection for the initial installation
* At least **4 GB RAM recommended**
* Enough free storage for the AI model and llama.cpp build files
* `sudo` access for installing system dependencies

You do **not** need to manually install Python, Git, CMake, llama.cpp, or llama-server.

The EzraOS installer handles the required dependencies automatically.

---

# Installation

## 1. Open Terminal

Open your Ubuntu terminal.

You can usually use:

```bash
Ctrl + Alt + T
```

## 2. Download EzraOS

Run:

```bash
git clone https://github.com/JezCruz/EzraOS-Ubuntu.git ~/EzraOS
```

Enter the EzraOS directory:

```bash
cd ~/EzraOS
```

## 3. Run the Installer

Make the installer executable:

```bash
chmod +x install.sh
```

Then run:

```bash
./install.sh
```

The installer will automatically:

* Detect your Linux environment
* Install required Ubuntu packages
* Install Python and development dependencies
* Download llama.cpp when needed
* Build llama-server
* Prepare EzraOS directories
* Configure permissions
* Create the global `ezra` command
* Verify the installation

During installation, Ubuntu may ask for your user password because some dependencies are installed using `sudo`.

---

# Start EzraOS

After installation, reload your terminal environment:

```bash
source ~/.bashrc
```

Then simply run:

```bash
ezra
```

You can also close the terminal, open a new terminal, and run:

```bash
ezra
```

EzraOS can be launched from any directory.

For example:

```bash
cd ~
ezra
```

or:

```bash
cd ~/Documents
ezra
```

---

# First AI Launch

The first time you select an AI mode, EzraOS may need to download the configured AI model.

You may see:

```text
Preparing AI server...
```

The first launch can take longer depending on:

* Internet speed
* CPU performance
* Available RAM
* AI model size

After the model has been downloaded, future launches should be faster.

---

# Using EzraOS

Start EzraOS:

```bash
ezra
```

You will see the EzraOS menu.

Select the mode you want to use.

Example:

```text
EzraOS

[1] General Chat
[2] Java Programming
[3] Python Programming
[4] SQL Learning
[5] Linux and Ubuntu
[6] Git and GitHub
[7] Bible Study
```

Select a number and start chatting with Ezra.

---

# Offline Usage

EzraOS runs its AI locally using llama.cpp.

After the required model and dependencies have been downloaded, the core AI features can work without an internet connection.

Internet access is still required for features or tasks involving external services, including:

* Initial installation
* AI model downloads
* GitHub operations
* Package downloads and updates
* Accessing online resources

---

# Useful Commands

Start EzraOS:

```bash
ezra
```

Check the AI server:

```bash
~/EzraOS/core/server.sh status
```

Stop the AI server:

```bash
~/EzraOS/core/server.sh stop
```

Restart the AI server:

```bash
~/EzraOS/core/server.sh restart
```

---

# Updating EzraOS

Go to your EzraOS installation:

```bash
cd ~/EzraOS
```

Download the latest changes:

```bash
git pull
```

If the update includes installer or dependency changes, run:

```bash
./install.sh
```

Then start EzraOS normally:

```bash
ezra
```

---

# Uninstalling EzraOS

Stop the AI server first:

```bash
~/EzraOS/core/server.sh stop
```

Remove the global EzraOS command:

```bash
rm -f ~/.local/bin/ezra
```

Remove EzraOS:

```bash
rm -rf ~/EzraOS
```

If llama.cpp was installed by EzraOS and you also want to remove it:

```bash
rm -rf ~/.local/share/ezraos
rm -f ~/.local/bin/llama-server
```

> Removing `~/EzraOS` will also remove local EzraOS data stored inside that directory. Back up anything important before uninstalling.

---

# Troubleshooting

## `ezra: command not found`

Run:

```bash
source ~/.bashrc
```

Then try:

```bash
ezra
```

If it still does not work:

```bash
echo $PATH
```

Make sure this directory is available:

```text
~/.local/bin
```

---

## Check EzraOS Installation

Run:

```bash
which ezra
```

Expected result:

```text
/home/YOUR_USERNAME/.local/bin/ezra
```

Check llama-server:

```bash
which llama-server
```

Expected result:

```text
/home/YOUR_USERNAME/.local/bin/llama-server
```

---

## AI Server Does Not Start

Check the server log:

```bash
tail -n 50 ~/EzraOS/logs/server.log
```

You can also restart the server:

```bash
~/EzraOS/core/server.sh restart
```

---

# Installation Directory

The recommended installation location is:

```text
~/EzraOS
```

The `ezra` command installed in:

```text
~/.local/bin/ezra
```

points to the EzraOS launcher in the installation directory.

This allows EzraOS to be started globally by simply running:

```bash
ezra
```

---

# Privacy

EzraOS is designed around local AI execution.

Your conversations with the local AI model are processed on your device rather than being sent to a hosted AI API.

Some operations may still connect to external services when explicitly required, such as downloading models, installing packages, or using GitHub.

---

# Current Status

**EzraOS Ubuntu v2.1.0 Alpha**

EzraOS Ubuntu is currently an alpha release.

Bugs, hardware-specific problems, installation issues, and compatibility issues may still occur.

EzraOS is an **OS-like AI development environment running on top of Ubuntu Linux**.

It is not a standalone operating system and does not replace Ubuntu.

---

## Developer

Developed by **JezCruz**

