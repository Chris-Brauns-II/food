# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  config.openapi_strict_schema_validation = true

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('openapi').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/openapi.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'API V1',
        version: 'v1'
      },
      paths: {},
      servers: [
        {
          url: 'https://{defaultHost}',
          variables: {
            defaultHost: {
              default: 'www.example.com'
            }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer
          }
        },
        schemas: {
          applicant: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              elevatorPitch: {
                type: :string,
                nullable: true
              },
              jobId: {
                type: :string,
                format: :uuid
              },
              seekerId: {
                type: :string,
                format: :uuid
              },
              createdAt: {
                type: :string,
                format: 'date-time'
              },
              updatedAt: {
                type: :string,
                format: 'date-time'
              }
            }
          },
          employer_applicants: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              jobId: {
                type: :string,
                format: :uuid
              },
              chatEnabled: {
                type: :boolean
              },
              certifiedBy: {
                type: :string,
                nullable: true
              },
              createdAt: {
                type: :string,
                format: 'date-time'
              },
              jobName: {
                type: :string
              },
              firstName: {
                type: :string
              },
              lastName: {
                type: :string
              },
              email: {
                type: :string,
                format: :email
              },
              phoneNumber: {
                type: :string,
                nullable: true
              },
              profileLink: {
                type: :string
              },
              programs: {
                type: :array
              },
              statusReason: {
                type: :string,
                nullable: true
              },
              status: {
                type: :string
              }
            }
          },
          employer_invite: {
            type: :object,
            properties: {
              email: {
                type: :string
              },
              firstName: {
                type: :string
              },
              lastName: {
                type: :string
              },
              usedAt: {
                type: :string,
                format: 'date-time',
                nullable: true
              },
              employerName: {
                type: :string
              },
              link: {
                type: :string
              }
            }
          },
          questions: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              title: {
                type: :string
              },
              questions: {
                type: :array,
                items: {
                  type: :string
                }
              }
            }
          },
          answers: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              title: {
                type: :string
              },
              personId: {
                type: :string,
                format: :uuid
              },
              screenerQuestionsId: {
                type: :string,
                format: :uuid
              },
              questionResponses: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/question_response'
                }
              }
            }
          },
          question_response: {
            type: :object,
            properties: {
              question: {
                type: :string
              },
              response: {
                type: :string
              }
            }
          },
          resume: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              anonymized: {
                type: :boolean
              },
              status: {
                type: :string,
                enum: Documents::DocumentStatus::ALL
              },
              generateAt: {
                type: :string,
                format: 'date-time'
              },
              documentKind: {
                type: :string,
                enum: Documents::DocumentKind::ALL
              },
              personId: {
                type: :string,
                format: :uuid
              }
            }
          },
          screener: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              status: {
                type: :string,
                enum: Documents::DocumentStatus::ALL
              },
              generateAt: {
                type: :string,
                format: 'date-time'
              },
              documentKind: {
                type: :string,
                enum: Documents::DocumentKind::ALL
              },
              personId: {
                type: :string,
                format: :uuid
              }
            }
          },
          training_provider_invite: {
            type: :object,
            properties: {
              email: {
                type: :string
              },
              firstName: {
                type: :string
              },
              lastName: {
                type: :string
              },
              usedAt: {
                type: :string,
                format: 'date-time',
                nullable: true
              },
              trainingProviderId: {
                type: :string,
                format: :uuid
              },
              trainingProviderName: {
                type: :string
              },
              roleDescription: {
                type: :string
              },
              link: {
                type: :string
              }
            }
          },
          one_user: {
            id: {
              type: :string,
              format: :uuid
            },
            firstName: {
              type: :string,
              nullable: true
            },
            lastName: {
              type: :string,
              nullable: true
            },
            email: {
              type: :string,
              nullable: true
            },
            onboarding_session: {
              type: :object,
              properties: {
                seekerId: {
                  type: :string,
                  format: 'date-time',
                  nullable: true
                }
              }
            },
            user_roles: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  role: {
                    type: :object,
                    properties: {
                      type: :string,
                      enum: Role::Types::ALL
                    }
                  }
                }
              }
            },
            notifications: {
              type: :object,
              properties: {
                notificationTitle: {
                  type: :string,
                  nullable: true
                },
                notificationBody: {
                  type: :string,
                  nullable: true
                },
                read: {
                  type: :boolean
                },
                url: {
                  type: :boolean,
                  nullable: true
                }
              }
            },
            profile: {
              id: {
                type: :string,
                format: :uuid,
                nullable: true
              },
              about: {
                type: :string,
                nullable: true
              },
              userId: {
                type: :string,
                format: :uuid,
                nullable: true
              },
              missingProfileItems: {
                type: :string,
                enum: %w[education work]
              },
              recruiter: {
                type: :object,
                properties: {
                  id: {
                    type: :string,
                    format: :uuid
                  }
                },
                nullable: true
              },
              trainingProviderProfile: {
                type: :object,
                properties: {
                  id: {
                    type: :string,
                    format: :uuid
                  }
                },
                nullable: true
              }
            }
          },
          onboarding_session: {
            type: :object,
            properties: {
              seekerId: {
                type: :string,
                format: :uuid,
                nullable: true
              },
              personId: {
                type: :string,
                format: :uuid,
                nullable: true
              },
              nextStep: {
                type: :string,
                enum: Onboarding::Steps::ALL
              },
              progress: {
                type: :integer
              }
            }
          },
          reminder: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              note: {
                type: :string
              },
              state: {
                type: :string,
                enum: Coaches::ReminderState::ALL
              },
              reminderAt: {
                type: :string,
                format: 'date-time'
              },
              contextId: {
                type: :string,
                format: :uuid,
                nullable: true
              }
            }
          },
          seeker: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              about: {
                type: :string
              },
              userId: {
                type: :string,
                format: :uuid
              },
              educationExperiences: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/education_experience'
                }
              },
              isProfileEditor: {
                type: :boolean
              },
              otherExperiences: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/other_experience'
                }
              },
              personalExperience: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/personal_experience'
                }
              },
              profileSkills: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/profile_skill'
                }
              },
              reference: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/reference_with_training_provider'
                }
              },
              stories: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/stories'
                }
              },
              missingProfileItems: {
                type: :array,
                items: {
                  type: :string,
                  enum: %w[education work]
                }
              },
              user: {
                '$ref' => '#/components/schemas/user'
              }
            }
          },
          lead: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              assignedCoach: {
                type: :string
              },
              email: {
                type: :string,
                format: :email,
                nullable: true
              },
              phoneNumber: {
                type: :string,
                nullable: true
              },
              firstName: {
                type: :string
              },
              lastName: {
                type: :string
              },
              leadCapturedAt: {
                type: :string,
                format: 'date-time',
                nullable: true
              },
              leadCapturedBy: {
                type: :string,
                format: :email,
                nullable: true
              },
              kind: {
                type: :string,
                enum: Coaches::PersonContext::Kind::ALL
              },
              status: {
                type: :string,
                enum: ["new"]
              }
            }
          },
          coach_seeker_table: {
            type: :object,
            additionalProperties: true,
            properties: {
              id: {
                type: :string
              },
              seekerId: {
                type: :string,
                format: :uuid
              },
              firstName: {
                type: :string,
                nullable: true
              },
              lastName: {
                type: :string,
                nullable: true
              },
              email: {
                type: :string,
                format: :email,
                nullable: true
              },
              phoneNumber: {
                type: :string,
                nullable: true
              },
              lastActiveOn: {
                type: :string,
                format: 'date-time',
                nullable: true
              },
              lastContacted: {
                oneOf: [
                  {
                    type: :string,
                    format: 'date-time'
                  },
                  {
                    type: :string,
                    enum: ['Never']
                  }
                ],
                nullable: true
              },
              certifiedBy: {
                type: :string,
                nullable: true
              },
              assignedCoach: {
                type: :string
              },
              barriers: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/seeker_barrier'
                }
              }
            }
          },
          coach_seeker: {
            allOf: [
              { '$ref' => '#/components/schemas/coach_seeker_table' },
              {
                type: :object,
                additionalProperties: true,
                properties: {
                  applications: {
                    type: :array,
                    items: {
                      '$ref' => '#/components/schemas/seeker_application'
                    }
                  },
                  kind: {
                    type: :string,
                    enum: Coaches::PersonContext::Kind::ALL
                  },
                  notes: {
                    type: :array,
                    items: {
                      '$ref' => '#/components/schemas/seeker_note'
                    }
                  },
                  jobRecommendations: {
                    type: :array,
                    items: {
                      type: :string,
                      format: :uuid
                    }
                  }
                }
              }
            ]
          },
          seeker_barrier: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              name: {
                type: :string,
                format: :uuid
              }
            }
          },
          seeker_note: {
            type: :object,
            properties: {
              note: {
                type: :string
              },
              noteId: {
                type: :string,
                format: :uuid
              },
              noteTakenBy: {
                type: :string,
                nullable: true
              },
              date: {
                type: :string,
                format: 'date-time'
              }
            }
          },
          seeker_application: {
            type: :object,
            properties: {
              status: {
                type: :string
              },
              employerName: {
                type: :string
              },
              jobId: {
                type: :string,
                format: :uuid,
                nullable: true
              },
              employmentTitle: {
                type: :string,
                nullable: true
              }
            }
          },
          other_experience: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              organizationName: {
                type: :string
              },
              position: {
                type: :string
              },
              startDate: {
                type: :string
              },
              endDate: {
                type: :string
              },
              isCurrent: {
                type: :boolean
              },
              description: {
                type: :string
              }
            }
          },
          education_experience: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              organizationName: {
                type: :string,
                nullable: true
              },
              title: {
                type: :string,
                nullable: true
              },
              graduationDate: {
                type: :string,
                nullable: true
              },
              gpa: {
                type: :string,
                nullable: true
              },
              activities: {
                type: :string,
                nullable: true
              }
            }
          },
          personal_experience: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              activity: {
                type: :string
              },
              startDate: {
                type: :string
              },
              endDate: {
                type: :string
              },
              description: {
                type: :string
              }
            }
          },
          profile_skill: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              description: {
                type: :string,
                nullable: true
              },
              masterSkill: {
                '$ref' => '#/components/schemas/master_skill'
              }
            }
          },
          master_skill: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              skill: {
                type: :string
              },
              type: {
                type: :string,
                enum: MasterSkill::SkillTypes::ALL
              }
            }
          },
          search_job: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              category: {
                type: :string,
                enum: Job::Categories::ALL
              },
              location: {
                type: :string
              },
              employmentTitle: {
                type: :string
              },
              industries: {
                type: :array,
                items: {
                  type: :string,
                  enum: Job::Industries::ALL
                }
              },
              startingPay: {
                type: :object,
                nullable: true,
                properties: {
                  employmentType: {
                    type: :string,
                    enum: %w[salary hourly]
                  },
                  upperLimit: {
                    type: :integer
                  },
                  lowerLimit: {
                    type: :integer
                  }
                }
              },
              tags: {
                type: :array,
                item: {
                  type: :string
                }
              },
              applicationStatus: {
                type: :string,
                enum: ApplicantStatus::StatusTypes::ALL,
                nullable: true
              },
              elevatorPitch: {
                type: :string,
                nullable: true
              },
              saved: {
                type: :boolean,
                nullable: true
              },
              employer: {
                '$ref' => '#/components/schemas/search_employer'
              }
            }
          },
          search_employer: {
            type: :object,
            additionalProperties: true,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              name: {
                type: :string
              },
              logoUrl: {
                type: :string,
                nullable: true
              }
            }
          },
          employer: {
            allOf: [
              { '$ref' => '#/components/schemas/search_employer' },
              {
                type: :object,
                additionalProperties: true,
                properties: {
                  location: {
                    type: :string,
                    nullable: true
                  },
                  bio: {
                    type: :string
                  },
                  createdAt: {
                    type: :string,
                    format: 'date-time'
                  }
                }
              }
            ]
          },
          admin_job: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              benefitsDescription: {
                type: :string
              },
              responsibilitiesDescription: {
                type: :string,
                nullable: true
              },
              employmentTitle: {
                type: :string
              },
              location: {
                type: :string
              },
              employmentType: {
                type: :string,
                enum: Job::EmploymentTypes::ALL
              },
              hideJob: {
                type: :boolean
              },
              schedule: {
                type: :string,
                nullable: true
              },
              workDays: {
                type: :string,
                nullable: true
              },
              requirementsDescription: {
                type: :string,
                nullable: true
              },
              createdAt: {
                type: :string,
                format: 'date-time'
              },
              category: {
                type: :string
              },
              employer: {
                '$ref' => '#/components/schemas/employer'
              },
              industry: {
                type: :array,
                items: {
                  type: :string
                }
              },
              jobAttributes: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    acceptibleSet: {
                      type: :array,
                      items: {
                        type: :string
                      }
                    },
                    attributeId: {
                      type: :string,
                      format: :uuid
                    },
                    attributeName: {
                      type: :string
                    }
                  }
                }
              },
              learnedSkills: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    masterSkill: {
                      '$ref' => '#/components/schemas/master_skill'
                    }
                  }
                }
              },
              desiredSkills: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    masterSkill: {
                      '$ref' => '#/components/schemas/master_skill'
                    }
                  }
                }
              },
              desiredCertifications: {
                id: {
                  type: :string,
                  format: :uuid
                },
                masterCertification: {
                  '$ref' => '#/components/schemas/master_certification'
                }
              },
              careerPaths: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/career_path'
                }
              },
              jobPhotos: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    photoUrl: {
                      type: :string
                    },
                    jobId: {
                      type: :string
                    }
                  }
                }
              },
              jobTag: {
                type: :array,
                items: {
                  id: {
                    type: :string,
                    format: :uuid
                  },
                  tag: {
                    type: :object,
                    properties: {
                      id: {
                        type: :string,
                        format: :uuid
                      },
                      name: {
                        type: :string
                      }
                    }
                  }
                }
              },
              numberOfApplicants: {
                type: :integer
              },
              testimonials: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/testimonial'
                }
              }
            }
          },
          job: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              benefitsDescription: {
                type: :string
              },
              responsibilitiesDescription: {
                type: :string,
                nullable: true
              },
              employmentTitle: {
                type: :string
              },
              location: {
                type: :string
              },
              employmentType: {
                type: :string,
                enum: Job::EmploymentTypes::ALL
              },
              schedule: {
                type: :string,
                nullable: true
              },
              workDays: {
                type: :string,
                nullable: true
              },
              requirementsDescription: {
                type: :string,
                nullable: true
              },
              category: {
                type: :string
              },
              employer: {
                '$ref' => '#/components/schemas/employer'
              },
              learnedSkills: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    masterSkill: {
                      '$ref' => '#/components/schemas/master_skill'
                    }
                  }
                }
              },
              desiredSkills: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    masterSkill: {
                      '$ref' => '#/components/schemas/master_skill'
                    }
                  }
                }
              },
              desiredCertifications: {
                id: {
                  type: :string,
                  format: :uuid
                },
                masterCertification: {
                  '$ref' => '#/components/schemas/master_certification'
                }
              },
              careerPaths: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/career_path'
                }
              },
              applicationStatus: {
                type: :string,
                enum: ApplicantStatus::StatusTypes::ALL,
                nullable: true
              },
              jobPhotos: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    photoUrl: {
                      type: :string
                    },
                    jobId: {
                      type: :string
                    }
                  }
                }
              },
              jobTag: {
                type: :array,
                items: {
                  id: {
                    type: :string,
                    format: :uuid
                  },
                  tag: {
                    type: :object,
                    properties: {
                      id: {
                        type: :string,
                        format: :uuid
                      },
                      name: {
                        type: :string
                      }
                    }
                  }
                }
              },
              testimonials: {
                type: :array,
                items: {
                  '$ref' => '#/components/schemas/testimonial'
                }
              }
            }
          },
          job_order_summary: {
            type: :object,
            additionalProperties: true,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              jobId: {
                type: :string,
                format: :uuid
              },
              employmentTitle: {
                type: :string
              },
              employerName: {
                type: :string
              },
              openedAt: {
                type: :string,
                format: 'date-time'
              },
              closedAt: {
                type: :string,
                format: 'date-time',
                nullable: true
              },
              orderCount: {
                type: :integer
              },
              hireCount: {
                type: :integer
              },
              recommendedCount: {
                type: :integer
              },
              status: {
                type: :string,
                enum: JobOrders::OrderStatus::ALL
              },
              teamId: {
                type: :string,
                format: :uuid,
                nullable: true
              }
            }
          },
          job_order: {
            allOf: [
              { '$ref' => '#/components/schemas/job_order_summary' },
              {
                type: :object,
                additionalProperties: true,
                properties: {
                  benefitsDescription: {
                    type: :string,
                    nullable: true
                  },
                  requirementsDescription: {
                    type: :string,
                    nullable: true
                  },
                  responsibilitiesDescription: {
                    type: :string,
                    nullable: true
                  },
                  candidates: {
                    type: :array,
                    items: {
                      '$ref' => '#/components/schemas/job_order_candidate'
                    }
                  },
                  notes: {
                    type: :array,
                    items: {
                      '$ref' => '#/components/schemas/job_order_note'
                    }
                  }
                }
              }
            ]
          },
          job_order_candidate: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              firstName: {
                type: :string
              },
              lastName: {
                type: :string
              },
              phoneNumber: {
                type: :string
              },
              email: {
                type: :string
              },
              appliedAt: {
                type: :string,
                format: "date-time",
                nullable: true
              },
              recommendedAt: {
                type: :string,
                format: "date-time",
                nullable: true
              },
              recommendedBy: {
                type: :string,
                nullable: true
              },
              status: {
                type: :string,
                enum: JobOrders::CandidateStatus::ALL
              },
              personId: {
                type: :string,
                format: :uuid
              }
            }
          },
          job_order_note: {
            type: :object,
            properties: {
              noteId: {
                type: :string,
                format: :uuid
              },
              note: {
                type: :string
              },
              date: {
                type: :string,
                format: "date-time"
              },
              noteTakenBy: {
                type: :string
              }
            }
          },
          job_order_job: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              employerName: {
                type: :string
              },
              employerId: {
                type: :string,
                format: :uuid
              },
              employmentTitle: {
                type: :string
              }
            }
          },
          master_certification: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              certification: {
                type: :string
              }
            }
          },
          career_path: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              title: {
                type: :string
              },
              upperLimit: {
                type: :string
              },
              lowerLimit: {
                type: :string
              },
              order: {
                type: :integer
              }
            }
          },
          testimonial: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              name: {
                type: :string
              },
              title: {
                type: :string
              },
              testimonial: {
                type: :string
              },
              photoUrl: {
                type: :string
              }
            }
          },
          user: {
            type: :object,
            additionalProperties: true,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              email: {
                type: :string,
                format: :email
              },
              firstName: {
                type: :string
              },
              lastName: {
                type: :string
              },
              zipCode: {
                type: :string,
                nullable: true
              },
              phoneNumber: {
                type: :string,
                nullable: true
              }
            }
          },
          seeker_training_provider: {
            type: :object,
            properties: {
              programId: {
                type: :string,
                format: :uuid
              },
              trainingProviderId: {
                type: :string,
                format: :uuid
              }
            }
          },
          program: {
            type: :object,
            properties: {
              name: {
                type: :string
              },
              description: {
                type: :string
              },
              trainingProviderId: {
                type: :string,
                format: :uuid
              },
              trainingProviderName: {
                type: :string
              }
            }
          },
          reference: {
            type: :object,
            additionalProperties: true,
            properties: {
              referenceText: {
                type: :string
              }
            }
          },
          training_provider: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              name: {
                type: :string
              },
              description: {
                type: :string
              },
              programs: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    id: {
                      type: :string,
                      format: :uuid
                    },
                    name: {
                      type: :string
                    },
                    description: {
                      type: :string
                    }
                  }
                }
              }
            }

          },
          reference_training_provider: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              name: {
                type: :string,
                format: :uuid
              }
            }
          },
          reference_with_training_provider: {
            allOf: [
              {
                '$ref' => '#/components/schemas/reference'
              },
              {
                type: :object,
                additionalProperties: true,
                properties: {
                  trainingProvider: {
                    '$ref' => "#/components/schemas/reference_training_provider"
                  },
                  authorUser: {
                    '$ref' => '#/components/schemas/user'
                  }
                }
              }
            ]
          },
          team: {
            type: :object,
            properties: {
              id: {
                type: :string,
                format: :uuid
              },
              name: {
                type: :string
              }
            }
          },
          not_found: {
            type: :object,
            properties: {
              error: {
                type: :string,
                enum: ['Resource not found']
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
