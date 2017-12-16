Setup and update of **health** (bash) script for statistic gaining

There is a list of components required for the script maintaining:

* **git** – required for updates of maintained script. In case the storjshare-daemon is already installed then git should be already installed too.
* **jq** – is used as a json-requests handler.
* **net-tools** – is used for network tasks.
* **bc** – is for mathematical calculations.
* **curl** – is used for http requests.

<hr/>

#####Script setup

1.	Make a script’s home directory then run utility from this folder, for instance:


```bash
mkdir /home/storj/scripts
```

```bash
cd /home/storj/scripts
```

Then run command:

```bash
git clone https://github.com/AntonMZ/Storj-Utils.git
```

2.	After the script has been downloaded successfully, change the **config.cfg**. Here is a list of changes you should make:

```bash
LOGS_FOLDER=/root/.config/storjshare/logs
CONFIGS_FOLDER=/root/.config/storjshare/configs
WATCHDOG_LOG=/var/log/storjshare-daemon-status.log
EMAIL=az@maxrival.com
```

**LOGS_FOLDER** – checks folder with nodes’ log files.
**CONFIGS_FOLDER** – checks folder with nodes’ configuration files;
**WATCHDOG_LOG** – was used for restarts calculation;
**EMAIL** – is used for profile maintaining on the <a href="https://stat.storj.maxrival.com/" target="_blank">statistic’s server</a>.

<font color="blue" size=2>* WATCHDOG_LOG - you may leave unfilled, it will be deprecated soon</font>.


3.	Save the configuration file.
4.	Now we need to set up an automatic data collection and sending it to the statistic server. Add following commands to the **crontab** file:

```bash
crontab -e
PATH=/bin:/usr/bin:/usr/local/bin:/home/storj/.nvm/versions/node/v6.11.2/bin/
*/5 * * * * /bin/bash /home/storj/scripts/Storj-Utils/health.sh --api > /dev/null 2>&1
```

The variable PATH probably already has some parameters, but we should add the path to the node environment interpreter. You can precise a path to the interpreter with command:

```bash
which node
```

You should receive an answer as follows:

```bash
~/.nvm/versions/node/v6.11.3/bin/node
```

You should add this path to the PATH variable.
Please note you should change this path every time after the **node** updates, because name of node folder will be changed with a new **node’s** version number.

<hr/>

#####Script update

To update the script, you should move to the script’s home folder and run command:

```bash
git pull
```

The utility **git** downloads the latest version of the **health** script. All changes will run immediately. There is no need to setup any additional components or make any changes in **config.cfg**.  Restarting the **storjshare-daemon** is not necessary too.  

<hr/>

#####How to run the script manually

The **health** script runs in two different modes:
The first mode is showing statistics without data sending to the statistic server:

```bash
bash health.sh –cli
```

<img src="/content/images/2017/10/storjshare_health_script_cli_mode-1.png">

The second mode is used for sending data to the statistic server:

```bash
bash health.sh –api
```

<img src="/content/images/2017/10/storjshare_health_script_api_mode.png">

<hr/>

#####Script diagnostic
In case the script does not send date to the statistic server, you should change an old string in the **crontab** file:

```bash
*/5 * * * * /bin/bash /home/storj/scripts/Storj-Utils/health.sh --api > /dev/null 2>&1
```

with the followed string:

```bash
*/1 * * * * /bin/bash /home/storj/sh/health.sh --api > /home/storj/log.log
```

After this script is completed by **crontab**, you will have a log file that contains an error, which encountered during script’s work in background.

An actual statistic you can check at <a href="http://stat.storj.maxrival.com" target="_blank">stat.storj.maxrival.com</a>

<hr/>

#####How to switch to the automatic update

First version of the **health** script were set up with **wget** command and changing an old script’s version with a new one. All of variables were inside the script and needed to be changed manually every update procedure. Nowadays these obstacles are successfully overcome.

To change a very old script with a new version you should set up it by using **git** and make changes in the **config.cfg** as described above.

If you already have a version with **config.cfg** file, you just need set up a new version with **git** and change a new **config.cfg** with the old version.

Take into account git makes a new folder **Storj-Utils** and all new files will be in this folder and don’t forget to change the path to the script in the **crontab**.

<b>Special thanks to Alexandr Goryachev for the translate!</b>
