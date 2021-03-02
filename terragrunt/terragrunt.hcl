terraform {
  after_hook "cloudrail_after_hook" {
    commands     = ["plan"]

    # Run Cloudrail as a docker container. Note that the plan outfile is hardcoded here.
    # We're running Cloudrail in CI mode, where you also need to supply information about the
    # build ID and the URL directly to the build. We put in some generic values for now, please replace them.
    # NOTE: We're not passing "--api-key" and instead relying on an environment variable by the name of 
    # CLOUDRAIL_API_KEY being defined.
    execute      = [
      "docker", 
      "run", 
      "--rm", 
      "-e", "CLOUDRAIL_API_KEY",
      "-v", "${get_env("PWD", "")}:${get_env("PWD", "")}", 
      "-w", "${get_env("PWD", "")}",
      "indeni/cloudrail-cli", 
      "run", 
      "-d", "${path_relative_to_include()}",
      "--tf-plan", "${path_relative_to_include()}/plan.out",
      "--origin", "ci",
      "--build-link", "https://somelink",
      "--execution-source-identifier", "somebuildnumber - tg module ${path_relative_to_include()}",
      "--auto-approve"
      ]
  }
}