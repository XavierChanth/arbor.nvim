# Plugin Spec

Legend:

> ? = It's an idea, more thought / investigation is needed

## Core features

### Creating worktrees

#### Checkout local branch

- [ ] vim.ui.select local branch and checkout in new worktree

#### New local branch

- [ ] Create a new branch from HEAD and checkout in new worktree
- [ ] Create a new branch with work dir and checkout in new worktree
- [ ] Create a new branch with index and checkout in new worktree

#### Remote branch

- [ ] Create a new worktree from a remote branch

#### Other

- [ ] `Smart mode` Create a worktree taking vim.ui.input  
  - URL: pull matching remote branch  
  - Matches remote ref: confirm Y = pull remote, N = new local  
  - Assume branch name: create branch using configurable default

### Switching worktrees

- [ ] Switch worktrees
- [ ] Option to change vim cwd on switch
- [ ] Option to git pull/fetch on switch

### Deleting worktrees

- [ ] Delete worktree
- [ ] Option to confirm if there are pending changes that haven't been pushed
- [ ] Option to automatically push local commits before delete?

### Caching

- [ ] Option to make an in-memory cache from important git info in the bg  
      - Opt-in feature, with configurable event for an autocmd  
      - Manually start  
      - Manually stop autocmd

## Integrations

### Select / finders

- Maybe all I need is vim.ui.select for now?

- [ ] Telescope
- [ ] fzf lua

### Git

Let's integrate with the existing plugin ecosystem!
If a library contains enough to use as a git driver for this plugin, my long
term goal is to support it. Why load a library twice, if you could load it once.
Note: this is a nice to have, it may never get implemented, only time will tell.

- [ ] mini.git?
- [ ] ... to be completed at a later date

## Plugin Best Practices

- [ ] healthcheck support
- [ ] vim help docs
- [ ] tests
- [ ] Supports lazy loading
- [ ] Feature customization
  - Opt-out when something seems nearly essential
  - Opt-out when something seems like an extra

