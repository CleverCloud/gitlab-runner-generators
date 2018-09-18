#!/usr/bin/env bash

: <<'COMMENT'
# Generate and deploy GitLab runner to Clever Cloud

## What is it?

This script is an experiment to easily create GitLab runners on Clever Cloud platform

## Requirements

The Clever Cloud CLI must be installed and and connected at least once. 

See: https://www.clever-cloud.com/doc/clever-tools/getting_started/

If not, install it and do this:

```shell
clever login
Opening https://console.clever-cloud.com/cli-oauth in your browser…
Enter CLI token: <type your token>
Enter CLI secret: <type your secret>
/Users/<user_name>/.config/clever-cloud has been updated.
```

## How to

- Create a project on GitLab
- Go to Settings > CI/CD
- Expand the "Runners settings" section
  - note the GitLab instance url, eg: https://gitlab.com/
  - note the registration token, eg: xxx15n9__zZmpxh5678y
- Go to your GitLab profile settings, and generate an access token, eg: zPw33KCoiMY2GGjaYzErt

## Run it

```shell
ORGANIZATION="wey-yu" \
PROJECT_NAME="cc-hello-runner-demo" \
GITLAB_INSTANCE="https://gitlab.com" \
PERSONAL_ACCESS_TOKEN="zPw33KCoiMY2GGjaYzErt" \
RUNNER_NAME="nodejs-runner-demo" \
REGISTRATION_TOKEN="xxx15n9__zZmpxh5678y" \
CLEVER_TOKEN=1234567890abcdef \
CLEVER_SECRET=abcdef123456789 \
./gen-runner.sh
```

- Wait for the deployment
- Once the runner deployed you can return to the "Runners settings" section to check that the runner is "linked"

COMMENT

# === Create project and git repository
mkdir $PROJECT_NAME
cd $PROJECT_NAME
git init

# === Generate Dockerfile ===
# Modify this part at your convenience
# You need to install all the assets you need in the container
#
cat > Dockerfile << EOF
# Runner for a nodejs project
# FROM ubuntu:latest
# It's better to fix the version of the distribution (early version could be not compliant with GL runner)
FROM ubuntu:16.04

COPY go.sh go.sh
RUN chmod +x go.sh

# Install gitlab-runner and nodejs
RUN apt-get update && \\
    apt-get install -y curl python3 && \\
    curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash  && \\
    apt-get install -y gitlab-runner && \\
    curl -sL https://deb.nodesource.com/setup_9.x | bash  && \\
    apt-get -y install nodejs && \\
    echo "👋 🦊 Runner is installed" 
CMD [ "/go.sh" ]
EOF


# === Generate go.sh ===
cat > go.sh << EOF
#!/bin/sh

# Get the id of the runner (if exists)
id=\$(curl --header \\
  "PRIVATE-TOKEN: \$PERSONAL_ACCESS_TOKEN" \\
  "\$GITLAB_INSTANCE/api/v4/runners" | python3 -c \\
'
import sys, json;
json_data=json.load(sys.stdin)
for item in json_data:
  if item["description"] == "'\$RUNNER_NAME'":
    print(item["id"])
')

echo "👋 id of \$RUNNER_NAME runner is: \$id"

echo "⚠️ trying to deactivate runner..."

curl --request DELETE --header \
  "PRIVATE-TOKEN: \$PERSONAL_ACCESS_TOKEN" \
  "\$GITLAB_INSTANCE/api/v4/runners/\$id"


# Register, then run the new runner
echo "👋 launching new gitlab-runner"

gitlab-runner register --non-interactive \\
  --url "\$GITLAB_INSTANCE/" \\
  --name \$RUNNER_NAME \
  --registration-token \$REGISTRATION_TOKEN \
  --executor shell

gitlab-runner run &

echo "🌍 executing the http server"
python3 -m http.server 8080
EOF

git add .
git commit -m "🦊 first commit"

# === Create the runner ===

## Clever login
clever login --token $CLEVER_TOKEN --secret $CLEVER_SECRET

## Application creation and deployment
clever create $PROJECT_NAME -t docker --org $ORGANIZATION --region par --alias $PROJECT_NAME
clever scale --flavor M --alias $PROJECT_NAME
clever env set GITLAB_INSTANCE $GITLAB_INSTANCE --alias $PROJECT_NAME
clever env set PERSONAL_ACCESS_TOKEN $PERSONAL_ACCESS_TOKEN --alias $PROJECT_NAME
clever env set REGISTRATION_TOKEN $REGISTRATION_TOKEN --alias $PROJECT_NAME
clever env set RUNNER_NAME $RUNNER_NAME --alias $PROJECT_NAME
clever deploy

