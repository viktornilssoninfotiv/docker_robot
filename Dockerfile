FROM python:3.12

# Install dependencies required for fetching and parsing JSON, and for installing Chrome
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Fetch and install Google Chrome and ChromeDriver using the provided JSON API
RUN set -eux; \
    JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"; \
    CHROME_URL=$(curl -sS ${JSON_URL} | jq -r '.channels.Stable.downloads.chrome[] | select(.platform=="linux64") | .url'); \
    CHROMEDRIVER_URL=$(curl -sS ${JSON_URL} | jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform=="linux64") | .url'); \
    wget -O chrome-linux.zip ${CHROME_URL}; \
    unzip chrome-linux.zip -d /opt/chrome; \
    wget -O chromedriver-linux.zip ${CHROMEDRIVER_URL}; \
    unzip -j chromedriver-linux.zip chromedriver-linux64/chromedriver -d /usr/local/bin; \
    chmod +x /usr/local/bin/chromedriver; \
    rm chrome-linux.zip chromedriver-linux.zip

# Set environment variable for Chrome binary
ENV CHROME_BIN=/opt/chrome/chrome


# set display port to avoid crash
ENV DISPLAY=:99

# install requirements
RUN pip install robotframework
RUN pip install robotframework-seleniumlibrary

COPY test1.robot test1.robot
