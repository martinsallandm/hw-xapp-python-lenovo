FROM registry.hub.docker.com/martinsallan/xapp-image-base

# copy rmr libraries from builder image in lieu of an Alpine package
COPY --from=nexus3.o-ran-sc.org:10002/o-ran-sc/bldr-alpine3-rmr:4.0.5 /usr/local/lib64/librmr* /usr/local/lib64/


# RMR setup
RUN mkdir -p /opt/route/
COPY init/test_route.rt /opt/route/test_route.rt
ENV LD_LIBRARY_PATH /usr/local/lib/:/usr/local/lib64
ENV RMR_SEED_RT /opt/route/test_route.rt


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
#ENV DBAAS_SERVICE_HOST=service-ricplt-dbaas-tcp.ricplt.svc.cluster.local
ENV DBAAS_SERVICE_HOST=10.244.0.143

#Run
CMD run-hw-python.py
