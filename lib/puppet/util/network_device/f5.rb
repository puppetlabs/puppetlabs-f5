require 'openssl'
require 'digest/sha1'
require 'puppet/util/network_device'

module Puppet::Util::NetworkDevice::F5
  # This is intended to decode certificate (subject, serial, issuer, expiration) for comparison.
  def self.decode(content)
    cert = case content.split("\n").first
           when /BEGIN X509 CRL/
             OpenSSL::X509::CRL
           when /BEGIN CERTIFICATE REQUEST/
             OpenSSL::X509::Request
           when /BEGIN CERTIFICATE/
             OpenSSL::X509::Certificate
           when /BEGIN RSA (PRIVATE|PUBLIC) KEY/
             OpenSSL::PKey::RSA
           when /BEGIN DSA (PRIVATE|PUBLIC) KEY/
             OpenSSL::PKey::DSA
           else return nil
           end
    cert.new(content)
  rescue Exception => e
    raise Puppet::Error, "Puppet::Provider::F5_Cert: failed to decode certificate content. Error: #{e.message}\n#{content}"
  end

  # Calculate cert fingerprint
  def self.fingerprint(content)
    cert = decode(content)
    Digest::SHA1.hexdigest(cert.to_der)
  end

  def self.snmpconfiguration_methods
    {:access_info=>
         [{"access_name"=>/.*/,
           "access_context"=>/.*/,
           "model"=>/^MODEL_(ANY|V1|V2C|USM)$/,
           "level"=>/^LEVEL_((NO)?AUTH|PRIV)$/,
           "prefix"=>/^PREFIX_(EXACT|PREFIX)$/,
           "read_access"=>/.*/,
           "write_access"=>/.*/,
           "notify_access"=>/.*/}],
     :agent_group_id=>/.*/,
     :agent_interface=>{"intf_name"=>/.*/, "intf_type"=>/.*/, "intf_speed"=>/.*/},
     :agent_listen_address=>
         [{"transport"=>/^TRANSPORT_(TCP|UDP)6?$/,
           "ipport"=>{"address"=>/.*/, "port"=>/^\d+$/}}],
     :agent_trap_state=>/^STATE_(EN|DIS)ABLED$/,
     :agent_user_id=>/.*/,
     :auth_trap_state=>/^STATE_(EN|DIS)ABLED$/,
     :check_disk=>
         [{"disk_path"=>/.*/,
           "check_type"=>/^DISKCHECK_(PERCENT|SIZE)$/,
           "minimum_space"=>/^\d+$/}],
     :check_file=>[{"file_name"=>/.*/, "maximum_size"=>/^\d+$/}],
     :check_load=>
         {"max_1_minute_load"=>/^\d+$/,
          "max_5_minute_load"=>/^\d+$/,
          "max_15_minute_load"=>/^\d+$/},
     :check_process=>[{"process_name"=>/.*/, "max"=>/^\d+$/, "min"=>/^\d+$/}],
     :client_access=>
         [{"address"=>/^[0-9A-Fa-f\.\:]+$/, "netmask"=>/^[0-9A-Fa-f\.\:]*$/}],
     :community_to_security_info=>
         [{"security_name"=>/.*/,
           "source"=>/.*/,
           "community_name"=>/.*/,
           "ipv6"=>/^(true|false)$/}],
     :create_user=>
         [{"user_name"=>/.*/,
           "auth_type"=>/^AUTH_(MD5|SHA|NONE)$/,
           "auth_pass_phrase"=>/.*/,
           "priv_protocol"=>/^PRIV_PROTOCOL_(DES|NONE)$/,
           "priv_pass_phrase"=>/.*/}],
     :engine_id=>/.*/,
     :exec=>
         [{"mib_num"=>/.*/,
           "name_prog_args"=>
               {"process_name"=>/.*/, "program_name"=>/.*/, "program_args"=>/.*/}}],
     :exec_fix=>
         [{"process_name"=>/.*/, "program_name"=>/.*/, "program_args"=>/.*/}],
     :generic_traps_v2=>
         [{"snmpcmd_args"=>/.*/, "sink_host"=>/.*/, "sink_port"=>/^\d+$/}],
     :group_info=>
         [{"group_name"=>/.*/,
           "model"=>/^MODEL_(ANY|V1|V2C|USM)$/,
           "security_name"=>/.*/}],
     :ignore_disk=>[/.*/],
     :pass_through=>[{"mib_oid"=>/.*/, "exec_name"=>/.*/}],
     :pass_through_persist=>[{"mib_oid"=>/.*/, "exec_name"=>/.*/}],
     :process_fix=>
         [{"process_name"=>/.*/, "program_name"=>/.*/, "program_args"=>/.*/}],
     :proxy=>[/.*/],
     :readonly_community=>
         [{"community"=>/.*/, "source"=>/.*/, "oid"=>/.*/, "ipv6"=>/^(true|false)$/}],
     :readonly_user=>
         [{"user"=>/.*/, "level"=>/^LEVEL_((NO)?AUTH|PRIV)$/, "oid"=>/.*/}],
     :readwrite_community=>
         [{"community"=>/.*/, "source"=>/.*/, "oid"=>/.*/, "ipv6"=>/^(true|false)$/}],
     :readwrite_user=>
         [{"user"=>/.*/, "level"=>/^LEVEL_((NO)?AUTH|PRIV)$/, "oid"=>/.*/}],
     :system_information=>
         {"sys_name"=>/.*/,
          "sys_location"=>/.*/,
          "sys_contact"=>/.*/,
          "sys_description"=>/.*/,
          "sys_object_id"=>/.*/,
          "sys_services"=>/.*/},
     :trap_community=>/.*/,
     :view_info=>
         [{"view_name"=>/.*/,
           "type"=>/^VIEW_(IN|EX)CLUDED$/,
           "subtree"=>/.*/,
           "masks"=>/.*/}]}
  end

  def self.validate_data_struct(struct, data, param)
    if struct.class == Hash
      struct.keys.each do |k|
        validate_data_struct(struct[k], data[k], k)
      end
    elsif struct.class == Array
      validate_data_struct(struct.first, data, param)
    else
      if data.scan(struct).empty?
        raise Puppet::Error, "Puppet::Type::F5_: parameter '#{param}' must match #{struct.inspect}."
      end
    end
  end

  def self.get_data_struct(struct, object)
    if struct.class == Hash
      r={}
      struct.keys.each do |k|
        r[k]=get_data_struct(struct[k], object.send(k))
      end
      return r
    elsif struct.class == Array
      r=[]
      object.each do |o|
        r.push(get_data_struct(struct.first, o))
      end
      return r
    else
      return object.to_s
    end
  end

end
