FROM alpine

ENV TEST_AUTOMATION_HOME=./test-automation-home
ENV scversion="stable"

WORKDIR $TEST_AUTOMATION_HOME

RUN apk update
RUN apk add bash jq

#  Installing shellcheck
RUN wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-${scversion?}.linux.x86_64.tar.xz" | tar -xJv
RUN cp "shellcheck-${scversion}/shellcheck" /usr/bin/
RUN shellcheck --version

# copying over files
COPY tests tests
COPY mocks mocks
COPY app app