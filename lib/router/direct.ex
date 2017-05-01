defmodule Agala.Router.Direct do
  use Supervisor

  @default_handler Agala.Handler.Echo

  @moduledoc """
  `Direct` router creates single `handler` process and pass all
   incoming messages to it.
   It's the simplest case. It also supervises handler process:
   if it falls - router will ensure to restart it before passing
   new incomming messages.

  To use this router, put in your configuration:

  ```elixir
  # config.exs
  router: Agala.Router.Direct
  ```

  or don't put anything, because this router goes by default.
  """
  defp via_tuple(name) do
    {:via, Registry, {Agala.Registry, {:router, name}}
  end


  def start_link(bot_params) do
    Supervisor.start_link(__MODULE__, [bot_params], name: via_tuple(bot_params.name))
  end

  @doc """
  This function initialises `Supervisor` tree, and is callback
   implementation for `Supervisor.init/1` function.

  Unlikely you need to call this function manualy.
  """
  def init(bot_params) do
    children = [
      worker(bot_params.handler, [bot_params])
    ]

    supervise(children, strategy: :one_for_one)
  end

  @doc """
  This function routes the message to defined `Agala.Handler`
   implementor.

  `message/0` is an instance of single message, which can be
   used to define, what handler should be used in this direct
   case of routing. In this module, `t:Agala.Model.Message.t/0`
   is simply passed to the `handler`
  """
  @type message :: Agala.Model.Message.t()
  @spec route(message) :: :ok
  def route(message) do
    Agala.get_handler().handle_message(Agala.get_handler(), message)
  end

end
