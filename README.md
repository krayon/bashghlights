# Bash GitHub Lights

----
# Introduction

This project inspired by my colleague's
[GitHubLights for macOS](https://github.com/oskarpie/GitHubLights.git) .  I
don't use macOS and spend most of my time in the terminal so this made more
sense to me.

It is licensed under the GNU GPL version 2. For more information,
see [LICENSE](LICENSE) / [COPYING](COPYING) .

For a list of the main author(s), and other contributors, see
[AUTHORS](AUTHORS.md) and [CONTRIBUTORS](CONTRIBUTORS.md) respectively.

For more information on contributing (new feature, bug fix, pull request etc),
please see [CONTRIBUTING](CONTRIBUTING.md) .

----
# PS1 (short mode)

_Bash GitHub Lights_ short mode (`-s`/`--short`) is perfect for including is
your prompt (`PS1`) via `PROMPT_COMMAND`. The light positions match that of
GitHubLights for macOS.

_Bash GitHub Lights_ will show all green lights under normal circumstances.

  ![Normal output](assets/ps1-oper.png)

In the event of a degradation of service(s), one or more yellow single quote
(`'`), comma (`,`) or exclamation marks (`!`) will be displayed depending on
what's degraded.

  ![Degraded output](assets/ps1-deg1.png)

For critical outages, one or more red single quote (`'`), comma (`,`) or
exclamation marks (`!`) will be displayed depending on what the outage is
impacting.

  ![Outage 1 output](assets/ps1-out1.png)

  ![Outage 2 output](assets/ps1-out2.png)

If more services are impacted, multiple characters and colours will be used to
represent the current state.

  ![Outage and Depredation output](assets/ps1-deg2-out3.png)

----
# Detailed mode

In detailed mode, a summary is listed:

  ![Summary of detailed degraded output](assets/detail1.png)

----
[//]: # ( vim: set ts=4 sw=4 et cindent tw=80 ai si syn=markdown ft=markdown: )
