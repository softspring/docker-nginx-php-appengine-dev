FROM gcr.io/google-appengine/php72:latest

RUN apt-get update -yq && apt-get upgrade -yq && \
    apt-get install -yq sudo autoconf gcc make

RUN /opt/php72/bin/pecl install xdebug

COPY entrypoint.sh /entrypoint.sh

ARG USER_NAME
ARG UID

RUN echo $USER_NAME && \
    useradd --uid $UID -g users $USER_NAME && \
    mkdir -p /home/$USER_NAME && \
    chown $USER_NAME /home/$USER_NAME && \
    chgrp users /home/$USER_NAME && \
    echo "$USER_NAME ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN chgrp -R users /opt/composer
RUN chmod g+w -R /opt/composer

ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash", "/app/vendor/softspring/docker-php72-appengine-dev/startup.sh"]
