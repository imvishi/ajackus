module Events
  class SyncFromBilletto
    def call
      rows = Billetto::PublicEvents.new(limit: 100).call.map do |event|
        {
          billetto_id: event["id"].to_s,
          title: event["title"],
          description: event["description"],
          url: event["url"],
          starts_at: event["startdate"],
          ends_at: event["enddate"]
        }
      end

      Event.upsert_all(rows, unique_by: :billetto_id) if rows.any?
      rows.size
    end
  end
end
