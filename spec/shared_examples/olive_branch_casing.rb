RSpec.shared_context "olive branch casing parameter" do
  parameter name: 'Key-Inflection',
            in: :header,
            schema: {
              type: :string,
              enum: %w[camel dash snake pascale]
            }
end

RSpec.shared_context "olive branch camelcasing" do
  let(:'Key-Inflection') { 'camel' }
end
