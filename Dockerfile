FROM ubuntu:18.04

ENV TEST_AUTOMATION_HOME=./test-automation-home
ENV scversion="stable"

WORKDIR $TEST_AUTOMATION_HOME

RUN apt-get update
RUN apt-get install -y build-essential curl file git locales-all xz-utils wget

#  Installing shellcheck
RUN wget -qO- "https://storage.googleapis.com/shellcheck/shellcheck-${scversion?}.linux.x86_64.tar.xz" | tar -xJv
RUN cp "shellcheck-${scversion}/shellcheck" /usr/bin/
RUN shellcheck --version
  
# Installing Homebrew and shellcheck with homebrew
# RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
# RUN mkdir ~/.linuxbrew/bin
# RUN ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
# RUN echo 'export PATH="/root/.linuxbrew/bin:$PATH"' >> ~/.bashrc
# RUN brew update
# RUN brew install shellcheck
# RUN shellcheck --version
# Shellcheck takes too long to install because of dependencies

COPY mocks mocks
COPY gitrise.sh gitrise.sh