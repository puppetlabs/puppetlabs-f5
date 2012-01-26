require 'puppet/provider/f5'
require 'puppet/util/network_device/f5'

Puppet::Type.type(:f5_snmpconfiguration).provide(:f5_snmpconfiguration, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 snmpconfiguration properties"
  
  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'Management.SNMPConfiguration'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    [new(:name => 'agent')]
  end

  methods=Puppet::Util::NetworkDevice::F5.snmpconfiguration_methods
  
  methods.keys.each do |method|
    define_method(method.to_sym) do
      # Initialized here and not in initialize because initialize isnt called
      #  when running "puppet resource f5_snmpconfiguration"
      @methods_data={} if @methods_data.class == NilClass     
      if transport[wsdl].respond_to?("get_#{method}".to_sym)
        @methods_data[method]=Puppet::Util::NetworkDevice::F5.get_data_struct(methods[method], transport[wsdl].send("get_#{method}"))
      end
    end
    define_method("#{method}=") do |value|
      if methods[method].class == Array
        add=(value-@methods_data[method])
        rem=(@methods_data[method]-value)
        if rem.empty? == false && transport[wsdl].respond_to?("remove_#{method}".to_sym)
          transport[wsdl].send("remove_#{method}", rem)
        end
      else
        add=value
      end
      if add.empty? == false && transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", add)
      end
    end
  end
  
  ### Inconsistent method handling in the BigIP. All methods managing arrays
  ### append to the existing elements but set_agent_listen_address and
  ### set_client_access replace them. Case C1042181 opened with F5.
  
  ['agent_listen_address','client_access'].each do |method|
    define_method("#{method}=") do |value|
      if transport[wsdl].respond_to?("set_#{method}".to_sym)
        transport[wsdl].send("set_#{method}", value)
      end
    end
  end
  
end
