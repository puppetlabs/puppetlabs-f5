Puppet::Type.newtype(:f5_snmpconfiguration) do
  @doc = "Manage F5 SNMP configuration properties."

  apply_to_device

  # We need to fix the hashes to symbolize all the keys and
  # convert true/false strings into true boolean values or
  # the responses we get from the F5 cause us to change
  # properties over and over.
  def self.fix_hashes(hash)
    new={}
    hash.map do |key,value|
      if value.is_a?(Hash)
        value = fix_hashes(value)
      end
      if value == "true"
        new[key.to_sym]=true
      elsif value == "false"
        new[key.to_sym]=false
      else
        new[key.to_sym]=value
      end
    end
    return new
  end

  newparam(:name, :namevar=>true) do
    desc "The SNMP type name. Fixed to 'agent'."
    newvalues(/^(agent)+$/)
    newvalues(/^[[:alpha:][:digit:]\.\-]+$/)
  end

  newproperty(:access_info) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:agent_group_id) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:agent_interface) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:agent_listen_address) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:agent_trap_state) do
  end

  newproperty(:agent_user_id) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:auth_trap_state) do
  end

  newproperty(:check_disk) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:check_file) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:check_load) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:check_process) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:client_access) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:community_to_security_info) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:create_user) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:engine_id) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:exec) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:exec_fix) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:generic_traps_v2) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:group_info) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:ignore_disk) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:pass_through) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:pass_through_persist) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:process_fix) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:proxy) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:readonly_community) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:readonly_user) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:readwrite_community) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:readwrite_user) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:system_information) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

  newproperty(:trap_community) do
  end

  newproperty(:view_info) do
    munge do |value|
      Puppet::Type::F5_snmpconfiguration.fix_hashes(value)
    end
  end

end
