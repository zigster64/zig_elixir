defmodule LiveCounter.Count do
  use GenServer
  use Zig, local_zig: true

  alias Phoenix.PubSub

  @name :count_server

  @start_value 0

  #-- external API runs in client process

  def topic do
    "count"
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, @start_value, name: @name)
  end

  def incr() do
    GenServer.call @name, :incr
  end

  def decr() do
    GenServer.call @name, :decr
  end

  def current() do
    GenServer.call @name, :current
  end

  def init(start_count) do
    {:ok, start_count}
  end

  #-- implementation 

  def handle_call(:current, _from, count) do
    {:reply, count, count}
  end

  def handle_call(:incr, _from, count) do
    make_change(count, +1)
  end

  def handle_call(:decr, _from, count) do
    make_change(count, -1)
  end

  ~Z""" 
  /// nif: apply_count/2
  const std = @import("std");
  fn apply_count(count: i64, change: i64) i64 {
    std.debug.print("apply_count in zig {} + {} = {}\n", .{count, change, count+change});
    return count + change;
  }
  """
  defp make_change(count, change) do
    new_count = LiveCounter.apply_count(count, change)
    PubSub.broadcast(LiveCounter.PubSub, topic(), {:count, new_count})
    {:reply, new_count, new_count}
  end
end

