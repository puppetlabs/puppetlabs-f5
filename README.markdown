# puppetlabs-f5 module
## Overview
Currently the testing against BigIP 10.1.0.3341. Mostly completed the get methods, haven't tested the set methods throughly yet. A list of providers:

    f5_certificate { 'ca-bundle':
      ensure => 'present',
    }
    f5_certificate { 'default':
      ensure => 'present',
    }
    f5_certificate { 'raiden':
      ensure => 'present',
    }

    f5_node { '172.16.182.153':
      ensure                => 'present',
      connection_limit      => ['0', '0'],
      dynamic_ratio         => '1',
      ratio                 => '1',
      session_enabled_state => 'STATE_ENABLED',
    }
    f5_node { '192.168.1.1':
      ensure                => 'present',
      connection_limit      => ['0', '10'],
      dynamic_ratio         => '1',
      ratio                 => '1',
      session_enabled_state => 'STATE_ENABLED',
    }

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
      monitor_association             => '#<SOAP::Mapping::Object:0x10443c470>',
      server_ip_tos                   => '65535',
      server_link_qos                 => '65535',
      simple_timeout                  => '0',
      slow_ramp_time                  => '10',
    }

    f5_rule { '_sys_https_redirect':
      ensure     => 'present',
      definition => '    when HTTP_REQUEST {
           set host [HTTP::host]
           HTTP::respond 302 Location "https://$host/"
        }',
    }
    f5_rule { 'demo':
      ensure     => 'present',
      definition => 'when HTTP_REQUEST {}',
    }

    f5_snat { 'nat_me':
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
      connection_limit => ['0', '0'],
      ip_timeout       => '4294967295',
      tcp_timeout      => '4294967295',
      udp_timeout      => '4294967295',
      unit_id          => '1',
    }
    f5_snattranslationaddress { '1.1.1.2':
      ensure           => 'present',
      arp_state        => 'STATE_ENABLED',
      connection_limit => ['0', '0'],
      ip_timeout       => '4294967295',
      tcp_timeout      => '4294967295',
      udp_timeout      => '4294967295',
      unit_id          => '1',
    }

    f5_virtualserver { 'db':
      ensure              => 'present',
      availability_status => 'AVAILABILITY_STATUS_BLUE',
      enabled_status      => 'ENABLED_STATUS_ENABLED',
    }
    f5_virtualserver { 'www':
      ensure              => 'present',
      availability_status => 'AVAILABILITY_STATUS_BLUE',
      enabled_status      => 'ENABLED_STATUS_DISABLED',
    }
