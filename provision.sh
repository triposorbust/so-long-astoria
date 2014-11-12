#!/bin/sh

sudo apt-get update
sudo apt-get -y install build-essential
sudo apt-get -y install clang gobjc gcc g++ gdb make valgrind
sudo apt-get -y install emacs git
sudo apt-get -y install libx11-dev

exit 0
