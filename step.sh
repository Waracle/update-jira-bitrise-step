#!/usr/bin/env bash
#set -e
set -o pipefail

if [[ "${is_debug}" == 'yes' ]]; then
	set -x
fi

# use the error comment field if build fails
if [ ${BITRISE_BUILD_STATUS} != "0" ]; then
    jira_comment="${jira_comment_error}";
fi

echo
echo "JIRA Config:"
echo "- url: $jira_url"
echo "- user: $jira_user"
echo "- password: $(if [ ! -z ${jira_password+x} ]; then echo "****"; fi)"
echo "- comment: $jira_comment"

# Required input validation
if [[ "${jira_url}" == "" ]]; then
	echo
	echo "No jira_url provided as environment variable. Terminating..."
	echo
	exit 1
fi

if [[ "${jira_user}" == "" ]]; then
	echo
	echo "No jira_user provided as environment variable. Terminating..."
	echo
	exit 1
fi

if [[ "${jira_password}" == "" ]]; then
	echo
	echo "No jira_password provided as environment variable. Terminating..."
	echo
	exit 1
fi


echo
echo "Extracting JIRA Issue number from branch: '$BITRISE_GIT_BRANCH', or commit message: '${BITRISE_GIT_MESSAGE}'"

JIRA_ISSUE="$(echo "${BITRISE_GIT_BRANCH}" | egrep -o '[A-Z]+-[0-9]+' | head -1)"

# If no issue number, check the commit message
if [ -z "${JIRA_ISSUE}" ]; then
    # lets check the commit message
    echo "No Issue number found in branch, checking commit message"
    JIRA_ISSUE="$(echo $BITRISE_GIT_MESSAGE | egrep -o '[A-Z]+-[0-9]+' | head -1)"
fi

# If no issue number, abort
if [ -z "${JIRA_ISSUE}" ]; then
	echo "Branch or Commit message doesn't not contain JIRA issue"
	exit 0
fi

if command -v envman 2>/dev/null; then
    echo "Adding $JIRA_ISSUE to env. vars"
    envman add --key JIRA_ISSUE --value "${JIRA_ISSUE}"
fi

# remove empty lines from the comment, as it messes up the formatting in the jira ticket
FORMATTED_JIRA_COMMENT="$(echo "${jira_comment}" | sed '/^$/d')"

# convert new line characters to jira-readable newlines
FORMATTED_JIRA_COMMENT="${FORMATTED_JIRA_COMMENT//$'\n'/\\n}"

if [[ "${is_debug}" == "yes" ]]; then
    echo
    echo "Formatted JIRA COMMENT: ${FORMATTED_JIRA_COMMENT}"
fi

#res="$(curl --write-out %{response_code} --silent --output /dev/null -u $jira_user:$jira_password -X POST -H "Content-Type: application/json" -d "{\"body\": \"${FORMATTED_JIRA_COMMENT}\"}" https://${jira_url}/rest/api/2/issue/$JIRA_ISSUE/comment)"
if test "$res" == "201"; then
    echo
    echo "--- Posted comment to jira successfully"
    echo "---------------------------------------------------"
    exit 0
else
   echo "the curl command failed with: $res"
   exit 1
fi
