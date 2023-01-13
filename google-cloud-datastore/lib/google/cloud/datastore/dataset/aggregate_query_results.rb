class AggregateQueryResults
  def self.from_grpc query_res
    aggregate_fields = query_res
                        .batch
                        .aggregation_results[0]
                        .aggregate_properties
                        .to_h
                        .transform_values { |v| v[:integer_value] }
    new.tap do |s|
      s.instance_variable_set :@aggregate_fields, aggregate_fields
    end
  end

  def get aggregate_alias
    @aggregate_fields[aggregate_alias]
  end
end