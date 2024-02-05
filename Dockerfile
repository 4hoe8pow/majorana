FROM archlinux/archlinux:base-devel
LABEL maintainer="Yu Tokunaga <tokunaga@agni.ninja>"

# Add meta data 
ARG UID=1000
ARG GID=1000
ARG USERNAME=hoe
ARG LOCATE=JP
ARG COUNTRY=ja_JP
ARG ENCODE=UTF-8
ENV TZ=Asia/Tokyo

# Install git
RUN pacman -Syu --needed --noconfirm git

# makepkg user(hoe) and workdir
ARG user=hoe
RUN useradd --system --create-home $user \
  && echo "$user ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user
USER $user
WORKDIR /home/$user

# Install yay
RUN git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -sri --needed --noconfirm \
  && cd \
  # Clean up
  && rm -rf .cache yay

# update yay
RUN yay -Syu

# Fish
RUN yay -S --needed --noconfirm fish
RUN sudo chsh $user -s $(which fish)
SHELL ["fish", "--command"]

# Fisherman
RUN curl -Lo ~/.config/fish/functions/fisher.fish --create-dirs https://git.io/fisher
RUN fisher install oh-my-fish/theme-bobthefish

# fzf
RUN sudo pacman -S --needed --noconfirm fzf
RUN fisher install jethrokuan/z

# Neovim
RUN sudo pacman -S --needed --noconfirm neovim
RUN export XDG_CONFIG_HOME=~/.config

# remove cache
RUN sudo pacman -Scc

ENTRYPOINT [ "fish" ]
