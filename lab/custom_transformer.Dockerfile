
FROM python:3.9-slim-bullseye


COPY poetry.lock /lab/
COPY pyproject.toml /lab/
WORKDIR /lab
RUN mkdir kservelab && \
    touch kservelab/__init__.py && \
    pip install --no-cache-dir -e .

COPY . /lab

RUN useradd kserve -m -u 1000 -d /home/kserve
USER 1000
ENTRYPOINT ["python", "-m", "kservelab.custom_transformer"]
