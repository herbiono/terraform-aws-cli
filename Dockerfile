FROM ubuntu:20.04 as builder
MAINTAINER "Yusuf Herbiono <yusuf_herbiono@linkaja.id>"
WORKDIR /tmp

RUN apt update -y \
    && apt install -y curl unzip jq \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install --bin-dir /aws-cli-bin/

ARG TF_VERSION=latest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TF_VERSION}" = "latest" ]; then \
    VERSION="$( curl -LsS https://releases.hashicorp.com/terraform/ \
    | grep -Eo '/[.0-9]+/' | grep -Eo '[.0-9]+' \
    | sort -V | tail -1 )" ;\
    else \
    VERSION="${TF_VERSION}" ;\
    fi ;\
    curl -LsS \
    https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip -o ./terraform.zip ;\
    unzip ./terraform.zip ;\
    chmod +x ./terraform

# Get Terragrunt by a specific version or search for the latest one
ARG TG_VERSION=latest
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
RUN if [ "${TG_VERSION}" = "latest" ]; then \
    VERSION="$( curl -LsS https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest \
    | jq -r .name  )" ;\
    else \
    VERSION="v${TG_VERSION}" ;\
    fi ;\
    curl -LsS \
    https://github.com/gruntwork-io/terragrunt/releases/download/${VERSION}/terragrunt_linux_amd64 -o /usr/bin/terragrunt ;\
    chmod +x /usr/bin/terragrunt

FROM ubuntu:20.04

COPY ./version.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/version.sh

# RUN apt update -y \
#     && apt install -y less groff 
COPY --from=builder /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=builder /aws-cli-bin/ /usr/local/bin/
COPY --from=builder /tmp/terraform /usr/local/bin/
COPY --from=builder /usr/bin/terragrunt /usr/local/bin/
# WORKDIR /aws

# ENTRYPOINT [ "/usr/local/bin/version.sh" ]


