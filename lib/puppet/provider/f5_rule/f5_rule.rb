require 'puppet/provider/f5'

Puppet::Type.type(:f5_rule).provide(:f5_rule, :parent => Puppet::Provider::F5) do
  @doc = "Manages f5 pool"

  confine :feature => :posix
  defaultfor :feature => :posix

  def self.wsdl
    'LocalLB.Rule'
  end

  def wsdl
    self.class.wsdl
  end

  def self.instances
    transport[wsdl].get_list.collect do |name|
      new(:name => name)
    end
  end

  def definition
    Puppet.debug("Puppet::Provider::F5_Rule: retrieving #{resource[:name]} rule definition")
    transport[wsdl].query_rule(resource[:name]).first.rule_definition
  end

  def definition=(val)
    Puppet.debug("Puppet::Provider::F5_Rule: updating #{resource[:name]} rule definition")
    rule = {"rule_name" => resource[:name], "rule_definition" => resource[:definition]}
    transport[wsdl].modify_rule([rule])
  end

  def create
    Puppet.debug("Puppet::Provider::F5_Rule: creating #{resource[:name]}")
    rule = {"rule_name" => resource[:name], "rule_definition" => resource[:definition]}
    transport[wsdl].create([rule])
  end

  def destroy
    Puppet.debug("Puppet::Provider::F5_Rule: destroying #{resource[:name]}")
    transport[wsdl].delete_rule(resource[:name])
  end

  def exists?
    transport[wsdl].get_list.include?(resource[:name])
  end
end
