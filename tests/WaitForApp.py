import requests
from time import sleep, time


def wait_for_application(url, timeout=300, interval=5):
    """Wait for the web application to become available."""
    start_time = time()
    while (time() - start_time) < timeout:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                print(f"Application is now accessible at {url}.")
                return True
        except requests.ConnectionError:
            print(f"Application at {url} not yet available. Retrying in {interval} seconds.")
        sleep(interval)
    raise Exception(f"Timed out waiting for application to start at {url}.")
