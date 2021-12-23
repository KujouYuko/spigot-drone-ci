#!/bin/bash

VERSION=("1.12.2" "1.16.5" "1.18.1")

function telegram_notify()
{
    curl -d parse_mode="Markdown" -d text="${1}" https://api.telegram.org/bot"${BOT_TOKEN}"/sendMessage?chat_id="${CHAT_ID}"
}

wget https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
telegram_notify "已开始新的构建。"
for i in ${VERSION[@]};
do
    telegram_notify "即将构建的 Spigot 版本为 ${i}。"
    START=$(date +"%s")
    VER=`echo ${i} | awk '{split($0,a,"[..]");print a[2]}'`
    if [ "${VER}" -ge 18 ]; then
        archlinux-java set java-17-openjdk
    else
        archlinux-java set java-8-openjdk
    fi
    java -jar BuildTools.jar --rev "${i}"
    if [ ! -f "spigot-${i}.jar" ]; then
        telegram_notify "构建失败，请检查输出日志。"
        exit 1
    fi
    END=$(date +"%s")
    DURTION=$((END - START))
    curl -F document=@spigot-"${i}".jar https://api.telegram.org/bot"${BOT_TOKEN}"/sendDocument?chat_id="${CHAT_ID}"
done
telegram_notify "构建完毕，此次构建耗时 $((DURTION / 60)) 分 $((DURTION % 60)) 秒。"
