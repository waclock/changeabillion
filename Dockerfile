FROM ruby:2.3.5-slim

# ENV: Sets the environment variable APP_HOME so we don't have to repeat it later
ENV APP_HOME /webapp
# RUN: Executes commands to build and customize the image. It runs from '/'
RUN mkdir $APP_HOME
# To allow a persistent bundle install
ENV BUNDLE_PATH /ruby_gems

# Update and install needed libraries
# Rails gems basics
RUN apt-get update -y && apt-get install -qq build-essential nodejs libpq-dev libxslt-dev libxml2-dev git-all -y --fix-missing --no-install-recommends
# For diagrams and image processing
RUN apt-get update -y && apt-get install graphviz -y
# For paperclip usage
RUN apt-get update -y && apt-get install imagemagick libmagickwand-dev --fix-missing --no-install-recommends -y
# # Word and PDF creation tools (optional)
# RUN gem install docsplit && add-apt-repository ppa:dhor/myway -y && apt-get update 
# RUN apt-get install graphicsmagick -y && apt-get install poppler-utils poppler-data
# RUN apt-get install pdftk -y && apt-get install libreoffice -y

# COPY: <src> <dest>
# Copy the Gemfile as well as the Gemfile.lock and install
# the RubyGems. This is a separate step so the dependencies
# will be cached unless changes to one of those two files
# are made.
COPY Gemfile $APP_HOME/
COPY Gemfile.lock $APP_HOME/

# WORKDIR: Configures the main working directory. This is the base
# directory used in any further RUN, COPY, and ENTRYPOINT commands.
# Allows us to modify files in the project and read them after a refresh.
WORKDIR $APP_HOME

RUN gem install bundler && \
    bundle config build.nokogiri --use-system-libraries && \
    gem install nokogiri -- --use-system-libraries=true --with-xml2-include=/usr/include/libxml2
COPY . $APP_HOME

# Disable Sidekiq Logging
RUN mkdir log/ || :
RUN touch log/development.log
RUN ln -fs /dev/null log/development.log
RUN touch log/production.log
RUN ln -fs /dev/null log/production.log
RUN touch log/sidekiq.log
RUN ln -fs /dev/null log/sidekiq.log


ENV GEM_HOME /ruby_gems
# We now run the Startfile for web

RUN chmod 777 ./Startfile.sh

CMD ["/bin/bash", "-l", "-c", "./Startfile.sh"]
