{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.worktree-tool;
  nixos-worktree = pkgs.writeShellScriptBin "nixos-worktree" ''
    set -e

    # Ensure we are in the right directory
    cd ~/.config/nixos

    # Check if .worktree already exists
    if [ -d ".worktree" ]; then
      echo "Error: .worktree directory already exists."
      exit 1
    fi

    # Prompt for branch name
    read -p "Enter feature branch name: " branch
    if [ -z "$branch" ]; then
      echo "Branch name cannot be empty."
      exit 1
    fi

    # Create the worktree
    echo "Creating worktree for branch '$branch'..."
    git worktree add .worktree -b "$branch"

    # Prompt for initial Gemini prompt
    read -p "Enter initial Gemini prompt: " initial_prompt

    # Start tmux session
    session_name="nixos-dev-$branch"
    echo "Starting tmux session '$session_name'..."

    # Create detached session in the worktree directory
    tmux new-session -d -s "$session_name" -c "$(pwd)/.worktree" -n "gemini"

    # Run gemini in the first window
    if [ -n "$initial_prompt" ]; then
      tmux send-keys -t "$session_name:gemini" "gemini --yolo -i "$initial_prompt"" C-m
    else
      tmux send-keys -t "$session_name:gemini" "gemini --yolo" C-m
    fi

    # Create a second window for a blank terminal
    tmux new-window -t "$session_name" -n "term" -c "$(pwd)/.worktree"

    # Select the gemini window and attach
    tmux select-window -t "$session_name:gemini"
    tmux attach-session -t "$session_name"
  '';
in
{
  options.features.worktree-tool.enable = lib.mkEnableOption "Git worktree helper for NixOS config";

  config = lib.mkIf cfg.enable {
    home.packages = [
      nixos-worktree
    ];

    programs.tmux = {
      enable = true;
      keyMode = "vi";
      shortcut = "a";
      baseIndex = 1;
      escapeTime = 0;
      mouse = true;
      extraConfig = ''
        set -g status-style bg=default
        set -g pane-border-style fg=brightblack
        set -g pane-active-border-style fg=blue
      '';
    };
  };
}
