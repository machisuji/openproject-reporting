def minimal_query
  before do
    @query = CostQuery.new
    @query.send(:minimal_chain!)
  end
end