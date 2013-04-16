for file in "$(dirname "$BASH_SOURCE")"/.bash/{shell,commands,aliases,prompt,git-completion,extra}; do
    [ -r "$file" ] && source "$file";
done;
unset file;
