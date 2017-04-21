#!/bin/bash

#
# --- Export Environment Variables for other Steps:
# You can export Environment Variables for other Steps with
#  envman, which is automatically installed by `bitrise setup`.
# A very simple example:
#  envman add --key EXAMPLE_STEP_OUTPUT --value 'the value you want to share'
# Envman can handle piped inputs, which is useful if the text you want to
# share is complex and you don't want to deal with proper bash escaping:
#  cat file_with_complex_input | envman add --KEY EXAMPLE_STEP_OUTPUT
# You can find more usage examples on envman's GitHub page
#  at: https://github.com/bitrise-io/envman

#
# --- Exit codes:
# The exit code of your Step is very important. If you return
#  with a 0 exit code `bitrise` will register your Step as "successful".
# Any non zero exit code will be registered as "failed" by `bitrise`.

JIRA_ISSUE=`echo $BITRISE_GIT_BRANCH | egrep -o '[A-Z]+-[0-9]+'`

# If no issue number, abort
if [ ! "$JIRA_ISSUE" ]; then
	echo Branch does not contain JIRA issue
	exit 0
fi

envman add --key JIRA_ISSUE --value $JIRA_ISSUE

# Generate comment body

export COMMENT_BODY="Build $BITRISE_BUILD_NUMBER at $BITRISE_BUILD_URL"
echo $COMMENT_BODY

curl -D- -u $JIRA_USER:$JIRA_PASSWORD -X POST -H "Content-Type: application/json" -d "{\"body\": \"$COMMENT_BODY\"}" https://$JIRA_HOST_PORT/rest/api/2/issue/$JIRA_ISSUE/comment
