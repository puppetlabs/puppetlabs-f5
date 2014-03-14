require 'puppet/util/network_device/f5'

class Puppet::Util::NetworkDevice::F5::Facts

  attr_reader :transport

  F5_WSDL = 'System.SystemInfo'

  def initialize(transport)
    @transport = transport
  end

  def to_64i(value)
    (value.high.to_i << 32) + value.low.to_i
  end

  def retrieve
    @facts = {}
    [ 'base_mac_address',
      'group_id',
      'hardware_information',
      'marketing_name',
      'pva_version',
      'system_id',
      'uptime',
      'version'
    ].each do |key|
        @facts[key] = @transport[F5_WSDL].send("get_#{key}".to_s)
    end

    # Not sure if there's a cleaner way to get SOAP Mapping Object attributes.
    # maybe if we use Savon to get a hash back instead of this kludge.
    soap = SOAP::Mapping::Object.new

    system_info = @transport[F5_WSDL].get_system_information
    attributes  = system_info.methods.reject{|k| k =~ /=$/} - soap.methods
    attributes.each { |key| @facts[key] = system_info[key] }

    hardware_info = @transport[F5_WSDL].get_hardware_information
    attributes    = hardware_info.first.methods.reject{|k| k =~ /=$/} - soap.methods
    attributes.each { |key| @facts["hardware_#{key}"] = hardware_info.first[key] }
    hardware_info.each do |hardware|
      attributes = hardware.methods.reject{|k| k =~ /=$/} - soap.methods
      attributes.each do |key|
        fact_key = key == 'name' ? "hardware_#{hardware.name}" : "hardware_#{hardware.name}_#{key}"
        @facts[fact_key] = hardware[key]
      end
    end

    disk_info = @transport[F5_WSDL].get_disk_usage_information
    disk_info.usages.each do |disk|
      @facts["disk_size_#{disk.partition_name.gsub('/','')}"] = "#{(to_64i(disk.total_blocks) * to_64i(disk.block_size))/1024/1024} MB"
      @facts["disk_free_#{disk.partition_name.gsub('/', '')}"] = "#{(to_64i(disk.free_blocks) * to_64i(disk.block_size))/1024/1024} MB"
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
      @facts['uptime']       = "#{String(@facts['uptime_seconds']/86400)} days" # String
      @facts['uptime_hours'] = @facts['uptime_seconds'] / (60 * 60)             # Integer
      @facts['uptime_days']  = @facts['uptime_hours'] / 24                      # Integer
    end
    if @facts['hardware_cpus_versions']
      @facts['hardware_cpus_versions'].each { |key| @facts["hardware_#{key.name.downcase.gsub(/\s/,'_')}"] = key.value }
      @facts.delete('hardware_cpus_versions')
      @facts.delete('hardware_information')
      @facts.delete('versions')
    end
    @facts['timezone'] = @transport[F5_WSDL].get_time_zone.time_zone
    @facts
  end
end
