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
# Uninstall it afterwards to prevent ChromeDriver from using old version
ARG CHROME_VERSION="114.0.5735.198-1"
RUN apt-get update
RUN apt-get install -f

RUN wget --no-verbose -O /tmp/chrome.deb https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}_amd64.deb \
  && apt install -y /tmp/chrome.deb \
  && rm /tmp/chrome.deb \
  && apt-get remove -y google-chrome-stable

# Fetch and install Google Chrome and ChromeDriver using the provided JSON API
RUN set -eux; \
    JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"; \
    CHROME_URL=$(curl -sS ${JSON_URL} | jq -r '.channels.Stable.downloads.chrome[] | select(.platform=="linux64") | .url'); \
    CHROMEDRIVER_URL=$(curl -sS ${JSON_URL} | jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform=="linux64") | .url'); \
    # Create /opt/chrome directory
    mkdir -p /opt/chrome; \
    # Download and unzip Chrome
    wget -O chrome-linux64.zip ${CHROME_URL}; \
    unzip -q chrome-linux64.zip -d /opt; \
    mv /opt/chrome-linux64/* /opt/chrome/; \
    rmdir /opt/chrome-linux64; \
    rm chrome-linux64.zip; \
    # Download and unzip ChromeDriver
    wget -O chromedriver-linux64.zip ${CHROMEDRIVER_URL}; \
    unzip -j chromedriver-linux64.zip -d /opt/chrome; \
    rm chromedriver-linux64.zip; \
    chmod +x /opt/chrome/chromedriver

# Set environment variable for Chrome binary
ENV CHROME_BIN=/opt/chrome/chrome
ENV PATH="/opt/chrome:$PATH"

# set display port to avoid crash
ENV DISPLAY=:99

# Set up virtual Python environment
# This prevents warnings about running pip as 'root'

# Create a virtual environment in the container at /opt/venv
RUN python -m venv /opt/venv

# Activate the virtual environment
ENV PATH="/opt/venv/bin:$PATH"

# Any subsequent RUN commands and CMD/ENTRYPOINT will use the virtual environment,
# and any Python packages installed will be contained within it.

RUN pip install robotframework
RUN pip install robotframework-seleniumlibrary

COPY test1.robot test1.robot
