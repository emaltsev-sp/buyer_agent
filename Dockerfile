# Используем официальный образ RunPod с PyTorch и CUDA
FROM runpod/pytorch:2.3.1-py3.11-cuda12.1.1-devel-ubuntu22.04

# Устанавливаем системные зависимости: рабочий стол, VNC, git-lfs для моделей
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 xfce4-goodies tightvncserver git-lfs && \
    rm -rf /var/lib/apt/lists/*

# Копируем файл с Python-зависимостями в контейнер
COPY requirements.txt /

# Устанавливаем все Python-библиотеки
RUN pip install --no-cache-dir -r /requirements.txt

# Устанавливаем браузеры, необходимые для Playwright
RUN playwright install --with-deps

# Устанавливаем рабочую директорию
WORKDIR /workspace

# Копируем наш скрипт запуска в контейнер
COPY start.sh /workspace/start.sh
RUN chmod +x /workspace/start.sh

# Открываем порты: 8000 для vLLM API, 5901 для VNC, 8888 для Jupyter
EXPOSE 8000 5901 8888

# Устанавливаем команду по умолчанию
CMD ["/bin/bash", "/workspace/start.sh"]
