# php85-alpine

> [!IMPORTANT]  
> **PHP 8.5 has not been released yet, so some functionality may be missing due to pending compatibility issues. Currently `imagick` and `xdebug` are not included. For testing purposes only.** 
 
## What is this?

This is a custom build based on PHP 8.5's Alpine docker image, with changes to make Laravel back-end testing easily possible.

This image includes:

- PHP 8.5 with `bcmath`, `exif`, `gd`, `intl`, `mysqli`, `pcntl`, `pdo_mysql`, `pdo_pgsql`, `pgsql`, `sodium`, `zip`, `xdebug`, and `imagick` installed.
- Packages: `curl`, `git`, `sqlite`, `nano`, `ncdu`, `nodejs`, `npm`, `openssh-client`.
- `opcache` now ships with PHP by default, it is no longer a separate extension.
- The latest version of Composer (at the time of the build) also comes pre-installed in `/usr/local/bin/composer`.


For the latest list of inclusions, see the [Dockerfile](./Dockerfile).

## Quick start

### Docker

In order to build and then test the container:

    docker buildx build . --platform linux/amd64 -t nicoverbruggen/php84-alpine \
    && docker run -it nicoverbruggen/php85-alpine sh

You may omit the `--platform` flag if you wish to build a container for your own architecture, but there may be issues with dependencies.

### Podman

    podman build . -t nicoverbruggen/php85-alpine \
    && podman run -it nicoverbruggen/php85-alpine sh

## Automatic builds

The automatically build the container and have it pushed, you must:

* Tag the commit you wish to build
* Create a new release with said tag

The Docker action will automatically build the release and push it under that tag to Docker Hub.

## Example usage

### GitHub Actions / Gitea Actions

`/.github/workflows/run-tests.yml`
```
name: Test Suite
on:
  push:
    branches:
      - main
jobs:
  test-suite:
    runs-on: ubuntu-latest
    container:
      image: nicoverbruggen/php85-alpine:latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4

      - name: Prepare Environment
        run: |
          cp .env.ci .env
          cp .env.ci .env.testing

      - name: Install Dependencies
        run: |
          composer install
          npm install --silent
          npm run production

      - name: Run Tests
        run: |
          touch ./database/tests.sqlite
          vendor/bin/pest --coverage --colors=never
```

### GitLab CI

`.gitlab-ci.yml`
```
tests:
  only:
    - main
  image: nicoverbruggen/php85-alpine:latest
  script:
    - cp .env.ci .env
    - cp .env.ci .env.testing
    - composer install
    - npm install --silent
    - npm run production
    - touch ./database/tests.sqlite
    - vendor/bin/pest --coverage --colors=never
```

## Where can I find it?

You can find the image on Docker Hub here: https://hub.docker.com/r/nicoverbruggen/php85-alpine.