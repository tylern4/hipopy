FROM alpine:3.8

RUN apk add --no-cache make g++ gcc cmake lz4-dev python3-dev && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --upgrade pip setuptools ipython cython numpy && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    rm -r /root/.cache

COPY . /usr/source/hipopy
WORKDIR /usr/source/hipopy

ENV LD_LIBRARY_PATH /usr/local/lib
ENV PYTHONPATH /usr/local/lib

RUN mkdir -p build && cd build && cmake .. && make && make install

WORKDIR /tmp
ENTRYPOINT ["ipython"]
