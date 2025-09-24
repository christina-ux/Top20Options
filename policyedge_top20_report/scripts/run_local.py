import sys, requests

def main():
    if len(sys.argv)<2:
        print("usage: python scripts/run_local.py [preopen|midday|eod|poll]")
        sys.exit(1)
    action = sys.argv[1]
    url = {"preopen":"/run/preopen","midday":"/run/midday","eod":"/run/eod","poll":"/run/poll"}[action]
    r = requests.post("http://127.0.0.1:8000"+url)
    print(r.status_code, r.text)

if __name__ == "__main__":
    main()
