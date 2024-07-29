# random_git

## 0.2.0

### Minor Changes

- 67595d6: Adds the config command. It allows the user to set and get values from the configuration file.

  Examples:

  - `config get directories.repos` -> `"default"` or `~/Document/Repos`
  - `config set github.username t3dotgg`:\
     Before:
    ```toml
    # ...
    [github]
    username = "theprimeagen" # bad
    # ...
    ```
    After:
    ```toml
    # ...
    [github]
    username = "t3dotgg" # good
    # ...
    ```
  - `config get --all` ->

    ```toml
    [github]
    username = "tsoding"
    token = "i-love-emacs"

    [directories]
    repos = "default"

    [settings]
    auto_clone = true
    forks = true

    ```

  - `config list` ->

    ```
    [github]
    token: string (e.g. "a string")
    username: string (e.g. "a string")

    [directories]
    repos: string (e.g. "a string")

    [settings]
    auto_clone: boolean (true/false)
    forks: boolean (true/false)
    ```

## 0.1.2

### Patch Changes

- 48216f6: Adding changeset
