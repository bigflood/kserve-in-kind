import sys
import time

import numpy as np
import requests
from argparse_dataclass import ArgumentParser, dataclass


@dataclass
class CmdArgs:
    delay: float
    namespace: str
    name: str = "sklearn-iris"
    model: str = "sklearn-iris"
    port: int = 30582
    input_file: str = "iris-input.json"
    domain: str = "example.com"
    log_interval: int = 100


def read_file(fn):
    with open(fn, "rb") as f:
        return f.read()


def tooks_to_str(tooks):
    if len(tooks) <= 10:
        return " ".join(map("{:.05f}".format, tooks))
    return tooks_to_str(tooks[:5]) \
        + " .. " \
        + tooks_to_str(tooks[-5:])


def main():
    args = ArgumentParser(CmdArgs).parse_args(sys.argv[1:])
    i = 0
    tooks = []

    with requests.Session() as s:
        while True:
            i += 1
            data = read_file(args.input_file)
            t1 = time.time()
            resp = s.post(
                f"http://localhost:{args.port}/v1/models/{args.model}:predict",
                data=data,
                headers={
                    "Host": f"{args.name}.{args.namespace}.{args.domain}",
                },
            )
            t2 = time.time()
            tooks.append(t2 - t1)

            if i == 1 or resp.status_code != 200:
                print("first resp:", resp, resp.json(), "took=", tooks)
                tooks = []
            elif i % args.log_interval == 0:
                tooks.sort()
                print(
                    f"{i=}: {resp.json()=}\n  "
                    + "took: "
                    + f"avg={np.average(tooks):.05f}, "
                    + f"min={np.min(tooks):.05f}, "
                    + f"max={np.max(tooks):.05f}, "
                    + f"p90={np.percentile(tooks, 90):.05f}, "
                    + f"p95={np.percentile(tooks, 95):.05f}, "
                    + f"p99={np.percentile(tooks, 99):.05f}, "
                    + "\n  "
                    + tooks_to_str(tooks)
                )
                tooks = []

            time.sleep(args.delay)


if __name__ == "__main__":
    main()
