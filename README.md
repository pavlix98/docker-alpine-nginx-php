# Powerful and extra small docker image for your PHP apps.

You can go to [Docker hub repository](https://hub.docker.com/r/misaon/alpine-nginx-php/ "Docker hub repository").

### Features
- Size of image is only **42MB**!
- **100% compatible** with Nette Framework (tested witch Nette Requirements Checker tool).
- Tweaked for **maximum performance**.
- Optimazed for **better security**.
- Very **lightweight** version.
- **Fixed** problematic **ICONV extension**.
- Much more...

### Included
- **Alpine Linux 3.8**
- **PHP 7.2.x**
- **Nginx 1.14.x**
- **Supervisor proccess manager**.

#### PHP modules
- **Core** modules (Nette Framework required)
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

Only thing which you must do is turn on Docker and run this command:

```bash
$ docker run -p 80:80 -v <your-nette-project-dir>:/var/www/html misaon/alpine-nginx-php:php72
```

## Nette Requirements Checker tool result

![alt Nette Requirements Checker tool result](https://preview.ibb.co/kyVCpc/nette_framework_checker.png)
