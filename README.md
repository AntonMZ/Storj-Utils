[![License](https://img.shields.io/github/license/AntonMZ/Storj-Utils.svg)](https://github.com/AntonMZ/Storj-Utils/blob/master/LICENSE)

**Compatible with Stat Storj Statistics (https://stat.storj.maxrival.com)**

**Compatible with storjshare daemon: 4.0.1, core: 7.0.0, protocol: 1.2.0**


Current Version 1.0.5

# Storj-Utils

Скрипт проверки основных параметров работы нод Storjshare-Cli для Linux.<br/>

![Storj bash health script](http://maxrival.com/content/images/2017/05/storj-bash-healt-script-v1.0.2.png)

Скрипт работает на CentOS Linux release 7.0.1406 (Core)<br/>
На других платформах не проверялся.
<hr>

Для корректной работы скрипта требуется утилита netstat из пакета net-tools.<br/>
Для установки пакета:

```
yum install net-tools git -y
```

Установка

```
git clone https://github.com/AntonMZ/Storj-Utils.git
chmod +x Storj-Utils/health.sh
```
<hr>

**Hostname** - hostname сервера где размещаются ноды<br/>
**Ip** - ip адреса сервера где размещаются ноды<br/>
**Date** - локальное время сервера где размещаются ноды<br/>
**Open Sessions** - количество открытых storjshare-cli tcp сессий<br/>
**Storjshare Version** - версия демона, ядра и протокола, используемого storjshare-cli

<hr>

- [**NodeID**] - уникальный идентификатор ноды.<br/>
Данные берутся из **storjshare status**

<hr>

- [**ResponseTime**] - показатель разницы между publish и offer.<br/>
Является показателем стабильности работы ноды, влияет на получение новых контрактов.<br/>
Выставляется непосредственно бриджем.<br/>
Чем ниже, тем больше шансов получить новые контракты.<br/>
Уменьшается со временем.<br/>
Чем стабильнее работает нода, тем меньше данный показатель.<br/>
Данный параметр является одним из главных, который проверяет бридж при загрузке нового контракта в сеть.<br/>
По данному параметру бридж сортирует список нод.<br/>
Данные берутся с api.storj.io

 Cтатусы<br/>
 **good** - в пределах нормы<br/>
 **bad** - не в пределах нормы

 *Для Москвы нормой считается значение данного показателя до 1000*<br/>

 Выставляется непосредственно бриджем.<br/>
 Данные берутся с api.storj.io

<hr>

- [**Address**] - текущий IP адрес ноды.<br/>
Данные берутся локально с сервера ноды.<br/>

<hr>

- [**User Agent**] - версия агента на ноде.<br/>

 Данные берутся с api.storj.io<br/>

<hr>

- [**Last Seen**] - последнее время появления ноды в сети.

 Последнее появление ноды в сети зафиксированное бриджем.<br/>
Данные берутся с api.storj.io<br/>

<hr>

- [**Port**] - порт ноды<br/>
Данные берутся с api.storj.io<br/>

 При запуске скрипта осуществляется проверка порта на ***открыт/закрыт*** через внешний api ресурс.

 Cтатусы<br/>
 **open** - порт открыт<br/>
 **close** - порт закрыт<br/>
 **filtered** - порт открыт, но используется через роутер или фаервол

 Порт может быть закрыт по многим причинам.

 Самые распространенные:

 * порт закрыт брандмауэром Windows или iptables
 * порт не "проброшен" в роутере/маршрутизаторе

<hr>

- [**Protocol**] - версия протокола storjshare-cli<br/>
Данные берутся с api.storj.io<br/>

<hr>

- [**Last Timeout**] - последнее замеченное время недоступности ноды<br/>
Влияет на получение новых контрактов.<br/>
Данные берутся с api.storj.io

<hr>

- [**Timeout Rate**] - коэффициент бриджа между lastseen и lastimeout<br/>
Влияет на получение новых контрактов.<br/>
Если данный параметр выше нуля, то получение новых контрактов будет затруднительно (не принимается offer)<br/>
Данные берутся с api.storj.io

 Cтатусы<br/>
 **good** - значение равно 0<br/>
 **bad** - значение отличное от 0

<hr>

- [**DeltaTime**] - временная дельта<br/>
Параметр показывает разницу локального времени и времени эталонного NTP сервера.<br/>
Параметр вычисляет нода сети.<br/>

 Cтатусы<br/>

 **bad** - значение больше 500 или -500<br/>
 **medium** - значение больше 100 или -100<br/>
 **good** - значение меньше 100 или -100


## Режим сбора статистики
Для использования этого режима необходимо настроить конфигурационный файл [config.cfg](config.cfg) и запустить один раз скрипт от пользователя, под которым будет работать задача периодической отправки статистики на [сайт статистики](https://stat.storj.maxrival.com/):
1. Клонируйте скрипт в нужную папку
```
git clone https://github.com/AntonMZ/Storj-Utils.git
```
2. Отредактируйте конфигурационный файл [config.cfg](config.cfg)
```
LOGS_FOLDER=/root/.config/storjshare/logs
CONFIGS_FOLDER=/root/.config/storjshare/configs
WATCHDOG_LOG=/var/log/storjshare-daemon-status.log
EMAIL=az@maxrival.com
```
где:
* LOGS_FOLDER – папка с логами StorjShare;
* CONFIGS_FOLDER – папка с конфигурационными файлами StorjShare;
* WATCHDOG_LOG – устарело;
* EMAIL – используется для авторизации на [сайте статистики](https://stat.storj.maxrival.com/).
3. Запустите скрипт от пользователя, под которым потом будет работать задача в crontab.
```
health.sh
```
или
```
sudo su -l USER -c "health.sh"
```
где USER - пользователь, от которого будет работать crontab.

4. Создайте задачу в crontab
```
crontab -e
*/5 * * * * /bin/bash /home/storj/scripts/Storj-Utils/health.sh --api > /dev/null 2>&1
```

<hr>
Полная инструкция по работе со скриптом на сайте <a href="http://maxrival.com/ispolzovaniie-health-skripta-dlia-provierki-storj-nod/" target="_blank">maxrival.com</a>




<hr>
v.1.0.1

Start repo
<hr>
v.1.0.2

Добавлено:

- вывод количества активных tcp сессий открытых storjshare-cli
- вывод поля **[ResponseTime]** и статус проверки
- вывод поля **[Address]**
- вывод поля **[User Agent]**
- вывод поля **[Last Seen]**
- вывод поля **[Port]** и статус внешней проверки через api
- вывод поля **[Protocol]**
- вывод поля **[Last Timeout]**
- вывод поля **[Timeout Rate]** и статус проверки
- вывод поля **[DeltaTime]** и статус проверки
<hr>

v.1.0.3

Добавлено/исправлено:

- сканирование лог файла за день (лог файлы от storjsgare-daemon теперь генерируются за день)
- добавлен вывод поля **[Log_file]**
- исправлен вывод поля **[DeltaTime]** (delta может отсутствовть в лог файле за день)
- добавлен вывод поля **[Share_allocated]**
- добавлен вывод поля **[Share_Used]**
- добавлен вывод поля **[Last publish]**
- добавлен вывод поля **[Last offer]**
- добавлен вывод поля **[Last consigned]**
- добавлен вывод поля **[Last download]**
- добавлен вывод поля **[Last upload]**
- добавлен вывод поля **[Offers counts]**
- добавлен вывод поля **[Publish counts]**
- добавлен вывод поля **[Download counts]**
- добавлен вывод поля **[Upload counts]**
- добавлен вывод поля **[Consignment counts]**

MIT License

Copyright (c) 2017 Anton Zheltyshev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
