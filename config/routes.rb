require 'sidekiq/web'

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'employers/jobs' => 'employers/jobs#index'
  put 'employers/applicants/:id' => 'employers/applicants#update', as: 'employers_applicant'

  scope module: 'coaches', path: 'coaches' do
    resources :attributes
    resources :contexts do
      resources :notes, only: %i[create update destroy]

      post 'skill-levels' => 'contexts#update_skill_level'
      post 'assign_coach' => 'contexts#assign'
      post 'recommend_job' => 'contexts#recommend_job'
      put 'update_barriers' => 'seeker_barriers#update_all'
    end
    resources :tasks, only: %i[index]
    scope path: 'tasks' do
      post 'reminders' => "tasks#create_reminder"
      put 'reminders/:id/complete' => "tasks#complete_reminder"
    end
    resources :feeds
    resources :seekers do
      post 'certify' => 'seekers#certify'
      resources :attributes, only: %i[create update destroy]
    end
    resources :leads, only: %i[create index]
    resources :jobs, only: [:index], as: 'coaches_jobs'
    resources :job_orders, only: %i[index recommend] do
      post 'recommend' => 'job_orders#recommend'
    end
  end
  resources :coaches

  scope module: 'screeners', path: 'screeners' do
    resources :questions, only: %i[index create update show]
    resources :answers, only: %i[create update show]
  end

  scope module: 'employers', path: 'employers' do
    resources :chats do
      post 'send_message' => 'chats#send_message', on: :collection
      post 'mark_read' => 'chats#mark_read', on: :collection
    end
  end

  scope module: 'teams', path: 'teams' do
    resources :teams, only: [:index]
  end

  scope module: 'contact', path: 'contact' do
    scope module: 'cal_dot_com', path: 'cal_dot_com' do
      resources :webhooks, only: [:create]
    end
  end

  scope module: 'job_orders', path: 'job_orders' do
    resources :jobs, only: [:index]

    resources :orders do
      resources :notes
      post "activate" => "orders#activate"
      post "close_not_filled" => "orders#close_not_filled"

      resources :candidates
    end
  end

  scope module: 'documents', path: 'documents' do
    resources :resumes, only: %i[create index show]
    resources :screeners, only: %i[create index show]
  end

  resources :employers
  resources :session, only: [:create]

  post 'hooks/:id' => 'hooks#event', as: 'hooks_event'

  post 'notifications/mark_read' => 'notifications#mark_read'

  mount Sidekiq::Web => '/sidekiq'

  resources :master_certifications
  resources :master_skills

  resources :one_user, only: [:index]

  resources :pass_reasons

  post 'onboarding_sessions' => 'onboarding_sessions#create'
  put 'onboarding_sessions' => 'onboarding_sessions#update'
  get 'onboarding_sessions' => 'onboarding_sessions#show'

  resources :users
  resources :profiles, only: %i[show] do
    resources :stories
    resources :skills
    resources :education_experiences
    resources :personal_experiences
    resources :other_experiences
  end
  resources :programs do
    scope module: 'programs' do
      resources :students
    end
  end

  resources :jobs do
    post 'apply' => 'jobs#apply'
    post 'elevator_pitch' => 'jobs#elevator_pitch'
    resources :career_paths do
      put 'up' => 'career_paths#up'
      put 'down' => 'career_paths#down'
    end
    resources :desired_skills
    resources :learned_skills
    resources :desired_certifications
    resources :testimonials
    resources :job_photos
    resources :job_tags
  end

  get 'training_providers/programs' => 'training_providers/programs#index'
  post 'training_providers/invites' => 'training_providers/invites#create'
  resources :training_providers do
    scope module: 'training_providers' do
      resources :programs
    end
  end

  scope module: 'seekers', path: 'seekers' do
    resources :jobs, only: [:index] do
      post 'save' => 'jobs#save'
      post 'unsave' => 'jobs#unsave'
    end

    resources :chats do
      post 'send_message' => 'chats#send_message', on: :collection
      post 'mark_read' => 'chats#mark_read', on: :collection
    end
  end

  namespace :admin do
    resources :attributes
    resources :jobs do
      resources :job_attributes
    end
    resources :users
  end

  resources :employer_invites do
    put 'used' => 'employer_invites#used'
  end
  resources :training_provider_invites do
    put 'used' => 'training_provider_invites#used'
  end

  if Rails.env.local?
    resource :test do
      post '/reset_database' => 'test#reset_test_database'
      post '/create_user' => 'test#create_test_user'
      post '/create_coach' => 'test#create_coach'
      post '/create_seeker' => 'test#create_seeker'
      post '/create_job' => 'test#create_job'
      post '/create_seeker_lead' => 'test#create_seeker_lead'
      post '/create_active_seeker' => 'test#create_active_seeker'
      get '/assert_no_failed_jobs' => 'test#assert_no_failed_jobs'
      get '/jobs_settled' => 'test#jobs_settled'
      post '/clear_failed_jobs' => 'test#clear_failed_jobs'
      post '/create_test_trainer_with_student' => 'test#create_test_trainer_with_student'
      post '/create_recruiter_with_applicant' => 'test#create_test_recruiter_with_applicant'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "main#index"

  get '/auth/auth0/callback' => 'auth0#callback'
  get '/auth/failure' => 'auth0#failure'
  get '/auth/logout' => 'auth0#logout'
end
