bash "stop " + node['dea']['component_name']  do
  user "root"
  cwd "/tmp"
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node['dea']['component_name']} stop
  EOH
end



