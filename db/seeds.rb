load 'spec/builders/user_builder.rb'
load 'spec/builders/person_builder.rb'

message_service = MessageService.new

JobStruct = Struct.new(
  :id,
  :category,
  :employer,
  :benefits_description,
  :responsibilities_description,
  :employment_title,
  :location,
  :employment_type,
  :hide_job,
  :industry,
  :schedule,
  :work_days,
  :requirements_description,
  keyword_init: true
)

EmployerStruct = Struct.new(
  :id,
  :name,
  :bio,
  :location,
  :logo_url
)

TrainingProviderStruct = Struct.new(
  :id,
  :name,
  :description
)

ProgramStruct = Struct.new(
  :id,
  :name,
  :description
)

turner_employer = EmployerStruct.new(
  id: 'eeaba08a-1ade-4250-b23c-0ae331576d2a',
  name: 'Turner Construction Company',
  bio: 'Turner is a North America-based, international construction services company and is a leading builder in diverse and numerous market segments. The company has earned recognition for undertaking large, complex projects, fostering',
  location: 'Global',
  logo_url:
    'https://media.licdn.com/dms/image/C4E0BAQGLeh2i2nqj-A/company-logo_200_200/0/1528380278542?e=2147483647&v=beta&t=L9tuLliGKhuA4_WGgrM1frOOSuxR6aupcExGE-r45g0'
)

sg_employer = EmployerStruct.new(
  id: 'c844012e-751b-4d0a-af62-89339a3f8af4',
  name: 'The Superior Group',
  bio: 'The Superior Group is a ​national leader in electrical construction, engineering, and technology services.',
  location: 'Ohio',
  logo_url:
    'https://media.licdn.com/dms/image/C4E0BAQGLeh2i2nqj-A/company-logo_200_200/0/1528380278542?e=2147483647&v=beta&t=L9tuLliGKhuA4_WGgrM1frOOSuxR6aupcExGE-r45g0'
)

mechanic_job = JobStruct.new(
  id: '08cedbc3-2e7b-4ba0-b7af-03df98c187b3',
  category: Job::Categories::STAFFING,
  employer: turner_employer,
  benefits_description: 'Dental insurance Vision insurance Disability insurance 401(k)',
  responsibilities_description:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
  employment_title: 'Level 2 Mechanic',
  location: 'Columbus, OH',
  employment_type: 'FULLTIME',
  hide_job: false,
  industry: %w[manufacturing construction],
  schedule: '40-55 hours weekly',
  work_days: 'Weekdays',
  requirements_description:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'
)

earthwork_job = JobStruct.new(
  id: 'c2c2d40d-4028-409e-8145-e77384a44daf',
  category: Job::Categories::STAFFING,
  employer: sg_employer,
  benefits_description: 'Dental insurance Vision insurance Disability insurance 401(k)',
  responsibilities_description:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
  employment_title: 'Earthwork Journeyman',
  industry: ['construction'],
  location: 'Dublin, OH',
  employment_type: 'PARTTIME',
  hide_job: false,
  schedule: '40 hours weekly',
  work_days: 'Weekdays, flexible',
  requirements_description:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'
)

contractor = JobStruct.new(
  id: '25ecbccf-9043-4da8-91b1-a5eee5c63634',
  category: Job::Categories::STAFFING,
  employer: sg_employer,
  benefits_description: 'Dental insurance, Vision insurance, Disability insurance 401(k)',
  responsibilities_description:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.',
  employment_title: 'General Contractor',
  industry: %w[healthcare construction],
  location: 'New Albany, OH',
  employment_type: 'FULLTIME',
  hide_job: false,
  schedule: '40-50 hours, weekly',
  work_days: 'Weekdays, some weekends',
  requirements_description:
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.'
)

megans_recruits = TrainingProviderStruct.new(
  id: SecureRandom.uuid,
  name: "Megan's Recruits",
  description: "We train people to help them get jobs"
)

cul = TrainingProviderStruct.new(
  id: SecureRandom.uuid,
  name: 'Columbus Urban League',
  description: 'We are super good at doing the thing we do which is to help the people we work with get jobs'
)

cool_program = ProgramStruct.new(
  id: SecureRandom.uuid,
  name: 'Cool Program',
  description: 'You learn stuff'
)

welding = ProgramStruct.new(
  id: SecureRandom.uuid,
  name: 'Welding Class 2023 Q1',
  description: 'You weld stuff'
)

plumbing = ProgramStruct.new(
  id: SecureRandom.uuid,
  name: 'Plumbing Class 2023 Q1',
  description: 'You plumb stuff'
)

carpentry = ProgramStruct.new(
  id: SecureRandom.uuid,
  name: 'Carpentry Class 2023 Q1',
  description: 'You carp stuff'
)

message_service.create!(
  employer_id: turner_employer.id,
  schema: Events::EmployerCreated::V1,
  data: {
    name: turner_employer.name,
    location: turner_employer.location,
    bio: turner_employer.bio,
    logo_url: turner_employer.logo_url
  }
)

message_service.create!(
  employer_id: sg_employer.id,
  schema: Events::EmployerCreated::V1,
  data: {
    name: sg_employer.name,
    location: sg_employer.location,
    bio: sg_employer.bio,
    logo_url: sg_employer.logo_url
  }
)

Builders::UserBuilder.new(message_service).build_as_recruiter(
  id: SecureRandom.uuid,
  first_name: 'Recruiter',
  last_name: 'User',
  email: 'recruiter@blocktrianapp.com',
  sub: 'recruitersub',
  employer_id: turner_employer.id,
  employer_name: turner_employer.name
)

message_service.create!(
  job_id: mechanic_job.id,
  schema: Events::JobCreated::V3,
  data: {
    category: mechanic_job.category,
    employment_title: mechanic_job.employment_title,
    employer_name: mechanic_job.employer.name,
    employer_id: mechanic_job.employer.id,
    benefits_description: mechanic_job.benefits_description,
    responsibilities_description: mechanic_job.responsibilities_description,
    location: mechanic_job.location,
    employment_type: mechanic_job.employment_type,
    hide_job: mechanic_job.hide_job,
    schedule: mechanic_job.schedule,
    work_days: mechanic_job.work_days,
    requirements_description: mechanic_job.requirements_description,
    industry: mechanic_job.industry
  }
)

message_service.create!(
  job_id: earthwork_job.id,
  schema: Events::JobCreated::V3,
  data: {
    category: earthwork_job.category,
    employment_title: earthwork_job.employment_title,
    employer_name: earthwork_job.employer.name,
    employer_id: earthwork_job.employer.id,
    benefits_description: earthwork_job.benefits_description,
    responsibilities_description: earthwork_job.responsibilities_description,
    location: earthwork_job.location,
    employment_type: earthwork_job.employment_type,
    hide_job: earthwork_job.hide_job,
    schedule: earthwork_job.schedule,
    work_days: earthwork_job.work_days,
    requirements_description: earthwork_job.requirements_description,
    industry: earthwork_job.industry
  }
)

message_service.create!(
  job_id: contractor.id,
  schema: Events::JobCreated::V3,
  data: {
    category: contractor.category,
    employment_title: contractor.employment_title,
    employer_name: contractor.employer.name,
    employer_id: contractor.employer.id,
    benefits_description: contractor.benefits_description,
    responsibilities_description: contractor.responsibilities_description,
    location: contractor.location,
    employment_type: contractor.employment_type,
    hide_job: contractor.hide_job,
    schedule: contractor.schedule,
    work_days: contractor.work_days,
    requirements_description: contractor.requirements_description,
    industry: contractor.industry
  }
)

tags = [
  {
    id: SecureRandom.uuid,
    name: 'No experience needed'
  },
  {
    id: SecureRandom.uuid,
    name: 'No experience needed'
  },
  {
    id: SecureRandom.uuid,
    name: 'Part time only'
  },
  {
    id: SecureRandom.uuid,
    name: 'Transportation assistance'
  },
  {
    id: SecureRandom.uuid,
    name: 'ESL-Friendly'
  },
  {
    id: SecureRandom.uuid,
    name: 'Fair chance employer'
  }
]

tags.each do |tag|
  message_service.create!(
    schema: Events::TagCreated::V1,
    tag_id: tag[:id],
    data: {
      name: tag[:name]
    }
  )
end

trained_seeker_with_reference = Builders::PersonBuilder.new(message_service).build(
  first_name: 'Tom',
  last_name: 'Hanks',
  phone_number: "+16666666666",
  email: 'trained-seeker-with-reference@skillarc.com',
  date_of_birth: "1963-06-14"
)

trained_seeker = Builders::PersonBuilder.new(message_service).build(
  first_name: 'Tim',
  last_name: 'Allen',
  email: 'trained-seeker@skillarc.com',
  phone_number: "+13333333333",
  date_of_birth: "1990-10-09"
)

seeker_with_profile = Builders::PersonBuilder.new(message_service).build(
  first_name: 'Rita',
  last_name: 'Wilson',
  phone_number: "+14444444444",
  email: 'seeker-with-profile@skillarc.com',
  date_of_birth: "1993-01-01"
)

message_service.create!(
  application_id: SecureRandom.uuid,
  schema: Events::ApplicantStatusUpdated::V6,
  data: {
    applicant_first_name: seeker_with_profile.first_name,
    applicant_last_name: seeker_with_profile.last_name,
    applicant_email: seeker_with_profile.email,
    applicant_phone_number: seeker_with_profile.phone_number,
    seeker_id: seeker_with_profile.id,
    user_id: seeker_with_profile.user_id,
    job_id: mechanic_job.id,
    employer_name: mechanic_job.employer.name,
    employment_title: mechanic_job.employment_title,
    status: ApplicantStatus::StatusTypes::NEW,
    reasons: []
  },
  metadata: {}
)

message_service.create!(
  training_provider_id: megans_recruits.id,
  schema: Events::TrainingProviderCreated::V1,
  data: {
    name: megans_recruits.name,
    description: megans_recruits.description
  }
)

message_service.create!(
  training_provider_id: cul.id,
  schema: Events::TrainingProviderCreated::V1,
  data: {
    name: cul.name,
    description: cul.description
  }
)

message_service.create!(
  training_provider_id: megans_recruits.id,
  schema: Events::TrainingProviderProgramCreated::V1,
  data: {
    program_id: cool_program.id,
    name: cool_program.name,
    description: cool_program.description
  }
)

message_service.create!(
  training_provider_id: cul.id,
  schema: Events::TrainingProviderProgramCreated::V1,
  data: {
    program_id: welding.id,
    name: welding.name,
    description: welding.description
  }
)

message_service.create!(
  training_provider_id: cul.id,
  schema: Events::TrainingProviderProgramCreated::V1,
  data: {
    program_id: plumbing.id,
    name: plumbing.name,
    description: plumbing.description
  }
)

message_service.create!(
  training_provider_id: cul.id,
  schema: Events::TrainingProviderProgramCreated::V1,
  data: {
    program_id: carpentry.id,
    name: carpentry.name,
    description: carpentry.description
  }
)

Builders::UserBuilder.new(message_service).build_as_trainer(
  id: SecureRandom.uuid,
  first_name: 'Cul',
  last_name: 'Trainer',
  email: 'trainer@skillarc.com',
  sub: "culTrainer",
  training_provider_id: cul.id,
  training_provider_name: cul.name,
  role_description: "A good trainer"
)

trainer_profile_id = SecureRandom.uuid
Builders::UserBuilder.new(message_service).build_as_trainer(
  id: SecureRandom.uuid,
  first_name: 'Bill',
  last_name: 'Traynor',
  sub: "meagansTrainer",
  email: 'trainer-with-reference@skillarc.com',
  training_provider_id: megans_recruits.id,
  training_provider_name: megans_recruits.name,
  training_provider_profile_id: trainer_profile_id,
  role_description: "A good who refers"
)

admin_user = Builders::UserBuilder.new(message_service).build(
  id: SecureRandom.uuid,
  first_name: 'Jake',
  last_name: 'Not-Onboard',
  sub: "admin",
  email: 'admin@skillarc.com',
  roles: [Role::Types::ADMIN, Role::Types::EMPLOYER_ADMIN]
)

Builders::UserBuilder.new(message_service).build(
  id: SecureRandom.uuid,
  first_name: 'Job',
  last_name: 'Master',
  sub: "job_order",
  email: 'job_order@skillarc.com',
  roles: [Role::Types::JOB_ORDER_ADMIN]
)

message_service.create!(
  schema: Events::PersonTrainingProviderAdded::V1,
  person_id: trained_seeker_with_reference.id,
  data: {
    id: SecureRandom.uuid,
    program_id: cool_program.id,
    training_provider_id: megans_recruits.id,
    status: "Enrolled"
  }
)

message_service.create!(
  schema: Events::PersonTrainingProviderAdded::V1,
  person_id: trained_seeker.id,
  data: {
    id: SecureRandom.uuid,
    program_id: plumbing.id,
    training_provider_id: cul.id,
    status: "Enrolled"
  }
)

message_service.create!(
  schema: Events::PersonTrainingProviderAdded::V1,
  person_id: trained_seeker.id,
  data: {
    id: SecureRandom.uuid,
    program_id: welding.id,
    training_provider_id: cul.id,
    status: "Enrolled"
  }
)

message_service.create!(
  schema: Events::PersonTrainingProviderAdded::V1,
  person_id: trained_seeker_with_reference.id,
  data: {
    id: SecureRandom.uuid,
    program_id: carpentry.id,
    training_provider_id: cul.id,
    status: "Enrolled"
  }
)

message_service.create!(
  reference_id: SecureRandom.uuid,
  schema: Events::ReferenceCreated::V2,
  data: {
    training_provider_id: megans_recruits.id,
    seeker_id: trained_seeker_with_reference.id,
    author_training_provider_profile_id: trainer_profile_id,
    reference_text: 'This person is good at carpentry'
  }
)

Builders::PersonBuilder.new(message_service).build(
  first_name: 'Coach',
  last_name: 'User',
  sub: "Coach",
  email: 'coach@skillarc.com',
  roles: [Role::Types::COACH]
)

team1_id = SecureRandom.uuid
team2_id = SecureRandom.uuid

message_service.create!(
  schema: Teams::Events::Added::V1,
  team_id: team1_id,
  data: {
    name: "Team 1"
  }
)

message_service.create!(
  schema: Teams::Events::Added::V1,
  team_id: team2_id,
  data: {
    name: "Team 2"
  }
)

message_service.create!(
  schema: JobOrders::Events::TeamResponsibleForStatus::V1,
  order_status: JobOrders::ActivatedStatus::OPEN,
  data: {
    team_id: team1_id
  }
)
message_service.create!(
  schema: JobOrders::Events::TeamResponsibleForStatus::V1,
  order_status: JobOrders::ActivatedStatus::NEEDS_ORDER_COUNT,
  data: {
    team_id: team2_id
  }
)

message_service.create!(
  schema: Events::PassReasonAdded::V1,
  pass_reason_id: SecureRandom.uuid,
  data: {
    description: "This candidate does not meet the role requirements"
  }
)
message_service.create!(
  schema: Events::PassReasonAdded::V1,
  pass_reason_id: SecureRandom.uuid,
  data: {
    description: "The role is filled, no longer accepting applications"
  }
)
message_service.create!(
  schema: Events::PassReasonAdded::V1,
  pass_reason_id: SecureRandom.uuid,
  data: {
    description: "The role is seasonal or pausing accepting candidates"
  }
)
message_service.create!(
  schema: Events::PassReasonAdded::V1,
  pass_reason_id: SecureRandom.uuid,
  data: {
    description: "This candidate is a better for another role"
  }
)
message_service.create!(
  schema: Events::PassReasonAdded::V1,
  pass_reason_id: SecureRandom.uuid,
  data: {
    description: "The candidate did not show up for the interview"
  }
)

message_service.create!(
  schema: Events::AttributeCreated::V1,
  attribute_id: SecureRandom.uuid,
  data: {
    name: "Background",
    description: "The candidate has a criminal background that may be a barrier to employment",
    set: %w[Misdemeanor Felony Violent],
    default: ["Misdemeanor"]
  }
)

message_service.create!(
  schema: Events::BarrierAdded::V1,
  user_id: admin_user.id,
  data: {
    barrier_id: SecureRandom.uuid,
    name: "Unable to Drive"
  }
)

message_service.create!(
  schema: Events::BarrierAdded::V1,
  user_id: admin_user.id,
  data: {
    barrier_id: SecureRandom.uuid,
    name: "Background"
  }
)

message_service.flush

message_service.create!(
  job_id: mechanic_job.id,
  schema: Events::JobTagCreated::V1,
  data: {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    tag_id: tags[0][:id]
  }
)

career_paths = [
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    title: 'Level 1',
    upper_limit: '60000',
    lower_limit: '55000',
    order: 0
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    title: 'Level 2',
    upper_limit: '65000',
    lower_limit: '60000',
    order: 1
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    title: 'Level 3',
    upper_limit: '70000',
    lower_limit: '65000',
    order: 2
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    title: 'Apprentice',
    upper_limit: '50',
    lower_limit: '45',
    order: 0
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    title: 'Journeyman',
    upper_limit: '60',
    lower_limit: '50',
    order: 1
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    title: 'Super',
    upper_limit: '80',
    lower_limit: '60',
    order: 2
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    title: 'Entry Level',
    upper_limit: '65000',
    lower_limit: '60000',
    order: 0
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    title: 'Mid-Level',
    upper_limit: '75000',
    lower_limit: '70000',
    order: 1
  }
]

career_paths.each do |career_path|
  message_service.create!(
    job_id: career_path[:job_id],
    schema: Events::CareerPathCreated::V1,
    data: {
      id: career_path[:id],
      job_id: career_path[:job_id],
      title: career_path[:title],
      lower_limit: career_path[:lower_limit],
      upper_limit: career_path[:upper_limit],
      order: career_path[:order]
    }
  )
end

jobs_photos = [
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    photo_url:
      'https://images.unsplash.com/photo-1517524206127-48bbd363f3d7?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bWVjaGFuaWN8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    photo_url:
      'https://images.unsplash.com/photo-1632733711679-529326f6db12?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTd8fG1lY2hhbmljfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    photo_url:
      'https://images.unsplash.com/photo-1599474151975-1f978922fa02?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fG1lY2hhbmljfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    photo_url:
      'https://plus.unsplash.com/premium_photo-1661899566960-942b158bab49?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8ZWFydGh3b3JrfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    photo_url:
      'https://images.unsplash.com/photo-1675600653433-c9f0040f62b0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fGVhcnRod29ya3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    photo_url:
      'https://images.unsplash.com/photo-1612878100556-032bbf1b3bab?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fGVhcnRod29ya3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    photo_url:
      'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8Y29uc3RydWN0aW9uJTIwd29ya2VyfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    photo_url:
      'https://plus.unsplash.com/premium_photo-1664299941780-e8badc0b1617?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8Y29uc3RydWN0aW9uJTIwd29ya2VyfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  }
]

jobs_photos.each do |job_photo|
  message_service.create!(
    job_id: job_photo[:job_id],
    schema: Events::JobPhotoCreated::V1,
    data: {
      id: job_photo[:id],
      job_id: job_photo[:job_id],
      photo_url: job_photo[:photo_url]
    }
  )
end

testimonials = [
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    name: 'Jane Doe',
    testimonial:
      'Ive worked here for 7 years and love it! This company is like a second family',
    title: 'Project Manager',
    photo_url:
      'https://plus.unsplash.com/premium_photo-1665865607224-9dcd2f488b38?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fHdvbWFufGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    name: 'Jack Wilson',
    testimonial: 'TSG is a great company. Fair pay, and great benefits!',
    title: 'Plumber',
    photo_url:
      'https://plus.unsplash.com/premium_photo-1682724031797-710f0ac9193f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y29uc3RydWN0aW9uJTIwd29ya2VyfGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    name: 'Lauren Jackson',
    testimonial: 'I love my job.',
    title: 'Project Accountant',
    photo_url:
      'https://plus.unsplash.com/premium_photo-1665865607224-9dcd2f488b38?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fHdvbWFufGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    name: 'John Doe',
    testimonial: 'This is a great place to work!',
    title: 'Project Manager',
    photo_url:
      'https://plus.unsplash.com/premium_photo-1665865607224-9dcd2f488b38?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTl8fHdvbWFufGVufDB8fDB8fHww&auto=format&fit=crop&w=800&q=60'
  },
]

testimonials.each do |testimonial|
  message_service.create!(
    job_id: testimonial[:job_id],
    schema: Events::TestimonialCreated::V1,
    data: {
      id: testimonial[:id],
      job_id: testimonial[:job_id],
      name: testimonial[:name],
      title: testimonial[:title],
      testimonial: testimonial[:testimonial],
      photo_url: testimonial[:photo_url]
    }
  )
end

master_certifications = [
  {
    id: 'a7ce3140-6b1a-4804-8071-364e7c80c44a',
    certification: "Driver's License"
  },
  {
    id: 'bf8ff563-3df5-47a7-9e19-3a374b15e8a8',
    certification: 'High School Diploma'
  },
  {
    id: '44a6b1a5-8cef-4eeb-b6c5-a0b762fca5ea',
    certification: 'GED'
  },
  {
    id: 'c67bec6a-31e9-4cbe-893d-804ac281a4eb',
    certification: 'Fire Alarm License'
  },
  {
    id: '93cc2a36-1c3a-42d6-8ffb-b1a2edce9238',
    certification: 'OSHA 10'
  },
  {
    id: '59e97302-5339-4443-a811-21d1ce09d0aa',
    certification: 'OSHA 30'
  },
  {
    id: 'cd122e26-f1af-4a1c-91fd-371e60ed73fa',
    certification: 'Forklift Certified'
  },
  {
    id: '3dd6ac83-8d19-4460-82bb-db9794b3d5d3',
    certification: 'CDL A'
  },
  {
    id: '0f34f1e7-7937-43af-941a-a4e12e9c46c4',
    certification: 'CDL B'
  },
  {
    id: '9ea915c1-54be-4817-9703-f3f22f3f09a7',
    certification: 'Customer Service'
  },
  {
    id: 'baa510a2-f96b-4f41-9164-90eaceca0c90',
    certification: 'Journeyman'
  },
  {
    id: 'c6332c74-bcfb-40fc-a823-e81fac6cd3d6',
    certification: 'Crane Operation'
  },
  {
    id: '422c829b-89d2-46a8-b120-d3dc5d0e6f08',
    certification: 'Certified Construction Manager (CCM)'
  },
  {
    id: 'c1be79ab-6908-4614-a486-f7ffe788f269',
    certification: 'Certified Safety Manger'
  },
  {
    id: '90a3c873-e9b4-47ae-a05d-440eb98326d6',
    certification: 'Certified Phlebotomy Technician (CPT)'
  },
  {
    id: 'b6dd096c-078d-43d4-bed7-94826e2b859c',
    certification: 'Certified Patient Care Technician (CPCT)'
  },
  {
    id: '0b27db4a-8687-4cd2-ab14-38367aa97830',
    certification: 'Certified Medical Assistant (CMA)'
  },
  {
    id: 'd533c908-e4a4-4fe8-a598-9a5ae3083c99',
    certification: 'Certified Nursing Assistant (CNA)'
  },
  {
    id: 'e1680acf-10ed-4456-85d8-3bb2f2f449f4',
    certification: 'Home Health Aid'
  },
  {
    id: '17ed7a82-749a-4527-b573-dfd11a59cec8',
    certification: 'Emergency Medical Technician (EMT)'
  },
  {
    id: '9368b029-4c64-4217-bbe4-34e0978da839',
    certification: 'Healthcare Compliance Certification'
  },
  {
    id: '09448e8b-5aba-4692-8339-4dddabbc564e',
    certification: 'Medical Biller and Coder Certification'
  },
  {
    id: '103fdb43-23d9-4f0a-9ec7-f2296f7662e5',
    certification: 'Certified Pharmacy Technician'
  },
]

master_certifications.each do |master_certification|
  message_service.create!(
    schema: Events::MasterCertificationCreated::V1,
    master_certification_id: master_certification[:id],
    data: {
      certification: master_certification[:certification]
    }
  )
end

master_skills = [
  {
    id: '3703d7d0-e20a-4635-a9d9-2092c7b03000',
    skill: 'Adaptability',
    type: 'PERSONAL'
  },
  {
    id: 'c4ca3bc7-b7e7-4193-ac90-532e0179a474',
    skill: 'Communication',
    type: 'PERSONAL'
  },
  {
    id: 'e0627968-c5f8-4f2c-9b23-948d2374644f',
    skill: 'Creativity',
    type: 'PERSONAL'
  },
  {
    id: 'c0f0442f-e01f-4aab-82c8-91e41cee2bbd',
    skill: 'Dependability',
    type: 'PERSONAL'
  },
  {
    id: 'ef0b7921-171d-4157-93bf-bf309f73ad57',
    skill: 'Interpersonal Skills',
    type: 'PERSONAL'
  },
  {
    id: '64543e56-dcc4-46f6-adec-b2a166149d3c',
    skill: 'Leadership',
    type: 'PERSONAL'
  },
  {
    id: 'f7b9b9a5-43a4-488d-a600-01a3018c2e1e',
    skill: 'Professionalism',
    type: 'PERSONAL'
  },
  {
    id: '5a12a33d-058b-4ba0-91c3-0725bade34ae',
    skill: 'Self Awareness',
    type: 'PERSONAL'
  },
  {
    id: 'a1f51ba9-3988-4e74-8fea-71bb1357a312',
    skill: 'Teamwork',
    type: 'PERSONAL'
  },
  {
    id: '8a39653c-530b-4abe-a12e-56c981544caa',
    skill: 'Willingness to Learn',
    type: 'PERSONAL'
  },
  {
    id: '58b90c17-fead-4af9-a8db-3ac152b0ad7e',
    skill: 'Other',
    type: 'PERSONAL'
  },
  {
    id: 'c1698e1e-c5ec-4f9d-8007-cb5a3f1b1968',
    skill: 'Math Basics',
    type: 'TECHNICAL'
  },
  {
    id: '7d76ec3e-2727-403b-9f0c-6fb75e31ebb7',
    skill: 'Physically able',
    type: 'TECHNICAL'
  },
  {
    id: '2b5d40f4-ec34-4eb8-9732-2264e9c88184',
    skill: 'Digital Technology Basics',
    type: 'TECHNICAL'
  },
  {
    id: '7ec2826d-8d1a-4433-9c94-ff194ceec7f9',
    skill: 'Customer Service',
    type: 'TECHNICAL'
  },
  {
    id: 'f3bc0510-6ad8-4159-aa63-f9504572fd5c',
    skill: 'Marketing/Sales',
    type: 'TECHNICAL'
  },
  {
    id: 'f33952cb-1f5b-4633-8697-095bd7a7d0ce',
    skill: 'Accounting/Budgeting',
    type: 'TECHNICAL'
  },
  {
    id: 'ec27be9b-53df-4fc1-808b-850fc7b723b0',
    skill: 'Blueprint Reading',
    type: 'TECHNICAL'
  },
  {
    id: '21a392df-5f88-4da4-a489-d1ef221b0771',
    skill: 'Computer Basics',
    type: 'TECHNICAL'
  },
  {
    id: 'ebb772a4-e7e9-4bac-9110-95e895b5dfe7',
    skill: 'Conflict Management',
    type: 'TECHNICAL'
  },
  {
    id: 'a294d91b-189a-4c9d-a88f-46addb1350f4',
    skill: 'Mechanical Aptitude',
    type: 'TECHNICAL'
  },
  {
    id: '0148f08f-f9ca-41e9-ad06-22665714bdaf',
    skill: 'Negotiation',
    type: 'TECHNICAL'
  },
  {
    id: '731e5aa5-e8d4-4a4e-9acb-3de414a17773',
    skill: 'Reading & Writing',
    type: 'TECHNICAL'
  },
  {
    id: 'c3dd6dbf-b974-4590-b5f8-3e316ea4e81e',
    skill: 'Time Management',
    type: 'TECHNICAL'
  },
  {
    id: '674464b5-66cc-423b-9297-7acdbab980c7',
    skill: 'Web Development',
    type: 'TECHNICAL'
  },
  {
    id: '5f3adf92-5bdc-4f2e-9e1b-8792cf0f6ff9',
    skill: 'Other',
    type: 'TECHNICAL'
  },
]

master_skills.each do |master_skill|
  message_service.create!(
    schema: Events::MasterSkillCreated::V1,
    master_skill_id: master_skill[:id],
    data: {
      skill: master_skill[:skill],
      type: master_skill[:type]
    }
  )
end

desired_skills = [
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: '3703d7d0-e20a-4635-a9d9-2092c7b03000'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: 'e0627968-c5f8-4f2c-9b23-948d2374644f'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: 'f33952cb-1f5b-4633-8697-095bd7a7d0ce'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: '0148f08f-f9ca-41e9-ad06-22665714bdaf'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: '731e5aa5-e8d4-4a4e-9acb-3de414a17773'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: 'c4ca3bc7-b7e7-4193-ac90-532e0179a474'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: 'f7b9b9a5-43a4-488d-a600-01a3018c2e1e'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: 'c3dd6dbf-b974-4590-b5f8-3e316ea4e81e'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: 'ebb772a4-e7e9-4bac-9110-95e895b5dfe7'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: '3703d7d0-e20a-4635-a9d9-2092c7b03000'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: 'a1f51ba9-3988-4e74-8fea-71bb1357a312'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: '7d76ec3e-2727-403b-9f0c-6fb75e31ebb7'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: 'c3dd6dbf-b974-4590-b5f8-3e316ea4e81e'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: '7d76ec3e-2727-403b-9f0c-6fb75e31ebb7'
  },
]

desired_skills.each do |desired_skill|
  message_service.create!(
    job_id: desired_skill[:job_id],
    schema: Events::DesiredSkillCreated::V1,
    data: {
      id: desired_skill[:id],
      job_id: desired_skill[:job_id],
      master_skill_id: desired_skill[:master_skill_id]
    }
  )
end

learned_skills = [
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: 'ef0b7921-171d-4157-93bf-bf309f73ad57'
  },
  {
    id: SecureRandom.uuid,
    job_id: mechanic_job.id,
    master_skill_id: 'ec27be9b-53df-4fc1-808b-850fc7b723b0'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: '3703d7d0-e20a-4635-a9d9-2092c7b03000'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: '5a12a33d-058b-4ba0-91c3-0725bade34ae'
  },
  {
    id: SecureRandom.uuid,
    job_id: earthwork_job.id,
    master_skill_id: 'f33952cb-1f5b-4633-8697-095bd7a7d0ce'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: '3703d7d0-e20a-4635-a9d9-2092c7b03000'
  },
  {
    id: SecureRandom.uuid,
    job_id: contractor.id,
    master_skill_id: '731e5aa5-e8d4-4a4e-9acb-3de414a17773'
  },
]

learned_skills.each do |learned_skill|
  message_service.create!(
    job_id: learned_skill[:job_id],
    schema: Events::LearnedSkillCreated::V1,
    data: {
      id: learned_skill[:id],
      job_id: learned_skill[:job_id],
      master_skill_id: learned_skill[:master_skill_id]
    }
  )
end

message_service.flush
