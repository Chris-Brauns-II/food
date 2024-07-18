FactoryBot.define do
  factory :attributes_attribute, class: 'Attributes::Attribute' do
    name { "attribute_name" }
    set { %w[1 2] }
    default { ["1"] }
  end
end
