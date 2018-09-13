FROM python:3

RUN apt-get update \
	&& apt-get install -y cmake liblz4-dev cython3 \
	&& rm -rf /var/lib/apt/lists

COPY . /usr/source/hipopy
WORKDIR /usr/source/hipopy

ENV LD_LIBRARY_PATH /usr/local/lib
ENV PYTHONPATH /usr/local/lib

RUN pip install numpy matplotlib pandas scikit-hep ipython uproot

RUN mkdir -p build && cd build && cmake .. && make && make install

WORKDIR /tmp
ENTRYPOINT ["python"]
