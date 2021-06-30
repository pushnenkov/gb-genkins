FROM php:7.4-cli
COPY ./vendor /usr/src/myapp/vendor
COPY ./script.php /usr/src/myapp/script.php
WORKDIR /usr/src/myapp
CMD [ "php", "./script.php" ]