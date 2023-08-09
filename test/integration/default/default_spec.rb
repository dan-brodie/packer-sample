require 'yaml'

if os.windows?
  vars = YAML.load(File.read('ansible/playbooks/vars/windows.yaml'))
  describe windows_feature('Windows-Defender') do
    it { should_not be_installed }
  end
else
  vars = YAML.load(File.read('ansible/playbooks/vars/linux.yaml'))
  vars['os_packages_list'].each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end
