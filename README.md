# Docker AppEngine PHP image for developing

Docker AppEngine Nginx+PHP 7.2 image for developing with sudo and Xdebug.

Prepared for Symfony applications.

## Install

    composer require softspring/docker-nginx-php-appengine-dev --no-scripts
    
## Configure docker-compose.yaml

    version: '3'
    
    services:
      nginx:
        container_name: container_name
        build:
            context: vendor/softspring/docker-nginx-php-appengine-dev
            args:
              USER_NAME: <USERNAME>
              UID: <UID>
        user: <USERNAME>
        environment:
          XDEBUG_ENABLED: 1
          XDEBUG_REMOTE_HOST: 172.18.0.1
          XDEBUG_REMOTE_PORT: 9000
          XDEBUG_IDEKEY: PHPSTORM
          USER_NAME: <USERNAME>
          DOCUMENT_ROOT: "/app/public"
          SKIP_LOCKDOWN_DOCUMENT_ROOT: "true"
          COMPOSER_FLAGS: "--no-scripts --prefer-dist"
          COMPOSER_HOME: /home/<USERNAME>/.composer
        volumes:
         - .:/app
         - ~/.composer:/home/<USERNAME>/.composer

