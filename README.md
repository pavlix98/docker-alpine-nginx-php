# Powerful and extra small docker image for your PHP apps.

You can go to [Docker hub repository](https://hub.docker.com/r/misaon/docker-alpine-nginx-php/tags/ "Docker hub repository").

### Features
- Size of image is only **43MB**!
- **100% compatible** with **Symfony** and **Nette** Framework (tested witch Nette Requirements Checker tool).
- Tweaked for **maximum performance**.
- Optimazed for **better security**.
- Very **lightweight** version.
- **Fixed** problematic **ICONV extension**.
- Much more...

### Included
- **Alpine Linux 3.8**
- **PHP 7.2.x**
- **Nginx 1.14.x**
- **Supervisor process manager**.

#### PHP modules
- **Core** modules
  - fpm
  - opcache
  - session 
  - intl 
  - mbstring 
  - json 
  - fileinfo 
  - tokenizer 
  - memcached 
  - curl 
  - gd 
  - pdo_sqlite 
  - pdo_mysql
  - mysqli
- **Other** modules
  - xml
  - simplexml
  - xmlwriter
  - dom
  - bcmath
  - ctype 
  - calendar 
  - zip
  - ssh2

## Lets start!

Only thing which you must do is turn on Docker and run one of these commands:

### Nette

```bash
$ docker run -p 80:80 -v "<your-nette-project-dir>:/var/www/html" misaon/docker-alpine-nginx-php:php72
```

### Symfony

```bash
$ docker run -p 80:80 -v "<your-symfony-project-dir>:/var/www/html" -e "NGINX_INDEX_FILE=app.php" -e "NGINX_DOCUMENT_ROOT=web" misaon/docker-alpine-nginx-php:php72
```