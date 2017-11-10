# php7-node-composer
This Docker image contains the PHP, Composer, Node.js and most common packages necessary for building php apps in a CI tool like GitLab CI.

Version 1.0.12
* PHP 7.1.11
* Composer 1.5.2
* Node.js 6.11.0
* Yarn 1.3.2
* npm 3.10.10
* phantomjs 2.0.0
* webpack 2.7.0
* phpunit 6.4.4
* phpdoc 2.9.0
* ...

```
docker run -it --rm unitedclassifiedsapps/php7-node-composer
```

A `.gitlab-ci.yml` with caching of your project's dependencies would look like this:

```
image: unitedclassifiedsapps/php7-node-composer:1.0.13

cache:
  paths:
    - .yarn

stages:
    - test
    - build-package
    - after-build

lint:
    stage: test
    tags:
        - docker
    except:
        - tags
    script:
        - parallel-lint --short --exclude vendor .
        - var-dump-check --exclude vendor --tracy --no-colors --extensions php,phtml .
        - composer --ansi --no-check-publish validate
        - jsdoc -c ./config/jsdoc.json
        - phpdoc -c config/phpdoc.xml
        - phpunit -c tests/phpunit/bootstrap/phpunit-gitlab-ci.xml --coverage-text=docs/phpunit/index.html --strict-coverage


build:
    stage: build-package
    tags:
        - docker
    before_script:
        - composer --ansi --no-dev --optimize-autoloader install
        - yarn config set yarn-offline-mirror .npm-packages-offline-cache
        - yarn config set cache-folder .yarn
        - yarn run deploy
    except:
        - tags
    script:
        -
            tar -pczf ./${BUILD_PACKAGE_NAME}.tar.gz ./*
                --exclude=./${BUILD_PACKAGE_NAME}.tar.gz
    artifacts:
        name: "${CI_JOB_STAGE}_${CI_COMMIT_REF_NAME}"
        expire_in: 1 day
        paths:
            - ${BUILD_PACKAGE_NAME}.tar.gz


```