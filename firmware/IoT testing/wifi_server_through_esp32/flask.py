import requests
import time

ESP32_IP = "http://192.168.4.1"  # Default SoftAP IP

def get_sound():
    try:
        r = requests.get(f"{ESP32_IP}/get-sound", timeout=0.5)
        return int(r.text.strip())
    except:
        return None

while True:
    val = get_sound()
    if val is not None:
        print("Mic Value:", val)
    time.sleep(0.01)  # 100Hz polling
