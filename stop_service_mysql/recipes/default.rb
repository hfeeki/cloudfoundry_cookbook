
bash "start MySQL Service"   do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n dea_mysql stop 
  EOH
end
