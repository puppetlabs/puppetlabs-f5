#f5

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with f5(#setup)
    * [What f5 affects](#what-f5-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with f5](#beginning-with-f5)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

The F5 module allows you to centralize the management of your F5 devices (running 11.0+) via many different types and providers.  This module, and the current design of it, is to be deprecated shortly with the introduction of a new REST based module written from scratch.  We have recently overhauled this module to work with Puppet 3+ and modern versions of Ruby, but the new module will be substantially different.

##Module Description

This module uses SOAP to manage F5 devices running 11.0+.  It consists of nineteen resources covering everything from users to irules.

##Setup

###What f5 affects

* F5 device configuration.
* Puppet device configuration.

###Setup Requirements **OPTIONAL**

As F5 devices cannot run Puppet natively we require the use of a proxy system.  This system must be running Puppet and have the "Savon"(http://www.savonrb.com) Ruby gem installed on it for working with the SOAP api.

The following profile class would deploy an appropriate configuration as well as setup a cron job to run the F5 configuration once an hour.

```puppet
    class profile::f5_proxy(
      $hostname = 'f5.puppetlabs.lan',
      $username = 'admin',
      $password = 'admin'
    ) {
      include f5

      f5::config { $hostname:
        username => $username,
        password => $password,
        url      => $hostname,
        target   => "${::settings::confdir}/device/${hostname}"
      }

      cron { "bigip-puppet-device-run":
        command => "puppet device --deviceconfig ${::settings::confdir}/device/${hostname}",
        minute  => fqdn_rand(60),
      }
    }
```

Once you've run this on a proxy you can then create a class and apply it to a node with the name of the f5 (in the above example f5.puppetlabs.lan).

```puppet
  class profile:f5_users {
    f5_user { 'test':
      ensure   => present,
      password => {'is_encrypted' => 'false', 'password' => 'test'}
    }
  }
```

###Beginning with [Modulename]  

To begin with you can simply call the types from the proxy system we set up earlier.  You can run puppet resource directly.

```
$ FACTER_url=https://admin:admin@f5.puppetlabs.lan/ puppet resource f5_user
```

You can change a property by hand this way too.

```
$ FACTER_url=https://admin:admin@f5.puppetlabs.lan/ puppet resource f5_user test ensure=absent
```

##Usage

[TODO:  Not sure what to put here yet.  Maybe a brief description of all the types.]

##Reference

###Global

All resource names are required to be in the format of /Partition/name.

###f5_certificate

`f5_certificate` can be used to manage SSL certificates on the F5.

####name

The name of the certificate to manage.

####content

The certificate content in PEM format. (sha1 fingerprint).

####real_content

The actual certificate content in PEM format.

####mode

The management mode of the certificate.

[TODO: How do we handle listing parameters like this that only allow certain options?]
Valid options are: MANAGEMENT_MODE_DEFAULT, MANAGEMENT_MODE_WEBSERVER, MANAGEMENT_MODE_EM, MANAGEMENT_MODE_IQUERY, MANAGEMENT_MODE_IQUERY_BIG3D

###f5_external_class

`f5_external_class` manages external classes (datagroups).

####name

The name of the external class to manage.

####file_format

The file format for the specified classes.

Valid options are: FILE_FORMAT_UNKNOWN, FILE_FORMAT_CSV

####file_mode

The file modes for the specified classes.

Valid options are: FILE_MODE_UNKNOWN, FILE_MODE_TYPE_READ, FILE_MODE_TYPE_READ_WRITE

####file_name

The file names for the specified classes.

####data_separator

The data seperator for the specified classes.

####type

The class types for the specified classes.

Valid options are: CLASS_TYPE_UNDEFINED, CLASS_TYPE_ADDRESS, CLASS_TYPE_STRING, CLASS_TYPE_VALUE

###f5_file

`f5_file` manages arbitary files on the f5.

####path

The absolute filepath to a file on the F5.

####content

The contents of the file.

####real_content
[TODO]: Why the hell does this have a content and then a real content, what the ?
The files real content. 

###f5_inet

`f5_inet` manages the inet properties on the F5.

#####name

The BigIP hostname.

#####hostname

The BigIP hostname.

#####ntp_server_address

The NTP server address.

###f5_key

`f5_key` manages security keys on the F5.

####name

The name of the key to manage.

####content

The certificate key in PEM format (sha1 fingerprint).

####real_content

Stores actual key PEM-formatted content.

####mode

The key management mode.

Valid options are:  MANAGEMENT_MODE_DEFAULT, MANAGEMENT_MODE_WEBSERVER, MANAGEMENT_MODE_EM, MANAGEMENT_MODE_IQUERY, MANAGEMENT_MODE_IQUERY_BIG3D

###f5_monitor

####name

The name of the monitor to manage.

####is_directly_usable

Determines if the specified monitor templates can be used directly, or if a user-defined monitor based on each monitor must be created first before it can be used.

Valid options are: true (default), false

####is_read_only

Determines if the specified monitor templates are read-only. The user can only modify properties for read/write monitor templates.

Valid options are: true, false (default)

####manual_resume_state

The monitor templates' manual resume states. When enabled and a monitor has marked an object down, that object will not be marked up by the monitor, i.e. the object will be manually marked up.

Valid options are: STATE_DISABLED, STATE_ENABLED

####parent_template

The parent monitor templates from which the specified monitor templates are derived. A user-defined monitor template will get its defaults from its parent monitor template.

Default: ''

####template_destination

The destination IP:port values for the specified templates. NOTE: This should only be done when the monitor templates in 'template_names' have NOT been associated to any node addresses or pool members.

Default: ['ATYPE_STAR_ADDRESS_STAR_PORT', '*:*']

####template_integer_property

The integer property values of the specified monitor templates.

Default: { 'ITYPE_INTERVAL' => 5, 'ITYPE_TIMEOUT'  => 16 }

####template_state

The monitor templates' enabled/disabled states. This will enable/disable all instances that use the specified templates. This serves as a quick and convenient method to enable/disable all instances, but if you want only to enable/disable a specific instance, use set_instance_enabled.

Valid options: STATE_DISABLED, STATE_ENABLED

####template_string_property

The string property values of the specified monitor templates.

####template_type

The template types of the specified monitor templates.

Valid options: TTYPE_UNSET, TTYPE_ICMP, TTYPE_TCP, TTYPE_TCP_ECHO, TTYPE_EXTERNAL, TTYPE_HTTP, TTYPE_HTTPS, TTYPE_NNTP, TTYPE_FTP, TTYPE_POP3, TTYPE_SMTP, TTYPE_MSSQL, TTYPE_GATEWAY, TTYPE_IMAP, TTYPE_RADIUS, TTYPE_LDAP, TTYPE_WMI, TTYPE_SNMP_DCA_BASE, TTYPE_SNMP_DCA, TTYPE_REAL_SERVER, TTYPE_UDP, TTYPE_NONE, TTYPE_ORACLE, TTYPE_SOAP, TTYPE_GATEWAY_ICMP, TTYPE_SIP, TTYPE_TCP_HALF_OPEN, TTYPE_SCRIPTED, TTYPE_WAP, TTYPE_RPC, TTYPE_SMB, TTYPE_SASP, TTYPE_MODULE_SCORE, TTYPE_FIREPASS, TTYPE_INBAND, TTYPE_RADIUS_ACCOUNTING, TTYPE_DIAMETER, TTYPE_VIRTUAL_LOCATION, TTYPE_MYSQL, TTYPE_POSTGRESQL

####template_transparent_mode

The monitor template transparent mode.

Valid options: true, false

###f5_node

Manage F5 nodes.

####name

The nodes hostname.
 
####connection_limit

The connection limits for the specified node addresses.
 
####dynamic_ratio

The dynamic ratios of a node addresses.
 
####addresses

The IP addresses of the specified node addresses.

####ratios

The ratios for the specified node addresses.

####session_enabled_state

The states that allows new sessions to be established for the specified node addresses.
 
Valid options: STATE_DISABLED, STATE_ENABLED

###f5_pool

Manage F5 pools.

####name

The name of the pool to manage.

####action_on_service_down

The action to take when the node goes down for the specified pools.

Valid options: SERVICE_DOWN_ACTION_NONE, SERVICE_DOWN_ACTION_RESET, SERVICE_DOWN_ACTION_DROP, SERVICE_DOWN_ACTION_RESELECT

####allow_nat_state

The states indicating whether NATs are allowed for the specified pool.

Valid options: STATE_DISABLED, STATE_ENABLED

####allow_snat_state

The states indicating whether SNATs are allowed for the specified pools.

Valid options: STATE_DISABLED, STATE_ENABLED

####client_ip_tos

The IP ToS values for client traffic for the specified pools.

####client_link_qos

The link QoS values for client traffic for the specified pools.

####gateway_failsafe_device

The gateway failsafe devices for the specified pools.

####lb_method

The load balancing methods for the specified pools.

Valid options: LB_METHOD_ROUND_ROBIN, LB_METHOD_RATIO_MEMBER, LB_METHOD_LEAST_CONNECTION_MEMBER, LB_METHOD_OBSERVED_MEMBER, LB_METHOD_PREDICTIVE_MEMBER, LB_METHOD_RATIO_NODE_ADDRESS, LB_METHOD_LEAST_CONNECTION_NODE_ADDRESS, LB_METHOD_FASTEST_NODE_ADDRESS, LB_METHOD_OBSERVED_NODE_ADDRESS, LB_METHOD_PREDICTIVE_NODE_ADDESS, LB_METHOD_DYNAMIC_RATIO, LB_METHOD_FASTEST_APP_RESPONSE, LB_METHOD_LEAST_SESSIONS, LB_METHOD_DYNAMIC_RATIO_MEMBER, LB_METHOD_L3_ADDR, LB_METHOD_UNKNOWN, LB_METHOD_WEIGHTED_LEAST_CONNECTION_MEMBER, LB_METHOD_WEIGHTED_LEAST_CONNECTION_NODE_ADDRESS, LB_METHOD_RATIO_SESSION, LB_METHOD_RATIO_LEAST_CONNECTION_MEMBER, LB_METHOD_RATIO_LEAST_CONNECTION_NODE_ADDRESS

####member

The list of pool members.


####membership

[todo]: no docs, have to figure that out.

Default: inclusive

####minimum_active_member

The minimum active member counts for the specified pools.

####minimum_up_member

The minimum member counts that are required to be in the up state for the specified pools.

####minimum_up_member_action

The actions to be taken if the minimum number of members required to be UP for the specified pools is not met.

####minimum_up_member_enabled_state

The states indicating that the feature that requires a minimum number of members to be UP is enabled/disabled for the specified pools.

####monitor_association

The monitor associations for the specified pools, i.e. the monitor rules used by the pools. The pool monitor association should be specified as a hash consisting of the following keys:

```
{ 'monitor_templates' => [],
  'quorum' => '0',
  'type' => 'MONITOR_RULE_TYPE_AND_LIST' }
```

####server_ip_tos

The IP ToS values for server traffic for the specified pools.

####server_link_qos

The link QoS values for server traffic for the specified pools.

####simple_timeout

The simple timeouts for the specified pools.

####slow_ramp_time

The ramp-up time (in seconds) to gradually ramp up the load on newly added or freshly detected UP pool members.

###f5_profileclientssl

Manage F5 Client SSL profiles.

####name

The name of the client SSL profile to manage.

####certificate_file

The certificate filenames to be used by BIG-IP acting as an SSL server.

####key_file

The key filenames to be used by BIG-IP acting as an SSL server. If a full path is not specified, the file name is relative to /config/ssl/ssl.key."

####ca_file

The CA to use to validate client certificates.

####client_certificate_ca_file

The CA to use to validate client certificates.

####peer_certification_mode

The peer certification modes for the specified client SSL profiles.

####chain_file

The certificate chain filenames for the specified client SSL profiles.

###f5_profilepersistence

[TODO: find right wording for this] Manage F5 Client SSL profiles.

####name

The persistence profile name.

####across_pool_state

The states to indicate whether persistence entries added under this profile are available across pools.

####across_service_state

The states to indicate whether persistence entries added under this profile are available across services.

####across_virtual_state

The states to indicate whether persistence entries added under this profile are available across virtuals.

####cookie_expiration

The cookie expiration in seconds for the specified Persistence profiles. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE.

####cookie_hash_length

The cookie hash lengths for the specified profiles. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE, and cookie persistence method is COOKIE_PERSISTENCE_METHOD_HASH.

####cookie_hash_offset

The cookie hash offsets for the specified profiles. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE, and cookie persistence method is COOKIE_PERSISTENCE_METHOD_HASH

####cookie_name

The cookie names for the specified Persistence profiles. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE.

####cookie_persistence_method

The cookie persistence methods to be used when in cookie persistence mode. Applicable when peristence mode is PERSISTENCE_MODE_COOKIE.

####default_profile

The names of the default profiles from which the specified profiles will derive default values for its attributes.

####description

The descriptions for a set of persistence profiles.

####ending_hash_pattern

The pattern marking the end of the section of payload data whose hashed value is used for the persistence value for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.

####hash_length

The length of payload data whose hashed value is used for the persistence value for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.

####hash_method

The hash method used to generate the persistence values for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH.

####hash_more_data_state

The enabled state whether to perform another hash operation after the current hash operation completes for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.

####hash_offset

The offset to the start of the payload data whose hashed value is used as the persistence value for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.

####map_proxy_address

The proxy map address used when map proxies state is enabled on source address persistence mode.

####map_proxy_class

The proxy map IP address class/datagroup name used when map known proxies state is enabled on source address persistence mode.

####map_proxy_state

The states to indicate whether to map known proxies when the persistence mode is source address affinity.

####mask

The masks used in either simple or sticky persistence mode.

####maximum_hash_buffer_size

The maximum size of the buffer used to hold the section of the payload data whose hashed value is used for the persistence value for a set of persistence values. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.

####mirror_state

The mirror states for the specified Persistence profiles.

####msrdp_without_session_directory_state

The states to indicate whether MS terminal services have been configured without a session directory for the specified Persistence profiles.

####override_connection_limit_state

The state indicating, when enabled, that the pool member connection limits are not enforced for persisted clients.

####persistence_mode

The persistence modes for the specified Persistence profiles.

####rule

The UIE rules for the specified Persistence profiles. Applicable when peristence mode is PERSISTENCE_MODE_UIE.

####sip_info

The sip_info headers for the specified Persistence profiles. Applicable when peristence mode is PERSISTENCE_MODE_SIP.

####starting_hash_pattern

The pattern marking the start of the section of payload data whose hashed value is used for the persistence value for a set of persistence profiles. This only returns useful values if the persistence mode is PERSISTENCE_MODE_HASH and the hash method is PERSISTENCE_HASH_CARP.

####timeout

The timeout for the specified Persistence profiles. The number of seconds to timeout a persistence entry.

###f5_route

Manage static routes within the F5.

####name

The name of the routing object to manage.

####description

Description of the route.

####destination

Destination of the route

####netmask

Netmask of the route.

####mtu

MTU of the route

####gateway

Gateway of the route

####pool

Pool to route to.

####vlan

VLAN to route to.

###f5_rule

####name

The name of the rule to manage.

####definition

The rule definition.

###f5_snat

#####name

The name of the snat to manage.

#####connection_mirror_state

The connection mirror states for a specified SNATs.

Valid options are: STATE_DISABLED, STATE_ENABLED

#####original_address

The list of original client addresses used to filter the traffic to the SNATs."


#####source_port_behavior

The source port behavior for the specified SNATs.

Valid options are: SOURCE_PORT_PRESERVE, SOURCE_PORT_PRESERVE_STRICT, SOURCE_PORT_CHANGE

#####translation_target

The translation targets for the specified SNATs. If the target type is SNAT_TYPE_AUTOMAP, then the translation object should be empty.

#####vlan

The list of VLANs on which access to the specified SNATs is disabled/enabled.

###f5_snatpool

####name

The name of the snatpool to manage.

####membership

Membes of the snat pool.

####member

The list of members belonging to the specified SNAT pools.

###f5_snattranslationaddress

####name

The snat translation address to manage.

####addresses

The IP addresses of the specified SNAT translation address/

####arp_state

The ARP states for the specified translation SNAT address.

Valid options are: STATE_DISABLED, STATE_ENABLED

####connection_limit

The connection limits of the specified original SNAT translation address.

####enabled_state

The state of a SNAT translation address.

Valid options are: STATE_DISABLED, STATE_ENABLED

####ip_timeout

The IP idle timeouts of the specified SNAT translation address.

####tcp_timeout

The TCP idle timeouts of the specified SNAT translation address.

####udp_timeout

The UDP idle timeouts of the specified SNAT translation addresses.

###f5_snmpconfiguration

# CURRENTLY UNAVAILABLE AND SET TO FAIL.

###f5_string_class

####name

The name of the string class to manage.

####members

The string class members.

###f5_user

####name

The user name to manage.

####user_permission

The list of user permissions.

####description

The description for the specified user.

####fullname

The full name for the specified user.

####password

The password for the specified user.

####login_shell

The login shell for the specified user.

###f5_virtualserver

####name

The virtual server name.

####clone_pool

The virtual server clone pool.

####cmp_enabled_state

The virtual server cmp enable state.

Valid options are: STATE_DISABLED, STATE_ENABLED

####connection_limit

The virtual server connection limit.

####connection_mirror_state

The virtual server connection limit.

Valid options are: STATE_DISABLED, STATE_ENABLED

####default_pool_name

The virtual server default pool name.

####destination

The virtual server destination virtual address and port.

####enabled_state

The virtual server state.

####fallback_persistence_profile

The virtual server fallback persistent profile.

####gtm_score

The virtual server gtm score.

####last_hop_pool

The virtual server lasnat64 state.

####nat64_state

The virtual server nat64 state.

Valid options are: STATE_DISABLED, STATE_ENABLED

####protocol

The virtual server protocol.

Valid options are: PROTOCOL_ANY, PROTOCOL_IPV6, PROTOCOL_ROUTING, PROTOCOL_NONE, PROTOCOL_FRAGMENT, PROTOCOL_DSTOPTS, PROTOCOL_TCP, PROTOCOL_UDP, PROTOCOL_ICMP, PROTOCOL_ICMPV6, PROTOCOL_OSPF, PROTOCOL_SCTP

####rate_class

The virtual server rate class.

####persistence_profile

The virtual server persistence profiles.

####profile

The virtual server profiles.

####rule

The virtual server rules. The rule order isn't enforced since F5 API does not provide ability to reorder rules, use irule priority to dictate rule processing order

####snat_type

The virtual server snat type.

Valid options are: SNAT_TYPE_NONE, SNAT_TYPE_TRANSLATION_ADDRESS, SNAT_TYPE_SNATPOOL, SNAT_TYPE_AUTOMAP

####snat_pool

Virtual server snat_pool.

####source_port_behavior

The virtual server source port behavior.

Valid options are: SOURCE_PORT_PRESERVE, SOURCE_PORT_PRESERVE_STRICT, SOURCE_PORT_CHANGE

####translate_address_state

The virtual server translate address state.

Valid options are: STATE_DISABLED, STATE_ENABLED

####translate_port_state

The virtual server translate port state.

Valid options are: STATE_DISABLED, STATE_ENABLED

####type

The virtual server type.

Valid options are: RESOURCE_TYPE_POOL, RESOURCE_TYPE_IP_FORWARDING, RESOURCE_TYPE_L2_FORWARDING, RESOURCE_TYPE_REJECT, RESOURCE_TYPE_FAST_L4, RESOURCE_TYPE_FAST_HTTP, RESOURCE_TYPE_STATELESS

####vlan

The virtual server vlan.

####wildmask

The virtual server wildmask.

##Limitations

- F5 v11.0+
- Nori 2.4
- Savon X

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community
contributions are essential for keeping them great. We can’t access the
huge number of platforms and myriad of hardware, software, and deployment
configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our
modules work in your environment. There are a few guidelines that we need
contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)
