# gitlab-runner-generators
A set of scripts to generate GitLab Runners and deploy them on Clever Cloud


## What is it?

These scripts are an experiment to easily create GitLab runners on Clever Cloud platform.

### Runner scripts:

> Currently, the first script is `gen-nodejs-runner.sh`, it generates a GitLab runner with nodejs installed

- `gen-nodejs-runner.sh` generates a GitLab runner (shell) for nodejs projects

If you want to create your own script generator, you just need to change this part of the script: https://github.com/CleverCloud/gitlab-runner-generators/blob/master/gen-nodejs-runner.sh#L75

```shell
# Install gitlab-runner and nodejs
RUN apt-get update && \\
    apt-get install -y curl && \\
    curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash  && \\
    apt-get install -y gitlab-runner && \\
    # ⚠️ From here you can add, change, ... everything you need 
    curl -sL https://deb.nodesource.com/setup_9.x | bash  && \\
    apt-get -y install nodejs && \\
    echo "👋 🦊 Runner is installed" 
CMD [ "/go.sh" ]
EOF
```

> Stay tuned, soon other scripts (Java, etc...)

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

