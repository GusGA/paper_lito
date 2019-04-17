defmodule Papelito.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # def start(_type, _args) do
  #   # List all child processes to be supervised
  #   children = [
  #     # Start the Ecto repository
  #     Papelito.Repo,
  #     # Start the endpoint when the application starts
  #     PapelitoWeb.Endpoint
  #     # Starts a worker by calling: Papelito.Worker.start_link(arg)
  #     # {Papelito.Worker, arg},
  #   ]

  #   # See https://hexdocs.pm/elixir/Supervisor.html
  #   # for other strategies and supported options
  #   opts = [strategy: :one_for_one, name: Papelito.Supervisor]
  #   Supervisor.start_link(children, opts)
  # end

  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Papelito.Repo, []),
      # Start the endpoint when the application starts
      supervisor(PapelitoWeb.Endpoint, []),
      # Start your own worker by calling: Papelito.Worker.start_link(arg1, arg2, arg3)
      # worker(Papelito.Worker, [arg1, arg2, arg3]),
      supervisor(Papelito.Supervisor.Root, [:ok]),
      supervisor(Phoenix.PubSub.PG2, [:scoreboard, []])
    ]

    # Game persistency
    Papelito.GameStorage.setup()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Papelito.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PapelitoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
