class EventsController < ApplicationController
  rescue_from Billetto::Error do |error|
    render json: { error: error.message }, status: :bad_gateway
  end

  # GET /events
  def index
    events = Event.order(:starts_at).page(params[:page]).per(params[:per_page])

    render json: EventSerializer.new(events, meta: pagination_meta(events)).serializable_hash
  end

  # GET /events/:id
  def show
    render json: EventSerializer.new(Event.find(params[:id])).serializable_hash
  end

  # POST /events/sync
  def sync
    render json: { synced: Events::SyncFromBilletto.new.call }
  end

  private

  def pagination_meta(records)
    {
      current_page: records.current_page,
      per_page: records.limit_value,
      total_pages: records.total_pages,
      total_count: records.total_count
    }
  end
end
