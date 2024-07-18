module Core
  module RequestorMetadata
    class V1
      extend Core::Payload

      schema do
        requestor_type Either(*Requestor::Kinds::ALL)
        requestor_id Either(String, nil)
      end
    end

    class V2
      extend Core::Payload

      schema do
        requestor_type Either(*Requestor::Kinds::ALL, nil)
        requestor_id Either(String, nil)
        requestor_email Either(String, nil)
      end
    end
  end
end
