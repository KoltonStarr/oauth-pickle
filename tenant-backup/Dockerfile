FROM amazon/aws-cli:latest AS awscli

FROM alpine:3.20.2
RUN apk add --no-cache gcompat git curl

# Copy AWS CLI and all dependencies from the awscli stage
COPY --from=awscli /usr/local/aws-cli/ /usr/local/aws-cli/
COPY --from=awscli /usr/local/bin/aws /usr/local/bin/aws

# Verify that the AWS CLI can run in the Alpine environment
RUN aws --version

ENV PATH="/usr/local/bin:${PATH}"

CMD ["sh"]
