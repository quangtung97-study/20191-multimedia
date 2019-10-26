defmodule Multimedia.Store do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def register(pid, session_id, user_id) do
    GenServer.call(__MODULE__, {:register, pid, session_id, user_id})
  end

  def join(session_id, user_id, group_id) do
    GenServer.call(__MODULE__, {:join, session_id, user_id, group_id})
  end

  def all_pids() do
    GenServer.call(__MODULE__, {:all_pids})
  end

  def group_sessons(group_id) do
    GenServer.call(__MODULE__, {:group_sessons, group_id})
  end

  @impl true
  def init(_args) do
    Process.flag(:trap_exit, true)

    state = %{
      pid_sessions: :ets.new(:pid_sessions, [:set, :protected]),
      session_groups: :ets.new(:session_groups, [:bag, :protected]),
      group_sessons: :ets.new(:group_sessons, [:bag, :protected]),
      group_users: :ets.new(:group_users, [:bag, :protected])
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:register, pid, session_id, user_id}, _from, state) do
    Process.link(pid)

    :ets.insert(state.pid_sessions, {pid, {session_id, user_id}})

    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:join, session_id, user_id, group_id}, _from, state) do
    users = :ets.lookup(state.group_users, group_id)

    if Enum.member?(users, {group_id, user_id}) do
      {:reply, {:error, :already_joined}, state}
    else
      :ets.insert(state.session_groups, {session_id, group_id})
      :ets.insert(state.group_sessons, {group_id, session_id})
      :ets.insert(state.group_users, {group_id, user_id})

      sessions =
        :ets.lookup(state.group_sessons, group_id)
        |> Enum.map(fn {_group_id, session_id} -> session_id end)

      {:reply, {:ok, sessions}, state}
    end
  end

  @impl true
  def handle_call({:all_pids}, _from, state) do
    pids = :ets.tab2list(state.pid_sessions)
    {:reply, pids, state}
  end

  @impl true
  def handle_call({:group_sessons, group_id}, _from, state) do
    sessions =
      :ets.lookup(state.group_sessons, group_id)
      |> Enum.map(fn {_, session_id} -> session_id end)

    {:reply, sessions, state}
  end

  @impl true
  def handle_info({:EXIT, from, _reason}, state) do
    [{from, {session_id, user_id}}] = :ets.lookup(state.pid_sessions, from)
    :ets.delete(state.pid_sessions, from)

    session_groups = :ets.lookup(state.session_groups, session_id)
    :ets.delete(state.session_groups, session_id)

    for {_session_id, group_id} <- session_groups do
      :ets.delete_object(state.group_sessons, {group_id, session_id})
      :ets.delete_object(state.group_users, {group_id, user_id})
    end

    {:noreply, state}
  end
end
