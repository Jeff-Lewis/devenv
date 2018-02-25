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
        wget

# User setup / Global binaries
WORKDIR /usr/local/bin
RUN groupadd -g 70 dev && \
    useradd -N -m -u 70 -g 70 -G sudo dev && \
    echo "root:dev" | chpasswd && \ 
    echo "dev:dev" | chpasswd && \
    pip install 'docker-compose==1.18.0' && \
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/v1.8.4/bin/linux/amd64/kubectl && \
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \ 
    cd /tmp && \
    curl -Lo protoc.zip https://github.com/google/protobuf/releases/download/v3.5.1/protoc-3.5.1-linux-x86_64.zip && \
    unzip protoc.zip -d protoc && \
    mv ./protoc/bin/protoc /usr/local/bin && \
    mv ./protoc/include/google /usr/local/include && \
    curl -Lo go.tar.gz https://dl.google.com/go/go1.10.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go.tar.gz && \
    cd /usr/local/bin &&\
    chmod +x ./minikube ./kubectl ./protoc

COPY ./bash/ /home/dev/
COPY ./welcome.sh /home/dev/

# Fix permissions in-case we're building on windows
WORKDIR /home/dev
RUN rm -rf .profile && \
    chown dev:dev welcome.sh .bash_profile .bash_prompt .bashrc .inputrc

#
# Anything below this point is attached to the `dev` user
#
USER dev
WORKDIR /home/dev
ENV HOME="/home/dev" GOROOT="/usr/local/go" GOPATH="$HOME/go" PATH="$HOME/.local/bin:$GOPATH/bin:$GOROOT/bin:$PATH"

# User apps / Create volume dir stubs
RUN git config --global user.name $name && \ 
    git config --global user.email $email && \
    pip install awscli --upgrade --user && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash && \
    source ~/.bashrc && \
    nvm install --lts && \
    echo "source $HOME/welcome.sh" >> $HOME/.bash_profile && \
    mkdir -p $HOME/workdir/go $HOME/credentials/ssh && \
    ln -s $HOME/credentials/ssh $HOME/.ssh

VOLUME ["/home/dev/credentials", "/home/dev/workdir"]

WORKDIR /home/dev
CMD /bin/bash
