CHEZMOI_SOURCE_PATH="$(chezmoi source-path)"
watchman watch "${CHEZMOI_SOURCE_PATH}"

watchman -j <<EOT
["trigger", "${CHEZMOI_SOURCE_PATH}", {
  "name": "chezmoi-apply",
  "command": ["chezmoi", "apply", "--force"]
}]
EOT
