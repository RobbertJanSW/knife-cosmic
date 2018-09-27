#
# knife-cosmic author:: Robbert-Jan Sperna Weiland (<rspernaweiland@schubergphilis.com>)
# Copyright:: Copyright (c) 2018 Robbert-Jan Sperna Weiland.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/cosmic_base'

module Knifecosmic
  class CosmicServerPasswordreset < Chef::Knife

    include Chef::Knife::KnifecosmicBase

    deps do
      require 'knife-cosmic/connection'
      require 'chef/api_client'
      require 'chef/knife'
      Chef::Knife.load_deps
    end

    banner "knife cosmic server passwordreset SERVER_NAME [SERVER_NAME ...] (options)"

    def run
      validate_base_options

      @name_args.each do |hostname|
        server = connection.get_server(hostname)

        if !server then
          ui.error("Server '#{hostname}' not found")
          next
        end

        rules = connection.list_port_forwarding_rules
       
        show_object_details(server, connection, rules) 

        server = connection.server_passwordreset(hostname)
        password = server['password']
        ui.msg("Password: #{password}")
      end
    end

    def show_object_details(s, connection, rules)
      return if locate_config_value(:yes)
      
      object_fields = []
      object_fields << ui.color("Name:", :cyan)
      object_fields << s['name'].to_s
      object_fields << ui.color("Public IP:", :cyan)
      object_fields << (connection.get_server_public_ip(s, rules) || '')
      object_fields << ui.color("Service:", :cyan)
      object_fields << s['serviceofferingname'].to_s
      object_fields << ui.color("Template:", :cyan)
      object_fields << s['templatename']
      object_fields << ui.color("Domain:", :cyan)
      object_fields << s['domain']
      object_fields << ui.color("Zone:", :cyan)
      object_fields << s['zonename']
      object_fields << ui.color("State:", :cyan)
      object_fields << s['state']

      puts "\n"
      puts ui.list(object_fields, :uneven_columns_across, 2)
      puts "\n"
    end

    def confirm_action(question)
      return true if locate_config_value(:yes)
      result = ui.ask_question(question, :default => "Y" )
      if result == "Y" || result == "y" then
        return true
      else
        return false
      end
    end

  end
end
