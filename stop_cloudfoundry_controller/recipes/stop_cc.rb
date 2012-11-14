bash "stop_CC_HM" do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n cloud_controller-health_manager stop
  EOH
end
