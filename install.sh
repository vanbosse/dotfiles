#!/bin/bash

# Go trough all the files available in this folder.
commonFiles=();
for sourceFile in .*; do
    # Exclude some files.
    if [[ "$sourceFile" == "." || "$sourceFile" == ".." || "$sourceFile" == ".git" ]]; then
        continue;
    fi;

    # Set the target path for the source file.
    # We'll port them to the ~/ (home) directory.
    targetFile="$HOME/$sourceFile";

    # The file already exists.
    if [ -e "$targetFile" ]; then
        # The source and target point to the same file, continue.
        [ "$sourceFile" -ef "$targetFile" ] && continue;

        # The content of the file is the same, continue.
        diff -rq "$sourceFile" "$targetFile" > /dev/null 2>&1 && continue;

        # The source file is another file than our dotfile.
        # Store it in the commonFiles array so we can back it up.
        commonFiles+=("$sourceFile");
    fi;
done;

# Show the files that will be overwritten.
conflictCount=${#commonFiles[@]};
if [ $conflictCount -gt 0 ]; then
    # Create a suffix with a timestamp so the user can see which
    # files and when they've been backupped.
    backupSuffix=".dotfiles-$(date +'%Y%m%d-%H%M%S')";

    # Print some information about the replacement.
    tput setaf 3;
    printf "Warning: there are some files that will be overwritten.";
    tput sgr0;
    echo " Your files will be given the suffix $backupSuffix and will be" \
        "replaced by symlinks to the Dotfiles:";

    # Print the conflict files.
    for sourceFile in "${commonFiles[@]}"; do
        targetFile="$HOME/$sourceFile";
        echo "Yours: $targetFile";
        echo "Dotfiles: $sourceFile";
    done;

    # Make sure the user knows that we'll be replacing the old files.
    read -p "Would you like to overwrite the current files? (yes|no): ";
    case "$(tr '[:upper:]' '[:lower:]' <<< "$REPLY")" in
        'yes'|'y')
            # The user is sure, continue.
            ;;
        'no'|'n')
            # The user isn't sure, abort.
            echo 'Aborting.';
            exit 1;
            ;;
        *)
            # The user didn't type yes/no.
            echo 'Invalid answer. Assumed "no". Installation aborted.';
            exit 1;
    esac;
fi;

# Rename the conflicting files as backup.
for sourceFile in "${commonFiles[@]}"; do
    targetFile="$HOME/$sourceFile";
    mv -v "$targetFile" "$targetFile$backupSuffix";
done;

# Symlink the files in the home dir by those in the dotfiles repo.
for sourceFile in .*; do
    # Exclude some files.
    if [[ "$sourceFile" == "." || "$sourceFile" == ".." || "$sourceFile" == ".git" ]]; then
        continue;
    fi;

    targetFile="$HOME/$sourceFile";

    # Delete the old file and replace it by the symlink.
    rm -rf "$targetFile" &&
        ln -vs "$PWD/$sourceFile" "$targetFile";
done;

echo "Done.";
