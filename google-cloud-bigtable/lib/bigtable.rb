# frozen_string_literal: true

require "logger"

module Bigtable
  # Logger
  # Default logger is standered output. To send logger instead of standered
  # output
  # @example
  #   Bigtable::LOGGER = Logger.new('bigtable_client.log')
  #   Bigtable::LOGGER.level = Logger::WARN
  LOGGER = Logger.new(STDOUT)

  # Create instance admin client
  # @param project_id [String]
  # @param options [Hash]
  # @example
  #   require "google-cloud-bigtable"
  #
  #   client = Bigtable.instance_admin_client("project-id")
  #
  #   # Or with keyfile
  #   client = Bigtable.instance_admin_client(
  #     "project-id",
  #     credentials: "keyfile.json"
  #   )

  def self.instance_admin_client \
      project_id,
      options = {}

    require "bigtable/instance_admin_client"

    InstanceAdminClient.new(project_id, options)
  end

  # Create table admin client
  # @param project_id [String]
  # @param instance_id [String]
  # @param options [Hash]
  # @example
  #   require "google-cloud-bigtable"
  #
  #   client = Bigtable.table_admin_client("project-id", "instance-id")
  #
  #   # Or with keyfile
  #   client = Bigtable.table_admin_client(
  #     "project-id",
  #     "instance-id"
  #     credentials: "keyfile.json"
  #   )

  def self.table_admin_client \
      project_id,
      instance_id,
      options = {}

    require "bigtable/table_admin_client"

    TableAdminClient.new(project_id, instance_id, options)
  end

  # Create client for data operations.
  # @param project_id [String]
  # @param instance_id [String]
  # @param options [Hash]
  # @example
  #   require "google-cloud-bigtable"
  #
  #   client = Bigtable.client("project-id", "instance_id")
  #
  #   # Or with keyfile
  #   client = Bigtable.table_admin_client(
  #     "project-id",
  #     "instance-id"
  #     credentials: "keyfile.json"
  #   )
  #
  def self.client \
      project_id,
      instance_id,
      options = {}

    require "bigtable/client"

    Client.new(project_id, instance_id, options)
  end
end
