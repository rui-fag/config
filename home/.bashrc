#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

########
#ALCI
########
alias evb='sudo systemctl enable --now vboxservice.service'
# Created by `pipx` on 2025-07-18 17:51:20
export PATH="$PATH:/home/ruifag/.local/bin"

PATH="/home/ruifag/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/home/ruifag/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/home/ruifag/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/home/ruifag/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/ruifag/perl5"; export PERL_MM_OPT;

# Increase Bash history size
HISTSIZE=5000
HISTFILESIZE=10000
