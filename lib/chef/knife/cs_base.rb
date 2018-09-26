#
# Author:: Sander Botman (<sbotman@schubergphilis.com>)
# Copyright:: Copyright (c) 2013 Sander Botman.
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

class Chef
  class Knife
    module KnifecosmicBase

      def self.included(includer)
        includer.class_eval do

          deps do
            require 'knife-cosmic/connection'
          end

          option :cosmic_url,
                 :short => "-U URL",
                 :long => "--cosmic-url URL",
                 :description => "The cosmic endpoint URL",
                 :proc => Proc.new { |url| Chef::Config[:knife][:cosmic_url] = url }

          option :cosmic_api_key,
                 :short => "-A KEY",
                 :long => "--cosmic-api-key KEY",
                 :description => "Your cosmic API key",
                 :proc => Proc.new { |key| Chef::Config[:knife][:cosmic_api_key] = key }

          option :cosmic_secret_key,
                 :short => "-K SECRET",
                 :long => "--cosmic-secret-key SECRET",
                 :description => "Your cosmic secret key",
                 :proc => Proc.new { |key| Chef::Config[:knife][:cosmic_secret_key] = key }

          option :cosmic_project,
                 :short => "-P PROJECT_NAME",
                 :long => '--cosmic-project PROJECT_NAME',
                 :description => "cosmic Project in which to create server",
                 :proc => Proc.new { |v| Chef::Config[:knife][:cosmic_project] = v },
                 :default => nil

          option :cosmic_no_ssl_verify,
                 :long => '--cosmic-no-ssl-verify',
                 :description => "Disable certificate verify on SSL",
                 :boolean => true

          option :cosmic_proxy,
                 :long => '--cosmic-proxy PROXY',
                 :description => "Enable proxy configuration for cosmic api access"

          def validate_base_options
            unless locate_config_value :cosmic_url
              ui.error "cosmic URL not specified"
              exit 1
            end
            unless locate_config_value :cosmic_api_key
              ui.error "cosmic API key not specified"
              exit 1
            end
            unless locate_config_value :cosmic_secret_key
              ui.error "cosmic Secret key not specified"
              exit 1
            end
          end

          def connection
            @connection ||= cosmicClient::Connection.new(
              locate_config_value(:cosmic_url),
              locate_config_value(:cosmic_api_key),
              locate_config_value(:cosmic_secret_key),
              locate_config_value(:cosmic_project),
              locate_config_value(:cosmic_no_ssl_verify),
              locate_config_value(:cosmic_proxy)
            )
          end

          def locate_config_value(key)
            key = key.to_sym
            config[key] || Chef::Config[:knife][key] || nil
          end 

          def exit_with_error(error)
            ui.error error
            exit 1
          end

          def valid_cs_name?(name)
            !!(name && /^[a-zA-Z0-9][a-zA-Z0-9_\-#]*$/.match(name))
          end

        end
      end
    end
  end
end
