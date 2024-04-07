#!/bin/bash

# Check if the correct number of arguments is provided
if (( $# != 2 )); then
    printf "%b" "Usage: git.sh <version> <annotation>\n" >&2
    exit 1
fi

# Assign command-line arguments to variables
VERSION="$1"
ANNOTATION="$2"

# Inform user about the tag creation
echo "Creating tag $VERSION with annotation \"$ANNOTATION\""
# Create annotated tag with version and annotation
./git.sh "$VERSION" "$ANNOTATION"

# Inform user about switching to the main branch
echo "Switching to the main branch"
git checkout main

# Inform user about merging the development branch into the main branch
echo "Merging development branch into main"
git merge development

# Inform user about the tag creation again
echo "Creating tag $VERSION with annotation \"$ANNOTATION\""
# Create annotated tag with version and annotation
./git.sh "$VERSION" "$ANNOTATION"

# Inform user about switching back to the development branch
echo "Switching back to the development branch"
git checkout development

# Show current status after operations
git status
