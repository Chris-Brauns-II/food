require 'rails_helper'

RSpec.describe JobOrders::JobOrdersReactor do
  it_behaves_like "a replayable message consumer"

  let(:instance) { described_class.new(message_service:) }
  let(:message_service) { MessageService.new }
  let(:trace_id) { SecureRandom.uuid }
  let(:job_order_id) { SecureRandom.uuid }
  let(:job_id) { SecureRandom.uuid }
  let(:person_id) { SecureRandom.uuid }

  describe "#add_order_count" do
    subject do
      instance.add_order_count(job_order_id:, order_count:, trace_id:)
    end

    let(:job_order_id) { 10 }
    let(:order_count) { 10 }

    it "fires off a job order order count added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: JobOrders::Events::OrderCountAdded::V1,
          job_order_id:,
          trace_id:,
          data: {
            order_count:
          }
        )

      subject
    end
  end

  describe "#close_job_order_not_filled" do
    subject do
      instance.close_job_order_not_filled(job_order_id:, trace_id:)
    end

    let(:job_order_id) { 10 }

    it "fires off a job order order activated event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: JobOrders::Events::NotFilled::V1,
          job_order_id:,
          trace_id:,
          data: Core::Nothing
        )

      subject
    end
  end

  describe "#add_note" do
    subject do
      instance.add_note(
        job_order_id:,
        originator:,
        note:,
        note_id:,
        trace_id:
      )
    end

    let(:job_order_id) { 10 }
    let(:originator) { "hannah@skillar.com" }
    let(:note) { "Great job order" }
    let(:note_id) { SecureRandom.uuid }

    it "fires off a job order note added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: JobOrders::Events::NoteAdded::V1,
          job_order_id:,
          trace_id:,
          data: {
            originator:,
            note:,
            note_id:
          }
        )

      subject
    end
  end

  describe "#modify_note" do
    subject do
      instance.modify_note(
        job_order_id:,
        originator:,
        note:,
        note_id:,
        trace_id:
      )
    end

    let(:job_order_id) { 10 }
    let(:originator) { "hannah@skillar.com" }
    let(:note) { "Great job order" }
    let(:note_id) { SecureRandom.uuid }

    it "fires off a job order note added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: JobOrders::Events::NoteModified::V1,
          job_order_id:,
          trace_id:,
          data: {
            originator:,
            note:,
            note_id:
          }
        )

      subject
    end
  end

  describe "#remove_note" do
    subject do
      instance.remove_note(
        job_order_id:,
        originator:,
        note_id:,
        trace_id:
      )
    end

    let(:job_order_id) { 10 }
    let(:originator) { "hannah@skillar.com" }
    let(:note_id) { SecureRandom.uuid }

    it "fires off a job order note added event" do
      expect(message_service)
        .to receive(:create!)
        .with(
          schema: JobOrders::Events::NoteRemoved::V1,
          job_order_id:,
          trace_id:,
          data: {
            originator:,
            note_id:
          }
        )

      subject
    end
  end

  describe "#update_status" do
    subject do
      instance.update_status(status:, job_order_id:, person_id:, trace_id:)
    end

    let(:candidate) { create(:job_orders__candidate) }
    let(:person_id) { candidate.person_id }
    let(:job_order_id) { candidate.job_order_id }

    context "added" do
      let(:status) { JobOrders::CandidateStatus::ADDED }

      it "emits a added event" do
        expect(message_service)
          .to receive(:create!)
          .with(
            schema: JobOrders::Events::CandidateAdded::V3,
            job_order_id:,
            trace_id:,
            data: {
              person_id:
            },
            metadata: {
              requestor_type: nil,
              requestor_id: nil,
              requestor_email: nil
            }
          ).and_call_original

        subject
      end
    end

    context "recommended" do
      let(:status) { JobOrders::CandidateStatus::RECOMMENDED }

      it "emits a recommended event" do
        expect(message_service)
          .to receive(:create!)
          .with(
            schema: JobOrders::Events::CandidateRecommended::V2,
            job_order_id:,
            trace_id:,
            data: {
              person_id:
            }
          ).and_call_original

        subject
      end
    end

    context "screened" do
      let(:status) { JobOrders::CandidateStatus::SCREENED }

      it "emits a screened event" do
        expect(message_service)
          .to receive(:create!)
          .with(
            schema: JobOrders::Events::CandidateScreened::V1,
            job_order_id:,
            trace_id:,
            data: {
              person_id:
            }
          ).and_call_original

        subject
      end
    end

    context "hired" do
      let(:status) { JobOrders::CandidateStatus::HIRED }

      it "emits a hired event" do
        expect(message_service)
          .to receive(:create!)
          .with(
            schema: JobOrders::Events::CandidateHired::V2,
            job_order_id:,
            trace_id:,
            data: {
              person_id:
            }
          ).and_call_original

        subject
      end
    end

    context "rescinded" do
      let(:status) { JobOrders::CandidateStatus::RESCINDED }

      it "emits a rescinded event" do
        expect(message_service)
          .to receive(:create!)
          .with(
            schema: JobOrders::Events::CandidateRescinded::V2,
            job_order_id:,
            trace_id:,
            data: {
              person_id:
            }
          ).and_call_original

        subject
      end
    end
  end

  describe "#handle_message" do
    subject { instance.handle_message(message) }

    before do
      messages.each do |message|
        Event.from_message!(message)
      end
    end

    let(:messages) { [] }

    context "when the message is add candidate" do
      let(:message) do
        build(
          :message,
          schema: JobOrders::Commands::AddCandidate::V2,
          stream:,
          data: {
            person_id:
          },
          metadata: {
            requestor_type: nil,
            requestor_id: nil,
            requestor_email: nil
          }
        )
      end
      let(:stream) { JobOrders::Streams::JobOrder.new(job_order_id: SecureRandom.uuid) }

      context "when the candidate has previously been added" do
        let(:messages) do
          [
            build(
              :message,
              schema: JobOrders::Events::CandidateAdded::V3,
              stream:,
              data: {
                person_id:
              },
              metadata: {
                requestor_type: nil,
                requestor_id: nil,
                requestor_email: nil
              }
            )
          ]
        end
        let(:message_service) { double }

        it "does nothing" do
          subject
        end
      end

      context "when the candidate has not previously been added" do
        let(:messages) { [] }

        it "emits a candidate added event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: JobOrders::Events::CandidateAdded::V3,
              stream: message.stream,
              trace_id: message.trace_id,
              data: {
                person_id: message.data.person_id
              },
              metadata: {
                requestor_type: nil,
                requestor_id: nil,
                requestor_email: nil
              }
            )
            .and_call_original

          subject
        end
      end
    end

    context "when the message is job created" do
      let(:message) do
        build(
          :message,
          schema: Events::JobCreated::V3,
          data: {
            category: Job::Categories::MARKETPLACE,
            employment_title: "A title",
            employer_name: "An employer",
            employer_id: SecureRandom.uuid,
            benefits_description: "Bad benifits",
            responsibilities_description: nil,
            location: "Columbus Ohio",
            employment_type: Job::EmploymentTypes::FULLTIME,
            hide_job: false
          }
        )
      end

      it "emits a JobOrderAdded event" do
        expect(message_service)
          .to receive(:create_once_for_trace!)
          .with(
            schema: JobOrders::Events::Added::V1,
            job_order_id: be_a(String),
            trace_id: message.trace_id,
            data: {
              job_id: message.stream.id
            }
          )

        subject
      end
    end

    context "when the message is applicant status updated" do
      let(:message) do
        build(
          :message,
          schema: Events::ApplicantStatusUpdated::V6,
          data: {
            applicant_first_name: "first_name",
            applicant_last_name: "last_name",
            applicant_email: "email",
            applicant_phone_number: "phone_number",
            seeker_id: person_id,
            user_id: "user_id",
            job_id:,
            employer_name: "employer_name",
            employment_title: "employment_title",
            status:,
            reasons: []
          },
          metadata: {}
        )
      end

      let(:person_id) { SecureRandom.uuid }
      let(:job_id) { SecureRandom.uuid }

      context "when status is not new" do
        let(:status) { ApplicantStatus::StatusTypes::INTERVIEWING }

        it "does nothing" do
          expect(message_service)
            .not_to receive(:create_once_for_trace!)

          subject
        end
      end

      context "when status is new" do
        let(:status) { ApplicantStatus::StatusTypes::NEW }

        context "when there is not a job order for the job_id" do
          let(:messages) { [] }

          it "does nothing" do
            expect(message_service)
              .not_to receive(:create_once_for_trace!)

            subject
          end
        end

        context "when there are job orders for the job_id" do
          let(:messages) { [job_order1, job_order1_closed, job_order2] }

          let(:job_order1) do
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              occurred_at: Time.zone.local(2019, 1, 1),
              data: {
                job_id:
              }
            )
          end
          let(:job_order1_closed) do
            build(
              :message,
              stream: job_order1.stream,
              schema: JobOrders::Events::NotFilled::V1,
              occurred_at: Time.zone.local(2019, 6, 1),
              data: Core::Nothing
            )
          end
          let(:job_order2) do
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              occurred_at: Time.zone.local(2020, 1, 1),
              data: {
                job_id:
              }
            )
          end

          it "emits the relevants messages" do
            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: JobOrders::Events::CandidateAdded::V3,
                trace_id: message.trace_id,
                stream: job_order2.stream,
                data: {
                  person_id:
                },
                metadata: {
                  requestor_type: nil,
                  requestor_id: nil,
                  requestor_email: nil
                }
              )
              .and_call_original

            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: JobOrders::Events::CandidateApplied::V2,
                trace_id: message.trace_id,
                stream: job_order2.stream,
                data: {
                  person_id:,
                  applied_at: message.occurred_at
                }
              )
              .and_call_original

            subject
          end
        end
      end
    end

    context "when the message is add job order" do
      let(:message) do
        build(
          :message,
          schema: JobOrders::Commands::Add::V1,
          stream:,
          data: {
            job_id:
          }
        )
      end
      let(:job_id) { SecureRandom.uuid }
      let(:stream) { JobOrders::Streams::JobOrder.new(job_order_id: SecureRandom.uuid) }

      context "when there is an active job order" do
        let(:messages) do
          [
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              stream:,
              occurred_at: Time.zone.local(2019, 1, 1),
              data: {
                job_id:
              }
            )
          ]
        end

        it "emits a job order creation failed event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: JobOrders::Events::CreationFailed::V1,
              trace_id: message.trace_id,
              stream: message.stream,
              data: {
                job_id: message.data.job_id,
                reason: "There is an existing active job order present"
              }
            )
            .and_call_original

          subject
        end
      end

      context "when there is not an active job order" do
        let(:messages) { [] }

        before do
          allow(MessageService)
            .to receive(:stream_events)
            .and_call_original

          expect(MessageService)
            .to receive(:stream_events)
            .with(Streams::Job.new(job_id: message.data.job_id))
            .and_return([])

          expect_any_instance_of(JobOrders::Projectors::JobOrderCriteriaMet)
            .to receive(:project)
            .with([])
            .and_return(met)
        end

        context "when criteria are already met" do
          let(:met) { true }

          it "emits a job order added event" do
            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: JobOrders::Events::Added::V1,
                trace_id: message.trace_id,
                stream: message.stream,
                data: {
                  job_id: message.data.job_id
                }
              )
              .and_call_original

            expect(message_service)
              .to receive(:create_once_for_stream!)
              .with(
                schema: JobOrders::Events::CriteriaAdded::V1,
                trace_id: message.trace_id,
                stream:,
                data: Core::Nothing
              )
              .and_call_original

            subject
          end
        end

        context "when criteria are not met" do
          let(:met) { false }

          it "emits a job order added event" do
            expect(message_service)
              .to receive(:create_once_for_trace!)
              .with(
                schema: JobOrders::Events::Added::V1,
                trace_id: message.trace_id,
                stream: message.stream,
                data: {
                  job_id: message.data.job_id
                }
              )
              .and_call_original

            subject
          end
        end
      end
    end

    context "when the message is activate job order" do
      let(:message) do
        build(
          :message,
          schema: JobOrders::Commands::Activate::V1,
          stream:,
          data: Core::Nothing
        )
      end
      let(:job_id) { SecureRandom.uuid }
      let(:stream) { JobOrders::Streams::JobOrder.new(job_order_id: SecureRandom.uuid) }

      context "when there is an active job order" do
        let(:messages) do
          [
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              stream:,
              occurred_at: Time.zone.local(2019, 1, 1),
              data: {
                job_id:
              }
            )
          ]
        end

        it "emits a job order activation failed event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: JobOrders::Events::ActivationFailed::V1,
              trace_id: message.trace_id,
              stream: message.stream,
              data: {
                reason: "There is an existing active job order present"
              }
            )
            .and_call_original

          subject
        end
      end

      context "when there is not a job order" do
        let(:messages) do
          []
        end

        it "reports to sentry a job order was not found" do
          expect(Sentry)
            .to receive(:capture_exception)
            .with(
              MessageConsumer::FailedToHandleMessage.new("Job Order not found", message)
            )
            .and_call_original

          subject
        end
      end

      context "when there is not an active job order" do
        let(:messages) do
          [
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              stream:,
              occurred_at: Time.zone.local(2019, 1, 1),
              data: {
                job_id:
              }
            ),
            build(
              :message,
              schema: JobOrders::Events::NotFilled::V1,
              stream:,
              occurred_at: Time.zone.local(2019, 1, 1),
              data: Core::Nothing
            )
          ]
        end

        it "emits a job order activated event" do
          expect(message_service)
            .to receive(:create_once_for_trace!)
            .with(
              schema: JobOrders::Events::Activated::V1,
              trace_id: message.trace_id,
              stream: message.stream,
              data: Core::Nothing
            )
            .and_call_original

          subject
        end
      end
    end

    context "for events that might trigger new job order status" do
      shared_examples "emits new status events if necessary" do
        context "when possible to emit a new status" do
          before do
            expect_any_instance_of(JobOrders::Projectors::JobOrderExistingStatus)
              .to receive(:project)
              .with(filtered_messages)
              .and_return(existing_status)
            expect_any_instance_of(JobOrders::Projectors::JobOrderStatus)
              .to receive(:project)
              .with(filtered_messages)
              .and_return(new_status)

            expect(MessageService)
              .to receive(:stream_events)
              .with(message.stream)
              .and_return(messages)
          end

          let(:message1) do
            build(
              :message,
              schema: JobOrders::Events::CandidateAdded::V3,
              data: {
                person_id: SecureRandom.uuid
              },
              metadata: {
                requestor_type: nil,
                requestor_id: nil,
                requestor_email: nil
              },
              occurred_at: message.occurred_at - 1.day
            )
          end
          let(:message2) do
            build(
              :message,
              schema: JobOrders::Events::CandidateAdded::V3,
              data: {
                person_id: SecureRandom.uuid
              },
              metadata: {
                requestor_type: nil,
                requestor_id: nil,
                requestor_email: nil
              },
              occurred_at: message.occurred_at + 1.day
            )
          end

          let(:messages) { [message1, message2] }
          let(:filtered_messages) { [message1] }

          context "when the current status and new status are the same" do
            let(:existing_status) do
              JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::ActivatedStatus::OPEN)
            end
            let(:new_status) do
              JobOrders::Projectors::JobOrderStatus::Projection.new(
                order_count: 1,
                criteria_met?: true,
                candidates: {},
                not_filled?: false
              )
            end

            it "does not emit a new message" do
              expect(message_service)
                .not_to receive(:create_once_for_trace!)

              subject
            end
          end

          context "when the current status and new status are the different" do
            context "when the new status should be need critiera" do
              let(:existing_status) do
                JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::StalledStatus::WAITING_ON_EMPLOYER)
              end
              let(:new_status) do
                JobOrders::Projectors::JobOrderStatus::Projection.new(
                  order_count: 2,
                  criteria_met?: false,
                  candidates: {},
                  not_filled?: false
                )
              end

              it "emits an activated event" do
                expect(message_service)
                  .to receive(:create_once_for_trace!)
                  .with(
                    trace_id: message.trace_id,
                    stream: message.stream,
                    schema: JobOrders::Events::NeedsCriteria::V1,
                    data: Core::Nothing
                  )

                subject
              end
            end

            context "when the new status should be activated" do
              let(:existing_status) do
                JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::StalledStatus::WAITING_ON_EMPLOYER)
              end
              let(:new_status) do
                JobOrders::Projectors::JobOrderStatus::Projection.new(
                  order_count: 2,
                  criteria_met?: true,
                  candidates: {},
                  not_filled?: false
                )
              end

              it "emits an activated event" do
                expect(message_service)
                  .to receive(:create_once_for_trace!)
                  .with(
                    trace_id: message.trace_id,
                    stream: message.stream,
                    schema: JobOrders::Events::Activated::V1,
                    data: Core::Nothing
                  )

                subject
              end
            end

            context "when the new status should be candidates screened" do
              let(:existing_status) do
                JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::ClosedStatus::FILLED)
              end
              let(:new_status) do
                JobOrders::Projectors::JobOrderStatus::Projection.new(
                  order_count: 2,
                  criteria_met?: true,
                  candidates: { one: :screened },
                  not_filled?: false
                )
              end

              it "emits an candidates screened event" do
                expect(message_service)
                  .to receive(:create_once_for_trace!)
                  .with(
                    trace_id: message.trace_id,
                    stream: message.stream,
                    schema: JobOrders::Events::CandidatesScreened::V1,
                    data: Core::Nothing
                  )

                subject
              end
            end

            context "when the new status should be stalled" do
              let(:existing_status) do
                JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::ActivatedStatus::OPEN)
              end
              let(:new_status) do
                JobOrders::Projectors::JobOrderStatus::Projection.new(
                  order_count: 2,
                  criteria_met?: true,
                  candidates: { one: :recommended, two: :recommended },
                  not_filled?: false
                )
              end

              it "emits an waiting on employer event" do
                expect(message_service)
                  .to receive(:create_once_for_trace!)
                  .with(
                    trace_id: message.trace_id,
                    stream: message.stream,
                    schema: JobOrders::Events::Stalled::V1,
                    data: {
                      status: JobOrders::StalledStatus::WAITING_ON_EMPLOYER
                    }
                  )

                subject
              end
            end

            context "when the new status should be filled" do
              let(:existing_status) do
                JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::ActivatedStatus::OPEN)
              end
              let(:new_status) do
                JobOrders::Projectors::JobOrderStatus::Projection.new(
                  order_count: 1,
                  criteria_met?: true,
                  candidates: { one: :hired },
                  not_filled?: false
                )
              end

              it "emits an filled event" do
                expect(message_service)
                  .to receive(:create_once_for_trace!)
                  .with(
                    trace_id: message.trace_id,
                    stream: message.stream,
                    schema: JobOrders::Events::Filled::V1,
                    data: Core::Nothing
                  )

                subject
              end
            end

            context "when the new status should be not filled" do
              let(:existing_status) do
                JobOrders::Projectors::JobOrderExistingStatus::Projection.new(status: JobOrders::ActivatedStatus::OPEN)
              end
              let(:new_status) do
                JobOrders::Projectors::JobOrderStatus::Projection.new(
                  order_count: 1,
                  criteria_met?: true,
                  candidates: { one: :hired },
                  not_filled?: true
                )
              end

              it "emits a not filled event" do
                expect(message_service)
                  .to receive(:create_once_for_trace!)
                  .with(
                    trace_id: message.trace_id,
                    stream: message.stream,
                    schema: JobOrders::Events::NotFilled::V1,
                    data: Core::Nothing
                  )

                subject
              end
            end
          end
        end
      end

      context "when the message is job order candidate added" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::CandidateAdded::V3,
            data: {
              person_id: SecureRandom.uuid
            },
            metadata: {
              requestor_type: nil,
              requestor_id: nil,
              requestor_email: nil
            }
          )
        end

        it_behaves_like "emits new status events if necessary"
      end

      context "when the message is job order candidate recommended" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::CandidateRecommended::V2,
            data: {
              person_id: SecureRandom.uuid
            }
          )
        end

        it_behaves_like "emits new status events if necessary"
      end

      context "when the message is job order candidate hired" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::CandidateHired::V2,
            data: {
              person_id: SecureRandom.uuid
            }
          )
        end

        it_behaves_like "emits new status events if necessary"
      end

      context "when the message is job order candidate rescinded" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::CandidateRescinded::V2,
            data: {
              person_id: SecureRandom.uuid
            }
          )
        end

        it_behaves_like "emits new status events if necessary"
      end

      context "when the message is job order candidate screened" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::CandidateScreened::V1,
            data: {
              person_id: SecureRandom.uuid
            }
          )
        end

        it_behaves_like "emits new status events if necessary"
      end

      context "when the message is job order added" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::OrderCountAdded::V1,
            data: {
              order_count: 2
            }
          )
        end

        it_behaves_like "emits new status events if necessary"
      end

      context "when the message is job order criteria added" do
        let(:message) do
          build(
            :message,
            schema: JobOrders::Events::CriteriaAdded::V1,
            data: Core::Nothing
          )
        end

        it_behaves_like "emits new status events if necessary"
      end
    end

    context "for events that might trigger criteria met" do
      shared_examples "emits criteria met event if necessary" do
        context "when possible to criteria met" do
          before do
            allow(MessageService)
              .to receive(:stream_events)
              .and_call_original

            expect(MessageService)
              .to receive(:stream_events)
              .with(message.stream)
              .and_return(job_messages)

            expect_any_instance_of(JobOrders::Projectors::JobOrderCriteriaMet)
              .to receive(:project)
              .with(job_messages)
              .and_return(met)
          end

          let(:job_stream) { Streams::Job.new(job_id: SecureRandom.uuid) }
          let(:job_order_stream) { JobOrders::Streams::JobOrder.new(job_order_id: SecureRandom.uuid) }
          let(:message1) do
            build(
              :message,
              schema: Events::JobCreated::V3,
              stream: job_stream,
              data: {
                category: Job::Categories::STAFFING,
                employment_title: "Plumber",
                employer_name: "Good Employer",
                employer_id: SecureRandom.uuid,
                benefits_description: "Great Benifits",
                location: "Columbus, OH",
                employment_type: Job::EmploymentTypes::FULLTIME,
                hide_job: false,
                industry: nil
              }
            )
          end
          let(:message2) do
            build(
              :message,
              schema: Events::JobAttributeCreated::V1,
              stream: job_stream,
              data: {
                id: SecureRandom.uuid,
                attribute_name: "name",
                attribute_id: SecureRandom.uuid,
                acceptible_set: %w[A B]
              }
            )
          end
          let(:message3) do
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              stream: job_order_stream,
              data: {
                job_id: job_stream.id
              }
            )
          end
          let(:message4) do
            build(
              :message,
              schema: JobOrders::Events::Added::V1,
              stream: job_order_stream,
              data: {
                job_id: SecureRandom.uuid
              }
            )
          end

          let(:job_messages) { [message1, message2] }
          let(:messages) { [message1, message2, message3, message4] }

          context "when the criteria is met" do
            let(:met) { true }

            it "does not emit a new message" do
              expect(message_service)
                .to receive(:create_once_for_stream!)
                .with(
                  schema: JobOrders::Events::CriteriaAdded::V1,
                  trace_id: message.trace_id,
                  stream: message3.stream,
                  data: Core::Nothing
                )
                .and_call_original

              subject
            end
          end

          context "when the criteria is not met" do
            let(:met) { false }
            let(:message_service) { double }

            it "does nothing" do
              subject
            end
          end
        end
      end

      context "when the message is job updated" do
        let(:message) do
          build(
            :message,
            schema: Events::JobUpdated::V2,
            stream: job_stream,
            data: {
              category: Job::Categories::STAFFING,
              employment_title: "Another title",
              employment_type: Job::EmploymentTypes::PARTTIME,
              hide_job: false
            }
          )
        end

        it_behaves_like "emits criteria met event if necessary"
      end

      context "when the message is job attribute created" do
        let(:message) do
          build(
            :message,
            schema: Events::JobAttributeCreated::V1,
            stream: job_stream,
            data: {
              id: SecureRandom.uuid,
              attribute_name: "name",
              attribute_id: SecureRandom.uuid,
              acceptible_set: %w[A B]
            }
          )
        end

        it_behaves_like "emits criteria met event if necessary"
      end

      context "when the message is job attribute updated" do
        let(:message) do
          build(
            :message,
            schema: Events::JobAttributeUpdated::V1,
            stream: job_stream,
            data: {
              id: SecureRandom.uuid,
              acceptible_set: %w[D F]
            }
          )
        end

        it_behaves_like "emits criteria met event if necessary"
      end

      context "when the message is job attribute destroyed" do
        let(:message) do
          build(
            :message,
            schema: Events::JobAttributeDestroyed::V1,
            stream: job_stream,
            data: {
              id: SecureRandom.uuid
            }
          )
        end

        it_behaves_like "emits criteria met event if necessary"
      end
    end
  end
end
