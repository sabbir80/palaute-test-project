#!/bin/bash

set -e

echo "--- Starting Translation Pull Script (GitLab -> Bitbucket) ---"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT=$(realpath "$SCRIPT_DIR/../..")

echo "Detected Palauteboksi repository root at: $REPO_ROOT"

TA_TRANSLATION_REPO_PATH=$(realpath "$REPO_ROOT/../weblate-test-project")

PALAUTEBOKSI_TRANSLATIONS_DIR="$REPO_ROOT/Palaute/translations"
PROJECT_NAME="ta-hire"
BRANCH_NAME="translations"

echo "Verifying local repository paths..."
if [ -z "$TA_TRANSLATION_REPO_PATH" ] || [ ! -d "$TA_TRANSLATION_REPO_PATH/.git" ]; then
  echo "Error: Path to 'weblate-test-project' repository is not a valid Git repo."
  echo "Expected at: '$TA_TRANSLATION_REPO_PATH'"
  echo "Please ensure 'palauteboksi' and 'weblate-test-project' are in the same parent directory."
  exit 1
fi
if [ ! -d "$PALAUTEBOKSI_TRANSLATIONS_DIR" ]; then
  echo "Error: Local palauteboksi translations directory not found at '$PALAUTEBOKSI_TRANSLATIONS_DIR'."
  exit 1
fi

echo "Navigating to '$TA_TRANSLATION_REPO_PATH' to pull from GitLab..."
pushd "$TA_TRANSLATION_REPO_PATH" > /dev/null

git checkout $BRANCH_NAME
git pull origin $BRANCH_NAME
echo "Successfully pulled latest changes from GitLab."

popd > /dev/null

SOURCE_DIR="$TA_TRANSLATION_REPO_PATH/$PROJECT_NAME/"
DESTINATION_DIR="$PALAUTEBOKSI_TRANSLATIONS_DIR/"

echo "Syncing translations for project '$PROJECT_NAME'..."

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Warning: Project '$PROJECT_NAME' not found in the GitLab repository. Nothing to pull."
    echo "--- Translation Pull Script Finished ---"
    exit 0
fi

rsync -av --delete "$SOURCE_DIR" "$DESTINATION_DIR"

echo "Successfully synced translations into palauteboksi."
echo "Developer can now commit these changes to Bitbucket."
echo "--- Translation Pull Script Finished ---"