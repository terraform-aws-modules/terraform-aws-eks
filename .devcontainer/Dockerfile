# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.205.1/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version (use hirsuite or bionic on local arm64/Apple Silicon): hirsute, focal, bionic
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

ARG TERRAFORM_VERSION="1.1.3"
ARG TERRAFORM_DOCS_VERSION="0.16.0"

RUN apt update && apt install -y python3-pip && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts
RUN pip install --no-cache-dir pre-commit
RUN curl -Lo ./terraform-docs.tar.gz https://github.com/terraform-docs/terraform-docs/releases/download/v${TERRAFORM_DOCS_VERSION}/terraform-docs-v${TERRAFORM_DOCS_VERSION}-$(uname)-amd64.tar.gz && tar -xzf terraform-docs.tar.gz terraform-docs && rm terraform-docs.tar.gz && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
RUN curl -L "$(curl -s https://api.github.com/repos/terraform-linters/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip tflint && rm tflint.zip && sudo mv tflint /usr/bin/
RUN curl -o terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && unzip terraform.zip && rm terraform.zip && sudo mv terraform /usr/bin/
