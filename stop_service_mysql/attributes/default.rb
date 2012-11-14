include_attribute "cloudfoundry"
include_attribute "deployment"
include_attribute "backup"
include_attribute "service_lifecycle"

default['cf_session']['cf_id'] = '13'




########################################### DEPLOYMENT  ###########################################################
default[:deployment][:name] = "dea_mysql"
default[:deployment][:user] = ENV["USER"]
default[:deployment][:group] = "vcap"
default[:cloudfoundry][:home] =  "/root/cloudfoundry"
default[:deployment][:home] = File.join(node[:cloudfoundry][:home], ".deployments", deployment[:name])
default[:deployment][:config_path] = File.join(deployment[:home], "config")
default[:deployment][:info_file] = File.join(deployment[:config_path], "deployment_info.json")
default[:deployment][:domain] = "vcap.me"
default[:deployment][:log_path] = File.join(deployment[:home], "log")
default[:deployment][:profile] = File.expand_path(File.join(ENV["HOME"], ".cloudfoundry_deployment_profile"))
default[:deployment][:local_run_profile] = File.expand_path(File.join(ENV["HOME"], ".cloudfoundry_deployment_local"))
default[:deployment][:setup_cache] = File.join("", "var", "cache", "dev_setup")




########################################### COMMON  ###########################################################
default['cloudfoundry_common']['vcap']['ruby_version'] = "/root/cloudfoundry/.deployments/rubynode/deploy/rubies/ruby-1.9.2-p180/bin/ruby"
default['ruby']['path'] = "/root/cloudfoundry/.deployments/rubynode/deploy/rubies/ruby-1.9.2-p180"
default['cloudfoundry_common']['vcap']['bin_path'] = "/root/cloudfoundry/vcap/dev_setup/bin/vcap" 
default['cloudfoundry_common']['vcap']['component_name'] = "dea_mysql" 
default['cloudfoundry_common']['vcap']['deplyment_path'] = "/root/cloudfoundry/.deployments" 
default['cloudfoundry_common']['vcap']['install_path'] = "/root/cloudfoundry/vcap"  
default['cloudfoundry_common']['vcap']['logs'] = "/root/cloudfoundry/.deployments/rubynode/log"


default[:mysql][:supported_versions] = {
        "5.1" => "5.1",
}
default[:mysql][:version_aliases] = {
        "current" => "5.1",
}
default[:mysql][:default_version] = "5.1"

default[:mysql][:server_root_password] = "mysql"
default[:mysql][:server_root_user] = "root"
default[:mysql][:host] = "localhost"

default[:mysql_gateway][:service][:timeout] = "15"
default[:mysql_gateway][:node_timeout] = "2"

default[:mysql_node][:capacity] = "50"
default[:mysql_node][:index] = "0"
default[:mysql_node][:max_index] = "-1"
default[:mysql_node][:max_db_size] = "20"
default[:mysql_node][:token] = "changemysqltoken"
default[:mysql_node][:op_time_limit] = "6"
default[:mysql_node][:connection_wait_timeout] = "10"



default[:mysql_backup][:config_file] = "mysql_backup.yml"
default[:mysql_backup][:cron_time] = "0 1 * * *"
default[:mysql_backup][:cron_file] = "mysql_backup.cron"

default[:mysql_worker][:config_file] = "mysql_worker.yml"


