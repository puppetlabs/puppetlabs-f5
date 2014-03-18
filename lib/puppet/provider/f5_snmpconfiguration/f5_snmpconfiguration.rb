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

  # Format:  { property => { message => array? } }
  def self.snmpmethods
    {
      :access_info                => { :access_info            => true },
      :agent_group_id             => { :group_id               => false },
      :agent_interface            => { :agent_intf             => false },
      :agent_listen_address       => { :agent_listen_addresses => true },
      :agent_trap_state           => { :state                  => false },
      :agent_user_id              => { :user_id                => false },
      :auth_trap_state            => { :state                  => false },
      :check_disk                 => { :disk_info              => true },
      :check_file                 => { :file_info              => false },
      :check_load                 => { :load_info              => false },
      :check_process              => { :proc_info              => true },
      :client_access              => { :client_access_info     => false },
      :client_access              => { :client_access_info     => true },
      :community_to_security_info => { :security_info          => false },
      :create_user                => { :user_info              => true },
      :engine_id                  => { :engine_id              => false },
      :exec                       => { :exec_info              => true },
      :exec_fix                   => { :exec_info              => true },
      :generic_traps_v2           => { :sink_info              => true },
      :group_info                 => { :group_info             => true },
      :ignore_disk                => { :ignore_disk            => true },
      :pass_through               => { :passthru_info          => true },
      :pass_through_persist       => { :passthru_info          => true },
      :process_fix                => { :fix_info               => true },
      :proxy                      => { :proxy_info             => true },
      :readonly_community         => { :ro_community_info      => true },
      :readonly_user              => { :ro_user_info           => true },
      :readwrite_community        => { :rw_community_info      => true },
      :readwrite_user             => { :rw_user_info           => true },
      :system_information         => { :system_info            => false },
      :trap_community             => { :community              => false },
      :view_info                  => { :view_info              => true },
    }
  end

  def munge(hash)
    # Short circuit for strings.
    return hash unless hash.is_a?(Hash)
    newhash = {}
    hash.each do |key, value|
      if value.is_a?(Hash)
        newhash[key] = munge(value)
      else
        if value.nil?
          newhash[key] = ''
        else
          newhash[key] = value
        end
      end
    end
    newhash
  end

  def self.instances
    [new(:name => 'agent')]
  end

  def access_info
    response = transport[wsdl].get(:get_access_info)
    munge(response)
  end

  def agent_group_id
    response = transport[wsdl].get(:get_agent_group_id)
    munge(response)
  end

  def agent_interface
    response = transport[wsdl].get(:get_agent_interface)
    munge(response)
  end

  def agent_listen_address
    response = transport[wsdl].get(:get_agent_listen_address)
    munge(response)
  end

  def agent_trap_state
    response = transport[wsdl].get(:get_agent_trap_state)
    munge(response)
  end

  def agent_user_id
    response = transport[wsdl].get(:get_agent_user_id)
    munge(response)
  end

  def auth_trap_state
    response = transport[wsdl].get(:get_auth_trap_state)
    munge(response)
  end

  def check_disk
    response = transport[wsdl].get(:get_check_disk)
    munge(response)
  end

  def check_file
    response = transport[wsdl].get(:get_check_file)
    munge(response)
  end

  def check_load
    response = transport[wsdl].get(:get_check_load)
    munge(response)
  end

  def check_process
    response = transport[wsdl].get(:get_check_process)
    munge(response)
  end

  def client_access
    response = transport[wsdl].get(:get_client_access)
    munge(response)
  end

  def community_to_security_info
    response = transport[wsdl].get(:get_community_to_security_info)
    munge(response)
  end

  def create_user
    response = transport[wsdl].get(:get_create_user)
    munge(response)
  end

  def engine_id
    response = transport[wsdl].get(:get_engine_id)
    munge(response)
  end

  def exec
    response = transport[wsdl].get(:get_exec)
    munge(response)
  end

  def exec_fix
    response = transport[wsdl].get(:get_exec_fix)
    munge(response)
  end

  def generic_traps_v2
    response = transport[wsdl].get(:get_generic_traps_v2)
    munge(response)
  end

  def group_info
    response = transport[wsdl].get(:get_group_info)
    munge(response)
  end

  def ignore_disk
    response = transport[wsdl].get(:get_ignore_disk)
    munge(response)
  end

  def pass_through
    response = transport[wsdl].get(:get_pass_through)
    munge(response)
  end

  def pass_through_persist
    response = transport[wsdl].get(:get_pass_through_persist)
    munge(response)
  end

  def process_fix
    response = transport[wsdl].get(:get_process_fix)
    munge(response)
  end

  def proxy
    response = transport[wsdl].get(:get_proxy)
    munge(response)
  end

  def readonly_community
    response = transport[wsdl].get(:get_readonly_community)
    munge(response)
  end

  def readonly_user
    response = transport[wsdl].get(:get_readonly_user)
    munge(response)
  end

  def readwrite_community
    response = transport[wsdl].get(:get_readwrite_community)
    munge(response)
  end

  def readwrite_user
    response = transport[wsdl].get(:get_readwrite_user)
    munge(response)
  end

  def system_information
    response = transport[wsdl].get(:get_system_information)
    munge(response)
  end

  def trap_community
    response = transport[wsdl].get(:get_trap_community)
    munge(response)
  end

  def view_info
    response = transport[wsdl].get(:get_view_info)
    munge(response)
  end

  snmpmethods.each do |method, apicall|
    define_method("#{method}=") do |value|
      remove  = {}
      message = {}
      # SNMP elements only sometimes want to be in an array.
      apicall.each do |message_name, array|
        if array
          remove  = { message_name => { items: send(method) }}
          message = { message_name => { items: value }}
        else
          remove  = { message_name => method }
          message = { message_name => value }
        end
      end
      # First we remove everything
      transport[wsdl].call("remove_#{method}".to_sym, message: remove)
      # Then set just the new items
      transport[wsdl].call("set_#{method}".to_sym, message: message)
    end
  end

end
