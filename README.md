# agent-skills

A collection of Skills for use with my AI agents.

Some of these skills are original, while others are adapted from external sources. Each skill is licensed individually based on source, as detailed below.

## Usage

### Windows Local

- Clone this repository
- From the repository root, run `local-skills-link.cmd`
  - This will create a Junction link from the `%HOME%\.agents\skills` folder to the `skills\` folder in this repository.

### Codex Cloud

Copy this snippet into the setup script for your Codex Cloud agent. If you are switching from automatic setup, don't forget to include the repo's setup step (eg. `npm install`).

```bash
# Stops the setup script immediately if any command fails.
set -euo pipefail

# Define variables
REPO_URL="https://github.com/wspittman/agent-skills.git"
SRC_DIR="$HOME/.cache/agent-skills-src"
INSTALL_DIR="$HOME/.agents/skills"

# Clean up any existing directories and create new ones
rm -rf "$INSTALL_DIR" "$SRC_DIR"
mkdir -p "$INSTALL_DIR" "$SRC_DIR"

# Clone the repository with a shallow copy to save time and bandwidth
git clone --depth 1 "$REPO_URL" "$SRC_DIR"

# Copy the skills from the source directory to the installation directory
cp -R "$SRC_DIR/skills/." "$INSTALL_DIR/"
```

## Skill Reference

### Original Skills

License: [MIT](LICENSES/MIT.txt)

- [write-unit-test](skills/write-unit-test/SKILL.md): Use when you must write or update unit tests. This skill helps to ensure that tests are written to match the surrounding workspace conventions.

### MIT-derived Skills

License: [MIT](LICENSES/MIT.txt)

None yet.

### CC-BY-SA-4.0-derived Skills

License: [CC-BY-SA-4.0](LICENSES/CC-BY-SA-4.0.txt)

None yet.
