# Ansible role: Bind
[![Version](https://img.shields.io/badge/latest_version-1.2.1-green.svg)](https://github.com/nishiki/ansible-role-bind/releases)
[![Build Status](https://travis-ci.org/nishiki/ansible-role-bind.svg?branch=master)](https://travis-ci.org/nishiki/ansible-role-bind)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](https://github.com/nishiki/ansible-role-bind/blob/master/LICENSE)

Install and configure bind with dnssec

## Requirements

* Ansible >= 2.4
* bind version >= 9.8
* Debian Stretch

## Role variables

* `bind_role` - the role `master` or `slave`, don't generate dnssec key on `slave`
* `bind_options` - hash general bind options
* `bind_zones` - the dns zones
* `bind_zones_subset` array to use in `extra-vars` with the list zones to update
* `bind_listen_ipv4` - enable or disable ip v4 support (default: true)
* `bind_listen_ipv6` - enable or disable ip v6 support (default: true)

## How to use

* `host_vars/dns-master`
 ```
 bind_role: master
 ```

* `host_vars/dns-slave`
 ```
 bind_role: slave
 ```

* `group_vars/dns-server`
 ```
bind_listen_ipv6: true
bind_listen_ipv4: true
bind_options:
  server-id: '"1"'

bind_zones:
  test.local:
    ns_primary: ns1.test.local
    mail: root@test.local
    serial: 2017092202
    dnssec: yes
    options:
      key-directory: '"/etc/bind/keys"'
      auto-dnssec: maintain
      inline-signing: yes
    records:
      - { name: '@', type: ns, value: localhost. }
      - { name: hello, type: a, ttl: 5m, value: 1.2.3.4 }
      - { name: hello, type: caa, flag: 0, tag: issue, value: letsencrypt.org }
      - { name: hello, type: srv, priority: 0, weight: 5, port: 80, value: www }
  hello.local:
    ns_primary: ns1.hello.local
    mail: root@hello.local
    serial: 2017092201
    dnssec: no
    state: disabled
    records:
      - { name: '@', type: ns, value: localhost. }
      - { name: hello, type: a, value: 4.3.2.1 }
 ```

* playbook

```
- hosts: dns-server
  roles:
    - bind 
```

## Development
### Tests with docker

* install [docker](https://docs.docker.com/engine/installation/)
* install ruby
* install bundler `gem install bundler`
* install dependencies `bundle install`
* run the tests `kitchen test`

## License

```
Copyright (c) 2017 Adrien Waksberg

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
