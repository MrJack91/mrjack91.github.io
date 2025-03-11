FROM ruby:3.4.2-slim-bookworm

# Install dependencies for Jekyll
RUN apt-get update && apt-get install -y \
  build-essential \
  libssl-dev \
  libreadline-dev \
  zlib1g-dev \
  git \
  && rm -rf /var/lib/apt/lists/*

# Install Jekyll and Bundler
RUN gem install jekyll bundler

# Set the working directory
WORKDIR /srv/jekyll

# Copy the current directory contents into the container
# COPY . /srv/jekyll
COPY Gemfile Gemfile
RUN bundle install

# Install required Ruby gems via Bundler
# RUN bundle install

# Expose port 4000 for serving the site
EXPOSE 4000

# Command to serve the Jekyll site
# CMD ["./entrypoint.sh"]
# CMD ["bundle", "exec", "jekyll", "serve", "--livereload", "--watch", "--host", "0.0.0.0"]
# CMD ["bundle", "exec", "jekyll", "serve", "--livereload", "--host", "0.0.0.0", "--drafts"]
CMD ["bundle", "exec", "jekyll", "serve", "--livereload", "--watch", "--host", "0.0.0.0", "--drafts"]