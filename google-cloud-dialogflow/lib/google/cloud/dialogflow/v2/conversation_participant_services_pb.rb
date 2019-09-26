require 'grpc'
require 'google/cloud/dialogflow/v2/entity_type_pb'

module Google
  module Cloud
    module Dialogflow
      module V2
        module ConversationParticipants
          class Service

            include GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.dialogflow.v2.ConversationParticipants'

            rpc :StreamingAnalyzeContent, stream(StreamingAnalyzeContentRequest), stream(StreamingAnalyzeContentResponse)
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
