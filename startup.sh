#!/bin/bash -xe

export TERM=xterm

DEFAULT_PHP_VERSION="7.2"

if [ -f ${APP_DIR}/composer.json ]; then
    if [ -n "${DETECTED_PHP_VERSION}" ]; then
        PHP_VERSION="${DETECTED_PHP_VERSION}"
    else
        echo "Detecting PHP version..."
        # Extract php version from the composer.json.
        PHP_VERSION=`php /build-scripts/detect_php_version.php ${APP_DIR}/composer.json`

        if [ "${PHP_VERSION}" == "exact" ]; then
            cat<<EOF
An exact PHP version was specified in composer.json. Please pin your PHP version to a minor version such as '7.2.*'.
EOF
            exit 1
        elif [ "${PHP_VERSION}" != "5.6" ] && [ "${PHP_VERSION}" != "7.0" ] && [ "${PHP_VERSION}" != "7.1" ] && [ "${PHP_VERSION}" != "7.2" ]; then
            cat<<EOF
There is no PHP runtime version specified in composer.json, or we don't support the version you specified. Google App Engine uses the latest 7.2.x version. We recommend pinning your PHP version by running:
composer require php 7.2.* (replace it with your desired minor version)
Using PHP version 7.2.x...
EOF
            PHP_VERSION=${DEFAULT_PHP_VERSION}
        fi

        if [ "${PHP_VERSION}" == "5.6" ]; then
            sudo apt-get -y update
            sudo -E /bin/bash /build-scripts/install_php56.sh
            sudo apt-get remove -y gcp-php71
        fi

        if [ "${PHP_VERSION}" == "7.0" ]; then
            sudo apt-get -y update
            sudo -E /bin/bash /build-scripts/install_php70.sh
            sudo apt-get remove -y gcp-php71
        fi
        if [ "${PHP_VERSION}" == "7.2" ]; then
            sudo apt-get -y update
            sudo -E /bin/bash /build-scripts/install_php72.sh
            sudo apt-get remove -y gcp-php71
        fi
    fi

    echo "Using PHP version: ${PHP_VERSION}"

    echo "Install PHP extensions..."
    # Auto install extensions
    sudo -E php -d auto_prepend_file='' /build-scripts/install_extensions.php ${APP_DIR}/composer.json ${PHP_DIR}/lib/conf.d/extensions.ini ${PHP_VERSION}
    sudo -E /bin/bash /build-scripts/apt-cleanup.sh
fi

if [ "$XDEBUG_ENABLED" = "1" ]
then
    echo "Enabling Xdebug for PHP 7.2"
    sudo -E bash -c 'echo "zend_extension=xdebug.so" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.default_enable=1" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.remote_enable=1" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.remote_autostart=1" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.remote_connect_back=1" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT" >> $PHP_DIR/lib/php.ini'
    sudo -E bash -c 'echo "xdebug.idekey=$XDEBUG_IDEKEY" >> $PHP_DIR/lib/php.ini'
fi

echo "Running composer..."
# Run Composer.
if [ -z "${COMPOSER_FLAGS}" ]; then
    COMPOSER_FLAGS='--no-scripts --prefer-dist'
fi
cd ${APP_DIR} && \
    php -d auto_prepend_file='' /usr/local/bin/composer \
      install \
      --optimize-autoloader \
      --no-interaction \
      --no-ansi \
      --no-progress \
      ${COMPOSER_FLAGS}


if [ "$STARTUP_SCRIPT" ]
then
    bash $STARTUP_SCRIPT
fi

# -E preserves environment variables
sudo -E /usr/bin/supervisord -c /etc/supervisor/supervisord.conf