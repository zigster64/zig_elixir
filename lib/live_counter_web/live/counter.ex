defmodule LiveCounterWeb.Counter do
  use Phoenix.LiveView
  alias LiveCounter.Count
  alias Phoenix.PubSub
  alias LiveCounter.Presence

  @topic Count.topic
  @presence_topic "presence"

  def mount(_params, _session, socket) do
    PubSub.subscribe(LiveCounter.PubSub, @topic)

    Presence.track(self(), @presence_topic, socket.id, %{})
    LiveCounterWeb.Endpoint.subscribe(@presence_topic)

    initial_present = 
      Presence.list(@presence_topic) 
      |> map_size

    {:ok, assign(socket, val: Count.current(), present: initial_present) }
  end

  def handle_event("inc", _, socket) do
    {:noreply, assign(socket, :val, Count.incr())}
  end

  def handle_event("dec", _, socket) do
    {:noreply, assign(socket, :val, Count.decr())}
  end

  def handle_info({:count, count}, socket) do
    {:noreply, assign(socket, val: count)}
  end

  def handle_info(
    %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
    %{assigns: %{present: present}} = socket
  ) do
    new_present = present + map_size(joins) - map_size(leaves)

    {:noreply, assign(socket, :present, new_present)}
  end
   

  def render(assigns) do
    ~L"""
    <div> 
      <h1>Current users: <%= @present %></h1>
      <h1>The count is: <%= @val %></h1>
      <button phx-click="dec">-</button>
      <button phx-click="inc">+</button>
    </div>
    <ul>
      <li>This frontend has no Javascript</li>
      <li>The button clicks fire requests over a socket</li>
      <li>The backend is Erlang/Elixir controlling the sockets</li>
      <li>The Button Click is routed to a Zig function</li>
      <li>The output of the Zig function is send back over the socket to tell the frontend to update its display</li>
      <li>No Javascript !!   like seriously - NONE</li>
    </ul>
    """
  end
end
