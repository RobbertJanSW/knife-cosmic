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

require 'chef/knife'
require 'chef/knife/cosmic_baselist'

module Knifecosmic
  class CosmicIsoList < Chef::Knife

    include Chef::Knife::KnifecosmicBaseList

    banner "knife cosmic iso list (options)"

    option :listall,
           :long => "--listall",
           :description => "List all iso's",
           :boolean => true

    option :name,
           :long => "--name NAME",
           :description => "Specify iso name to list"

    option :keyword,
           :long => "--keyword KEY",
           :description => "List by keyword"

    option :isofilter,
           :long => "--isofilter FILTER",
           :description => "Default: 'featured'. Options: 'self','selfexecutable','sharedexecutable','executable','community'",
           :default => "featured"

    def run
      validate_base_options

      columns = [
        'Name    :name',
        'Account :account',
        'Domain  :domain',
        'Public  :ispublic',
        'Size    :size',
        'OS      :ostypename'
      ]

      params = { 'command' => "listIsos" }
      params['filter']  = locate_config_value(:filter)  if locate_config_value(:filter)
      params['keyword'] = locate_config_value(:keyword) if locate_config_value(:keyword)
      params['listall'] = locate_config_value(:listall) if locate_config_value(:listall)
      params['name']    = locate_config_value(:name)    if locate_config_value(:name)

      if ['all','featured','self','selfexecutable','sharedexecutable','executable','community'].include?(locate_config_value(:templatefilter))
        params['isofilter'] = locate_config_value(:isofilter)
      else
        params['isofilter'] = 'featured'
      end
 
      result = connection.list_object(params, "iso")
      result.each do |r|
        r['size'] = human_file_size(r['size']) if r['size']
      end

      list_object(columns, result)
    end

    def human_file_size n
      count = 0
      while  n >= 1024 and count < 4
        n /= 1024.0
        count += 1
      end
      format("%.0f", n) + %w(B KB MB GB TB)[count]
    end

  end
end
