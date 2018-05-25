require 'serverspec'

set :backend, :exec

puts
puts '================================'
puts %x(ansible --version)
puts '================================'

%w[
  bind9
  cron
].each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

%w[
  test.local
  hello.local
  disabled.local
].each do |zone|
  describe file("/etc/bind/zones/#{zone}") do
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by 'bind' }
    it { should be_grouped_into 'bind' }
  end

  describe file("/etc/bind/zones/#{zone}/db") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

describe file('/etc/bind/zones/test.local/db.signed') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file('/etc/bind/zones/absent.local') do
  it { should_not exist }
end

describe file('/etc/bind/named.conf.local') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should contain '4.2.2.4' }
  it { should contain 'inline-signing yes;' }
end

describe file('/etc/bind/named.conf.options') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should contain 'listen-on { any; };' }
  it { should contain 'listen-on-v6 { none; };' }
  it { should contain 'server-id "1";' }
end

describe service('bind9') do
  it { should be_enabled }
  it { should be_running.under('systemd') }
end

describe port(53) do
  it { should be_listening.with('tcp') }
  it { should be_listening.with('udp') }
end

describe command('dig +nocmd +noall +answer +dnssec hello.test.local @127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain(/hello\.test\.local\.\s+300\s+IN\s+A\s+1\.2\.3\.4/) }
  its(:stdout) { should contain(/hello\.test\.local\.\s+300\s+IN\s+RRSIG\s+A /) }
end

describe command('dig +nocmd +noall +answer -t mx test.local @127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain(/test\.local\.\s+3600\s+IN\s+MX\s+20 mail\.test\.local\./) }
end

describe command('dig +nocmd +noall +answer -t srv hello.test.local @127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain(/hello\.test\.local\.\s+3600\s+IN\s+SRV\s+0\s+5\s+80\s+www\.test\.local\.$/) }
end

describe command('dig +nocmd +noall +answer -t caa hello.test.local @127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain(/hello\.test\.local\.\s+3600\s+IN\s+CAA\s+0 issue "letsencrypt\.org"/) }
  its(:stdout) { should contain(/hello\.test\.local\.\s+3600\s+IN\s+CAA\s+0 iodef "mailto:root@test\.local"/) }
end

describe command('dig +nocmd +noall +answer hello.hello.local @127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain(/hello\.hello\.local\.\s+3600\s+IN\s+A\s+4\.3\.2\.1/) }
end

describe command('dig +nocmd +noall +answer -t txt hello.local @127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('"0L4M99yv8ZLptmS2GP6goHXZgTdFIyYCdfziQgoENcloUI3KshDscsoh6H6I2LA"') }
end
