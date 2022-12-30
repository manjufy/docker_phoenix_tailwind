defmodule DockerPhoenixTailwindWeb.PageController do
  use DockerPhoenixTailwindWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
