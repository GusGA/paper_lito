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
        {:ok, assign(socket, %{game_name: game_id, summary: summary})}
    end
  end

  def render(assigns), do: PapelitoWeb.GameView.render("bowl.html", assigns)
end
