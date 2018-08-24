FROM ruby:2.5.0
RUN apt-get update && \
    apt-get install -y net-tools

# Install depends.
RUN apt-get install -y x11vnc xvfb fluxbox wget
# Install Chrome
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

RUN apt-get update && apt-get -y install google-chrome-stable

ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install
  
COPY . $APP_HOME
ENV ENVIRONMENT default

CMD bundle exec cucumber features/specs