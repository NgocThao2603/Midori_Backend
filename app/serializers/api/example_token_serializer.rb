module Api
  class ExampleTokenSerializer < ActiveModel::Serializer
    attributes :id, :jp_token, :vn_token, :token_index
  end
end
