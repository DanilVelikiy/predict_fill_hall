# базовый образ - убунту 20
ARG ROOT_CONTAINER=ubuntu:focal

FROM $ROOT_CONTAINER

#RUN apt-get install --yes python3.9 && python3-pip && jupyterlab && jupyterlab && matplotlib && keras
RUN apt-get update --yes
RUN apt-get upgrade --yes
RUN apt-get install --yes sudo
RUN apt-get install --yes python3.9
RUN apt-get install --yes python3-pip
RUN pip install jupyterlab

# это взял из какой то официальной сборки на гитхаб по юпитеру 
# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
RUN apt-get update --yes && \
    # - apt-get upgrade is run to patch known vulnerabilities in apt-get packages as
    #   the ubuntu base image is rebuilt too seldom sometimes (less than once a month)
    apt-get upgrade --yes && \
    apt-get install --yes --no-install-recommends \
    # - bzip2 is necessary to extract the micromamba executable.
    bzip2 \
    ca-certificates \
    fonts-liberation \
    locales \
    # - pandoc is used to convert notebooks to html files
    #   it's not present in aarch64 ubuntu image, so we install it here
    pandoc \
    # - run-one - a wrapper script that runs no more
    #   than one unique  instance  of  some  command with a unique set of arguments,
    #   we use `run-one-constantly` to support `RESTARTABLE` option
    run-one \
    # - tini is installed as a helpful container entrypoint that reaps zombie
    #   processes and such of the actual executable we want to start, see
    #   https://github.com/krallin/tini#why-tini for details.
    tini \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

RUN pip install numpy
RUN pip install matplotlib
RUN pip install seaborn
RUN pip install pandas
RUN pip install scipy
RUN pip install plotly

# создам системного пользователя для jupiter
RUN useradd -ms /bin/bash jupyter
# переключаюсь на этого юзера
USER jupyter
# Set the container working directory to the user home folder
WORKDIR /home/jupyter
# запуск юпитер лабы с нужными параметрами и портом
# запись в таком виде что бы потом работал Сtrl-C для прерывания
CMD ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--ServerApp.token=''", "--ServerApp.password=''", "--ServerApp.allow_origin='*'"]:
