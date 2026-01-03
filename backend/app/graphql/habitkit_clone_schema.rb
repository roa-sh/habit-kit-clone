class HabitkitCloneSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)
  
  # Use batch loading to avoid N+1 queries
  use GraphQL::Batch
end

