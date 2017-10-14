require 'serverspec'

set :backend, :exec

%w[
  bind9
  cron
].each do |package|
  describe package(package) do
    it { should be_installed }
  end
end

%w[
  db.test.local
  db.test.local.signed
  db.hello.local
].each do |file|
  describe file("/etc/bind/zones/#{file}") do
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

describe file('/etc/bind/named.conf.local') do
  it { should be_file }
  it { should be_mode 644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  it { should contain '4.2.2.4' }
end

describe command('host hello.test.local 127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('1.2.3.4') }
end

describe command('host hello.hello.local 127.0.0.1') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should contain('4.3.2.1') }
end
