## This code is simply the icontrol gem renamed and mashed up.
require 'openssl'
require 'savon'

module Savon
  class Client
    def get(call, message=nil)
      if message
        reply = self.call(call, message: message).body["#{call}_response".to_sym]
      else
        reply = self.call(call).body["#{call}_response".to_sym]
      end

      # Attempt to divine the appropriate repsonse from the reply message.
      # What we're looking for here is a {:return => nil} which we can get
      # from Savon 2.4.0.  If we get that just skip to returning a blank
      # hash and we move on.
      if reply[:return] == nil
        return {}
      # Almost everything in Savon comes back as a hash, except SOMETIMES
      # in SNMP it doesn't.  WHAT?
      elsif reply[:return].is_a?(String) or reply[:return].is_a?(Array)
        return reply[:return]
      elsif reply[:return].has_key?(:item)
        response = reply[:return][:item]
      else
        response = reply[:return]
      end

      # Here we handle nested hashes, which can be a pain in Savon.
      return response if response.is_a?(String) or response.is_a?(Array)
      if response.is_a?(Hash)
        if response[:item]
          return response[:item]
        else
          return response
        end
      end
      return {}
    end
  end
end

module Puppet::Util::NetworkDevice::F5
  class Transport
    attr_reader :hostname, :username, :password, :directory
    attr_accessor :wsdls, :endpoint, :interfaces

    def initialize hostname, username, password, wsdls = []
      @hostname = hostname
      @username = username
      @password = password
      @directory = File.join(File.dirname(__FILE__), '..', 'wsdl')
      @wsdls = wsdls
      @endpoint = '/iControl/iControlPortal.cgi'
      @interfaces = {}
    end

    def get_interfaces
      @wsdls.each do |wsdl|
        # We use + here to ensure no / between wsdl and .wsdl
        wsdl_path = File.join(@directory, wsdl + '.wsdl')

        if File.exists? wsdl_path
          namespace = 'urn:iControl:' + wsdl.gsub(/(.*)\.(.*)/, '\1/\2')
          url = 'https://' + @hostname + '/' + @endpoint
          @interfaces[wsdl] = Savon.client(wsdl: wsdl_path, ssl_verify_mode: :none,
            basic_auth: [@username, @password], endpoint: url,
            namespace: namespace, convert_request_keys_to: :none,
            strip_namespaces: true, log: false, :convert_attributes_to => lambda {|k,v| []})
        end
      end

      @interfaces
    end

    def get_all_interfaces
      @wsdls = self.available_wsdls
      puts @wsdls
      self.get_interfaces
    end

    def available_interfaces
      @interfaces.keys.sort
    end

    def available_wsdls
      Dir.entries(@directory).delete_if {|file| !file.end_with? '.wsdl'}.sort
    end
  end
end
