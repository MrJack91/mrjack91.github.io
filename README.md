using https://github.com/jekyll/minima




Windows:
```bash
podman build -t mrjack91 .
podman run --rm -it --name jekyll -v ".:/srv/jekyll" -p 4000:4000 -p 35729:35729 localhost/mrjack91


# or direct in container:
bundle install
bundle exec jekyll serve --livereload --watch --draft --host 0.0.0.0
```