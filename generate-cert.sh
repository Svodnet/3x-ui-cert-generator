#!/bin/bash

# --- Проверка наличия необходимых утилит ---
if ! command -v curl &> /dev/null || ! command -v openssl &> /dev/null; then
    echo -e "\033[31mОшибка: Не найдены необходимые утилиты (curl и/или openssl).\033[0m"
    echo "Рекомендации:"
    echo "1. Установите их: sudo apt update && sudo apt install curl openssl -y"
    echo "2. После установки запустите скрипт заново."
    exit 1
fi

echo -e "\n\033[36m--- Шаг 1: Получение вашего публичного IP-адреса ---\033[0m"
ip=$(timeout 5 curl -4 -s icanhazip.com)
if [ -z "$ip" ]; then
    echo -e "\033[31mОшибка: Не удалось получить IP-адрес. Проверьте подключение к интернету.\033[0m"
    echo "Рекомендации:"
    echo "1. Проверьте, работает ли сеть: ping icanhazip.com"
    echo "2. Попробуйте выполнить скрипт ещё раз."
    exit 1
else
    echo -e "\033[32mУспешно: Ваш IP-адрес - $ip\033[0m"
fi

echo -e "\n\033[36m--- Шаг 2: Создание приватного ключа и сертификата ---\033[0m"
openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 3650 \
  -keyout secret.key -out cert.crt \
  -subj "/C=RU/ST=StateName/L=CityName/O=CompanyName/OU=CompanySectionName/CN=$ip" \
  -addext "subjectAltName=DNS:$ip,DNS:*.$ip,IP:$ip" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo -e "\033[31mОшибка: Не удалось создать сертификат. Проверьте права доступа.\033[0m"
    echo "Рекомендации:"
    echo "1. Убедитесь, что у вас есть права на запись в текущей директории."
    echo "2. Попробуйте запустить скрипт с правами администратора: sudo bash $0"
    exit 1
fi

echo -e "\n\033[32m✅ Готово! Сертификат и ключ успешно созданы!\033[0m"
echo -e "\033[33mФайлы сохранены в текущей папке:\033[0m"
echo -e "\033[31m  - Публичный ключ сертификата: $(pwd)/cert.crt\033[0m"
echo -e "\033[31m  - Приватный ключ: $(pwd)/secret.key\033[0m"
echo "Теперь вы можете использовать эти файлы для настройки вашего сервера."
