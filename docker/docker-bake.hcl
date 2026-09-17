// One target per stage of docker/Dockerfile. Run from the repository root:
//
//   docker buildx bake -f docker/docker-bake.hcl        # all of them
//   docker buildx bake -f docker/docker-bake.hcl js     # one

group "default" {
  targets = ["c", "js", "python", "go"]
}

target "_lab" {
  context    = "docker"
  dockerfile = "Dockerfile"
}

target "c" {
  inherits = ["_lab"]
  target   = "c"
  tags     = ["coverage-studio-lab:c"]
}

target "js" {
  inherits = ["_lab"]
  target   = "js"
  tags     = ["coverage-studio-lab:js"]
}

target "python" {
  inherits = ["_lab"]
  target   = "python"
  tags     = ["coverage-studio-lab:python"]
}

target "go" {
  inherits = ["_lab"]
  target   = "go"
  tags     = ["coverage-studio-lab:go"]
}
