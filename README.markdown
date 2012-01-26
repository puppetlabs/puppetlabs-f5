# Puppet Labs F5 module
Warning: this project is currently work in progress, *pending* sections are planned features.

## Overview
The F5 module was written against F5 VE version 10.1.0.3341. F5 have released version 11 with several API changes but currently they have not released any hardware or software running version 11. This provider uses several version 10.1 API, so it is not expected to work with older F5 devices.

Thanks to the following contributor/testers for this module (outside of PuppetLabs employees):
Bernard Nauwelaerts (bernardn)
Brenton Leanhardt (brenton)
Bretm (bretm-rh)
Scott Henson (shenson)

## Installation and Usage
Since we can not directly install a puppet agent on F5, it is managed through an intermediate proxy system running puppet agent similar to cisco devices. The requirement for the proxy system:

* Puppet 2.7.+
* F5 iControl gem

The following puppet manifest will deploy f5 gem on the f5_proxy system and deploy the appropriate config:

    node f5_proxy_system {
      include f5

      f5::config { "f5.puppetlabs.lan":
        username => 'admin',
        password => 'admin',
        url      => 'f5.puppetlabs.lan',
        target   => '/etc/puppetlabs/puppet/device/f5.puppetlabs.lan.conf'
      }

      cron { "bigip":
        command => 'puppet device --deviceconf /etc/puppetlabs/puppet/device/f5.puppetlabs.lan.conf',
        min     => fqdn_rand(60),
      }
    }

1. Create F5 Device configuration file in $confdir/device.conf (typically /etc/puppet/device.conf or /etc/puppetlabs/puppet/device.conf)

        [certname]
        type f5
        url https://username:password@address/

2. F5 Partition support is added as part of device.conf (url.path of "" or "/" is interpretted as Common partition):
        url https://username:password@address/partition

3. Create the corresponding node configuration on the puppet master site.pp:

        node f5.puppetlabs.lan {
          f5_rule { 'demo':
            ensure     => 'present',
            definition => 'when HTTP_REQUEST {}',
          }
        }

4. Execute puppet device command *:

        $ puppet device

5. Currently to simplify testing we allow usage of custom puppet fact to query/configure f5 resources against a specific system *:

        $ FACTER_url=https://admin:admin@f5.puppetlabs.lan/ puppet resource f5_rule

## Known Limitations

* puppet agent on the proxy system will only enforce the system catalog, and it will not enforce the network device catalog. Network devices should be scheduled via cron to run puppet device command with the appropriate flags.
* puppet device will run against all device specified in device.conf. If they should not be applied simultanously, maintain seperate conf files for f5 device and specify --deviceconfig.
* puppet resource attribute hash values will be squashed unless the following commit [23d5aeb](https://github.com/jhelwig/puppet/commit/23d5aeb5cbc1f55ba4f40d9def149f22d8be33aa) or feature [#9879](http://projects.puppetlabs.com/issues/9879) is included in puppet on the proxy server.
* Because pluginsync only support custom facts/functions [#7316](http://projects.puppetlabs.com/issues/7316), all puppet commands needs the appropriate RUBYLIB path (including puppet master):

        export RUBYLIB=/etc/puppet/modules/f5/lib/:$RUBYLIB

For more information see our website on [network device management](http://www.puppetlabs.com/blog/puppet-network-device-management/).

## F5 Facts
Similar to Puppet 2.7 cisco devices, the F5 facts are not collected via facter, so please review $vardir/yaml/facts for F5 system information.

    --- !ruby/object:Puppet::Node::Facts
      expiration: 2011-08-19 10:26:54.779410 -07:00
      name: bigip
      values:
        clientversion: 2.7.2
        environment: production
        clientcert: bigip
        !ruby/sym _timestamp: 2011-08-19 09:56:55.077534 -07:00
        !ruby/sym annunciator_board_part_revision: ""
        !ruby/sym annunciator_board_serial: ""
        !ruby/sym chassis_serial: b500b9b79397
        !ruby/sym disk_free_/: 82 MB
        !ruby/sym disk_free_/config: 369 MB
        !ruby/sym disk_free_/shared: 1835 MB
        !ruby/sym disk_free_/usr: 301 MB
        !ruby/sym disk_free_/var/log: 1829 MB
        !ruby/sym disk_free_/var: 2219 MB
        !ruby/sym disk_size_/: 201 MB
        !ruby/sym disk_size_/config: 398 MB
        !ruby/sym disk_size_/shared: 2015 MB
        !ruby/sym disk_size_/usr: 1007 MB
        !ruby/sym disk_size_/var/log: 2015 MB
        !ruby/sym disk_size_/var: 2421 MB
        !ruby/sym domain: puppetlabs.lan
        !ruby/sym fqdn: f5.puppetlabs.lan
        !ruby/sym group_id: DefaultGroup
        !ruby/sym hardware_cache_size: 3072 KB
        !ruby/sym hardware_cores: "1"
        !ruby/sym hardware_cpu_mhz: "2654.616"
        !ruby/sym hardware_cpus: &id002 cpus
        !ruby/sym hardware_cpus_model: *id001
        !ruby/sym hardware_cpus_slot: "0"
        !ruby/sym hardwaremodel: i686
        !ruby/sym host_board_part_revision: ""
        !ruby/sym host_board_serial: ""
        !ruby/sym hostname: f5
        !ruby/sym macaddress: 00:0C:29:B7:93:97
        !ruby/sym marketing_name: Z99
        !ruby/sym model: &id001 Intel(R) Core(TM)2 Duo CPU     P8800  @ 2.66GHz
        !ruby/sym name: *id002
        !ruby/sym os_release: 2.6.18-164.2.1.el5.1.0.f5app
        !ruby/sym os_version: "#1 SMP Sat Feb 6 00:16:40 PST 2010"
        !ruby/sym platform: Z99
        !ruby/sym product_category: Z99
        !ruby/sym pva_version: ""
        !ruby/sym slot: "0"
        !ruby/sym switch_board_part_revision: ""
        !ruby/sym switch_board_serial: ""
        !ruby/sym system_id: 568E1D2F-1974-0D1B-F952-4691FBEAE92D
        !ruby/sym system_name: Linux
        !ruby/sym timezone: PDT
        !ruby/sym uptime: 1 days
        !ruby/sym uptime_days: "1"
        !ruby/sym uptime_hours: "30"
        !ruby/sym uptime_seconds: "108141"
        !ruby/sym version: BIG-IP_v10.1.0

## Appendix
Sample Puppet F5 manifests and usage notes where applicable. See [F5 iControl API documentation](http://devcentral.f5.com/wiki/iControl.APIReference.ashx) for more more information.

f5_(key|certificate) content attribute accepts the certificate in PEM format:

    ----BEGIN CERTIFICATE-----
    MIICbDCCAdWgAwIBAgIBATANBgkqhkiG9w0BAQUFADAVMRMwEQYDVQQDDApyYWlk
    ...
    -----END CERTIFICATE-----

The certificate content can be embedded via file or template function:

    f5_key { 'ca-key':
      ensure  => 'present',
      content => file('/etc/puppet/ssl/ca_key.pem'),
      mode    => 'MANAGEMENT_MODE_DEFAULT',
    }

    f5_certificate { 'ca-bundle':
      ensure  => 'present',
      content => file('/etc/puppet/ssl/ca_bundle.pem'),
      mode    => 'MANAGEMENT_MODE_DEFAULT',
    }

Certificates comparison is completed via sha1 fingerprint which is also used during logging instead of the actual certificate content.

    notice: /Stage[main]//F5_certificate[ca-bundle]/content: content changed 'sha1(0197e53f31798d43eac830b8561887dae22fd5c2)' to 'sha1(39c2e7fa576e98431bbab66ca0cb14e01cb8bfe4)'

f5_file resource is intended for f5_external_class to manage datagroup files. The performance in v10 is slow because it requires downloading the file to calculate the file checksum. Content should be the string content of the file, and internally the type converts into md5 checksum (example below content comparison value is 'md5(b8353824beaf868010d823cf128ecc97)'). f5_files are processed in 64KB chunks per F5 [techtips recommendation](http://devcentral.f5.com/Tutorials/TechTips/tabid/63/articleType/ArticleView/articleId/144/iControl-101--06--File-Transfer-APIs.aspx).

    f5_file { '/config/addr.class':
      ensure  => 'present',
      content => 'host 192.168.1.1,
                  host 192.168.1.2 := "host 2",
                  network 192.168.2.0/24,
                  network 192.168.3.0/24 := "network 2",',
    }

    f5_monitor { 'my_https':
      ensure                    => 'present',
      manual_resume_state       => 'STATE_ENABLED',
      template_destination      => ['ATYPE_STAR_ADDRESS_STAR_PORT', '*:*'],
      template_integer_property => { 'ITYPE_INTERVAL'            => '5',
                                     'ITYPE_PROBE_INTERVAL'      => '0',
                                     'ITYPE_PROBE_NUM_PROBES'    => '0',
                                     'ITYPE_PROBE_NUM_SUCCESSES' => '0',
                                     'ITYPE_PROBE_TIMEOUT'       => '0',
                                     'ITYPE_TIMEOUT'             => '16',
                                     'ITYPE_TIME_UNTIL_UP'       => '0',
                                     'ITYPE_UNSET'               => '0',
                                     'ITYPE_UP_INTERVAL'         => '0' },
      template_state            => 'STATE_ENABLED',
      template_string_property  => { 'STYPE_CIPHER_LIST'        => 'DEFAULT:+SHA:+3DES:+kEDH',
                                     'STYPE_CLIENT_CERTIFICATE' => '',
                                     'STYPE_CLIENT_KEY'         => '',
                                     'STYPE_PASSWORD'           => '',
                                     'STYPE_RECEIVE'            => '',
                                     'STYPE_SEND'               => 'GET /',
                                     'STYPE_SSL_OPTIONS'        => 'enabled',
                                     'STYPE_USERNAME'           => '' },
      template_transparent_mode => 'false',
      template_type             => 'TTYPE_HTTPS',
    }

    f5_node { '192.168.1.1':
      ensure                => 'present',
      connection_limit      => '10',
      dynamic_ratio         => '1',
      ratio                 => '1',
      screen_name           => 'demo_node',
      session_enabled_state => 'STATE_ENABLED',
    }

F5_pool resource notes:

* The member attribute is not order dependent, the monitor_associate is order dependent.
* The member attribute may contain addresses A.B.C.D%ID such as: 192.168.1.1.%0, ID indicates route domain (0 is common).

See [F5 documentation](http://support.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos_management_guide_10_1/tmos_route_domains.html) for more information.

    f5_pool { 'webserver':
      ensure                          => 'present',
      action_on_service_down          => 'SERVICE_DOWN_ACTION_NONE',
      allow_nat_state                 => 'STATE_ENABLED',
      allow_snat_state                => 'STATE_ENABLED',
      client_ip_tos                   => '65535',
      client_link_qos                 => '65535',
      gateway_failsafe_unit_id        => '0',
      lb_method                       => 'LB_METHOD_ROUND_ROBIN',
      member                          => { '192.168.1.1:80' => { 'ratio'            => '1' ,
                                                                 'dynamic_ratio'    => '1',
                                                                 'priority'         => '2',
                                                                 'connection_limit' => '0' },
                                           '192.168.1.2:80' => { 'ratio'            => '1',
                                                                 'dynamic_ratio'    => '1',
                                                                 'priority'         => '1',
                                                                 'connection_limit' => '0' } },
      minimum_active_member           => '0',
      minimum_up_member               => '0',
      minimum_up_member_action        => 'HA_ACTION_FAILOVER',
      minimum_up_member_enabled_state => 'STATE_DISABLED',
      monitor_association             => { 'monitor_templates' => ['http', 'demo'],
                                           'quorum'            => '0',
                                           'type'              => 'MONITOR_RULE_TYPE_AND_LIST' },
      server_ip_tos                   => '65535',
      server_link_qos                 => '65535',
      simple_timeout                  => '0',
      slow_ramp_time                  => '10',
    }

    f5_rule { 'demo':
      ensure     => 'present',
      definition => 'when HTTP_REQUEST {}',
    }

    f5_selfip { 'fd88:d0a3:9645:6b83::':
      ensure         => 'present',
      netmask        => 'ffff:ffff:ffff:ffff:0000:0000:0000:0000',
      floating_state => 'STATE_DISABLED',
      unit_id        => 0,
      vlan           => 'vlan_test_01'
    }

    f5_snat { 'nat':
      ensure                  => 'present',
      connection_mirror_state => 'STATE_DISABLED',
      original_address        => ['0.0.0.0', '0.0.0.0'],
      source_port_behavior    => 'SOURCE_PORT_PRESERVE',
      translation_target      => ['SNAT_TYPE_TRANSLATION_ADDRESS', '10.10.10.10'],
      vlan                    => { 'state' => 'STATE_DISABLED',
                                   'vlans' => ['default'] },
    }

    f5_snatpool { 'nat_pool':
      ensure => 'present',
      member => ['1.1.1.1', '1.1.1.2'],
    }

    f5_snattranslationaddress { '1.1.1.1':
      ensure           => 'present',
      arp_state        => 'STATE_ENABLED',
      connection_limit => '0',
      enabled_state    => 'STATE_ENABLED',
      ip_timeout       => '4294967295',
      tcp_timeout      => '4294967295',
      udp_timeout      => '4294967295',
      unit_id          => '1',
    }

F5_virtualserver does not atomically change rules (F5 API limitation), so to reorder rule priority please use irule priority which can be modified in f5_rule. See [F5 documentation](http://devcentral.f5.com/wiki/iRules.priority.ashx).

    f5_virtualserver { 'www':
      ensure                  => 'present',
      cmp_enable_mode         => 'RESOURCE_TYPE_CMP_ENABLE_ALL',
      cmp_enabled_state       => 'STATE_ENABLED',
      connection_limit        => '5000000',
      connection_mirror_state => 'STATE_DISABLED',
      destination             => '192.168.1.1:90',
      enabled_state           => 'STATE_DISABLED',
      gtm_score               => '0',
      protocol                => 'PROTOCOL_TCP',
      profile                 => { 'http'       => 'PROFILE_CONTEXT_TYPE_ALL',
                                   'oneconnect' => 'PROFILE_CONTEXT_TYPE_ALL' },
      rule                    => [ 'demo', 'demo2' ],
      snat_pool               => 'alpha',
      snat_type               => 'SNAT_TYPE_SNATPOOL',
      source_port_behavior    => 'SOURCE_PORT_PRESERVE',
      translate_address_state => 'STATE_ENABLED',
      translate_port_state    => 'STATE_ENABLED',
      type                    => 'RESOURCE_TYPE_POOL',
      vlan                    => { 'state' => 'STATE_DISABLED',
                                   'vlans' => ['default'] },
      wildmask                => '255.255.255.255',
    }

    f5_vlan { 'vlan_test_01':
      ensure                 => 'present',
      vlan_id                => 127,
      member                 => [
        { member_name => '1.2', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_TAGGED' },
        { member_name => '1.3', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_TAGGED' },
        { member_name => '1.4', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_TAGGED' },
        { member_name => '1.5', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_UNTAGGED' },
      ],
      failsafe_action        => 'HA_ACTION_RESTART_ALL',
      failsafe_state         => 'STATE_DISABLED',
      failsafe_timeout       => 60,
      learning_mode          => 'LEARNING_MODE_ENABLE_FORWARD',
      mtu                    => 1000,
      static_forwarding      => [
        { mac_address => '02:02:29:97:79:92', 'interface_name' => '1.2', 'interface_type' => 'MEMBER_INTERFACE' },
        { mac_address => '02:02:29:97:79:93', 'interface_name' => '1.3', 'interface_type' => 'MEMBER_INTERFACE' },
        { mac_address => '02:02:29:97:79:95', 'interface_name' => '1.5', 'interface_type' => 'MEMBER_INTERFACE' }
      ],
      source_check_state     => 'STATE_ENABLED',
      mac_masquerade_address => '02:02:29:97:79:90',
    }

F5_virtualserver attribute profile_persistence should configure the value => false. Currently, it does not appear that this can be configured to true:

    persistence_profile: persistence_profile changed '{"ssl"=>"false", "cookie"=>"false"}' to '{"ssl"=>false, "cookie"=>true}'

    > transport[wsdl].add_persistence_profile(resource[:name], [[{"default_profile"=>"true", "profile_name"=>"ssl"}, {"default_profile"=>"false", "profile_name"=>"cookie"}]])
    > transport[wsdl].get_persistence_profile(resource[:name])
    => [[#<SOAP::Mapping::Object:0x827c3f1c {}profile_name="cookie" {}default_profile=false>, #<SOAP::Mapping::Object:0x827c207c {}profile_name="ssl" {}default_profile=false>]]

F5 datagroup consists of f5_string_class and f5_external_class. f5_external_class will autorequire f5_files that matches the file_name (fully qualified file path).

    f5_string_class { 'default_accept_language':
      ensure  => 'present',
      members => {'en' => '', 'ja' => '', 'zh-cn' => '', 'zh-tw' => ''},
    }

f5_external_class resource using external data group should subscribe to f5_file to trigger a data reload when the file content changes.  This issue is explained in further details in the following [F5 techtip](http://devcentral.f5.com/Tutorials/TechTips/tabid/63/articleType/ArticleView/articleId/33/Forcing-a-reload-of-External-Data-Groups-within-an-iRule.aspx).

    f5_external_class { 'addr':
      ensure         => 'present',
      data_separator => ':=',
      file_format    => 'FILE_FORMAT_CSV',
      file_mode      => 'FILE_MODE_TYPE_READ_WRITE',
      file_name      => '/config/addr.class',
      type           => 'CLASS_TYPE_ADDRESS',
      subscribe      => F5_file['/config/addr.class'],
    }
    
F5_snmpconfiguration configures the SNMP agent

    f5_snmpconfiguration { 'agent':
    access_info                => [
      { access_context => 'access_context_01', access_name => 'access_map_01', level => 'LEVEL_NOAUTH', model => 'MODEL_V2C', notify_access => 'c', prefix => 'PREFIX_PREFIX', read_access => 'r', write_access => 'w'},
      { access_context => 'access_context_02', access_name => 'access_map_02', level => 'LEVEL_NOAUTH', model => 'MODEL_V2C', notify_access => 'c', prefix => 'PREFIX_PREFIX', read_access => 'r', write_access => 'w'},
    ],
    agent_group_id             => 'agent_group_01',
    agent_interface            => {
      intf_name  => '',
      intf_speed => '',
      intf_type  => ''
    },
    agent_listen_address       => [
      { ipport => { address => '', port => 161}, transport => 'TRANSPORT_UDP6'},
      { ipport => { address => '', port => 161}, transport => 'TRANSPORT_TCP6'},
      { ipport => { address => '105.0.1.1', port =>1161}, transport => 'TRANSPORT_TCP6'},
      { ipport => { address => '105.0.2.1', port =>2161}, transport => 'TRANSPORT_TCP6'},     
    ],
    agent_trap_state           => 'STATE_ENABLED',
    agent_user_id              => 'agent_user_01',
    auth_trap_state            => 'STATE_DISABLED',
    check_disk                 => [
      { check_type => 'DISKCHECK_SIZE', disk_path => '/',    minimum_space => 2000},
      { check_type => 'DISKCHECK_SIZE', disk_path => '/var', minimum_space => 10000},
    ],
    check_file                 => [
      { file_name => '/tmp/foo',    maximum_size => 2000 },
      { file_name => '/tmp/bar',    maximum_size => 2000 },
      { file_name => '/tmp/baz',    maximum_size => 2000 },
    ],
    check_load                 => {
      max_1_minute_load  => 12,
      max_5_minute_load  => 11,
      max_15_minute_load => 10
    },
    check_process              => [
      { max => 1, min => 1, process_name => '/usr/bin/bigd'},
      { max => 1, min => 1, process_name => '/bin/chmand'},
      { max => 0, min => 1, process_name => '/usr/sbin/httpd'},
      { max => 1, min => 1, process_name => '/bin/mcpd'},
      { max => 1, min => 1, process_name => '/usr/bin/sod'},
      { max => 1, min => 0, process_name => '/tmp/foo'},
    ],
    client_access              => [
      { address => '127.',      netmask => '' },
      { address => '105.0.1.1', netmask => '' },
      { address => '105.0.2.1', netmask => '' },
    ],
    community_to_security_info => [
      { community_name => 'community_name_01', ipv6 => 'false', security_name => 'security_name_01', source => 'source_01'},
      { community_name => 'community_name_02', ipv6 => 'false', security_name => 'security_name_02', source => 'source_02'},
    ],
    exec                       => [
      { mib_num => '', name_prog_args => { process_name => '1', program_args => 'foo', program_name => '/bin/foo'}},
      { mib_num => '', name_prog_args => { process_name => '2', program_args => 'bar', program_name => '/bin/bar'}},
    ],
    exec_fix                   => [
      { process_name => '/bin/foo', program_args => '', program_name => 'foo'},
      { process_name => '/bin/bar', program_args => '', program_name => 'bar'},
      { process_name => '/bin/baz', program_args => '', program_name => 'baz'},
    ],
    generic_traps_v2           => [
      { sink_host => 'snmp.example.com', sink_port => 162, snmpcmd_args => '-v 2c -c public'},
      { sink_host => 'snmp.example.org', sink_port => 162, snmpcmd_args => '-v 2c -c public'},
    ],
    group_info                 => [
      { group_name => 'group_name_01', model => 'MODEL_ANY', security_name => 'security_name_01'},
      { group_name => 'group_name_02', model => 'MODEL_ANY', security_name => 'security_name_02'},
    ],
    ignore_disk                => [
      '/dev/sdy1',
      '/dev/sdz1'
    ],
    pass_through               => [
      { mib_oid   => 1, exec_name => '/tmp/foo' },
      { mib_oid   => 2, exec_name => '/tmp/bar' },
    ],
    pass_through_persist       => [
      { mib_oid   => 1, exec_name => '/tmp/foo' },
      { mib_oid   => 2, exec_name => '/tmp/bar' },
    ],
    process_fix                => [
      { process_name => '/bin/foo', program_name => 'foo', program_args => '--noargs' },
      { process_name => '/bin/bar', program_name => 'bar', program_args => '--noargs' },
    ],
    proxy                      => [
      'snmp-proxy-01.example.com',
      'snmp-proxy-2.example.com',
    ],
    readonly_community         => [
      { community => 'public', 'ipv6' => 'false', 'oid' => '', 'source' => 'default'},
      { community => 'commu_t_01', 'ipv6' => 'false', 'oid' => 'oid_test_01', 'source' => 'sefg'},
    ],
    readonly_user              => [
      {'level' => 'LEVEL_PRIV', 'oid' => '.1.3.6.1.2.1.2.2.1.8.1301', 'user' => 'test_user_ro_01'},
      {'level' => 'LEVEL_PRIV', 'oid' => '.1.3.6.1.2.1.2.2.1.8.1301', 'user' => 'test_user_ro_02'},
    ],
    readwrite_community         => [
      { community => 'private', 'ipv6' => 'false', 'oid' => '', 'source' => 'default'},
      { community => 'commu_rw_01', 'ipv6' => 'false', 'oid' => 'oid_test_01', 'source' => 'sefg'},
    ],
    readwrite_user             => [
      {'level' => 'LEVEL_PRIV', 'oid' => '.1.3.6.1.2.1.2.2.1.8.1301', 'user' => 'toto'},
      {'level' => 'LEVEL_PRIV', 'oid' => '.1.3.6.1.2.1.2.2.1.8.1301', 'user' => 'test_user_rw_02'},
    ],
    system_information         => {
      sys_name        => "BigIP_01",
      sys_location    => "Office01 - ServerRoom01 - Rack01 - U01",
      sys_contact     => "Infrastructure (noc@example.com)",
      sys_description => "Traffic Manager Unit 01",
      sys_object_id   => "LTM01",
      sys_services    => 76
    },
    trap_community             => 'public',
    view_info                  => [
      { view_name => 'view_info_01', type => 'VIEW_INCLUDED', subtree   => '', masks     => '' },
      { view_name => 'view_info_02', type => 'VIEW_EXCLUDED', subtree   => '', masks     => '' },
    ],
  }


F5 provision resource notes :

    Provision level can be NONE, MINIMUM, NOMINAL, DEDICATED or CUSTOM. The custom level allows you specify a value between 0 and 255 for CPU, disk and memory usage.

    f5_provision { 'TMOS_MODULE_LTM':
      level               => 'PROVISION_LEVEL_NOMINAL',
    }

    f5_provision { 'TMOS_MODULE_ASM':
      custom_cpu_ratio    => '127',
      custom_disk_ratio   => '127',
      custom_memory_ratio => '127',
      level               => 'PROVISION_LEVEL_CUSTOM',
    }

F5 license manages the device's licence file.

    f5_license { 'license':
      license_file_data => file('/path/to/bigip.licence'),
    }

F5 VLAN resource notes :

    f5_vlan { 'vlan_test_01':
      ensure                 => 'present',
      vlan_id                => 127,
      member                 => [
        { member_name => '1.2', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_TAGGED' },
        { member_name => '1.3', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_TAGGED' },
        { member_name => '1.4', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_TAGGED' },
        { member_name => '1.5', 'member_type' =>  'MEMBER_INTERFACE', 'tag_state' => 'MEMBER_UNTAGGED' },
      ],
      failsafe_state         => 'STATE_DISABLED',
      failsafe_timeout       => 60,
      
      failsafe_action        => 'HA_ACTION_RESTART_ALL',
      learning_mode          => 'LEARNING_MODE_ENABLE_FORWARD',
      mtu                    => 1000,
      static_forwarding      => [
        { mac_address => '02:02:29:97:79:92', 'interface_name' => '1.2', 'interface_type' => 'MEMBER_INTERFACE' },
        { mac_address => '02:02:29:97:79:93', 'interface_name' => '1.3', 'interface_type' => 'MEMBER_INTERFACE' },
        { mac_address => '02:02:29:97:79:95', 'interface_name' => '1.5', 'interface_type' => 'MEMBER_INTERFACE' },  
      ],
      source_check_state     => 'STATE_ENABLED',
      mac_masquerade_address => '02:02:29:97:79:90',
    }  

## Development

The following section applies to developers of this module only.

### Testing

You will need to install the 'f5-icontrol' gem for most of the tests to work.
This file is available in the 'files' section of this module.

    gem install --no-ri files/f5-icontrol-10.2.0.2.gem
