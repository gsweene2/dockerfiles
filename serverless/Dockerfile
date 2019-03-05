# Pull base image.
FROM alpine:3.6

################################
# Install python
################################

RUN apk add --update python

RUN apk add python3

RUN apk add py-pip

RUN python3 -V

RUN pip --version

################################
# Install AWS CLI
################################
RUN pip install awscli --upgrade --user

# add aws cli location to path
ENV PATH=~/.local/bin:$PATH

RUN mkdir ~/.aws && touch ~/.aws/credentials

################################
# Install npm & serverless
################################

# Install Serverless
RUN apk add --update nodejs-npm

RUN npm install -g serverless