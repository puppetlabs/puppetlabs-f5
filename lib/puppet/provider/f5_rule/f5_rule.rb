require 'puppet/provider/f5'

Puppet::Type.type(:f5_rule).provide(:f5_rule, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 pool"

  confine :feature => :posix
  defaultfor :feature => :posix

  F5_WSDL = 'LocalLB.Rule'

  def self.instances
    transport[F5_WSDL].get_list.collect do |name|
      new(:name => name)
    end
  end

  def definition
    Puppet.debug("Puppet::Provider::F5_Rule: retrieving #{resource[:name]} rule definition")
    transport[F5_WSDL].query_rule(resource[:name]).first.rule_definition
  end

  def definition=(val)
    Puppet.debug("Puppet::Provider::F5_Rule: updating #{resource[:name]} rule definition")
    rule = {"rule_name" => resource[:name], "rule_definition" => resource[:definition]}
    transport[F5_WSDL].modify_rule([rule])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Rule: creating #{resource[:name]}")
    rule = {"rule_name" => resource[:name], "rule_definition" => resource[:definition]}
    transport[F5_WSDL].create([rule])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Rule: destroying #{resource[:name]}")
    transport[F5_WSDL].delete_rule(resource[:name])
  end

  def exists?
    transport[F5_WSDL].get_list.include?(resource[:name])
  end
end
