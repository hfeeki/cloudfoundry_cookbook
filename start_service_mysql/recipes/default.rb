#
# Cookbook Name:: start_service_mysql
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
node.set[:deployment][:name] = "mysql_service"
node.set[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", node[:deployment][:name])
node.set[:deployment][:config_path] = File.join(node[:deployment][:home], "config")
node.set[:deployment][:info_file] = File.join(node[:deployment][:config_path], "deployment_info.json")

Chef::Log.warn("default[:deployment][:name] = " + node[:deployment][:name].to_s)
Chef::Log.warn(" [:deployment][:config_path]  = " + node[:deployment][:config_path].to_s)


if Chef::Config[:solo]
        Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
        cf_id_node = node['cf_session']['cf_id']
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
       while m_nodes_nats.count < 1
        Chef::Log.warn("Waiting for nats .... I am sleeping 7 sec")
        sleep 7
        m_nodes_nats = search(:node, "role:cloudfoundry_nats_server_ng AND cf_id:#{cf_id_node}")
       end
       m_nodes_nats.each {|k|
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then
              node.set['nats_server']['user']= k['nats_server']['user']
              node.set['nats_server']['password']= k['nats_server']['password']
              node.set['nats_server']['host']= k['ipaddress']
              node.set['nats_server']['port']= k['nats_server']['port']
        end
       }


        cf_id_node = node['cf_session']['cf_id']
        m_nodes_cc = search(:node, "role:cloudfoundry_controller_nv AND cf_id:#{cf_id_node}")
       while m_nodes_cc.count < 1
        Chef::Log.warn("Waiting for cc .... I am sleeping 7 sec")
        sleep 7
        m_nodes_cc = search(:node, "role:cloudfoundry_controller_nv AND cf_id:#{cf_id_node}")
       end
       m_nodes_cc.each {|k|
        if (k['cf_session']['cf_id'] == node['cf_session']['cf_id']) then
              node.set['cloud_controller']['service_api_uri'] = "" + k['ipaddress'].to_s + ":9022"   #['cloud_controller']['service_api_uri']
        end
       }

end


case node['platform']
when "ubuntu"

    configs = ["mysql_backup.yml", "mysql_node.yml", "mysql_worker.yml", "mysql_gateway.yml"]
    configs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end 

    confs = ["mysql_backup.cron", "ubuntu.cnf"]
    
    confs.each do |config|
     template File.join(node[:deployment][:config_path],config ) do
      source "#{config}.erb"
      owner node[:deployment][:user]
      mode "0644"
      action :create
     end
    end

  template File.join("", "etc", "mysql", "my.cnf") do
    source "ubuntu.cnf.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :restart, "service[mysql]"
  end

  service "mysql" do
    supports :status => true, :restart => true, :reload => true
    action [ :enable, :restart ]
  end

else
  Chef::Log.error("Installation of mysql not supported on this platform.")
end




bash "start MySQL Service"   do
  user "root" 
  cwd "/tmp" 
  code <<-EOH
  /root/cloudfoundry/vcap/dev_setup/bin/vcap_dev -n mysql_service start 
  EOH
end
