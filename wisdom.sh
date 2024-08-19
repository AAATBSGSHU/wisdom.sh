#!/bin/bash

REPO_DIR="$HOME/quotes-repo"
REPO_URL="https://github.com/username/reponame.git"
QUOTES_FILE="$REPO_DIR/quotes.txt"
LOCAL_FOLDER="$HOME/local-quotes"
USE_LOCAL_FOLDER=false  # Change this to true to use the local folder instead of the Git repo

display_quote() {
    local quote
    quote=$(shuf -n 1 "$QUOTES_FILE")

    tput clear
    tput civis

    local term_width=$(tput cols)
    local term_height=$(tput lines)

    local quote_width=$(echo "$quote" | awk '{ print length }')
    local start_col=$(( (term_width - quote_width) / 2 ))
    local start_row=$(( term_height / 2 ))

    tput cup $start_row $start_col
    echo "$quote"

    read -n 1 -s

    tput cvvis
}

if [ "$USE_LOCAL_FOLDER" = true ]; then
    if [ ! -d "$LOCAL_FOLDER" ]; then
        echo "Local folder does not exist: $LOCAL_FOLDER"
        exit 1
    fi
    QUOTES_FILE="$LOCAL_FOLDER/quotes.txt"
else
    if [ ! -d "$REPO_DIR" ]; then
        echo "Cloning repository..."
        git clone "$REPO_URL" "$REPO_DIR"
    fi

    cd "$REPO_DIR" || { echo "Failed to navigate to repo directory"; exit 1; }

    echo "Fetching latest changes..."
    git fetch origin

    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    echo "Local commit: $LOCAL"
    echo "Remote commit: $REMOTE"

    if [ "$LOCAL" != "$REMOTE" ]; then
        echo "Updates found. Pulling changes..."
        git pull
    fi

    QUOTES_FILE="$REPO_DIR/quotes.txt"
fi

display_quote
