class ExportsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "exports_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end