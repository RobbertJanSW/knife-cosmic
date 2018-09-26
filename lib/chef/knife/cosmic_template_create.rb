#
# Author:: Sander Botman (<sbotman@schubergphilis.com>)
# Author:: Frank Breedijk (<fbreedijk@schubergphilis.com>)
# Copyright:: Copyright (c) 2013 
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
  class CosmicTemplateCreate < Chef::Knife

    include Chef::Knife::KnifecosmicBase

    deps do
      require 'knife-cosmic/connection'
      Chef::Knife.load_deps
    end

    banner "knife cosmic template create NAME (options)"

    option :displaytext,
           :long => "--displaytext DISPLAYTEXT",
           :description => "The display text of the template",
           :on => :head

    option :name,
           :long => "--name NAME",
           :description => "Specify templatename (without format checking)"

    option :ostypeid,
           :long => "--ostypeid ID",
           :description => "Specify OS type ID",
           :on => :head

    option :volumeid,
           :long => "--volumeid ID",
           :description => "Specify volume ID",
           :on => :head

    option :hypervisor,
           :long => "--hypervisor=TYPE",
           :description => "Specify hypervisor type",
           :on => :head

    option :optimisefor,
           :long => "--optimisefor PROFILE",
           :description => "Specify hardware optimisation (Generic vs Windows)",
           :on => :head

    option :ispublic,
           :long => "--[no-]public",
	   :description => "Make the template public after creation",
	   :boolean => true,
	   :default => false

    option :isfeatured,
           :long => "--[no-]featured",
	   :description => "Make the template featured after creation",
	   :boolean => true,
	   :default => false

    option :passwordenabled,
           :long => "--[no-]passwordenabled",
	   :description => "Make the template password reset enabled  after creation",
	   :boolean => true,
	   :default => true

    option :extractable,
           :long => "--[no-]extractable",
	   :description => "Make the template extractable after creation",
	   :boolean => "true",
	   :default => false

    def run
      validate_base_options

      Chef::Log.debug("Validate hostname and options")
      if  locate_config_value(:name)
        templatename = locate_config_value(:name)
      else
        templatename = @name_args.first
        unless /^[a-zA-Z0-9][a-zA-Z0-9_\-#]*$/.match templatename then
          ui.error "Invalid templatename. Please specify a simple name without any spaces"
          exit 1
        end
      end

      print "#{ui.color("Creating template: #{templatename}", :magenta)}\n"

      params = {
        'command' => 'createTemplate',
        'name' => templatename,
        'displaytext' => locate_config_value(:displaytext),
        'ostypeid' => locate_config_value(:ostypeid),
        'volumeid' => locate_config_value(:volumeid),
        'hypervisor' => locate_config_value(:hypervisor)
      }
      params['ispublic'] = locate_config_value(:ispublic) if locate_config_value(:ispublic)
      params['isfeatured'] = locate_config_value(:isfeatured) if locate_config_value(:isfeatured)
      params['optimisefor'] = locate_config_value(:optimisefor) if locate_config_value(:optimisefor)
      params['passwordenabled'] = locate_config_value(:passwordenabled) if locate_config_value(:passwordenabled)
      params['isextractable'] = locate_config_value(:extractable) if locate_config_value(:extractable)
      json = connection.send_request(params)

      if ! json then
        ui.error("Unable to create template")
	exit 1
      end

      print "Template #{json['id']} is being created in the background\n";

      return json['id']
    end

  end # class
end
