defmodule PapelitoWeb.GameLive.Bowl do
  use Phoenix.LiveView
  alias PapelitoWeb.Router.Helpers, as: Routes

  def mount(%{path_params: %{"game_id" => game_id}}, socket) do
    case Papelito.GameManager.alive?(game_id) && !Papelito.LockManager.bowl_locked?(game_id) do
      false ->
        {:stop,
         socket
         |> put_flash(:error, "The game does not exist, please create a new one")
         |> redirect(to: Routes.page_path(%Plug.Conn{}, :index))}

      true ->
        summary = Papelito.GameManager.summary(game_id)
        # Papelito.LockManager.lock_bowl(game_id)
        {:ok,
         assign(socket, %{
           game_name: game_id,
           current_paper: "Are you ready?",
           summary: summary,
           timer: 45,
           playing: false
         })}
    end
  end

  def render(assigns), do: PapelitoWeb.GameView.render("bowl.html", assigns)

  def handle_event("pass_paper", _value, socket) do
    current_paper = Papelito.Server.Game.pass_paper(socket.assigns.game_name)

    {:noreply,
     assign(socket, %{
       game_name: socket.assigns.game_name,
       current_paper: current_paper,
       summary: socket.assigns.summary,
       timer: socket.assigns.timer,
       playing: socket.assigns.playing
     })}
  end

  def handle_event("check_paper", _value, socket) do
    # {:noreply, assign(socket, %{})}
    {:noreply, socket}
  end

  def handle_event("start_timer", _value, socket) do
    current_paper = Papelito.Server.Game.fetch_paper(socket.assigns.game_name)
    :timer.send_after(1500, self(), :start_countdown)

    {:noreply,
     assign(socket, %{playing: true, timer: socket.assigns.timer, current_paper: current_paper})}
  end

  def handle_event("stop_timer", _value, socket) do
  end

  def handle_info(:stop_timer, socket) do
  end

  def handle_info(:start_countdown, socket) do
    timer = socket.assigns.timer
    playing = socket.assigns.playing
    current_paper = socket.assigns.current_paper

    case socket.assigns.timer do
      0 ->
        playing = false
        current_paper = "Are you ready?"

      _ ->
        nil
    end

    if socket.assigns.timer > 0 do
      :timer.send_after(1000, self(), :start_countdown)
      timer = timer - 1
    end

    {:noreply, assign(socket, %{timer: timer, playing: playing, current_paper: current_paper})}
  end
end
