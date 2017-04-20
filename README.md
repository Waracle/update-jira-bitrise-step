# Update JIRA Step

This is a BitRise step for adding a JIRA comment with the build location if a JIRA issue number is detected in the branch name.

It uses Basic Auth over HTTPS and will require you to enable the API for your instance and provide the following:

* A username
* A password
* The hostname and port of the instance

You should probably create a specific user for this type of activity to prevent user credentials leaking.
