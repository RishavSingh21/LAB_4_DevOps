FROM python:3.12-slim
WORKDIR /app
RUN useradd -m appuser
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app.py .
USER appuser
EXPOSE 5000
HEALTHCHECK --interval=10s --timeout=3s CMD python -c "import urllib.request;urllib.request.urlopen('http://localhost:5000/health')"
CMD ["gunicorn", "-b", "0.0.0.0:5000", "-w", "2", "app:app"]
