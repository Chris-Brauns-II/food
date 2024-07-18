FactoryBot.define do
  factory :document do
    id { SecureRandom.uuid }

    file_data { "\xDE\xAD\xBE\xEF" }
    file_name { "cool_file.text" }
  end
end
