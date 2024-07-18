FactoryBot.define do
  factory :employer do
    id { SecureRandom.uuid }
    name { "Acme Inc." }
    bio { "We are a company." }
    location { "Columbus, OH" }
    logo_url { 'https://media.licdn.com/dms/image/C4E0BAQGLeh2i2nqj-A/company-logo_200_200/0/1528380278542?e=2147483647&v=beta&t=L9tuLliGKhuA4_WGgrM1frOOSuxR6aupcExGE-r45g0' }
  end
end
