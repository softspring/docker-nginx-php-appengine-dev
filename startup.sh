#!/bin/bash -x

export TERM=xterm

if [ "$XDEBUG_ENABLED" = "1" ]
then
    sudo bash -c 'echo "zend_extension=xdebug.so" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.default_enable=1" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.remote_enable=1" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.remote_autostart=1" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.remote_connect_back=1" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT" >> /opt/php72/lib/php.ini'
    sudo bash -c 'echo "xdebug.idekey=$XDEBUG_IDEKEY" >> /opt/php72/lib/php.ini'
fi

/opt/php72/bin/php /usr/local/bin/composer install --no-progress --dev

# custom startup-script.sh

if [ "$STARTUP_SCRIPT" ]
then
    bash $STARTUP_SCRIPT
fi

# -E preserves environment variables
sudo -E /usr/bin/supervisord -c /etc/supervisor/supervisord.conf