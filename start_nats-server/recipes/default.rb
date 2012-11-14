#
# Cookbook Name:: nats
# Recipe:: default
#
# Copyright 2011, VMware
#
node.set[:deployment][:name] = "nats_server"
node.set[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", node[:deployment][:name])
node.set[:deployment][:config_path] = File.join(node[:deployment][:home], "config")
node.set[:deployment][:info_file] = File.join(node[:deployment][:config_path], "deployment_info.json")
node.set[:nats_server][:host]= node[:ipaddress].to_s 


nats_config_dir = File.join(node[:deployment][:config_path], "nats_server")
node[:nats_server][:config] = File.join(nats_config_dir, "nats_server.yml")


template node[:nats_server][:config] do
#  path node[:nats_server][:config]
  source "nats_server.yml.erb"
  owner node[:deployment][:user]
  mode 0644
#  notifies :restart, "service[nats_server]"
  action :create 
end

bash "start_nats_server "+  " #{node[:deployment][:name]} " do
  user "root" 
  cwd "/tmp"
  ignore_failure true 
  code <<-EOH
  nohup /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} restart
  EOH
end

service "nats_server" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :restart ]
end

bash "start_nats_server "+  " #{node[:deployment][:name]} " do
  user "root"
  cwd "/tmp"
  ignore_failure true
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n #{node[:deployment][:name]} status 
  EOH
end

