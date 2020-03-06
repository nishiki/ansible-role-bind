# CHANGELOG

This project adheres to [Semantic Versioning](http://semver.org/).
Which is based on [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]

### Changed

- test: replace kitchen to molecule
- feat: use label in loop_control

## v1.3.0 (2020-02-12)
- feat: add support debian 10
- break: change with_items to loop
- break: remove support ansible < 2.7
- test: add test with ansible 2.7
- test: add ansible-lint

## v1.2.2 (2018-09-07)
- fix: remove a bug in dnssec cron

## v1.2.1 (2018-08-08)
- fix: add dnssec cron

## v1.2.0 (2018-07-09)
- feat: add bind_zones_subnet for extra-vars 
- fix: disable allow transfer if isn't set

## v1.1.0 (2018-03-31)
- feat: remove old zone files
- feat: test the playbook with ansible 2.5

## v1.0.0 (2018-03-21)
- first version
