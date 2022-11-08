import kserve
from kserve import ModelServer, model_server
from typing import Dict
import logging
import argparse


logging.basicConfig(level=kserve.constants.KSERVE_LOGLEVEL)


def custom_transform(instance):
    logging.info(instance)
    return instance


# for REST predictor the preprocess handler converts to input dict to the v1 REST protocol dict
class CustomTransformer(kserve.Model):
    def __init__(self, name: str, predictor_host: str, protocol: str):
        super().__init__(name)
        self.predictor_host = predictor_host
        self.protocol = protocol
        self.ready = True

    def preprocess(self, inputs: Dict) -> Dict:
        return {'instances': [custom_transform(instance) for instance in inputs['instances']]}

    def postprocess(self, infer_response: Dict) -> Dict:
        return infer_response


if __name__ == "__main__":
    parser = argparse.ArgumentParser(parents=[model_server.parser])
    parser.add_argument(
        "--predictor_host", help="The URL for the model predict function", required=True
    )
    parser.add_argument(
        "--protocol", help="The protocol for the predictor", default="v1"
    )
    parser.add_argument(
        "--model_name", help="The name that the model is served under."
    )
    args, _ = parser.parse_known_args()

    model = CustomTransformer(args.model_name, predictor_host=args.predictor_host,
                             protocol=args.protocol)
    ModelServer().start(models=[model])
