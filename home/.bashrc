#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias neofetch='hyfetch'
alias ls='ls --color=auto -h'
alias loadnoise='noisetorch -i -o'
alias discord='/bin/discord --ignore-gpu-blocklist --disable-features=UseOzonePlatform --enae-features=VaapiVideoDecoder --use-gl=desktop --enable-gpu-rasterization --enable-zero-copy --no-sandbox; loadnoise'
PS1='[\u@\h \W]\$ '
cat /home/dani/.cache/wal/sequences