require 'net/http'
require 'json'
require 'uri'

# Base URL and cluster
base_url = 'http://localhost:8080'

# ANSI color codes
GREEN = "\e[32m"
RED = "\e[31m"
BLUE = "\e[34m"
YELLOW = "\e[33m"
RESET = "\e[0m"

# Kafka UI container configuration
KAFKA_UI_ENV = [
  "-e KAFKA_CLUSTERS_0_NAME=staging_enclave",
  '-e KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS=`newrelic-vault us read -field=value discovery/staging/stg-fearful-cat/kafka-brokers-tls/endpoint`',
  '-e KAFKA_CLUSTERS_0_PROPERTIES_SECURITY_PROTOCOL=`newrelic-vault us read -field=value discovery/staging/stg-fearful-cat/kafka-brokers-tls-security-protocol/endpoint`',
  '-e KAFKA_CLUSTERS_0_READONLY=true',
  "-e KAFKA_CLUSTERS_1_NAME=production_enclave",
  '-e KAFKA_CLUSTERS_1_BOOTSTRAPSERVERS=`newrelic-vault us read -field=value discovery/production/us-rad-house/kafka-brokers-tls/endpoint`',
  '-e KAFKA_CLUSTERS_1_PROPERTIES_SECURITY_PROTOCOL=`newrelic-vault us read -field=value discovery/production/us-rad-house/kafka-brokers-tls-security-protocol/endpoint`',
  '-e KAFKA_CLUSTERS_1_READONLY=true'
].join(' ')

# Check if Kafka UI container is running
def check_and_start_kafka_ui
  container_name = "kafka-ui"
  
  # Check if container exists and is running
  container_status = `docker ps -a --filter name=#{container_name} --format "{{.Status}}" 2>/dev/null`.strip
  
  if container_status.empty?
    puts "#{GREEN}Starting Kafka UI container...#{RESET}"
    system("docker run -d --name #{container_name} -p 8080:8080 #{KAFKA_UI_ENV} provectuslabs/kafka-ui")
    sleep 5  # Give the container time to start
  elsif !container_status.include?('Up')
    puts "#{GREEN}Starting existing Kafka UI container...#{RESET}"
    system("docker start #{container_name}")
    sleep 5  # Give the container time to start
  else
    puts "#{GREEN}Kafka UI container is already running#{RESET}"
  end
end

# Start Kafka UI if needed
check_and_start_kafka_ui

# List of topics to query
topics = [
  'account_product_provisioned',
  'account_provisioned_promotions',
  'compact_account_entitlements_v2',
  'compact_customer_entitlements_v2', 
  'compact_entitlements',
  'compact_entitlements_v2',
  'compact_org_group_entitlements_v2',
  'compact_organization_entitlements_v2',
  'entity_product_provisioned'
]

# Define clusters
clusters = ['staging_enclave', 'production_enclave']

clusters.each do |cluster|
  cluster_color = cluster == 'staging_enclave' ? BLUE : YELLOW
  puts "\n#{cluster_color}Connecting to cluster: #{cluster}#{RESET}\n"

  topics.each do |topic|
    # Construct the URL
    uri = URI("#{base_url}/api/clusters/#{cluster}/topics/#{topic}/consumer-groups")
    
    begin
      # Make the HTTP request
      response = Net::HTTP.get_response(uri)
      
      if response.is_a?(Net::HTTPSuccess)
        # Parse JSON response and get unique sorted group IDs
        consumer_groups = JSON.parse(response.body)
        unique_groups = consumer_groups.map { |group| group['groupId'] }.uniq.sort
        
        puts "\n#{cluster_color}Consumer groups for topic '#{topic}':#{RESET}"
        unique_groups.each do |group_id|
          puts "- #{group_id}"
        end
      else
        puts "#{RED}Error fetching data for topic '#{topic}': #{response.code} #{response.message}#{RESET}"
      end
    rescue => e
      puts "#{RED}Error processing topic '#{topic}': #{e.message}#{RESET}"
    end
  end
end
