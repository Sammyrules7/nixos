{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.worktree-tool;

  # Helper to find the project root robustly
  findRoot = ''
    if git rev-parse --git-dir > /dev/null 2>&1; then
      # Get the main worktree root (first path in 'git worktree list')
      REPO_ROOT="$(git worktree list | head -n 1 | awk '{print $1}')"
    else
      REPO_ROOT="$HOME/.config/nixos"
    fi
  '';

  # ANSI Color helpers
  colors = ''
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
  '';

  # Workflow helper script
  flow-script = pkgs.writeShellScriptBin "flow" ''
    set -e
    ${colors}

    while true; do
      clear
      echo -e "''${BLUE}=== NMC Workflow Helper ===''${NC}"
      echo ""
      echo "1) Test (nixos-rebuild test)"
      echo "2) Switch (nixos-rebuild switch)"
      echo "3) Finish (nmc finish)"
      echo "q) Quit"
      echo ""
      read -n 1 -p "Select [1-3, q]: " choice
      echo ""

      case $choice in
        1)
          echo -e "''${YELLOW}Building and testing...''${NC}"
          sudo nixos-rebuild test --flake .#
          echo ""
          read -p "Press Enter to continue..."
          ;;
        2)
          echo -e "''${YELLOW}Applying changes...''${NC}"
          sudo nixos-rebuild switch --flake .#
          echo ""
          read -p "Press Enter to continue..."
          ;;
        3)
          nmc finish
          exit 0
          ;;
        q) exit 0 ;;
      esac
    done
  '';

  nmc-script = pkgs.writeShellScriptBin "nmc" ''
    set -e
    ${colors}
    ${findRoot}

    show_help() {
      echo -e "''${BLUE}NixOS Management CLI (nmc)''${NC}"
      echo ""
      echo "Commands:"
      echo -e "  nmc [start] <branch> [prompt]  Create or resume a feature worktree"
      echo -e "  nmc finish [branch]            Squash merge and cleanup"
      echo -e "  nmc help                       Show this message"
      echo ""
      echo "Inside worktree:"
      echo -e "  flow                           Start the workflow helper"
    }

    start_worktree() {
      local branch="$1"
      local initial_prompt="$2"

      # Change to main repo root to ensure .worktrees is found
      cd "$REPO_ROOT"

      if [ -z "$branch" ]; then
        if [ -d ".worktrees" ] && [ "$(ls -A .worktrees)" ]; then
          echo -e "''${YELLOW}Existing worktrees:''${NC}"
          ls -1 .worktrees/ | sed 's/^/  - /'
          echo ""
        fi
        read -p "Enter branch name: " branch
      fi

      if [ -z "$branch" ]; then
        echo -e "''${RED}Error: Branch name cannot be empty.''${NC}"
        exit 1
      fi

      local worktree_path=".worktrees/$branch"
      local is_resume=false

      if [ -d "$worktree_path" ]; then
        echo -e "''${GREEN}Resuming worktree '$branch'...''${NC}"
        is_resume=true
      else
        if git rev-parse --verify "$branch" >/dev/null 2>&1; then
          echo -e "''${GREEN}Branch '$branch' exists. Adding worktree...''${NC}"
          git worktree add "$worktree_path" "$branch"
        else
          echo -e "''${GREEN}Creating new branch '$branch'...''${NC}"
          git worktree add "$worktree_path" -b "$branch"
        fi
      fi

      local session_name="nixos-$(echo "$branch" | tr '.:' '-')"

      if tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "''${GREEN}Attaching to existing tmux session...''${NC}"
        tmux attach-session -t "$session_name"
        exit 0
      fi

      if [ "$is_resume" = false ] && [ -z "$initial_prompt" ]; then
        echo -e "''${YELLOW}Starting in interactive mode...''${NC}"
      fi

      echo -e "''${BLUE}Initializing tmux session '$session_name'...''${NC}"
      # Create session detached first
      tmux new-session -d -s "$session_name" -c "$REPO_ROOT/$worktree_path" -n "kilo"

      # Session ID based on branch to keep sessions separate per worktree
      local kilo_session="$branch"

      if [ "$is_resume" = true ]; then
        tmux send-keys -t "$session_name:kilo" "kilo --model kilo/kilo-auto/free --session $kilo_session" C-m
      else
        if [ -n "$initial_prompt" ]; then
          # Escape quotes in the prompt
          local safe_prompt="''${initial_prompt//\"/\\\"}"
          tmux send-keys -t "$session_name:kilo" "kilo --model kilo/kilo-auto/free --session $kilo_session --prompt \"$safe_prompt\"" C-m
        else
          tmux send-keys -t "$session_name:kilo" "kilo --model kilo/kilo-auto/free --session $kilo_session" C-m
        fi
      fi

      tmux new-window -t "$session_name" -n "lazygit" -c "$REPO_ROOT/$worktree_path" "lazygit"
      tmux new-window -t "$session_name" -n "term" -c "$REPO_ROOT/$worktree_path"
      tmux select-window -t "$session_name:kilo"

      tmux set-option -t "$session_name" status-left "[#S: $branch] "
      tmux set-option -t "$session_name" status-left-length 50

      # Finally attach
      tmux attach-session -t "$session_name"
    }

    finish_worktree() {
      local branch="$1"

      # Determine if we are running INSIDE a worktree
      local current_dir_branch=""
      if [ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]; then
         current_dir_branch=$(git branch --show-current 2>/dev/null || true)
      fi

      cd "$REPO_ROOT"

      if [ -z "$branch" ]; then
        if [ -n "$current_dir_branch" ] && [ "$current_dir_branch" != "main" ]; then
             branch="$current_dir_branch"
        else
             echo -e "''${YELLOW}Select a feature branch to finish:''${NC}"
             if [ -d ".worktrees" ]; then
                ls ".worktrees/" 2>/dev/null || true
             fi
             read -p "Branch name: " branch
        fi
      fi

      if [ -z "$branch" ] || [ "$branch" == "main" ]; then
        echo -e "''${RED}Error: Invalid branch name (cannot finish 'main').''${NC}"
        exit 1
      fi

      local worktree_path=".worktrees/$branch"

      if [ ! -d "$worktree_path" ]; then
        echo -e "''${RED}Error: Worktree directory '$worktree_path' not found.''${NC}"
        exit 1
      fi

      echo -ne "''${YELLOW}Squash merge '$branch' into 'main' and delete? [y/N] ''${NC}"
      read confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
      fi

      # Stash changes in MAIN repo if any (we are in REPO_ROOT now)
      if ! git diff-index --quiet HEAD --; then
        echo -e "''${BLUE}Stashing changes in main repo...''${NC}"
        git stash push -m "nmc-finish: $branch cleanup"
        trap 'echo -e "''${BLUE}Restoring stashed changes...''${NC}"; git stash pop || true' EXIT
      fi

      echo -e "''${BLUE}Merging into main...''${NC}"
      git checkout main
      git pull --rebase || true

      if ! git merge --squash "$branch"; then
        echo -e "''${RED}CONFLICTS DETECTED. Resolution required.''${NC}"
        exit 1
      fi

      echo -e "''${GREEN}Merge successful.''${NC}"
      read -p "Commit message (empty for manual): " commit_msg
      [ -n "$commit_msg" ] && git commit -m "$commit_msg" || echo "Please commit manually."

      echo -e "''${BLUE}Cleaning up worktree and branch...''${NC}"
      git worktree remove -f "$worktree_path"
      git branch -D "$branch"

      local session_name="nixos-$(echo "$branch" | tr '.:' '-')"

      # Kill session at the VERY END to ensure script completes if running inside it
      if tmux has-session -t "$session_name" 2>/dev/null; then
          echo -e "''${BLUE}Killing tmux session...''${NC}"
          tmux kill-session -t "$session_name" 2>/dev/null || true
      fi

      echo -e "''${GREEN}Successfully finished '$branch'!''${NC}"
    }

    # Dispatch command
    case "$1" in
      "start")
        shift
        start_worktree "$@"
        ;;
      "finish")
        shift
        finish_worktree "$1"
        ;;
      "help"|"--help"|"-h")
        show_help
        ;;
      *)
        if [ -n "$1" ]; then
          start_worktree "$@"
        else
          start_worktree ""
        fi
        ;;
    esac
  '';

  # Dedicated finish shorthand
  nmcf-script = pkgs.writeShellScriptBin "nmcf" ''
    exec nmc finish "$@"
  '';

  # Kilo CLI script
  kilo-script = pkgs.writeShellScriptBin "kilo" ''
    exec steam-run npx @kilocode/cli "$@"
  '';

  # Walker integration script
  walker-nmc = pkgs.writeShellScriptBin "walker-nmc" ''
    ${findRoot}

    # List existing worktrees for selection
    worktrees=$(ls -1 "$REPO_ROOT/.worktrees/" 2>/dev/null || true)

    input=$(echo "$worktrees" | walker --dmenu \
      --placeholder "Branch" \
      --width 400 \
      --maxheight 300 \
      --exit)

    if [ -z "$input" ]; then exit 0; fi

    # Parse Branch[:Prompt]
    if [[ "$input" == *":"* ]]; then
      branch=$(echo "$input" | cut -d':' -f1 | xargs)
      prompt=$(echo "$input" | cut -d':' -f2- | xargs)

      if [ -n "$prompt" ]; then
        ghostty -e bash -c "nmc start \"$branch\" \"$prompt\""
      else
        ghostty -e nmc start "$branch"
      fi
      exit 0
    fi

    branch=$(echo "$input" | xargs)

    # If it's an existing branch, skip prompt dialog
    if [ -d "$REPO_ROOT/.worktrees/$branch" ]; then
      ghostty -e nmc start "$branch"
      exit 0
    fi

    # For new branches, show optional prompt dialog
    prompt=$(echo "" | walker --dmenu \
      --placeholder "Initial Gemini prompt (optional)" \
      --width 400 \
      --inputonly \
      --exit)

    # Trim whitespace
    prompt="$(echo "$prompt" | xargs)"

    if [ -n "$prompt" ]; then
      ghostty -e nmc start "$branch" "$prompt"
    else
      ghostty -e nmc start "$branch"
    fi
  '';
in
{
  options.features.worktree-tool.enable = lib.mkEnableOption "Git worktree helper for NixOS config";

  config = lib.mkIf cfg.enable {
    programs.lazygit.enable = true;

    home.packages = [
      nmc-script
      nmcf-script
      kilo-script
      walker-nmc
      flow-script
    ];

    xdg.desktopEntries.nmc-start = {
      name = "Add feature";
      exec = "walker-nmc";
      icon = "nix-snowflake";
      categories = [ "Development" ];
      comment = "Create or resume a NixOS feature worktree";
    };

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "a";
      baseIndex = 1;
      escapeTime = 0;
      mouse = true;
      historyLimit = 10000;
      extraConfig = ''
        set -g status-style bg=default
        set -g pane-border-style fg=brightblack
        set -g pane-active-border-style fg=blue
        set -g status-right ""
      '';
    };
  };
}
