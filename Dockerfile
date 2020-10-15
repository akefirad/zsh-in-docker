# This is only used for developing the zsh-in-docker script, but can be used as an example.

FROM debian:latest

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo wget nano \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME

# RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.1/zsh-in-docker.sh)" -- \
COPY zsh-in-docker.sh /tmp
RUN /tmp/zsh-in-docker.sh \
    -p git \
    -p kubectl

COPY dot.p10k.zsh /home/$USERNAME/.p10k.zsh
COPY dot.zshrc /home/$USERNAME/.zshrc

RUN sudo curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.19.3/bin/linux/amd64/kubectl" \
    && sudo mv kubectl /usr/local/bin/kubectl \
    && sudo chmod +x /usr/local/bin/kubectl

COPY dot.kube-config /home/$USERNAME/.kube/config

RUN sudo curl -LO "https://raw.githubusercontent.com/DannyBen/alf/master/alf" \
    && sudo mv alf /usr/local/bin/alf \
    && sudo chmod +x /usr/local/bin/alf \
    && echo "/home/$USERNAME/alf-conf" > /home/$USERNAME/.alfrc

COPY alf-conf /home/$USERNAME/alf-conf/alf.conf

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
