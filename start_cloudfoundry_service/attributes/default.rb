########################################### DEPLOYMENT  ###########################################################
include_attribute "cloudfoundry"
default[:deployment][:name] = "dea_java"
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
default[:ruby][:path] = "/root/cloudfoundry/.deployments/rubynode/deploy/rubies/ruby-1.9.2-p180"
default['cloudfoundry_common']['vcap']['bin_path'] = "/root/cloudfoundry/vcap/dev_setup/bin/vcap" 
default['cloudfoundry_common']['vcap']['component_name'] = "" 
default['cloudfoundry_common']['vcap']['deplyment_path'] = "/root/cloudfoundry/.deployments" 
default['cloudfoundry_common']['vcap']['install_path'] = "/root/cloudfoundry/vcap"  
default['cloudfoundry_common']['vcap']['logs'] = "/root/cloudfoundry/.deployments/rubynode/log"



########################################### DEA  ###########################################################
default[:dea][:config_file] = "dea.yml"
default[:dea][:local_route] = nil
#default[:dea][:runtimes] = ["ruby18", "ruby19", "node04", "node06", "node08", "java", "java7", "erlang", "php", "python2"]
#default[:dea][:runtimes] = ["ruby18", "ruby19"]
default[:dea][:logging] = 'debug'
default[:dea][:secure] = false
default[:dea][:multi_tenant] = true
default[:dea][:enforce_ulimit] = false

default['cf_session']['cf_id'] = '13'


default['dea']['component_name'] = default[:deployment][:name]
