# DockerPhoenixTailwind

![Phoenix Application](https://github.com/manjufy/docker_phoenix_tailwind/blob/main/screens/project-screen.png)

## Production Deployment To run locally

  Following steps describes running the project in prod mode locally

  ```
  // Generate the secret and export before running the rest of the commands
  $ mix phx.gen.secret
  $ export SECRET_KEY_BASE=<KEY_GENERATED_FROM_PREV_STEP>
  
  // Initial setup
  $ mix deps.get --only prod
  $ MIX_ENV=prod mix compile
  
  // Compile assets
  $ MIX_ENV=prod mix assets.deploy
  // Run the server
  $ PORT=4001 MIX_ENV=prod SECRET_KEY_BASE=$(mix phx.gen.secret)  mix phx.server


  // Release
  $ MIX_ENV=prod mix release

  // Short cut to run it locally.
  $ rm -rf _build && mix deps.get --only prod && MIX_ENV=prod mix compile && MIX_ENV=prod mix assets.deploy && MIX_ENV=prod mix release
  ```

  Then access it through http://localhost:4000 (Port is defined in config/runtime.exs). If 4000 is taken, change to some other port

## Dockerize with debian (Dockerfile)

  `Dockerfile` is based on the debian bullseye slim image 

  ```
  docker image build -t elixir/docker_phoenix_tailwind .

  docker run -e SECRET_KEY_BASE="$(mix phx.gen.secret)" -p  4001:4000 elixir/docker_phoenix_tailwind
  ```

## Dockerize with alpine (Dockerfile.alpine)

  `Dockerfile.alpine` is based on the debian bullseye slim image 

  ```
  docker image build -t elixir/docker_phoenix_tailwind . --no-cache -f Dockerfile.alpine

  docker run -e SECRET_KEY_BASE="$(mix phx.gen.secret)" -p  4001:4000  elixir.alpine/docker_phoenix_tailwind
  ```

## Useful commands

  ```
  // 1. Stop running containers
  // 2. Remove the container
  // 3. Remove the image
  docker stop $(docker ps -a | grep elixir | awk '{print $1}') \
  && docker rm $(docker ps -a | grep elixir | awk '{print $1}') \
  && docker image rm $(docker images | grep elixir | awk '{print $3}')
  ```

## References
  
  Mix Release Reference: https://hexdocs.pm/phoenix/releases.html

  Elixir Release blog: https://blog.miguelcoba.com/deploying-a-phoenix-16-app-with-docker-and-elixir-releases

  Handling Secrets: https://hexdocs.pm/phoenix/deployment.html#handling-of-your-application-secrets

  Debian User managmenet: https://medium.com/3-elm-erlang-elixir/how-to-deploying-phoenix-application-on-ubuntu-293645f38145