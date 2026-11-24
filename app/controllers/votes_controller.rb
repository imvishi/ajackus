class VotesController < ApplicationController
  before_action :require_user!

  COMMANDS = { "up" => Voting::Commands::UpvoteEvent, "down" => Voting::Commands::DownvoteEvent }.freeze

  # POST /events/:event_id/vote   body: value=up|down   header: Authorization: Bearer <Clerk session token>
  def create
    command = COMMANDS[params[:value]]
    return render json: { error: "value must be 'up' or 'down'" }, status: :unprocessable_entity unless command

    command_bus.call(command.new(event_id: params[:event_id], user_id: current_user_id))
    render_event
  end

  # DELETE /events/:event_id/vote   header: Authorization: Bearer <Clerk session token>
  def destroy
    command_bus.call(Voting::Commands::RemoveVote.new(event_id: params[:event_id], user_id: current_user_id))
    render_event
  end

  private

  def render_event
    render json: EventSerializer.new(Event.find(params[:event_id])).serializable_hash
  end
end
