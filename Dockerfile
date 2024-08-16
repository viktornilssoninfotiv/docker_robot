FROM python:3.12

# Install dependencies required for fetching and parsing JSON and for installing ChromeDriver
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    curl \
    jq \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install latest stable chrome via package manager
# Could be obtained with Chrome-for-Testing JSON API, but that won't include dependencies

# Download the Google Chrome signing key to a temporary location
RUN wget https://dl-ssl.google.com/linux/linux_signing_key.pub -O /tmp/google.pub

# Import the downloaded signing key into a custom keyring within the /etc/apt/keyrings directory
RUN gpg --no-default-keyring --keyring /etc/apt/keyrings/google-chrome.gpg --import /tmp/google.pub

# Add the Google Chrome repository to the system's software sources list,
# specifying the custom keyring for signature verification
RUN echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] \
http://dl.google.com/linux/chrome/deb/ stable main' | \
tee /etc/apt/sources.list.d/google-chrome.list


# Update the package list to include the new repository before installing
RUN apt-get -y update
RUN apt-get install -y google-chrome-stable

# Fetch and install ChromeDriver using the Chrome-for-Testing JSON API
ENV JSON_URL="https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json"

# Define the platform variable
ENV PLATFORM="linux64"

# Use curl to fetch the Chrome-for-Testing JSON
# and extract the ChromeDriver URL for the specified platform
RUN set -eux; \
    CHROMEDRIVER_URL=$(curl -sS ${JSON_URL} | \
    jq -r --arg platform "$PLATFORM" '.channels.Stable.downloads.chromedriver[] | select(.platform==$platform) | .url'); \
    # Download ChromeDriver using the extracted URL
    wget -O chromedriver-${PLATFORM}.zip "${CHROMEDRIVER_URL}"; \
    # Unzip ChromeDriver to /opt/chrome, ignoring the directory structure within the zip file
    unzip -j chromedriver-${PLATFORM}.zip -d /opt/chrome; \
    # Remove the zip file to clean up
    rm chromedriver-${PLATFORM}.zip; \
    # Make ChromeDriver executable
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

COPY requirements.txt /
RUN python -m pip install --upgrade pip \
    && pip install -r requirements.txt
