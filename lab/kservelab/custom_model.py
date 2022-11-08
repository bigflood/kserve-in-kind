import kserve
from kserve import ModelServer, model_server
from typing import Dict
import logging
import time


logging.basicConfig(level=kserve.constants.KSERVE_LOGLEVEL)


def custom_predict(instance):
    logging.info(instance)
    return 0.5


# for REST predictor the preprocess handler converts to input dict to the v1 REST protocol dict
class CustomModel(kserve.Model):
    def __init__(self, name: str):
        super().__init__(name)
        self.name = name
        self.ready = False

    def load(self):
        logging.info("load..")
        time.sleep(10)
        self.ready = True
        logging.info("ready!")

    def predict(self, payload: Dict, headers: Dict[str, str] = None) -> Dict:
        return {"predictions": [custom_predict(instance) for instance in payload['instances']]}


if __name__ == "__main__":
    model = CustomModel("custom-model")
    model.load()
    ModelServer(workers=1).start(models=[model])
