#!/bin/bash
# Отключаем мгновенное падение при ошибках, чтобы увидеть их текст
set -uo pipefail

count=0

# Сортировка файлов
for file in *; do
    [ -f "$file" ] || continue
    [ "$file" != "$(basename "$0")" ] || continue

    filename="${file%.*}"
    mkdir -p "$filename"
    mv "$file" "$filename/"
    ((count++))
done

if [ "$count" -eq 0 ]; then
    echo "Нет файлов для переноса."
    exit 0
fi

echo "--> Индексация файлов в Git..."
git add .

echo "--> Создание коммита..."
git commit -m "Авто-пуш: файлы разложены по персональным папкам ($count шт.)"

echo "--> Отправка на GitHub..."
# Запускаем push и смотрим, что пойдет не так
if git push; then
    echo "🚀 Всё готово! Успешно отправлено файлов: $count"
else
    echo "❌ Ошибка: git push не сработал!"
    echo "Выполняем принудительную связку веток на случай, если они слетели..."
    git push -u origin main
fi
