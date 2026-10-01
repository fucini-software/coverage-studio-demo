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
  // Two names for one image, as for dotnet below: the C++ sample's generator
  // runs in the C image, and generate-all.sh looks an image up by the sample's
  // name — without the second tag it stopped at "cpp" with no such image.
  tags     = ["coverage-studio-lab:c", "coverage-studio-lab:cpp"]
}

target "js" {
  inherits = ["_lab"]
  target   = "js"
  // …and the TypeScript sample's in the JavaScript one.
  tags     = ["coverage-studio-lab:js", "coverage-studio-lab:ts"]
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
  // Two names for one image: generate-all.sh looks an image up by the sample's
  // name, and the Visual Basic sample needs what the .NET one needs.
  tags     = ["coverage-studio-lab:dotnet", "coverage-studio-lab:vb"]
}
