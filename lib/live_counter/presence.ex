defmodule LiveCounter.Presence do
  use Phoenix.Presence,
    otp_app: :live_counter,
    pubsub_server: LiveCounter.PubSub
end
