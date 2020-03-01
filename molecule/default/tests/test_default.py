import os, re
import testinfra.utils.ansible_runner

def test_packages(host):
  for package_name in ['bind9', 'cron']:
    package = host.package(package_name)
    assert package.is_installed

def test_cron_file(host):
  config = host.file('/etc/cron.weekly/dnssec')
  assert config.exists
  assert config.is_file
  assert config.user == 'root'
  assert config.group == 'root'
  assert config.mode == 0o700
  assert config.contains('test.local')

def test_local_file(host):
  config = host.file('/etc/bind/named.conf.local')
  assert config.exists
  assert config.is_file
  assert config.user == 'root'
  assert config.group == 'root'
  assert config.mode == 0o644
  assert config.contains('4.2.2.4')
  assert config.contains('inline-signing yes;')

def test_options_file(host):
  config = host.file('/etc/bind/named.conf.options')
  assert config.exists
  assert config.is_file
  assert config.user == 'root'
  assert config.group == 'root'
  assert config.mode == 0o644
  assert config.contains('listen-on { any; };')
  assert config.contains('listen-on-v6 { none; };')
  assert config.contains('server-id "1";')

def test_db_file(host):
  for zone in ['test.local', 'hello.local', 'disabled.local']:
    directory = host.file('/etc/bind/zones/%s' % (zone))
    assert directory.exists
    assert directory.is_directory
    assert directory.user == 'bind'
    assert directory.group == 'bind'
    assert directory.mode == 0o755

    config = host.file('/etc/bind/zones/%s/db' % (zone))
    assert config.exists
    assert config.is_file
    assert config.user == 'root'
    assert config.group == 'root'
    assert config.mode == 0o644

def test_db_signed_file(host):
  config = host.file('/etc/bind/zones/test.local/db.signed')
  assert config.exists
  assert config.is_file
  assert config.user == 'root'
  assert config.group == 'root'
  assert config.mode == 0o644

def test_service(host):
  service = host.service('bind9')
  assert service.is_running
  assert service.is_enabled

def test_socket(host):
  socket = host.socket('tcp://127.0.0.1:53')
  assert socket.is_listening

  socket = host.socket('udp://127.0.0.1:53')
  assert socket.is_listening

def test_dns_a(host):
  result = host.check_output('dig +nocmd +noall +answer hello.hello.local @127.0.0.1')
  assert re.search(r'hello\.hello\.local\.\s+3600\s+IN\s+A\s+4\.3\.2\.1', result)

def test_dns_a_signed(host):
  result = host.check_output('dig +nocmd +noall +answer +dnssec hello.test.local @127.0.0.1')
  assert re.search(r'hello\.test\.local\.\s+300\s+IN\s+A\s+1\.2\.3\.4', result)
  assert re.search(r'hello\.test\.local\.\s+300\s+IN\s+RRSIG\s+A ', result)

def test_dns_mx(host):
  result = host.check_output('dig +nocmd +noall +answer -t mx test.local @127.0.0.1')
  assert re.search(r'test\.local\.\s+3600\s+IN\s+MX\s+20 mail\.test\.local\.', result)

def test_dns_srv(host):
  result = host.check_output('dig +nocmd +noall +answer -t srv hello.test.local @127.0.0.1')
  assert re.search(r'hello\.test\.local\.\s+3600\s+IN\s+SRV\s+0\s+5\s+80\s+www\.test\.local\.$', result)

def test_dns_caa(host):
  result = host.check_output('dig +nocmd +noall +answer -t caa hello.test.local @127.0.0.1')
  assert re.search(r'hello\.test\.local\.\s+3600\s+IN\s+CAA\s+0 issue "letsencrypt\.org', result)
  assert re.search(r'hello\.test\.local\.\s+3600\s+IN\s+CAA\s+0 iodef "mailto:root@test\.local"', result)

def test_dns_dnssec(host):
  result = host.check_output('dig +nocmd +noall +answer -t txt hello.local @127.0.0.1')
  assert re.search(r'"0L4M99yv8ZLptmS2GP6goHXZgTdFIyYCdfziQgoENcloUI3KshDscsoh6H6I2LA"', result)
