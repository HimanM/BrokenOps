from __future__ import annotations

import textwrap


def build_restricted_shell_rcfile() -> str:
    return textwrap.dedent(
        """
        brokenops_blocked_command() {
            printf 'bash: %s: command not found\\n' "$1"
            return 127
        }

        shutdown() { brokenops_blocked_command shutdown; }
        reboot() { brokenops_blocked_command reboot; }
        poweroff() { brokenops_blocked_command poweroff; }
        halt() { brokenops_blocked_command halt; }

        sudo() {
            case "$1" in
                reboot|poweroff|halt|shutdown)
                    brokenops_blocked_command "$1"
                    ;;
                systemctl)
                    case "$2" in
                        reboot|poweroff|halt)
                            brokenops_blocked_command systemctl
                            ;;
                        *)
                            command sudo "$@"
                            ;;
                    esac
                    ;;
                *)
                    command sudo "$@"
                    ;;
            esac
        }

        init() {
            case "$1" in
                0|6)
                    brokenops_blocked_command init
                    ;;
                *)
                    command init "$@"
                    ;;
            esac
        }

        telinit() {
            case "$1" in
                0|6)
                    brokenops_blocked_command telinit
                    ;;
                *)
                    command telinit "$@"
                    ;;
            esac
        }

        systemctl() {
            case "$1" in
                reboot|poweroff|halt)
                    brokenops_blocked_command systemctl
                    ;;
                *)
                    command systemctl "$@"
                    ;;
            esac
        }
        """
    ).strip() + "\n"


def build_restricted_shell_command(rcfile_path: str) -> str:
    return f"bash --noprofile --rcfile {rcfile_path} -i"
