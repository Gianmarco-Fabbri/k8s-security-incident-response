/*
 * ptrace_anti_debug.c
 *
 * Demonstrates the ptrace(PTRACE_TRACEME) anti-debugging technique.
 * A process that calls PTRACE_TRACEME signals to the OS that it is
 * already being traced. As a side effect, no external debugger can
 * subsequently attach to that process, since only one tracer is
 * allowed at a time. This is a classic technique used by malware to
 * evade dynamic analysis tools such as gdb or strace.
 *
 * MITRE ATT&CK: T1622 - Debugger Evasion
 *
 * Compile with:
 *   gcc -o ptrace ptrace_anti_debug.c
 *
 * For educational purposes only.
 */

#include <sys/ptrace.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    printf("[*] Invoking ptrace(PTRACE_TRACEME, 0, NULL, NULL)...\n");
    fflush(stdout);

    long ret = ptrace(PTRACE_TRACEME, 0, NULL, NULL);

    if (ret == -1) {
        printf("[-] ptrace failed: syscall denied (EPERM) or process already traced.\n");
        return 1;
    }

    printf("[+] ptrace(PTRACE_TRACEME) succeeded.\n");
    printf("[*] This process is now marked as being traced.\n");
    printf("[*] No external debugger can attach to this PID anymore.\n");
    return 0;
}
