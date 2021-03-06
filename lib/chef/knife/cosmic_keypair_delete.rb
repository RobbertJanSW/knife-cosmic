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
  class CosmicKeypairDelete < Chef::Knife

    include Chef::Knife::KnifecosmicBase

    deps do
      require 'knife-cosmic/connection'
      Chef::Knife.load_deps
    end

    banner "knife cosmic keypair delete KEY_NAME (options)"

    option :name,
           :long => "--name NAME",
           :description => "Specify the ssh keypair name"

    def run
      validate_base_options

      Chef::Log.debug("Validate keypair name")
      keypairname = locate_config_value(:name) || @name_args.first
      unless /^[a-zA-Z0-9][a-zA-Z0-9\-\_]*$/.match(keypairname) then
          ui.error "Invalid keypairname. Please specify a short name for the keypair"
          exit 1
      end

      params = {
        'command' => 'deleteSSHKeyPair',
        'name' => keypairname,
      }

      json = connection.send_request(params)

      unless json['success'] == 'true' then
        ui.error("Unable to delete SSH Keypair")
	exit 1
      end
      print "#{ui.color("Deleted the SSH Keypair: #{keypairname}", :magenta)}\n"
    end

  end # class
end
