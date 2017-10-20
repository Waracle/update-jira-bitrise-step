#!/usr/bin/env bash
set -e
set -o pipefail

if [[ "${is_debug}" == 'yes' ]]; then
	set -x
fi

echo
echo "JIRA Config:"
echo "- url: $jira_url"
echo "- user: $jira_user"
echo "- password: $(if [ ! -z ${jira_password+x} ]; then echo "****"; fi)"

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
echo "Extracting JIRA Issue number from branch: $BITRISE_GIT_BRANCH"

JIRA_ISSUE="$(echo $BITRISE_GIT_BRANCH | egrep -o '[A-Z]+-[0-9]+')"

echo "Found '$JIRA_ISSUE'"

# If no issue number, abort
if [ ! "$JIRA_ISSUE" ]; then
	echo Branch does not contain JIRA issue
	exit 0
fi

echo "Adding $JIRA_ISSUE to env. vars"
envman add --key JIRA_ISSUE --value $JIRA_ISSUE

res="$(curl --write-out %{response_code} --silent --output /dev/null -u $jira_user:$jira_password -X POST -H "Content-Type: application/json" -d "{\"body\": \"${jira_build_message//$'\n'/\n}\"}" https://${jira_url}/rest/api/2/issue/$JIRA_ISSUE/comment)"
if test "$res" == "201"; then
    echo
    echo "--- Posted comment to jira successfully"
    echo "---------------------------------------------------"
    exit 0
else
   echo "the curl command failed with: $res"
   exit 1
fi