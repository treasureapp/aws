#!/usr/bin/env bash


# prereqs: https://www.howtogeek.com/211541/homebrew-for-os-x-easily-installs-desktop-apps-and-terminal-utilities/
# install MacOS command line tools
xcode-select --install
# install brew
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# ensure brew installed
brew doctor

# use brew to install:
# python
brew install python3
# aws command line interface
brew install awscli
# to configure auto complete see http://docs.aws.amazon.com/cli/latest/userguide/cli-command-completion.html

# add following to profile
#source /usr/local/bin/aws_zsh_completer.sh
#source /usr/local/share/zsh/site-functions
