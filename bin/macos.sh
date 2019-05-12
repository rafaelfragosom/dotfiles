#!/usr/bin/env bash

NUMBER_OF_STEPS=4

# Questions
question() {
  read -p "$(echo -e "\n\b")$1 [Y/n]: " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    NUMBER_OF_STEPS=$((NUMBER_OF_STEPS + 1))
    eval "$2"=1
  fi
}

# Necessary tools to compile and install other tools
command_line_tools() {
  printf "\n\033[0;32m[1|$NUMBER_OF_STEPS] Installing command line tools\033[0m"
  if hash $(xcode-select -p) 0>/dev/null; then
    printf "\nCommand-line tools is already installed. Skipping."
    return
  fi

  xcode-select --install
}

homebrew() {
  printf "\n\033[0;32m[2|$NUMBER_OF_STEPS] Installing Homebrew\033[0m"
  if hash brew 2>/dev/null; then
    printf "\nHomebrew is already installed. Skipping."
    return
  fi

  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}

git() {
  printf "\n\033[0;32m[3|$NUMBER_OF_STEPS] Installing Git\033[0m"
  if hash git 2>/dev/null; then
    printf "\nGit is already installed. Skipping."
    return
  fi

  brew install git
}

sshkeys() {
  printf "\n\033[0;32m[4|$NUMBER_OF_STEPS] Generating SSH keys for Github and Bitbucket\033[0m"
  local SSH_PATH=~/.ssh
  local GITHUB_KEY=$SSH_PATH/id_rsa
  local BITBUCKET_KEY=$SSH_PATH/$GIT_USERNAME
  local CONFIG=$SSH_PATH/config

  if [ -f "$GITHUB_KEY" ]; then
    printf "\nGithub key already exists. Skipping."
  else
    printf "\nGenerating Github keys."
    
    ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -N ""
  fi

  if [  -f "$BITBUCKET_KEY" ]; then
    printf "\nBitbucket key already exists. Skipping."
  else
    printf "\nGenerating Bitbucket keys."

    ssh-keygen -f ~/.ssh/$GIT_USERNAME -N ""
  fi

  if [ -f "$CONFIG" ]; then
    printf "\nconfig file already exists. Skipping."
  else
    printf "\nConfiguring SSH keys"

    echo "Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa

Host bitbucket.org
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/$GIT_USERNAME" >> ~/.ssh/config

    eval "$(ssh-agent -s)"
    ssh-add -K ~/.ssh/id_rsa
    ssh-add ~/.ssh/$GIT_USERNAME
  fi
}

# Programming Languages
# Databases
# Development Software
# User Preferences

read -p "Do you wish to install everything? Say $(echo -e "\033[1;31mno\033[0m") if you want a custom install: " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
  printf "\nInstalling everything..."
  command_line_tools
  homebrew
  git
  sshkeys
else
  NUMBER_OF_STEPS=0
  question "Install Command-line Tools?" "INSTALL_COMMAND_LINE_TOOLS"
  question "Install Homebrew?" "INSTALL_HOMEBREW"
  question "Install Git?" "INSTALL_GIT"
  question "Generate SSH keys" "GENERATE_SSH_KEYS"

  if [[ ! -z "$INSTALL_COMMAND_LINE_TOOLS" ]] || [[ "$INSTALL_COMMAND_LINE_TOOLS" =~ (Y|y|1) ]]; then
    command_line_tools
  fi

  if [[ ! -z "$INSTALL_HOMEBREW" ]] || [[ "$INSTALL_HOMEBREW" =~ (Y|y|1) ]]; then
    homebrew
  fi

  if [[ ! -z "$INSTALL_GIT" ]] || [[ "$INSTALL_GIT" =~ (Y|y|1) ]]; then
    git
  fi

  if [[ ! -z "$GENERATE_SSH_KEYS" ]] || [[ "$GENERATE_SSH_KEYS" =~ (Y|y|1) ]]; then
    sshkeys
  fi
fi