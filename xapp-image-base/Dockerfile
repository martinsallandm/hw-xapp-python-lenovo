FROM ubuntu

# copy rmr libraries from builder image in lieu of an Alpine package
COPY --from=nexus3.o-ran-sc.org:10002/o-ran-sc/bldr-alpine3-rmr:4.0.5 /usr/local/lib64/librmr* /usr/local/lib64/


# install TONS of packages that we probably wont need
RUN apt update 
#RUN apt install -y default-jre openjdk-11-jre-headless openjdk-8-jre-headless 
RUN apt install -y python3-pip
#RUN apt install -y wget
#RUN apt install -y git
#RUN apt install -y cmake

# pip3 is not in the python38 docker image 🤦
RUN pip3 install dataclasses

# more dependencies for xapps...
RUN pip3 install -U protobuf

# even more... swagger shit
RUN mkdir /tmp/swagger
COPY swagger /tmp/swagger
WORKDIR /tmp/swagger
RUN python3 setup.py install




# install xappframe
RUN mkdir /tmp/xapp-frame-py
COPY xapp-frame-py /tmp/xapp-frame-py
WORKDIR /tmp/xapp-frame-py
RUN python3 setup.py build 
RUN python3 setup.py install

# install rmr libs (The RIC Message Router (RMR))
COPY rmr_4.7.4_amd64.deb /tmp
RUN apt install /tmp/rmr_4.7.4_amd64.deb

