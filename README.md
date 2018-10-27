# Docker PHP 7.2 image for developing AppEngine based

This image is prepared for developing PHP 7.2 applications based on AppEngine image.

Provides Xdebug and is configured to execute commands as local user to prevent permission problems.

## Install

    composer require softspring/docker-php72-appengine-dev --no-scripts --dev
    
## Configure docker-compose.yaml

    version: '3'
    
    services:
      php:
        container_name: container_name
        build:
            context: vendor/softspring/docker-php72-appengine-dev
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
        volumes:
         - .:/app

## Setup a startup script

Create a startup script with your required commands:

    # startup_script.sh
    #!/bin/bash
    
    php bin/console cache:clear --env=dev
    php bin/console doctrine:migrations:migrate -n --env=dev
    

Configure STARTUP_SCRIPT environment variable to run it.
    
    version: '3'
    
    services:
      php:
        environment:
          STARTUP_SCRIPT: /app/startup_script.sh


## Share composer cache

    version: '3'
    
    services:
      php:
        environment:
          COMPOSER_HOME: /home/<USERNAME>/.composer
        volumes:
         - ~/.composer:/home/<USERNAME>/.composer