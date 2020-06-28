#FROM gcr.io/tfx-oss-public/ml_metadata_store_server:v0.21.1
FROM python:3.6-alpine
#ADD Anaconda3-2020.02-Linux-x86_64.sh /opt
#WORKDIR /opt
#RUN sh -c '/bin/echo -e "\n\yes\n\nyes" | sh Anaconda3-2020.02-Linux-x86_64.sh'
RUN mkdir /home/jovyan
# Install required packages
RUN apk add --update --virtual=.build-dependencies alpine-sdk nodejs ca-certificates musl-dev gcc   make cmake g++ gfortran  py-pip mysql-dev linux-headers libffi-dev libpng-dev freetype-dev libxml2-dev libxslt-dev
RUN apk add --update git
RUN apk add font-adobe-100dpi

# Additional packages for compatability (glibc)
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-i18n-2.23-r3.apk && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-bin-2.23-r3.apk && \
  apk add --no-cache glibc-2.23-r3.apk glibc-bin-2.23-r3.apk glibc-i18n-2.23-r3.apk && \
  rm "/etc/apk/keys/sgerrand.rsa.pub" && \
  /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
  echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
  ln -s /usr/include/locale.h /usr/include/xlocale.h

RUN pip install --upgrade pip
RUN pip install Cython --install-option="--no-cython-compile"
# Install Jupyter
RUN pip install jupyter
RUN pip install ipywidgets
RUN pip install nbresuse==0.3.3
#RUN pip install tensorflow
#RUN pip install tf-nightly
#RUN pip install -i https://pypi.tuna.tsinghua.edu.cn/simple tensorflow==1.8.0
RUN jupyter nbextension enable --py widgetsnbextension

# Install JupyterLab
RUN pip install jupyterlab && jupyter serverextension enable --py jupyterlab

# Optional Clean-up
#  RUN apk del glibc-i18n && \
#  apk del .build-dependencies && \
#  rm glibc-2.23-r3.apk glibc-bin-2.23-r3.apk glibc-i18n-2.23-r3.apk && \
#  rm -rf /var/cache/apk/*

ENV LANG=zh_CN.UTF-8

# Install Python Packages & Requirements (Done near end to avoid invalidating cache)
#COPY requirements.txt requirements.txt
#RUN pip install -r requirements.txt

# Expose Jupyter port & cmd
EXPOSE 8888
RUN mkdir -p /opt/app/data
#CMD jupyter lab --ip=* --port=8888 --no-browser --notebook-dir=/opt/app/data --allow-root
ENV NB_PREFIX /

CMD ["sh","-c", "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.tornado_settings='{\"headers\":{\"Content-Security-Policy\":\"frame-ancestors self http://*.*.*.*:8082 http://10.18.3.10:8082 http://183.66.41.254:8082/   http://192.168.1.229:8082;\" }}' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
