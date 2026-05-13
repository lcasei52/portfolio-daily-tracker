FROM python:3.11-slim
WORKDIR /app
# Copy entire dashboard so backend can import from core/, config/, providers/, agents/
COPY backend/requirements.txt ./backend/
RUN pip install --no-cache-dir -r ./backend/requirements.txt
COPY . .
ENV PORTFOLIO_DIR=/app/portfolio
EXPOSE 8000
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]
