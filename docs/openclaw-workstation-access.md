# OpenClaw workstation execution access

Desktop and Laptop explicitly enable `features.openclaw-node.fullAccess`.
Other users of this module retain the existing strict filesystem policy.

On service startup, the opt-in atomically merges `security: full`, `ask: off`,
`askFallback: deny` into the **main** agent entry of
`/var/lib/openclaw/exec-approvals.json`. Existing socket metadata, defaults,
other agents, allowlists and unrelated fields are preserved. Invalid input
or a symlink fails service startup rather than overwriting it. Permissions
are 0600. Legacy fields are intentional for the existing 2026.6.x nodes.

The service drops ProtectSystem=strict only on opted-in hosts, allowing
ordinary user filesystem writes. It retains User, NoNewPrivileges,
PrivateTmp, credential loading and state-directory permissions. This is
unprompted user-level execution, not root access or a sudo grant.

The gateway execution policy remains an independent upper bound: a stricter
gateway/session policy can still block commands. This repository cannot
change the gateway policy, and this PR does not do so.

There is **no SSH-private-key isolation**: unrestricted execution as the
workstation user can read anything that user can read, including ~/.ssh.
There are no phone changes or new mobile shell/screen capabilities.

Apply through the normal reviewed NixOS deployment after merge; this PR
has not changed running hosts. Confirm effective node approvals using
`openclaw approvals get --node SammyDesktop` / `--node SammyLaptop`, then
run a harmless agent command to confirm end-to-end behavior. Do not print
approval socket tokens or credentials into shared logs.

Rollback: disable fullAccess and deploy to restore ProtectSystem=strict.
The merged on-disk main approval entry is intentionally persistent; also
restore its prior security/ask policy using OpenClaw's approvals UI/CLI if
revoking execution. Disabling the option alone does not revoke approvals.

Validation: tree-sitter Nix syntax checks for all three changed Nix files;
bash syntax and actual merge-script tests for missing/existing files,
metadata/allowlist preservation, 0600 mode, malformed JSON and symlink
rejection. The published npm artifacts for OpenClaw 2026.6.5 and 2026.6.33
contain the legacy full/off/askFallback policy fields. No Nix executable is
available in the authoring environment, so flake evaluation/build, formatter,
systemd-generated-unit validation and live deployment are not tested.
