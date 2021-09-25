FROM ubuntu

# copy rmr libraries from builder image in lieu of an Alpine package
COPY --from=nexus3.o-ran-sc.org:10002/o-ran-sc/bldr-alpine3-rmr:4.0.5 /usr/local/lib64/librmr* /usr/local/lib64/
# RMR setup
RUN mkdir -p /opt/route/
COPY init/test_route.rt /opt/route/test_route.rt
ENV LD_LIBRARY_PATH /usr/local/lib/:/usr/local/lib64
ENV RMR_SEED_RT /opt/route/test_route.rt


# install TONS of packages that we probably wont need
RUN apt update 
RUN apt install -y default-jre openjdk-11-jre-headless openjdk-8-jre-headless 
RUN apt install -y python3-pip
RUN apt install -y wget
RUN apt install -y git
RUN apt install -y cmake

# pip3 is not in the python38 docker image 🤦
RUN pip3 install dataclasses

# more dependencies for xapps...
RUN pip3 install -U protobuf

# even more... swagger shit
RUN cd /tmp && \
	wget https://repo1.maven.org/maven2/io/swagger/swagger-codegen-cli/2.4.13/swagger-codegen-cli-2.4.13.jar -O swagger-codegen-cli.jar && \
	java -jar swagger-codegen-cli.jar generate -i https://developers.strava.com/swagger/swagger.json -l python -o generated && \
	cd generated/ && \
	python3 setup.py install




# install xappframe
RUN git clone "https://gerrit.o-ran-sc.org/r/ric-plt/xapp-frame-py" 
WORKDIR ./xapp-frame-py
RUN python3 setup.py build 
RUN python3 setup.py install

# install rmr libs (The RIC Message Router (RMR))
RUN git clone "https://gerrit.o-ran-sc.org/r/ric-plt/lib/rmr"
WORKDIR ./rmr
RUN mkdir build 
WORKDIR ./build 
RUN cmake .. 
RUN make package
RUN make install



# Install
COPY setup.py /tmp
COPY README.md /tmp
COPY LICENSE.txt /tmp/
COPY src/ /tmp/src
COPY init/ /tmp/init
RUN pip3 install /tmp

# Env - TODO- Configmap
ENV PYTHONUNBUFFERED 1
ENV CONFIG_FILE=/tmp/init/config-file.json

# For Default DB connection, modify for resp kubernetes env
ENV DBAAS_SERVICE_PORT=6379
ENV DBAAS_SERVICE_HOST=service-ricplt-dbaas-tcp.ricplt.svc.cluster.local

#Run
CMD run-hw-python.py
