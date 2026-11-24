class EventSerializer
  include JSONAPI::Serializer

  attributes :billetto_id, :title, :description, :url, :starts_at, :ends_at, :upvotes_count, :downvotes_count
end
