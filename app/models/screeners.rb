module Screeners
  def self.table_name_prefix
    "screeners_"
  end

  class QuestionResponse
    extend Core::Payload

    schema do
      question String
      response String
    end
  end
end
