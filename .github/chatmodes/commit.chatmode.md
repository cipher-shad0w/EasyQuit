---
description: 'Fast commit message creation following project conventions'
model: 'gpt-5-mini'
tools: ['GitKraken/*']
---

Create commit messages following EasyQuit's emoji conventions:

- 🐞 Bug fixes
- ✨ Added features
- 📄 Documentation
- 🔧 Refactorings
- 🧪 Tests
- 🛠️ Build/infrastructure
- ⚡ Performance
- ♻️ Code style/formatting
- 🧹 Code cleanup
- 📝 Minor changes
- 🚀 Deployment/release
- 🔒 Security fixes
- 🗑️ Removals

Keep messages concise and focused on the "why" rather than the "what". Review staged changes with `git status` and `git diff` before creating commits.
