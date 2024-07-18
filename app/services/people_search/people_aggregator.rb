module PeopleSearch
  class PeopleAggregator < MessageConsumer
    def reset_for_replay
      Coach.delete_all
      PersonExperience.delete_all
      PersonEducationExperience.delete_all
      Person.delete_all
    end

    on_message Events::PersonAdded::V1 do |message|
      person = Person.new
      person.id = message.stream.id
      person.first_name = message.data.first_name
      person.last_name = message.data.last_name
      person.email = message.data.email
      person.phone_number = message.data.phone_number
      person.date_of_birth = message.data.date_of_birth
      person.last_active_at = message.occurred_at

      person.search_vector = search_vector(person)

      person.save!
    end

    on_message Events::BasicInfoAdded::V1 do |message|
      person = find_person(message.stream.id)

      person.first_name = message.data.first_name
      person.last_name = message.data.last_name
      person.email = message.data.email || person.email
      person.phone_number = message.data.phone_number || person.phone_number

      person.search_vector = search_vector(person)

      person.save!
    end

    on_message Events::CoachAdded::V1 do |message|
      Coach.create!(
        id: message.data.coach_id,
        email: message.data.email
      )
    end

    on_message Events::CoachAssigned::V3 do |message|
      person = find_person(message.stream.id)

      coach = Coach.find(message.data.coach_id)

      person.assigned_coach = coach.email

      person.save!
    end

    on_message Events::ExperienceAdded::V2 do |message|
      person = find_person(message.stream.id)

      experience = person.experiences.find_or_initialize_by(id: message.data.id)

      experience.description = message.data.description
      experience.organization_name = message.data.organization_name
      experience.position = message.data.position

      person.search_vector = search_vector(person)

      person.save!
    end

    on_message Events::ExperienceRemoved::V2 do |message|
      person = find_person(message.stream.id)

      person.experiences.find(message.data.id).destroy!

      person.search_vector = search_vector(person.reload)

      person.save!
    end

    on_message Events::EducationExperienceAdded::V2 do |message|
      person = find_person(message.stream.id)

      ee = person.education_experiences.find_or_initialize_by(id: message.data.id)

      ee.title = message.data.title
      ee.organization_name = message.data.organization_name
      ee.activities = message.data.activities

      person.search_vector = search_vector(person)

      person.save!
    end

    on_message Events::EducationExperienceDeleted::V2 do |message|
      person = find_person(message.stream.id)

      person.education_experiences.find(message.data.id).destroy!

      person.search_vector = search_vector(person.reload)

      person.save!
    end

    on_message Events::NoteAdded::V4 do |message|
      person = find_person(message.stream.id)

      person.last_contacted_at = message.occurred_at

      person.save!
    end

    on_message Events::PersonAssociatedToUser::V1 do |message|
      person = find_person(message.stream.id)

      person.user_id = message.data.user_id

      person.save!
    end

    on_message Events::PersonCertified::V1 do |message|
      person = find_person(message.stream.id)

      person.certified_by = message.data.coach_email

      person.save!
    end

    on_message Events::SessionStarted::V1 do |message|
      person = Person.find_by(user_id: message.stream.id)

      return unless person

      person.last_active_at = message.occurred_at

      person.save!
    end

    private

    def find_person(id)
      Person.includes(:experiences, :education_experiences).find(id)
    end

    def search_vector(person)
      vector = [
        person.first_name,
        person.last_name,
        person.email,
        person.phone_number,
        person.date_of_birth
      ]

      person.experiences.each do |experience|
        vector << experience.organization_name
        vector << experience.position
        vector << experience.description
      end

      person.education_experiences.each do |education_experience|
        vector << education_experience.organization_name
        vector << education_experience.title
        vector << education_experience.activities
      end

      vector.join(" ")
    end
  end
end
