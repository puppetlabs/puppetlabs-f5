# Puppet Labs F5 module
Warning: this project is currently work in progress, *pending* sections are planned features.

## Overview
The F5 module was written against F5 VE version 10.1.0.3341. F5 have released version 11 with several API changes but currently they have not released any hardware or software running version 11. This provider uses several version 10.1 API, so it is not expected to work with older F5 devices.

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
* Because pluginsync only support custom facts/functions [#7316](http://projects.puppetlabs.com/issues/7316), all puppet commands needs the appropriate RUBYLIB path (including puppet master):

        export RUBYLIB=/etc/puppet/modules/f5/lib/:$RUBYLIB

For more information see: http://www.puppetlabs.com/blog/puppet-network-device-management/

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
Sample Puppet F5 manifests and usage notes where applicable. F5 API documentation:
http://devcentral.f5.com/wiki/iControl.APIReference.ashx

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

    f5_node { '192.168.1.1':
      ensure                => 'present',
      connection_limit      => '10',
      dynamic_ratio         => '1',
      ratio                 => '1',
      screen_name           => 'demo_node',
      session_enabled_state => 'STATE_ENABLED',
    }

The member attribute is not order dependent, the monitor_associate is order dependent:

    f5_pool { 'webserver':
      ensure                          => 'present',
      action_on_service_down          => 'SERVICE_DOWN_ACTION_NONE',
      allow_nat_state                 => 'STATE_ENABLED',
      allow_snat_state                => 'STATE_ENABLED',
      client_ip_tos                   => '65535',
      client_link_qos                 => '65535',
      gateway_failsafe_unit_id        => '0',
      lb_method                       => 'LB_METHOD_ROUND_ROBIN',
      member                          => ['192.168.1.1:80', '192.168.1.2:80'],
      minimum_active_member           => '0',
      minimum_up_member               => '0',
      minimum_up_member_action        => 'HA_ACTION_FAILOVER',
      minimum_up_member_enabled_state => 'STATE_DISABLED',
      monitor_association             => ['MONITOR_RULE_TYPE_AND_LIST', '0', 'http', 'Demo'],
      server_ip_tos                   => '65535',
      server_link_qos                 => '65535',
      simple_timeout                  => '0',
      slow_ramp_time                  => '10',
    }

    f5_rule { 'demo':
      ensure     => 'present',
      definition => 'when HTTP_REQUEST {}',
    }

    f5_snat { 'nat':
      ensure                  => 'present',
      connection_mirror_state => 'STATE_DISABLED',
      original_address        => ['0.0.0.0', '0.0.0.0'],
      source_port_behavior    => 'SOURCE_PORT_PRESERVE',
      translation_target      => ['SNAT_TYPE_TRANSLATION_ADDRESS', '10.10.10.10'],
      vlan                    => ['STATE_DISABLED', ''],
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

    f5_virtualserver { 'www':
      ensure                       => 'present',
      actual_hardware_acceleration => 'HW_ACCELERATION_MODE_NONE',
      cmp_enable_mode              => 'RESOURCE_TYPE_CMP_ENABLE_ALL',
      cmp_enabled_state            => 'STATE_ENABLED',
      connection_limit             => '5000000',
      connection_mirror_state      => 'STATE_DISABLED',
      destination                  => '192.168.1.1:90',
      enabled_state                => 'STATE_DISABLED',
      gtm_score                    => '0',
      protocol                     => 'PROTOCOL_TCP',
      source_port_behavior         => 'SOURCE_PORT_PRESERVE',
      translate_address_state      => 'STATE_DISABLED',
      translate_port_state         => 'STATE_ENABLED',
      type                         => 'RESOURCE_TYPE_POOL',
      vlan                         => '#<SOAP::Mapping::Object:0x104292408>',
      wildmask                     => '255.255.255.255',
    }
