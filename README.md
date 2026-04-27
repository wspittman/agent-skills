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

- [write-unit-test](skills/write-unit-test/): Use when you must write or update unit tests. This skill helps to ensure that tests are written to match the surrounding workspace conventions.

### MIT-derived Skills

License: [MIT](LICENSES/MIT.txt)

- [security-awareness](skills/security-awareness/): Use for agents that access email, credential vaults, web browsers, or sensitive data. Teaches agents to recognize and avoid security threats during normal activity, including phishing detection, credential protection, domain verification, and social engineering defense.
  - Source: https://github.com/trailofbits/skills-curated, 022fa09

### CC-BY-SA-4.0-derived Skills

License: [CC-BY-SA-4.0](LICENSES/CC-BY-SA-4.0.txt)

- [humanizer](skills/humanizer/): Use when editing or reviewing text to make it sound more natural and human-written. Based on Wikipedia's comprehensive "Signs of AI writing" guide. Detects and fixes patterns including: inflated symbolism, promotional language, superficial -ing analyses, vague attributions, em dash overuse, rule of three, AI vocabulary words, negative parallelisms, and excessive conjunctive phrases.
  - Source: https://github.com/trailofbits/skills-curated, 022fa09
- [planning-with-files](skills/planning-with-files/): Use for complex, multi-step tasks that require maintaining state across many tool calls. This skill uses markdown files on disk as persistent working memory to overcome context window limitations.
  - Source: https://github.com/trailofbits/skills-curated, 022fa09
