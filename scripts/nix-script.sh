#!/usr/bin/env nix-shell
#!nix-shell -i bash -p cowsay lolcat

cowsay "Hello from Nix!" | lolcat
sleep 50