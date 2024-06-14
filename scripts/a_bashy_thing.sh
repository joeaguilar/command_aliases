#Test that this works
echo "Loading Bash Aliases"



function subl()
{
        /mnt/c/Program\ Files\ \(x86\)/Sublime\ Text\ 3/sublime_text.exe $@
}

function explorer()
{
        /mnt/c/Windows/explorer.exe $@
}

function webprog()
{
        mkdir ./web
        touch ./web/index.html
        touch ./web/index.js
        touch ./web/styles.css
        printf "<html>\n\t<head>\n\t\t<link href='./styles.css'></link>\n\t\t<script src='index.js'></script>\n\t</head>\n\t<body>\n\t</body>\n</html>" >> ./web/index.html
}

function cheat() {
	curl cht.sh/$1
}

 function extract () {
      if [ -f $1 ] ; then
        case $1 in
          *.tar.bz2)   tar xjf $1     ;;
          *.tar.gz)    tar xzf $1     ;;
          *.bz2)       bunzip2 $1     ;;
          *.rar)       unrar e $1     ;;
          *.gz)        gunzip $1      ;;
          *.tar)       tar xf $1      ;;
          *.tbz2)      tar xjf $1     ;;
          *.tgz)       tar xzf $1     ;;
          *.zip)       unzip $1       ;;
          *.Z)         uncompress $1  ;;
          *.7z)        7z x $1        ;;
          *)     echo "'$1' cannot be extracted via extract()" ;;
           esac
       else
           echo "'$1' is not a valid file"
       fi
     }


    #  firefox --new-instance --profile $(mktemp -d)
    #  chromium --user-data-dir $(mktemp -d)

alias ls='ls --color=auto --human-readable --group-directories-first --classify'

alias h='cd -'
alias g='git status'
alias s="git status"
alias d="git diff"
alias dc='git diff --cached'
alias gl='git log --oneline --graph --all --decorate'

alias gitdiff='git difftool -y -x "colordiff -y -W $COLUMNS" | less -R'

# make directory and enter it
mdc() {
	mkdir -p "$@" && cd "$@"
}

# make directory and enter it
mkcd() {
	mkdir -p "$@" && cd "$@"
}


# create a file and make git track it
ga() {
	touch "$@" && git add "$@"
}


  # set terminal window title
  title() { print -Pn "\e]2;$@\a" }

alias glnp="git --no-pager log --oneline -n30"

   # Have I been pwned?
    # usage: `hibp email@example.com`
    hibp() {
        curl -fsS "https://haveibeenpwned.com/api/v2/breachedaccount/$1" | jq -r 'sort_by(.BreachDate)[] | [.Title,.Domain,.BreachDate,.PwnCount] | @tsv' | column -t -s$'\t'
    }




  cdf () {
        target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
        if [ "$target" != "" ]
        then
                cd "$target"
                pwd
        else
                echo 'No Finder window found' >&2
        fi
}


function badnames {
	find . -name '*[?<>\\:*|\"]*'
  }






   alias gs="g status"
   alias glff="git pull --ff-only"
   alias glffc="git pull origin \$(current_branch) --ff-only"
   alias glc="git pull origin \$(current_branch)"
   alias gpc="git push origin \$(current_branch)"
   alias gpcfl="git push origin \$(current_branch) --force-with-lease"
   function goops { git add -A "$@" && git commit --amend --no-edit && gpcfl }
   alias gbr="git branch -r"
   alias grm="git branch --merged | grep -v \"\*\" | xargs -n 1 git branch -d"
   function mkb() {
       git fetch && git checkout -b "$1" origin/master
   }


git_branch_dates() {
      git for-each-ref --sort=authordate --format '%(authordate:iso) %(align:left,25)%(refname:short)%(end) %(subject)' refs/heads
    }


alias=devme'npm dev start'



#
#  Add directory to PATH if it exists
#
function add_to_path
{
   if [ -d "$1" ]; then
      export PATH=$1:$PATH
   fi
}


#
# Empty the PATH so we have a known-starting point.
#
export PATH=

#
# Add on the expected/standard directories.
#
add_to_path /bin
add_to_path /usr/bin
add_to_path /sbin
add_to_path /usr/sbin
add_to_path /usr/local/bin
add_to_path /usr/local/sbin

#
# Some optional directories might exist, and if so they will be added.
#
add_to_path /opt/node/bin
add_to_path /opt/packer
add_to_path /opt/pass
add_to_path /opt/sysadmin-util
add_to_path /usr/games
add_to_path /usr/lib/ccache
add_to_path /var/lib/gems/1.8/bin
add_to_path /var/lib/gems/1.9/bin

#
# We allow a per-user, and a per-user + per-host setup.
#
add_to_path ~/bin/
add_to_path ~/bin-$(hostname --short)


#
# Now we have some extra setup for things that might be present.
#


#
# Golang
#
if [ -d /opt/go ]; then

    # Add the path
    add_to_path /opt/go/bin
    add_to_path $HOME/go/bin

    # go-specific environmental variable setup.
    export GO111MODULE=on
    export GOPATH=$HOME/go
    export GOROOT=/opt/go

fi


#
# Ruby Gems
#
if [ -d ~/gems/bin ]; then
    export GEM_HOME=~/gems/
    add_to_path $HOME/gems/bin
fi





#
#  Remove any duplicated entries.
#
export PATH=$(echo "$PATH" | awk -F: '{for (i=1;i<=NF;i++) { if ( !x[$i]++ ) printf("%s:",$i); }}')




alias duss="sudo du -d 1 -h | sort -hr | egrep -v ^0"




 function getIPAddress()
 {
  	SYSTEM=$(\uname | \tr /a-z/ /A-Z/ | \cut -c-5)

    # MacOS
    if [ "$SYSTEM" = "DARWI" ]; then
    	\ifconfig | \sed '/vboxnet/{N;N;d;}' | \grep 'inet ' | \grep -v '127.0.0.1' | \awk '{print $2}' | \tr '\n' '-' | \sed 's/-.*//' | \tr -d '\n'
    	\exit 0
    fi

    # Linux
    if [ "$SYSTEM" = "LINUX" ]; then
    	\ip route get 1 | \awk '{print $NF}' | \tr -d '\n'
    	\exit 0
    fi

    # MINGW/CYGWIN on Windows
    if [ "$SYSTEM" = "MINGW" -o "$SYSTEM" = "CYGWI" ]; then
    	\ipconfig | \grep 'IPv4' | \awk '{print $NF}' | \tr -d '\n'
    	\exit 0
    fi
 }


   # misc
  alias mount="mount | column -t"
  alias ports="netstat -tulanp"
  alias vmstat="vmstat -w"
  alias ed="ed -p '>>> '"
  # genpass
  function genpass() { head -c 500 /dev/urandom | tr -dc a-z0-9A-Z | head -c $1; echo; }

  # git stuff
  alias gitpretty="git log --graph --oneline --decorate --all"
  alias gitprettyall="git log --oneline --decorate --all --  graph --stat"
  alias gfiles="git show --pretty='' --name-only $1"
  alias gitstat="git log --stat"
  alias gitchangelog="git log --oneline --no-merges ${1}..HEAD"
  alias gittopcontrib="git shortlog -ns"
  alias gitdiff="git difftool $1"




     #! /bin/bash
    fpath=$HOME/notes.md

    if [ "$1" == "cat" ]; then
        cat "$fpath"
        exit 0
    elif [ "$1" == "rg" ]; then
        rg "$2" "$fpath"
    elif [ "$1" == "nano" ]; then
        nano "$fpath"
    elif [ "$1" == "--help" ]; then
        printf 'Commands: \n-----------------------------------------------\n
        $ notes \n
        $ notes --help\t\t--\tdisplay this help\n
        $ notes date\t\t--\tadd date row to notes\n
        $ notes <text>\t\t--\tadd new entry \n
        $ notes cat\t\t--\tprint notes using cat\n
        $ notes rg <pattern>\t--\tripgrep notes\n
        Remember to use #tags (for easier grepping)!\n\n'
    elif [ "$1" == "date" ]; then
        {
        echo ''
        echo '# '"$(date +"%m-%d-%Y-%T")"
        echo '-'
        } >> "$fpath"
    elif [ "$1" == "" ]; then
        less +G "$fpath"
    else
        {
            echo ''
            echo "$@"
            echo ''
        } >>"$fpath"
    fi


   alias shrug='echo -n "¯\_(ツ)_/¯" | xclip -selection clipboard && echo "\"¯\_(ツ)_/¯\" copied to clipboard!"'shrug='echo -n "¯\_(ツ)_/¯" | xclip -selection clipboard && echo "\"¯\_(ツ)_/¯\" copied to clipboard!"'shrug='echo -n "¯\_(ツ)_/¯" | xclip -selection clipboard && echo "\"¯\_(ツ)_/¯\" copied to clipboard!"'



    # (Sort stuff by size, latest down, in a directory)
  alias lss="ls -lSrh"
  alias ld="ls -lrt"

  # First 100 of largest files/directories in a folder
  function qqlargest_files_100(){
    du -a ./ | sort -n -r | head -n 100
  }



  #c10b00
  #15141a
  #c2beb3
  #dca361

