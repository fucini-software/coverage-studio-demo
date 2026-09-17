// @file docker-bake.hcl
// @brief One build target per stage of docker/Dockerfile.
// @author Mario Fucini
// @copyright Copyright (c) 2026 Fucini Consulting. Released under the MIT
//            License; see the LICENSE file in the repository root.
//
// Run from the repository root:
//
//   docker buildx bake -f docker/docker-bake.hcl        # all of them
//   docker buildx bake -f docker/docker-bake.hcl js     # one

group "default" {
  targets = ["c", "js", "python", "go", "dotnet"]
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

target "dotnet" {
  inherits = ["_lab"]
  target   = "dotnet"
  tags     = ["coverage-studio-lab:dotnet"]
}
