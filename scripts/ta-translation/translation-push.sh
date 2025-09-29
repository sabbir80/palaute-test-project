#!/bin/bash

set -e

echo "--- Starting Translation Push Script (Bitbucket -> GitLab) ---"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT=$(realpath "$SCRIPT_DIR/../..")

echo "Detected Palauteboksi repository root at: $REPO_ROOT"

TA_TRANSLATION_REPO_PATH=$(realpath "$REPO_ROOT/../weblate-test-project")
PALAUTEBOKSI_TRANSLATIONS_DIR="$REPO_ROOT/Palaute/translations"
PROJECT_NAME="ta-hire"
BRANCH_NAME="main"

pushd "$REPO_ROOT" > /dev/null
git checkout $BRANCH_NAME
git pull origin $BRANCH_NAME
popd > /dev/null


if [ -z "$TA_TRANSLATION_REPO_PATH" ] || [ ! -d "$TA_TRANSLATION_REPO_PATH/.git" ]; then
  echo "Error: Path to 'weblate-test-project' repository is not a valid Git repo."
  echo "Please edit this script and set TA_TRANSLATION_REPO_PATH to the correct local path."
  exit 1
fi
if [ ! -d "$PALAUTEBOKSI_TRANSLATIONS_DIR" ]; then
    echo "Error: Local translations directory '$PALAUTEBOKSI_TRANSLATIONS_DIR' not found. Aborting."
    exit 1
fi

SOURCE_DIR="$PALAUTEBOKSI_TRANSLATIONS_DIR/" # The trailing slash is important for rsync
DESTINATION_DIR="$TA_TRANSLATION_REPO_PATH/$PROJECT_NAME/"

echo "Syncing entire translations directory to local GitLab repo clone..."
echo "Source: $SOURCE_DIR"
echo "Destination: $DESTINATION_DIR"

mkdir -p "$DESTINATION_DIR"


rsync -av --delete "$SOURCE_DIR" "$DESTINATION_DIR"

echo "Navigating to '$TA_TRANSLATION_REPO_PATH' to commit and push to GitLab..."
pushd "$TA_TRANSLATION_REPO_PATH" > /dev/null

if [ -z "$(git status --porcelain)" ]; then
  echo "No new source strings or file changes to push. Working tree is clean."
  echo "--- Translation Push Script Finished ---"
  popd > /dev/null
  exit 0
fi

git add .
git commit -m "i18n: Sync translation source files from palauteboksi"
git push origin translations
echo "Successfully pushed translation file updates to GitLab."

popd > /dev/null

echo "--- Translation Push Script Finished ---"