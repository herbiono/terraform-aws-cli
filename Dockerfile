FROM alpine:latest as builder
MAINTAINER "Yusuf Herbiono <yusuf_herbiono@linkaja.id>"

WORKDIR /tmp

RUN apk add --no-cache curl

ENV TERRAFORM_VERSION=0.12.24

RUN curl https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip

RUN unzip terraform.zip \
    && rm -rf terraform.zip \
    && chmod +x terraform 

FROM amazon/aws-cli:latest

COPY --from=builder /tmp/terraform /usr/local/bin/terraform

RUN aws --version && terraform version

ENTRYPOINT ["terraform"]