from backend.shell_sandbox import build_restricted_shell_command, build_restricted_shell_rcfile


def test_restricted_shell_rcfile_blocks_power_commands():
    rcfile = build_restricted_shell_rcfile()

    assert "brokenops_blocked_command()" in rcfile
    assert "shutdown()" in rcfile
    assert "reboot()" in rcfile
    assert "poweroff()" in rcfile
    assert "halt()" in rcfile
    assert "sudo()" in rcfile
    assert "init()" in rcfile
    assert "telinit()" in rcfile
    assert "systemctl()" in rcfile
    assert "command not found" in rcfile


def test_restricted_shell_command_uses_temp_rcfile():
    command = build_restricted_shell_command("/tmp/brokenops-shell.rc")

    assert command == "bash --noprofile --rcfile /tmp/brokenops-shell.rc -i"
