# Ansible role: Bind
[![Version](https://img.shields.io/badge/latest_version-0.1.0-green.svg)](https://github.com/nishiki/ansible-role-bind/releases)
[![Build Status](https://travis-ci.org/nishiki/ansible-role-bind.svg?branch=master)](https://travis-ci.org/nishiki/ansible-role-bind)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://github.com/nishiki/ansible-role-bind/blob/master/LICENSE)

Install and configure bind with dnssec

## Requirements

None

## Role variables

 * `bind_role` - the role `master` or `slave`, don't generate dnssec key on `slave`
 * `bind_zones` - the dns zones

## How to use

```
- hosts: dns-server
  vars:
    bind_role: master
    bind_zones:
      test.local:
        ns_primary: ns1.test.local
        mail: root@test.local
        serial: 2017092202
        dnssec: yes
        entries:
          - { name: '@', type: ns, value: localhost. }
          - { name: hello, type: a, value: 1.2.3.4 }
      hello.local:
        ns_primary: ns1.hello.local
        mail: root@hello.local
        serial: 2017092201
        dnssec: no
        entries:
          - { name: '@', type: ns, value: localhost. }
          - { name: hello, type: a, value: 4.3.2.1 }
  roles:
    - bind 
```

## Development
### Tests with docker

  * install [docker](https://docs.docker.com/engine/installation/)
  * install dependencies `bundle install`
  * run the tests `rake`
