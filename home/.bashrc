#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto -h'
PS1='[\u@\h \W]\$ '
cat /home/dani/.cache/wal/sequences