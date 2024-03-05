#cloud-config
package_update: true
package_upgrade: false
packages:
  - docker.io
  - docker-compose
#   - git
groups:
  - docker
system_info:
  default_user:
    groups: [docker]
write_files:
  - owner: root:root 
    path: /opt/fluent/null
  - owner: root:root 
    path: /opt/fluent/fluent.conf
    content: |
      [SERVICE]
          Flush        1
          Daemon       Off
          Log_Level    info
          Parsers_File parsers_json.conf

      [FILTER]
          Name      parser
          Key_Name *
          Match     *
          Parser    json_parser

      [INPUT]
          Name              forward
          Listen            0.0.0.0
          Port              24224
          Buffer_Chunk_Size 1M
          Buffer_Max_Size   6M

      [OUTPUT]
          Name   stdout
          format json
          Match  *
      [OUTPUT]
          Name              kafka
          Match             *
          Brokers ${fluent_bit_kafka_brokers}
          Topics ${fluent_bit_kafka_topic}
          rdkafka.security.protocol   SASL_SSL
          rdkafka.sasl.username       $ConnectionString
          rdkafka.sasl.password       ${fluent_bit_kafka_password}
          rdkafka.sasl.mechanism      PLAIN     
runcmd:
  - cd /opt/fluent
  - git clone ${repo}
  - dir=$(ls -d */)
  - cd $dir
  - git checkout feature/fluentd
  - cd docker
  - cp ../../fluent.conf .
  - docker-compose -p demo up -d
#  git clone ${repo} && cd "$(basename "$_" .git)"
#  - sudo docker run --name fluent -d -v /opt/fluent/fluent-bit.conf:/fluent-bit/etc/fluent-bit.conf fluent/fluent-bit 