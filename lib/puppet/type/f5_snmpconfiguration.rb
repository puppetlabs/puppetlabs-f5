require 'puppet/util/network_device/f5'
Puppet::Type.newtype(:f5_snmpconfiguration) do
  @doc = "Manage F5 SNMP configuration properties."

  apply_to_device

  newparam(:name, :namevar=>true) do
    desc "The SNMP type name. Fixed to 'agent'."
    newvalues(/^(agent)+$/)
    newvalues(/^[[:alpha:][:digit:]\.\-]+$/)
  end
  
  methods=Puppet::Util::NetworkDevice::F5.snmpconfiguration_methods
  
  methods.keys.each do |method|
    args={}
    if methods[method].class == Array
      args[:array_matching] = :all
    end
    newproperty(method, args) do
      if methods[method].class == Array
        def insync?(is)
          is.count == @should.count && (is & @should).count == @should.count
        end
      end
      if methods[method].class == Array || methods[method].class == Hash
        def should_to_s(newvalue)
          newvalue.inspect
        end
        def is_to_s(currentvalue)
          currentvalue.inspect
        end
      end
      validate do |value|
        Puppet::Util::NetworkDevice::F5.validate_data_struct(methods[method], value, method)
      end
    end
  end
end
