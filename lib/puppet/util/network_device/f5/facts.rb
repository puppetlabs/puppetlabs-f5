require 'puppet/util/network_device/f5'

class Puppet::Util::NetworkDevice::F5::Facts

  attr_reader :transport

  F5_WSDL = 'System.SystemInfo'

  def initialize(transport)
    @transport = transport
  end

  def to_64i(value)
    (value[:high].to_i << 32) + value[:low].to_i
  end

  def retrieve
    @facts = {}
    [ 'base_mac_address',
      'group_id',
      'marketing_name',
      'pva_version',
      'system_id',
      'uptime',
      'version'
    ].each do |key|
      @facts[key] = @transport[F5_WSDL].call("get_#{key}".to_sym).body["get_#{key}_response".to_sym][:return]
    end

    system_info = @transport[F5_WSDL].call(:get_system_information).body
    system_info[:get_system_information_response][:return].each do |key|
      @facts[key] = system_info[:get_system_information_response][:return][key]
    end

    # We want to get two kinds of values from get_hardware_information, the
    # first is a bunch of key/value pairs.  However, if the key is versions
    # then we want to iterate a subarray of hashes (it gets messy in SOAP)
    # to get the rest of the facts we need here.
    hardware_info = @transport[F5_WSDL].call(:get_hardware_information).body[:get_hardware_information_response][:return][:item]
    hardware_info.each do |key, value|
      if key == :versions
        hardware_info[key][:item].each do |hash|
          @facts["hardware_#{hash[:name]}"] = hash[:value]
        end
      else
        @facts["hardware_#{key}"] = value
      end
    end

    disk_info = @transport[F5_WSDL].call(:get_disk_usage_information).to_hash
    disk_info[:get_disk_usage_information_response][:return][:usages][:item].each do |disk|
      @facts["disk_size_#{disk[:partition_name].gsub('/','')}"]  = "#{(to_64i(disk[:total_blocks]) * to_64i(disk[:block_size]))/1024/1024} MB"
      @facts["disk_free_#{disk[:partition_name].gsub('/', '')}"] = "#{(to_64i(disk[:free_blocks]) * to_64i(disk[:block_size]))/1024/1024} MB"
    end

    # cleanup of f5 output to match existing facter key values.
    map = { 'host_name'        => 'fqdn',
            'base_mac_address' => 'macaddress',
            'os_machine'       => 'hardwaremodel',
            'uptime'           => 'uptime_seconds',
    }
    @facts = Hash[@facts.map {|k, v| [map[k] || k, v] }]\

    if @facts['fqdn'] then
      fqdn = @facts['fqdn'].split('.', 2)
      @facts['hostname'] = fqdn.shift
      @facts['domain']   = fqdn
    end

    if @facts['uptime_seconds'] then
      @facts['uptime']       = "#{String(@facts['uptime_seconds'].to_i / 86400)} days" # String
      @facts['uptime_hours'] = @facts['uptime_seconds'].to_i / (60 * 60)             # Integer
      @facts['uptime_days']  = @facts['uptime_hours'].to_i / 24                      # Integer
    end

    if @facts['hardware_cpus_versions']
      @facts['hardware_cpus_versions'].each { |key| @facts["hardware_#{key.name.downcase.gsub(/\s/,'_')}"] = key.value }
      @facts.delete('hardware_cpus_versions')
      @facts.delete('hardware_information')
      @facts.delete('versions')
    end

    @facts['timezone'] = @transport[F5_WSDL].call(:get_time_zone).body[:get_time_zone_response][:return][:time_zone]
    @facts
  end
end
