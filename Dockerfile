FROM ubuntu:17.10

ARG name="Aric Beagley" 
ARG email="abeagley@bastionweb.io"

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils && \
    apt-get install -y \
        curl \
        git \
        nano \
        ssh \
        openssl \
        python \
        python-pip \
        python3 \
        sudo \
        unzip \
        vim \
        wget \
        zsh

# User setup
RUN groupadd -g 70 dev && \
    useradd -N -m -u 70 -g 70 -G sudo dev && \
    echo "root:dev" | chpasswd && \ 
    echo "dev:dev" | chpasswd

# PIP Global Modules
RUN pip install 'docker-compose==1.18.0'

# Global binaries
WORKDIR /usr/local/bin
RUN curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.8.4/bin/linux/amd64/kubectl && \
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/v0.8.0/minikube-linux-amd64 && \ 
    cd /tmp && \
    curl -Lo protoc.zip https://github.com/google/protobuf/releases/download/v3.5.1/protoc-3.5.1-linux-x86_64.zip && \
    unzip protoc.zip -d protoc && \
    mv ./protoc/bin/protoc /usr/local/bin && \
    mv ./protoc/include/google /usr/local/include && \
    curl -Lo go.tar.gz https://dl.google.com/go/go1.9.4.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    cd /usr/local/bin &&\
    chmod +x ./minikube ./kubectl ./protoc

COPY ./bootstrap.sh /home/dev/
COPY ./welcome.sh /home/dev

RUN chown dev:dev /home/dev/bootstrap.sh /home/dev/welcome.sh

#
# Anything below this point is attached to the `dev` user
#
USER dev
WORKDIR /home/dev
ENV HOME="/home/dev" GOROOT="/usr/local/go" SHELL="/bin/zsh" GOPATH="$HOME/go" PATH="$HOME/.local/bin:$GOPATH/bin:$GOROOT/bin:$PATH"
SHELL ["/bin/zsh", "-c"]

# Whitelist common source repositories
# RUN ssh-keyscan github.com >> /

# Config
RUN git config --global user.name $name && \ 
    git config --global user.email $email

# AWS
run pip install awscli --upgrade --user

# Oh-My-ZSH Setup / NVM Setup
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/lukechilds/zsh-nvm $HOME/.oh-my-zsh/custom/plugins/zsh-nvm && \
    rm -rf $HOME/.zshrc && \
    curl -Lo .zshrc "https://gist.githubusercontent.com/abeagley/c446ba4a9f6f33b8a1a02a842f6a8bc7/raw/364545026b9d2776a38dc4fc51aec1f66ec4ac81/.zshrc-docker" && \
    source $HOME/.zshrc && \
    nvm upgrade && \
    nvm install 8 && \
    echo "source $HOME/welcome.sh" >> $HOME/.zshrc

# Mount up
RUN mkdir -p $HOME/workdir/go $HOME/credentials/ssh && \
    ln -s $HOME/credentials/ssh $HOME/.ssh
VOLUME ["/home/dev/credentials", "/home/dev/workdir"]

WORKDIR /home/dev
CMD /bin/zsh
