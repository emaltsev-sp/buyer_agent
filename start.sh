#!/bin/bash

# --- 1. Настройка и запуск VNC сервера для GUI ---
# Создаем директорию VNC, если ее нет
mkdir -p ~/.vnc

# Устанавливаем пароль VNC (замените 'yourpassword' на свой)
# Важно: этот пароль будет виден в вашем репозитории. Для безопасности используйте переменные окружения RunPod.
echo "ValidPass123!" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

# Создаем конфигурацию для запуска рабочего стола XFCE
echo "startxfce4 &" > ~/.vnc/xstartup
chmod +x ~/.vnc/xstartup

# Запускаем VNC сервер на "экране" :1 с хорошим разрешением
tightvncserver -kill :1 || true # Убиваем старый процесс, если он есть
tightvncserver -geometry 1920x1080 :1

# --- 2. Загрузка модели (если она еще не скачана) ---
MODEL_DIR="/workspace/models/GLM-4.5"
if [ ! -d "$MODEL_DIR" ]; then
  echo "Модель не найдена. Начинаю загрузку zai-org/GLM-4.5..."
  # Используем huggingface-cli для надежной загрузки
  huggingface-cli download zai-org/GLM-4.5 --local-dir $MODEL_DIR --local-dir-use-symlinks False
  echo "Загрузка модели завершена."
else
  echo "Модель уже существует в $MODEL_DIR."
fi

# --- 3. Запуск Jupyter Lab в фоновом режиме ---
jupyter lab --ip=0.0.0.0 --port=8888 --allow-root --no-browser --NotebookApp.token='' &

# --- 4. Запуск vLLM сервера ---
echo "Запускаю vLLM сервер..."
python -m vllm.entrypoints.openai.api_server \
  --model $MODEL_DIR \
  --served-model-name glm-4.5 \
  --trust-remote-code \
  --tensor-parallel-size 8 \
  --dtype bfloat16 \
  --max-model-len 131072 \
  --enable-auto-tool-choice \
  --tool-call-parser glm45 \
  --reasoning-parser glm45