from alpine/openssl as certr
workdir certs
run openssl req -x509 -newkey rsa:2048 -sha256 -days 36500 -nodes -keyout key.pem -out cert.pem -subj '/CN=ret' && cp cert.pem cacert.pem


# run mkdir -p /storage && chmod 777 /storage

# copy --from=builder /_build/turkey/rel/ret/ .

# RUN apk update && apk add --no-cache bash openssl-dev openssl jq libstdc++ coreutils
###vborja
# FROM vborja/asdf-alpine

# start erlang install
# COPY erlang .asdf/toolset/erlang/
# USER root
# RUN bash .asdf/toolset/erlang/build-deps
# USER asdf
# RUN asdf-install-toolset erlang

# # install elixir tool if needed
# COPY elixir .asdf/toolset/elixir/
# USER root
# RUN bash .asdf/toolset/elixir/build-deps
# USER asdf
# RUN asdf-install-toolset elixir
###
###ubuntu
## Add required deps
# FROM ubuntu
# RUN apt update
# RUN apt install -y curl git
# RUN apt install -y wget build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk libsctp-dev lksctp-tools
# # Add WKHTMLTOPDF
# RUN wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.4/wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
# RUN tar xvf wkhtmltox-0.12.4_linux-generic-amd64.tar.xz
# RUN mv wkhtmltox/bin/wkhtmlto* /usr/bin/
# RUN rm -rf wkhtmltox
# ## Add Asdf
# RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf
# RUN cd ~/.asdf && git checkout "$(git describe --abbrev=0 --tags)"
# ENV PATH /root/.asdf/bin:/root/.asdf/shims:${PATH}
# RUN /bin/bash -c "source ~/.bashrc"
# RUN /bin/bash -c "asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git"
# ENV KERL_CONFIGURE_OPTIONS --disable-silent-rules --without-javac --enable-shared-zlib --enable-dynamic-ssl-lib --enable-hipe --enable-sctp --enable-smp-support --enable-threads --enable-kernel-poll --enable-wx --disable-debug --without-javac --enable-darwin-64bit
# RUN /bin/bash -c "asdf install erlang 23.3"
# RUN apt-get install -y locales && locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8
# RUN /bin/bash -c "asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git"
# RUN /bin/bash -c "asdf global erlang 1.12.3"

#test archecture
# FROM centos
# workdir /reticulum

# RUN yum upgrade -y && \
#     yum updateinfo -y && \
#     yum install -y \
#       ca-certificates \
#       && \
#     yum clean all && \
#     update-ca-trust enable && \
#     update-ca-trust extract

###alpine
FROM --platform=linux/arm64 arm64v8/alpine
copy --from=certr /certs ./certs
workdir /reticulum
COPY . .
RUN apk upgrade \
    && apk add --no-cache bash nodejs yarn git build-base postgresql-client curl perl automake autoconf openssl-dev ncurses-dev libxslt libxml2-utils inotify-tools nano
RUN export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" && \
    echo "PATH=$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH" >> /root/.profile
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf \
    && echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc \
    && echo '. $HOME/.asdf/completions/asdf.bash' >> $HOME/.bashrc \
    && echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile
RUN curl -O https://raw.githubusercontent.com/kerl/kerl/master/kerl && \
    chmod a+x kerl && \
    bash -c "./kerl build 23.3 23.3 && \
            ./kerl install 23.3 ~/kerl/23.3 && \
            source ~/kerl/23.3/activate"
# RUN echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
# RUN echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc
# USER asdf 
# ENV PATH="${PATH}:/asdf/.asdf/shims:/asdf/.asdf/bin"
# RUN sudo su 
# RUN asdf
RUN bash -ic "asdf plugin-add elixir && \
            asdf install elixir 1.12.3 && \
            asdf global elixir 1.12.3"

RUN mv ./turnserver.conf ../etc

# RUN bash -ic "asdf plugin-add erlang && \
#             asdf plugin-add elixir && \
#             export KERL_CONFIGURE_OPTIONS='--without-javac --with-ssl=$(brew --prefix openssl@1.1)' && \
#             asdf install erlang 23.3 && \
#             asdf install elixir 1.12.3 && \
#             asdf global erlang 23.3 && \
#             asdf global elixir 1.12.3"

# FROM elixir:1.12.3-alpine as builder
# SHELL ["/bin/bash", "-c"] 
# RUN uname -a
# # RUN apt-get
# RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
#     echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && \
#     echo '. $HOME/.asdf/completions/asdf.bash' >> $HOME/.bashrc && \
#     echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile
# RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0
# RUN chmod +x ~/.asdf/asdf.sh ~/.asdf/completions/asdf.bash
# RUN echo ". $HOME/.asdf/asdf.sh" >> ~/.bashrc
# RUN echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.bashrc
# ENV PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"
# ENV PATH="$HOME/.asdf:$PATH"
# RUN echo -e '\nsource $HOME/.asdf/asdf.sh' >> ~/.bashrc
# RUN source ~/.bashrc
# RUN bash -c 'echo -e which asdf'
# RUN source ~/.bashrc && \
#     asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git && \
#     asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git && \
#     uname -a && \
#     # compgen -c && \
#     # pacman && \
#     export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac" && \
#     # export KERL_CONFIGURE_OPTIONS='--without-javac --with-ssl=$(brew --prefix openssl@1.1)' && \
#     asdf install erlang 23.3 && \
#     asdf install elixir 1.12.3 && \
#     asdf global erlang 23.3 && \
#     asdf global elixir 1.12.3
#end apline
# RUN asdf plugin-add python


# copy . .
# RUN mix local.hex --force && mix local.rebar --force && mix deps.get
# run mix deps.clean mime --build && rm -rf _build && mix compile
# # run MIX_ENV=turkey mix distillery.release
# # run postgres -D /usr/local/var/postgres
# # RUN mix ecto.create 
# # RUN mix ecto.migrate 

# RUN 
EXPOSE 4000
# CMD ["bash", "./scripts/docker/entrypoint.sh"]
CMD ["bash"]
# RUN yarn
# RUN mix deps.get
# RUN mix ecto.create 
# RUN mix ecto.migrate 
# RUN mix phx.server
# copy scripts/docker/run.sh /run.sh
# cmd /bin/bash /run.sh
