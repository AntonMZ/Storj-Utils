# Storj-Utils

![Storj bash health script](http://maxrival.com/content/images/2017/05/storj-bash-healt-script-v1.0.2.png)


Скрипт проверки основных параметров работы ноды Storjshare-Cli для Linux.

Установка скрипта.
wget https://raw.githubusercontent.com/AntonMZ/Storj-Utils/master/health.sh


- [**NodeID**]<br/>
Уникальный идентификатор ноды.<br/>
Данные берутся из **storjshare status**

- [**ResponseTime**]<br/>
Показатель стабильности работы.<br/>
Выставляется непосредственно бриджем.<br/>
Данные беруться с api.storj.io

    Cтатусы<br/>
    - **good** - в пределах нормы
    - **bad** - не в пределах нормы

  Для Москвы нормой считается значение данного показателя до 1000<br/>
  Выставляется непосредственно бриджем.<br/>
  Данные беруться с api.storj.io

- [**Address**]<br/>
Текущий IP адрес ноды<br/>
Данные берутся локально с сервера.<br/>

- [**User Agent**]<br/>
Версия агента на ноде<br/>
Данные беруться с api.storj.io

- [**Last Seen**]<br/>
Последнее появление в сети, зафиксированное бриджем.<br/>
Данные беруться с api.storj.io

- [**Port**]<br/>
Порт ноды<br/>
Данные беруться с api.storj.io

- [**Protocol**]<br/>
Версия протокола storjshare-cli<br/>
Данные беруться с api.storj.io

- [**Last Timeout**]<br/>
Данные беруться с api.storj.io

- [**Timeout Rate**]<br/>
Данные беруться с api.storj.io

- [**DeltaTime**]<br/>
Параметр проверяет синхронизацию локального времени и времени эталонного NTP сервера. Параметр передается непосредственно бриджом сети.<br/>

<hr>
Описание всех параметров будет представлено отдельной публикацией на сайте http://maxrival.com
