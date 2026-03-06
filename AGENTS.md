# Claude Code Agents and Sub-Agents Guide

## Overview

Agents in Claude Code are specialized AI assistants that handle specific types of tasks. Each agent runs in its own context window with:

- A custom system prompt tailored to specific domains
- Independent tool access and permissions
- Separate context management
- Ability to work autonomously or in parallel

**Benefits:**
- Preserve context by keeping exploration separate from implementation
- Enforce constraints by limiting which tools specific tasks can use
- Reduce costs by using faster, cheaper models for simple tasks (e.g., Haiku)
- Enable parallelism by running multiple agents simultaneously

---

## Built-in Agents

| Agent | Model | Purpose | Tools |
|-------|-------|---------|-------|
| **Explore** | Haiku | Fast, read-only codebase exploration | Read, Grep, Glob, Bash |
| **Plan** | Inherits | Research codebase during plan mode | Read, Grep, Glob, Bash |
| **General-purpose** | Inherits | Complex multi-step tasks | All tools |
| **Bash** | Inherits | Isolated terminal command execution | Bash |

### Explore Agent Thoroughness Levels
- **quick**: Targeted lookups for specific files
- **medium**: Balanced exploration
- **very thorough**: Comprehensive codebase analysis

---

## Creating Custom Agents

### Method 1: Interactive (Recommended)

```bash
/agents
```

This opens an interface to create, edit, and manage agents.

### Method 2: File-Based

**Project-level** (checked into version control):
```
.claude/agents/my-agent.md
```

**User-level** (available across all projects):
```
~/.claude/agents/my-agent.md
```

### Agent File Structure

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use after code changes.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: default
---

You are a senior code reviewer ensuring high code quality.

When invoked:
1. Run `git diff` to see recent changes
2. Read modified files
3. Provide feedback by priority (Critical, Warning, Suggestion)
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier (lowercase, hyphens) |
| `description` | Yes | When Claude should delegate to this agent |
| `tools` | No | Comma-separated tools available |
| `disallowedTools` | No | Tools to explicitly deny |
| `model` | No | `sonnet`, `opus`, `haiku`, or `inherit` |
| `permissionMode` | No | `default`, `acceptEdits`, `plan`, etc. |
| `skills` | No | Skills to preload into agent context |

### Method 3: CLI (Session Only)

```bash
claude --agents '{
  "test-runner": {
    "description": "Run tests and report failures",
    "prompt": "You are a testing expert.",
    "tools": ["Bash", "Read"],
    "model": "sonnet"
  }
}'
```

---

## Using Agents

### Automatic Delegation

Claude automatically uses agents when your request matches an agent's description:

```
> search for all database migration files
[Claude delegates to Explore agent]
```

### Explicit Request

```
> use the code-reviewer agent to analyze the authentication module
```

### Background Execution

```
> run this in the background: test the payment module
[Claude continues working while agent runs in parallel]
```

**Keyboard shortcuts:**
- `Ctrl+B` - Send running agent to background
- `Ctrl+G` - View list of background tasks

---

## Model Selection

| Model | Cost | Speed | Best For |
|-------|------|-------|----------|
| **Haiku** | Lowest | Very fast | Search, simple analysis |
| **Sonnet** | Medium | Fast | Code review, implementation |
| **Opus** | Higher | Slower | Complex reasoning, architecture |

---

## Permission Modes

| Mode | Behavior |
|------|----------|
| `default` | Standard prompting |
| `acceptEdits` | Auto-accept file edits |
| `plan` | Read-only mode |
| `bypassPermissions` | Skip all checks (use carefully) |

---

## Practical Examples

### Code Reviewer Agent

```markdown
---
name: code-reviewer
description: Reviews code for quality, security, and maintainability.
tools: Read, Grep, Glob, Bash
model: sonnet
permissionMode: plan
---

You are a senior code reviewer.

Checklist:
- Clear, readable code
- Good naming conventions
- Proper error handling
- No security issues
- Test coverage adequate
```

### Test Runner Agent

```markdown
---
name: test-fixer
description: Run tests and fix failures automatically.
tools: Bash, Read, Edit, Grep, Glob
model: sonnet
permissionMode: acceptEdits
---

You are a testing expert who fixes broken tests.

Process:
1. Run full test suite
2. Analyze failures
3. Fix issues (minimal changes only)
4. Re-run tests to verify
```

### Database Query Agent (Read-Only)

```markdown
---
name: db-reader
description: Execute read-only database queries for analysis.
tools: Bash
---

You are a database analyst with read-only access.
Only use SELECT queries. Never INSERT, UPDATE, or DELETE.
```

---

## Best Practices

1. **Design focused agents** - Single, clear purpose per agent
2. **Write clear descriptions** - Helps Claude know when to delegate
3. **Restrict tools appropriately** - Grant only necessary permissions
4. **Use permission modes strategically** - Match to agent trustworthiness
5. **Check agents into version control** - Keep in `.claude/agents/`
6. **Use Haiku for simple tasks** - Faster and cheaper
7. **Use Opus for complex reasoning** - Architecture decisions, debugging

---

## Agent Scope Priority

When agents have the same name:

1. **Session-level** (`--agents` CLI flag) - Highest
2. **Project-level** (`.claude/agents/`)
3. **User-level** (`~/.claude/agents/`)
4. **Plugin-level** - Lowest

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Agent not invoked | Make description more specific |
| Wrong agent invoked | Make descriptions distinct |
| Missing permissions | Check tools list matches task |
| Context fills quickly | Use background execution |

---

## Quick Reference

```bash
# Open agent management interface
/agents

# Check running background tasks
Ctrl+G

# Send current task to background
Ctrl+B

# View context usage
/context
```
