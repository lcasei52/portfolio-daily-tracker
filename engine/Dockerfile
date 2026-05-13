FROM python:3.11-slim
WORKDIR /app
COPY scripts/ scripts/
RUN pip install --no-cache-dir requests
RUN mkdir -p portfolio/holdings portfolio/snapshots reports logs
ENV PORTFOLIO_DIR=/app/portfolio
# Default: run scheduler. Override with: docker compose run engine python3 scripts/portfolio_snapshot.py
CMD ["python3", "scripts/portfolio_scheduler.py"]
