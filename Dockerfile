FROM python:3.12

# Install dependencies required for fetching and parsing JSON and for installing Chrome
# libnss3 for running ChromeDriver
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    jq \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install old chrome version via package manager to get dependencies
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list'
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# Fetch and install ChromeDriver using the Chrome-for-Testing JSON API
RUN set -eux; \
    JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"; \
    CHROMEDRIVER_URL=$(curl -sS ${JSON_URL} | jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform=="linux64") | .url'); \
    # Download and unzip ChromeDriver
    wget -O chromedriver-linux64.zip ${CHROMEDRIVER_URL}; \
    unzip -j chromedriver-linux64.zip -d /opt/chrome; \
    rm chromedriver-linux64.zip; \
    chmod +x /opt/chrome/chromedriver

# set display port to avoid crash
ENV DISPLAY=:99

# Set up virtual Python environment
# This prevents warnings about running pip as 'root'
RUN python -m venv /opt/venv

# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Any subsequent RUN commands and CMD/ENTRYPOINT will use the virtual environment,
# and any Python packages installed will be contained within it.

RUN pip install robotframework
RUN pip install robotframework-seleniumlibrary

COPY test1.robot test1.robot
