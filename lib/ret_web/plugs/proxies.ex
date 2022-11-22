defmodule RetWeb.Plugs.PostgrestProxy do
  use Plug.Builder
  plug ReverseProxyPlug, upstream: "http://host.docker.internal:3000"
end

defmodule RetWeb.Plugs.ItaProxy do
  use Plug.Builder
  plug ReverseProxyPlug, upstream: "http://localhost:6000"
end
