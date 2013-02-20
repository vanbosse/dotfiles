for file in "$(dirname "$BASH_SOURCE")"/.bash/{shell,commands,prompt,git-completion}; do
    [ -r "$file" ] && source "$file";
done;
unset file;
